import assert from "node:assert/strict";
import test from "node:test";

import {
  addOrUpdateMemory,
  applicableMemories,
  chooseMemories,
  dedupeItems,
  findMatchingMemories,
  forgetByQuery,
  formatInjectedMemory,
  getEffectiveConfidence,
  isExpired,
  MEMORY_CUSTOM_TYPE,
  markMemoriesUsed,
  parseReplaceCommand,
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
    makeMemory({
      id: "global-pref",
      kind: "preference",
      scope: "global",
      repoKey: undefined,
      text: "Prefer minimal diffs",
    }),
    makeMemory({
      id: "repo-hit",
      kind: "decision",
      text: "Use zod for schema validation",
      tags: ["zod", "schema"],
    }),
    makeMemory({ id: "repo-miss", repoKey: "/other" }),
    makeMemory({
      id: "session-hit",
      scope: "session",
      sessionFile: "/tmp/session-a.jsonl",
      repoKey: undefined,
    }),
    makeMemory({
      id: "session-miss",
      scope: "session",
      sessionFile: "/tmp/session-b.jsonl",
      repoKey: undefined,
    }),
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

test("applicableMemories excludes superseded memories", () => {
  const active = makeMemory({
    id: "new",
    text: "This repo uses bun",
    supersedes: ["old"],
  });
  const old = makeMemory({ id: "old", text: "This repo uses pnpm" });
  const result = applicableMemories([old, active], "/repo", undefined);
  assert.deepEqual(
    result.map((item) => item.id),
    ["new"],
  );
});

test("getEffectiveConfidence decays stale extension memories", () => {
  const stale = makeMemory({
    id: "stale",
    source: "extension",
    confidence: 0.5,
    updatedAt: "2026-01-01T00:00:00.000Z",
  });
  const fresh = makeMemory({
    id: "fresh",
    source: "extension",
    confidence: 0.5,
    updatedAt: "2026-04-10T00:00:00.000Z",
  });
  assert.ok(
    getEffectiveConfidence(stale, Date.parse("2026-04-20T00:00:00.000Z")) <
      0.35,
  );
  assert.equal(
    getEffectiveConfidence(fresh, Date.parse("2026-04-20T00:00:00.000Z")),
    0.5,
  );
});

test("chooseMemories prefers relevant repo decision over generic preference", () => {
  const items = [
    makeMemory({
      id: "pref",
      kind: "preference",
      scope: "global",
      repoKey: undefined,
      text: "Prefer minimal diffs",
      tags: ["minimal", "diffs"],
    }),
    makeMemory({
      id: "decision",
      kind: "decision",
      text: "Use zod for schema validation",
      tags: ["zod", "schema", "validation"],
    }),
  ];

  const result = chooseMemories(items, "/repo", undefined, [
    userMessage("Please update the zod schema parser"),
  ]);
  assert.equal(result.chosen[0]?.item.id, "decision");
  assert.match(
    formatInjectedMemory(result.chosen.map(({ item }) => item)),
    /Decision: Use zod/,
  );
});

test("chooseMemories falls back to preferences when nothing matches", () => {
  const items = [
    makeMemory({
      id: "pref-1",
      kind: "preference",
      scope: "global",
      repoKey: undefined,
      text: "Prefer minimal diffs",
      tags: ["minimal"],
    }),
    makeMemory({
      id: "pref-2",
      kind: "preference",
      scope: "global",
      repoKey: undefined,
      text: "Ask before destructive commands",
      tags: ["ask", "destructive"],
    }),
  ];

  const result = chooseMemories(items, "/repo", undefined, [
    userMessage("hello there"),
  ]);
  assert.deepEqual(
    result.chosen.map(({ item }) => item.id),
    ["pref-1", "pref-2"],
  );
});

test("chooseMemories ignores existing hidden memory messages in context", () => {
  const items = [
    makeMemory({
      id: "decision",
      kind: "decision",
      text: "Use zod for schema validation",
      tags: ["zod"],
    }),
  ];
  const result = chooseMemories(items, "/repo", undefined, [
    {
      role: "custom",
      customType: MEMORY_CUSTOM_TYPE,
      content: "Old memory",
      display: false,
      timestamp: Date.now(),
    },
    userMessage("Update the zod validators"),
  ]);
  assert.equal(result.chosen[0]?.item.id, "decision");
});

test("chooseMemories skips superseded memories in debug reasons", () => {
  const items = [
    makeMemory({ id: "old", text: "This repo uses pnpm" }),
    makeMemory({ id: "new", text: "This repo uses bun", supersedes: ["old"] }),
  ];
  const result = chooseMemories(items, "/repo", undefined, [
    userMessage("which package manager?"),
  ]);
  assert.equal(
    result.skipped.some(
      ({ item, skippedReason }) =>
        item.id === "old" && /superseded/.test(skippedReason),
    ),
    true,
  );
  assert.equal(
    result.chosen.some(({ item }) => item.id === "new"),
    true,
  );
});

test("chooseMemories caps selected items by kind and records skipped reasons", () => {
  const items = [
    makeMemory({
      id: "decision-1",
      kind: "decision",
      text: "Use zod for schema validation",
      tags: ["zod", "schema"],
    }),
    makeMemory({
      id: "decision-2",
      kind: "decision",
      text: "Keep zod schemas in src/schema",
      tags: ["zod", "schema", "src/schema"],
    }),
    makeMemory({
      id: "decision-3",
      kind: "decision",
      text: "Prefer zod-safe parsing helpers",
      tags: ["zod", "safe", "parsing"],
    }),
    makeMemory({
      id: "pref",
      kind: "preference",
      scope: "global",
      repoKey: undefined,
      text: "Prefer minimal diffs",
      tags: ["minimal", "diffs"],
    }),
  ];
  const result = chooseMemories(items, "/repo", undefined, [
    userMessage("Please update the zod schema"),
  ]);
  assert.deepEqual(
    result.chosen.filter(({ item }) => item.kind === "decision").length,
    2,
  );
  assert.equal(
    result.skipped.some(
      ({ item, skippedReason }) =>
        item.id === "decision-3" && /kind limit/.test(skippedReason),
    ),
    true,
  );
  assert.equal(
    result.skipped.some(
      ({ item, skippedReason }) =>
        item.id === "pref" &&
        /(weaker than repo-specific hit|below score threshold)/.test(
          skippedReason,
        ),
    ),
    true,
  );
});

test("addOrUpdateMemory merges duplicates and extends tags", () => {
  const existing = [
    makeMemory({
      id: "same",
      text: "Use pnpm",
      tags: ["pnpm"],
      confidence: 0.6,
    }),
  ];
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

test("parseReplaceCommand parses query and replacement text", () => {
  assert.deepEqual(parseReplaceCommand("pnpm => This repo uses bun"), {
    query: "pnpm",
    replacement: "This repo uses bun",
  });
  assert.equal(parseReplaceCommand("invalid"), undefined);
});

test("findMatchingMemories ignores superseded entries and respects scope", () => {
  const items = [
    makeMemory({ id: "old", text: "This repo uses pnpm" }),
    makeMemory({ id: "new", text: "This repo uses bun", supersedes: ["old"] }),
    makeMemory({
      id: "global",
      kind: "preference",
      scope: "global",
      repoKey: undefined,
      text: "Prefer concise answers",
    }),
  ];
  const result = findMatchingMemories(items, "repo uses", "/repo", undefined);
  assert.deepEqual(
    result.map((item) => item.id),
    ["new"],
  );
});

test("forgetByQuery removes matching global and current-repo memories only", () => {
  const items = [
    makeMemory({
      id: "global",
      kind: "preference",
      scope: "global",
      repoKey: undefined,
      text: "Prefer minimal diffs",
    }),
    makeMemory({ id: "repo-hit", text: "Use pnpm" }),
    makeMemory({ id: "repo-miss", repoKey: "/other", text: "Use pnpm" }),
  ];

  const result = forgetByQuery(items, "pnpm", "/repo");
  assert.deepEqual(
    result.removed.map((item) => item.id),
    ["repo-hit"],
  );
  assert.deepEqual(
    result.items.map((item) => item.id),
    ["global", "repo-miss"],
  );
});

test("dedupeItems keeps the newest duplicate", () => {
  const older = makeMemory({
    id: "older",
    text: "Use pnpm",
    updatedAt: "2026-04-15T00:00:00.000Z",
  });
  const newer = makeMemory({
    id: "newer",
    text: "Use pnpm",
    updatedAt: "2026-04-16T00:00:00.000Z",
  });
  const deduped = dedupeItems([older, newer]);
  assert.equal(deduped.length, 1);
  assert.equal(deduped[0].id, "newer");
});

test("markMemoriesUsed stamps selected items only", () => {
  const items = [
    makeMemory({ id: "a" }),
    makeMemory({ id: "b", text: "Use zod", tags: ["zod"] }),
  ];
  const chosen = [{ item: items[1], score: 0.9 }];
  const result = markMemoriesUsed(items, chosen, "2026-04-20T12:00:00.000Z");
  assert.equal(result.touched, true);
  assert.equal(result.items[0].lastUsedAt, undefined);
  assert.equal(result.items[1].lastUsedAt, "2026-04-20T12:00:00.000Z");
});
