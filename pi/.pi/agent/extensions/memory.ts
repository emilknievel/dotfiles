import type { AgentMessage } from "@mariozechner/pi-agent-core";
import type { ExtensionAPI, ExtensionContext, ExtensionCommandContext } from "@mariozechner/pi-coding-agent";
import {
	MEMORY_CUSTOM_TYPE,
	applicableMemories,
	chooseMemories,
	estimateTokens,
	formatInjectedMemory,
	formatMemoryList,
	forgetByQuery,
	isExpired,
	isMemoryMessage,
	markMemoriesUsed,
	parseCommandText,
	tagsFromText,
} from "./memory-lib.js";
import { addOrUpdateMemoryInStore, findRepoRoot, getStorePath, persistStore, readStore } from "./memory-store.js";

type MemoryKind = "preference" | "project_fact" | "decision" | "task_note";
type MemoryScope = "global" | "repo" | "session";

interface MemoryItem {
	id: string;
	kind: MemoryKind;
	scope: MemoryScope;
	repoKey?: string;
	sessionFile?: string;
	text: string;
	tags: string[];
	source: "user" | "agent" | "extension" | "imported";
	confidence: number;
	createdAt: string;
	updatedAt: string;
	lastUsedAt?: string;
	expiresAt?: string;
	supersedes?: string[];
}

interface MemoryAuditEntry {
	action: string;
	kind?: MemoryKind;
	id?: string;
	text?: string;
	query?: string;
	count?: number;
}

function getBranchMessages(ctx: ExtensionContext): AgentMessage[] {
	const messages: AgentMessage[] = [];
	for (const entry of ctx.sessionManager.getBranch()) {
		if (entry.type === "message") messages.push(entry.message);
		if (entry.type === "custom_message") {
			messages.push({
				role: "custom",
				customType: entry.customType,
				content: entry.content,
				display: entry.display,
				details: entry.details,
				timestamp: Date.parse(entry.timestamp),
			});
		}
	}
	return messages;
}

function sendVisibleMessage(pi: ExtensionAPI, customType: string, content: string): void {
	pi.sendMessage(
		{
			customType,
			content,
			display: true,
		},
		{ triggerTurn: false },
	);
}

