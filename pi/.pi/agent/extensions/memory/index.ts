import type { AgentMessage } from "@mariozechner/pi-agent-core";
import type { ExtensionAPI, ExtensionContext, ExtensionCommandContext, Theme } from "@mariozechner/pi-coding-agent";
import {
	MEMORY_CUSTOM_TYPE,
	applicableMemories,
	chooseMemories,
	estimateTokens,
	formatInjectedMemory,
	formatMemoryList,
	findMatchingMemories,
	forgetByQuery,
	isExpired,
	isMemoryMessage,
	markMemoriesUsed,
	parseCommandText,
	parseReplaceCommand,
	tagsFromText,
} from "./memory-lib.js";
import { addOrUpdateMemoryInStore, findRepoRoot, getStorePath, persistStore, readStore } from "./memory-store.js";
import { extractMemoryCandidatesFromMessages } from "./memory-extract.js";
import { extractObservedCandidates, mergeObservedCandidates } from "./memory-observe.js";

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
	toolName?: string;
}

function matchesKey(data: string, key: string): boolean {
	switch (key) {
		case "escape":
			return data === "\x1b";
		case "enter":
			return data === "\r" || data === "\n";
		case "ctrl+c":
			return data === "\u0003";
		default:
			return data === key;
	}
}

function truncateToWidth(text: string, width: number): string {
	return text.length <= width ? text : `${text.slice(0, Math.max(0, width - 1))}…`;
}

class MemoryListComponent {
	private items: MemoryItem[];
	private theme: Theme;
	private onClose: () => void;
	private cachedWidth?: number;
	private cachedLines?: string[];

	constructor(items: MemoryItem[], theme: Theme, onClose: () => void) {
		this.items = items;
		this.theme = theme;
		this.onClose = onClose;
	}

	handleInput(data: string): void {
		if (matchesKey(data, "escape") || matchesKey(data, "ctrl+c") || matchesKey(data, "enter")) {
			this.onClose();
		}
	}

	render(width: number): string[] {
		if (this.cachedLines && this.cachedWidth === width) return this.cachedLines;
		const th = this.theme;
		const lines: string[] = [];
		lines.push("");
		const title = th.fg("accent", " Memories ");
		const header = th.fg("borderMuted", "─".repeat(3)) + title + th.fg("borderMuted", "─".repeat(Math.max(0, width - 13)));
		lines.push(truncateToWidth(header, width));
		lines.push("");
		if (this.items.length === 0) {
			lines.push(truncateToWidth(`  ${th.fg("dim", "No stored memories.")}`, width));
		} else {
			const counts = {
				preference: this.items.filter((item) => item.kind === "preference").length,
				decision: this.items.filter((item) => item.kind === "decision").length,
				project_fact: this.items.filter((item) => item.kind === "project_fact").length,
				task_note: this.items.filter((item) => item.kind === "task_note").length,
			};
			lines.push(
				truncateToWidth(
					`  ${th.fg("muted", `${this.items.length} total · pref ${counts.preference} · decisions ${counts.decision} · facts ${counts.project_fact} · tasks ${counts.task_note}`)}`,
					width,
				),
			);
			lines.push("");
			for (const item of this.items) {
				const kindColor = item.kind === "preference" ? "accent" : item.kind === "decision" ? "success" : item.kind === "task_note" ? "warning" : "text";
				const scope = th.fg("dim", `[${item.scope}]`);
				const kind = th.fg(kindColor, item.kind.replace("_", " "));
				lines.push(truncateToWidth(`  ${scope} ${kind} ${th.fg("text", item.text)}`, width));
				lines.push(
					truncateToWidth(
						`      ${th.fg("dim", `confidence=${item.confidence.toFixed(2)} · id=${item.id.slice(0, 8)}`)}`,
						width,
					),
				);
			}
		}
		lines.push("");
		lines.push(truncateToWidth(`  ${th.fg("dim", "Press Enter or Escape to close")}`, width));
		lines.push("");
		this.cachedWidth = width;
		this.cachedLines = lines;
		return lines;
	}

	invalidate(): void {
		this.cachedWidth = undefined;
		this.cachedLines = undefined;
	}
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
	let observationCounts = new Map<string, number>();

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

