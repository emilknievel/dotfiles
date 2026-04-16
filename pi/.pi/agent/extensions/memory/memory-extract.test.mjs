import test from "node:test";
import assert from "node:assert/strict";
import { extractMemoryCandidatesFromMessages } from "./memory-extract.js";

test("extractMemoryCandidatesFromMessages finds preference, project fact, and decision candidates", () => {
  const messages = [
    { role: "user", content: "Prefer minimal diffs. Ask before destructive commands.", timestamp: Date.now() },
    { role: "assistant", content: "This repo uses pnpm. Keep schemas in src/schema.", timestamp: Date.now() },
    { role: "assistant", content: "Use zod for schema validation.", timestamp: Date.now() },
  ];

  const result = extractMemoryCandidatesFromMessages(messages);
  assert.equal(result.some((item) => item.kind === "preference" && /Prefer minimal diffs/i.test(item.text)), true);
  assert.equal(result.some((item) => item.kind === "project_fact" && /This repo uses pnpm/i.test(item.text)), true);
  assert.equal(result.some((item) => item.kind === "decision" && /Keep schemas in src\/schema/i.test(item.text)), true);
});

test("extractMemoryCandidatesFromMessages deduplicates and ignores memory-context custom messages", () => {
  const messages = [
    { role: "custom", customType: "memory-context", content: "Old memory block", display: false, timestamp: Date.now() },
    { role: "user", content: "Prefer minimal diffs. Prefer minimal diffs.", timestamp: Date.now() },
  ];
  const result = extractMemoryCandidatesFromMessages(messages);
  assert.equal(result.length, 1);
  assert.match(result[0].text, /Prefer minimal diffs/i);
});