export default function memoryExtension(pi: ExtensionAPI) {
	let repoKey = "";
	let storePath = "";
	let store: MemoryItem[] = [];

	const refreshStatus = (ctx: ExtensionContext) => {
		const applicable = applicableMemories(store, repoKey, ctx.sessionManager.getSessionFile());
		ctx.ui.setStatus("memory", `memory:${applicable.length}`);
	};

	const load = (ctx: ExtensionContext) => {
		repoKey = findRepoRoot(ctx.cwd);
		storePath = getStorePath(repoKey);
		store = readStore(storePath) as MemoryItem[];
		refreshStatus(ctx);
	};

	const persist = () => {
		store = persistStore(storePath, store) as MemoryItem[];
	};

	const remember = (
		ctx: ExtensionCommandContext,
		kind: MemoryKind,
		scope: MemoryScope,
		text: string,
		options?: { confidence?: number; expiresAt?: string },
	) => {
		const parsed = addOrUpdateMemoryInStore(store, {
			kind,
			scope,
			repoKey: scope === "repo" ? repoKey : undefined,
			sessionFile: scope === "session" ? ctx.sessionManager.getSessionFile() : undefined,
			text,
			tags: tagsFromText(text),
			source: "user",
			confidence: options?.confidence ?? 1,
			expiresAt: options?.expiresAt,
		});
		store = parsed.items as MemoryItem[];
		persist();
		pi.appendEntry<MemoryAuditEntry>("memory-state", {
			action: parsed.created ? "remember" : "refresh",
			kind,
			id: parsed.memory.id,
			text: parsed.memory.text,
		});
		refreshStatus(ctx);
		ctx.ui.notify(parsed.created ? "Memory saved" : "Memory refreshed", "info");
	};

	pi.on("session_start", async (_event, ctx) => {
		load(ctx);
		ctx.ui.notify(`Memory ready (${store.length} item${store.length === 1 ? "" : "s"})`, "info");
	});

	pi.on("session_tree", async (_event, ctx) => {
		load(ctx);
	});

	pi.on("context", async (event, ctx) => {
		if (!storePath) load(ctx);

		const filteredMessages = event.messages.filter((message) => !isMemoryMessage(message));
		const { chosen } = chooseMemories(store, repoKey, ctx.sessionManager.getSessionFile(), filteredMessages);
		if (chosen.length === 0) {
			return { messages: filteredMessages };
		}

		const marked = markMemoriesUsed(store, chosen);
		store = marked.items as MemoryItem[];
		if (marked.touched) persist();

		const memoryMessage: AgentMessage = {
			role: "custom",
			customType: MEMORY_CUSTOM_TYPE,
			content: formatInjectedMemory(chosen.map(({ item }) => item)),
			display: false,
			timestamp: Date.now(),
		};

		return {
			messages: [memoryMessage, ...filteredMessages],
		};
	});

	pi.registerCommand("remember", {
		description: "Store a repo-scoped project fact. Usage: /remember <fact>",
		handler: async (args, ctx) => {
			const text = parseCommandText(args);
			if (!text) {
				ctx.ui.notify("Usage: /remember <fact>", "warning");
				return;
			}
			remember(ctx, "project_fact", "repo", text);
		},
	});

	pi.registerCommand("remember-pref", {
		description: "Store a global preference. Usage: /remember-pref <preference>",
		handler: async (args, ctx) => {
			const text = parseCommandText(args);
			if (!text) {
				ctx.ui.notify("Usage: /remember-pref <preference>", "warning");
				return;
			}
			remember(ctx, "preference", "global", text);
		},
	});

	pi.registerCommand("remember-decision", {
		description: "Store a repo-scoped decision. Usage: /remember-decision <decision>",
		handler: async (args, ctx) => {
			const text = parseCommandText(args);
			if (!text) {
				ctx.ui.notify("Usage: /remember-decision <decision>", "warning");
				return;
			}
			remember(ctx, "decision", "repo", text);
		},
	});

	pi.registerCommand("remember-task", {
		description: "Store a session-scoped task note for 7 days. Usage: /remember-task <note>",
		handler: async (args, ctx) => {
			const text = parseCommandText(args);
			if (!text) {
				ctx.ui.notify("Usage: /remember-task <note>", "warning");
				return;
			}
			const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();
			remember(ctx, "task_note", "session", text, { confidence: 0.9, expiresAt });
		},
	});

	pi.registerCommand("forget", {
		description: "Forget memories by substring or id. Usage: /forget <query>",
		handler: async (args, ctx) => {
			const query = parseCommandText(args);
			if (!query) {
				ctx.ui.notify("Usage: /forget <query>", "warning");
				return;
			}
			const result = forgetByQuery(store, query, repoKey);
			store = result.items as MemoryItem[];
			persist();
			pi.appendEntry<MemoryAuditEntry>("memory-state", {
				action: "forget",
				query,
				count: result.removed.length,
			});
			refreshStatus(ctx);
			if (result.removed.length === 0) {
				ctx.ui.notify("No matching memories", "info");
				return;
			}
			sendVisibleMessage(
				pi,
				"memory-forget",
				`Forgot ${result.removed.length} memor${result.removed.length === 1 ? "y" : "ies"}:\n${result.removed
					.map((item) => `- [${item.kind}] ${item.text}`)
					.join("\n")}`,
			);
		},
	});

	pi.registerCommand("memories", {
		description: "Show stored memories relevant to the current repo/session",
		handler: async (_args, ctx) => {
			const items = applicableMemories(store, repoKey, ctx.sessionManager.getSessionFile());
			sendVisibleMessage(pi, "memory-list", formatMemoryList(items));
			ctx.ui.notify(`Listed ${items.length} memory item${items.length === 1 ? "" : "s"}`, "info");
		},
	});

	pi.registerCommand("memory-debug", {
		description: "Show what memory would be injected on the next turn",
		handler: async (_args, ctx) => {
			const branchMessages = getBranchMessages(ctx);
			const { queryText, chosen } = chooseMemories(store, repoKey, ctx.sessionManager.getSessionFile(), branchMessages);
			const body =
				chosen.length === 0
					? "No memory would be injected right now."
					: formatInjectedMemory(chosen.map(({ item }) => item));
			sendVisibleMessage(
				pi,
				"memory-debug",
				[`Query text: ${queryText || "(empty)"}`, "", body, "", `Estimated tokens: ${estimateTokens(body)}`].join("\n"),
			);
		},
	});

	pi.registerCommand("memory-prune", {
		description: "Remove expired task notes and duplicate entries",
		handler: async (_args, ctx) => {
			const before = store.length;
			store = store.filter((item) => !isExpired(item));
			persist();
			pi.appendEntry<MemoryAuditEntry>("memory-state", {
				action: "prune",
				count: before - store.length,
			});
			refreshStatus(ctx);
			ctx.ui.notify(`Pruned ${before - store.length} memory item${before - store.length === 1 ? "" : "s"}`, "info");
		},
	});
}
