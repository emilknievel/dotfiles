import test from "node:test";
import assert from "node:assert/strict";
import { extractObservedCandidates, mergeObservedCandidates } from "./memory-observe.js";

test("extractObservedCandidates learns conservative bash facts", () => {
	const result = extractObservedCandidates("bash", { command: "pnpm test && pnpm lint" });
	assert.equal(result.some((item) => item.text === "This repo uses pnpm"), true);
	assert.equal(result.every((item) => item.confidence < 0.5), true);
});

test("mergeObservedCandidates only accepts repeated observations", () => {
	const observed = extractObservedCandidates("bash", { command: "pnpm install" });
	let merged = mergeObservedCandidates(new Map(), observed);
	assert.equal(merged.accepted.length, 0);
	merged = mergeObservedCandidates(merged.counts, observed);
	assert.equal(merged.accepted.some((item) => item.text === "This repo uses pnpm"), true);
});
