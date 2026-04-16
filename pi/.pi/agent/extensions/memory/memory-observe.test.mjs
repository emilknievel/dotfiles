import test from "node:test";
import assert from "node:assert/strict";
import { extractObservedCandidates, mergeObservedCandidates } from "./memory-observe.js";

test("extractObservedCandidates learns conservative bash facts from safe commands", () => {
  const result = extractObservedCandidates("bash", { command: "pnpm test" });
  assert.equal(result.some((item) => item.text === "This repo uses pnpm"), true);
  assert.equal(result.every((item) => item.confidence < 0.5), true);
});

test("extractObservedCandidates ignores install and compound commands", () => {
  assert.deepEqual(extractObservedCandidates("bash", { command: "pnpm install" }), []);
  assert.deepEqual(extractObservedCandidates("bash", { command: "pnpm test && echo done" }), []);
});

test("mergeObservedCandidates respects candidate-specific thresholds", () => {
  const pnpmObserved = extractObservedCandidates("bash", { command: "pnpm test" });
  let merged = mergeObservedCandidates(new Map(), pnpmObserved);
  assert.equal(merged.accepted.length, 0);
  merged = mergeObservedCandidates(merged.counts, pnpmObserved);
  assert.equal(merged.accepted.some((item) => item.text === "This repo uses pnpm"), true);

  const zodObserved = extractObservedCandidates("bash", { command: "pnpm test zod" });
  let zodMerged = mergeObservedCandidates(new Map(), zodObserved);
  assert.equal(zodMerged.accepted.some((item) => item.observationKey === "bash:zod"), false);
  zodMerged = mergeObservedCandidates(zodMerged.counts, zodObserved);
  assert.equal(zodMerged.accepted.some((item) => item.observationKey === "bash:zod"), false);
  zodMerged = mergeObservedCandidates(zodMerged.counts, zodObserved);
  assert.equal(zodMerged.accepted.some((item) => item.observationKey === "bash:zod"), true);
});