	const learnObservedCandidates = (ctx: ExtensionContext, toolName: string, input: unknown) => {
		const observed = extractObservedCandidates(toolName, input);
		if (observed.length === 0) return;

		const merged = mergeObservedCandidates(observationCounts, observed);
		observationCounts = merged.counts;
		let learned = 0;
		for (const candidate of merged.accepted) {
			const result = addOrUpdateMemoryInStore(store, {
				kind: candidate.kind,
				scope: candidate.scope,
				repoKey: candidate.scope === "repo" ? repoKey : undefined,
				sessionFile: undefined,
				text: candidate.text,
				tags: candidate.tags,
				source: "extension",
				confidence: candidate.confidence,
				expiresAt: undefined,
			});
			const beforeSize = store.length;
			store = result.items as MemoryItem[];
			if (result.created || store.length !== beforeSize) learned++;
		}
		if (learned === 0) return;
		persist();
		pi.appendEntry<MemoryAuditEntry>("memory-state", {
			action: "tool-observe",
			count: learned,
			toolName,
		});
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
		options?: { confidence?: number; expiresAt?: string; supersedes?: string[] },
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
			supersedes: options?.supersedes,
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

	pi.on("tool_call", async (event, ctx) => {
		if (!storePath) load(ctx);
		learnObservedCandidates(ctx, event.toolName, event.input);
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

	pi.on("session_before_compact", async (event, ctx) => {
		if (!storePath) load(ctx);

		const messagesToScan = [...event.preparation.messagesToSummarize, ...event.preparation.turnPrefixMessages].filter(
			(message) => !isMemoryMessage(message),
		);
		const candidates = extractMemoryCandidatesFromMessages(messagesToScan);
		if (candidates.length === 0) return;

		let added = 0;
		for (const candidate of candidates) {
			const result = addOrUpdateMemoryInStore(store, {
				kind: candidate.kind,
				scope: candidate.scope,
				repoKey: candidate.scope === "repo" ? repoKey : undefined,
				sessionFile: undefined,
				text: candidate.text,
				tags: candidate.tags,
				source: "extension",
				confidence: candidate.confidence,
				expiresAt: undefined,
			});
			store = result.items as MemoryItem[];
			if (result.created) added++;
		}
		if (added === 0) return;
		persist();
		pi.appendEntry<MemoryAuditEntry>("memory-state", {
			action: "compact-extract",
			count: added,
		});
		refreshStatus(ctx);
		ctx.ui.notify(`Memory: extracted ${added} candidate${added === 1 ? "" : "s"} during compaction`, "info");
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

	pi.registerCommand("replace-memory", {
		description: "Replace matching memories. Usage: /replace-memory <query> => <new text>",
		handler: async (args, ctx) => {
			const parsed = parseReplaceCommand(args);
			if (!parsed) {
				ctx.ui.notify("Usage: /replace-memory <query> => <new text>", "warning");
				return;
			}
			const matches = findMatchingMemories(store, parsed.query, repoKey, ctx.sessionManager.getSessionFile());
			if (matches.length === 0) {
				ctx.ui.notify("No matching active memories", "info");
				return;
			}
			const kinds = [...new Set(matches.map((item) => item.kind))];
			const scopes = [...new Set(matches.map((item) => item.scope))];
			const kind = (kinds.length === 1 ? kinds[0] : "project_fact") as MemoryKind;
			const scope = (scopes.length === 1 ? scopes[0] : "repo") as MemoryScope;
			remember(ctx, kind, scope, parsed.replacement, { supersedes: matches.map((item) => item.id) });
			pi.appendEntry<MemoryAuditEntry>("memory-state", {
				action: "replace",
				query: parsed.query,
				count: matches.length,
				text: parsed.replacement,
			});
			sendVisibleMessage(
				pi,
				"memory-replace",
				[
					`Replaced ${matches.length} memor${matches.length === 1 ? "y" : "ies"}:`,
					...matches.map((item) => `- [${item.kind}] ${item.text}`),
					"",
					`New active memory:`,
					`- [${kind}] ${parsed.replacement}`,
				].join("\n"),
			);
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
			if (ctx.hasUI && typeof ctx.ui.custom === "function") {
				await ctx.ui.custom<void>((_tui, theme, _kb, done) => new MemoryListComponent(items, theme, () => done()));
				return;
			}
			sendVisibleMessage(pi, "memory-list", formatMemoryList(items));
			ctx.ui.notify(`Listed ${items.length} memory item${items.length === 1 ? "" : "s"}`, "info");
		},
	});

	pi.registerCommand("memory-debug", {
		description: "Show what memory would be injected on the next turn",
		handler: async (_args, ctx) => {
			const branchMessages = getBranchMessages(ctx);
			const { queryText, chosen, skipped, tokenBudget, kindCounts } = chooseMemories(
				store,
				repoKey,
				ctx.sessionManager.getSessionFile(),
				branchMessages,
			);
			const selectedSection =
				chosen.length === 0
					? "No memory would be injected right now."
					: [
						"Selected:",
						...chosen.map(
							({ item, score, reasons }) =>
								`- [${item.kind}] ${item.text}\n  score=${score.toFixed(3)} exact=${reasons.exactMatches.join(",") || "-"} overlap=${reasons.overlap.toFixed(2)}`,
						),
					].join("\n");
			const skippedSection =
				skipped.length === 0
					? "Skipped: none"
					: [
						"Skipped:",
						...skipped.slice(0, 8).map(
							({ item, score, skippedReason }) =>
								`- [${item.kind}] ${item.text}\n  score=${score.toFixed(3)} reason=${skippedReason}`,
						),
					].join("\n");
			const injected = chosen.length === 0 ? "" : formatInjectedMemory(chosen.map(({ item }) => item));
			sendVisibleMessage(
				pi,
				"memory-debug",
				[
					`Query text: ${queryText || "(empty)"}`,
					`Token budget used: ${tokenBudget}`,
					`Kind counts: pref=${kindCounts.preference}, decision=${kindCounts.decision}, fact=${kindCounts.project_fact}, task=${kindCounts.task_note}`,
					"",
					selectedSection,
					"",
					skippedSection,
					...(injected ? ["", "Injected block:", injected, "", `Estimated tokens: ${estimateTokens(injected)}`] : []),
				].join("\n"),
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
