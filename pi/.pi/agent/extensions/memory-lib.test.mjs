import test from "node:test";
import assert from "node:assert/strict";

import {
	MEMORY_CUSTOM_TYPE,
	addOrUpdateMemory,
	applicableMemories,
	chooseMemories,
	dedupeItems,
	forgetByQuery,
	formatInjectedMemory,
	isExpired,
	markMemoriesUsed,
} from "./memory-lib.js";

function makeMemory(overrides = {}) {
	return {
		id: overrides.id ?? "m1",
		kind: overrides.kind ?? "project_fact",
		scope: overrides.scope ?? "repo",
		repoKey: overrides.repoKey ?? "/repo",
		sessionFile: overrides.sessionFile,
		text: overrides.text ?? "Use pnpm for package commands",
		tags: overrides.tags ?? ["pnpm", "package"],
		source: overrides.source ?? "user",
		confidence: overrides.confidence ?? 1,
		createdAt: overrides.createdAt ?? "2026-04-15T00:00:00.000Z",
		updatedAt: overrides.updatedAt ?? "2026-04-15T00:00:00.000Z",
		lastUsedAt: overrides.lastUsedAt,
		expiresAt: overrides.expiresAt,
		supersedes: overrides.supersedes,
	};
}

function userMessage(text) {
	return { role: "user", content: text, timestamp: Date.now() };
}

test("applicableMemories filters by repo/session/confidence/expiry", () => {
	const items = [
		makeMemory({ id: "global-pref", kind: "preference", scope: "global", repoKey: undefined, text: "Prefer minimal diffs" }),
		makeMemory({ id: "repo-hit", kind: "decision", text: "Use zod for schema validation", tags: ["zod", "schema"] }),
		makeMemory({ id: "repo-miss", repoKey: "/other" }),
		makeMemory({ id: "session-hit", scope: "session", sessionFile: "/tmp/session-a.jsonl", repoKey: undefined }),
		makeMemory({ id: "session-miss", scope: "session", sessionFile: "/tmp/session-b.jsonl", repoKey: undefined }),
		makeMemory({ id: "low-confidence", confidence: 0.2 }),
		makeMemory({ id: "expired", expiresAt: "2000-01-01T00:00:00.000Z" }),
	];

	const result = applicableMemories(items, "/repo", "/tmp/session-a.jsonl");
	assert.deepEqual(
		result.map((item) => item.id),
		["global-pref", "repo-hit", "session-hit"],
	);
	assert.equal(isExpired(items[6]), true);
});

test("chooseMemories prefers relevant repo decision over generic preference", () => {
	const items = [
		makeMemory({ id: "pref", kind: "preference", scope: "global", repoKey: undefined, text: "Prefer minimal diffs", tags: ["minimal", "diffs"] }),
		makeMemory({ id: "decision", kind: "decision", text: "Use zod for schema validation", tags: ["zod", "schema", "validation"] }),
	];

	const result = chooseMemories(items, "/repo", undefined, [userMessage("Please update the zod schema parser")]);
	assert.equal(result.chosen[0]?.item.id, "decision");
	assert.match(formatInjectedMemory(result.chosen.map(({ item }) => item)), /Decision: Use zod/);
});

test("chooseMemories falls back to preferences when nothing matches", () => {
	const items = [
		makeMemory({ id: "pref-1", kind: "preference", scope: "global", repoKey: undefined, text: "Prefer minimal diffs", tags: ["minimal"] }),
		makeMemory({ id: "pref-2", kind: "preference", scope: "global", repoKey: undefined, text: "Ask before destructive commands", tags: ["ask", "destructive"] }),
	];

	const result = chooseMemories(items, "/repo", undefined, [userMessage("hello there")]);
	assert.deepEqual(result.chosen.map(({ item }) => item.id), ["pref-1", "pref-2"]);
});

test("chooseMemories ignores existing hidden memory messages in context", () => {
	const items = [makeMemory({ id: "decision", kind: "decision", text: "Use zod for schema validation", tags: ["zod"] })];
	const result = chooseMemories(items, "/repo", undefined, [
		{ role: "custom", customType: MEMORY_CUSTOM_TYPE, content: "Old memory", display: false, timestamp: Date.now() },
		userMessage("Update the zod validators"),
	]);
	assert.equal(result.chosen[0]?.item.id, "decision");
});

test("addOrUpdateMemory merges duplicates and extends tags", () => {
	const existing = [makeMemory({ id: "same", text: "Use pnpm", tags: ["pnpm"], confidence: 0.6 })];
	const result = addOrUpdateMemory(
		existing,
		{
			kind: "project_fact",
			scope: "repo",
			repoKey: "/repo",
			sessionFile: undefined,
			text: " Use   pnpm ",
			tags: ["package-manager"],
			source: "user",
			confidence: 1,
			expiresAt: undefined,
			supersedes: undefined,
		},
		() => "new-id",
	);

	assert.equal(result.created, false);
	assert.equal(result.memory.id, "same");
	assert.equal(result.memory.confidence, 1);
	assert.deepEqual(result.memory.tags.sort(), ["package-manager", "pnpm"]);
});

test("forgetByQuery removes matching global and current-repo memories only", () => {
	const items = [
		makeMemory({ id: "global", kind: "preference", scope: "global", repoKey: undefined, text: "Prefer minimal diffs" }),
		makeMemory({ id: "repo-hit", text: "Use pnpm" }),
		makeMemory({ id: "repo-miss", repoKey: "/other", text: "Use pnpm" }),
	];

	const result = forgetByQuery(items, "pnpm", "/repo");
	assert.deepEqual(result.removed.map((item) => item.id), ["repo-hit"]);
	assert.deepEqual(result.items.map((item) => item.id), ["global", "repo-miss"]);
});

test("dedupeItems keeps the newest duplicate", () => {
	const older = makeMemory({ id: "older", text: "Use pnpm", updatedAt: "2026-04-15T00:00:00.000Z" });
	const newer = makeMemory({ id: "newer", text: "Use pnpm", updatedAt: "2026-04-16T00:00:00.000Z" });
	const deduped = dedupeItems([older, newer]);
	assert.equal(deduped.length, 1);
	assert.equal(deduped[0].id, "newer");
});

test("markMemoriesUsed stamps selected items only", () => {
	const items = [makeMemory({ id: "a" }), makeMemory({ id: "b", text: "Use zod", tags: ["zod"] })];
	const chosen = [{ item: items[1], score: 0.9 }];
	const result = markMemoriesUsed(items, chosen, "2026-04-20T12:00:00.000Z");
	assert.equal(result.touched, true);
	assert.equal(result.items[0].lastUsedAt, undefined);
	assert.equal(result.items[1].lastUsedAt, "2026-04-20T12:00:00.000Z");
});
