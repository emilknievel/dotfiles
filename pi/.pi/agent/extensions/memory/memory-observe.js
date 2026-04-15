import { normalizeText, tagsFromText } from "./memory-lib.js";

function compact(text) {
	return normalizeText(text).replace(/[.]+$/, "");
}

function fromBashInput(input) {
	const command = compact(String(input?.command ?? ""));
	if (!command) return [];

	const candidates = [];
	if (/\bpnpm\b/.test(command)) {
		candidates.push({
			kind: "project_fact",
			scope: "repo",
			text: "This repo uses pnpm",
			confidence: 0.45,
			tags: ["pnpm", ...tagsFromText(command)].slice(0, 12),
			observationKey: "bash:pnpm",
		});
	}
	if (/\bzod\b/.test(command)) {
		candidates.push({
			kind: "decision",
			scope: "repo",
			text: "Zod is part of the active workflow in this repo",
			confidence: 0.4,
			tags: ["zod", ...tagsFromText(command)].slice(0, 12),
			observationKey: "bash:zod",
		});
	}
	return candidates;
}

function fromReadInput(input) {
	const target = compact(String(input?.path ?? ""));
	if (!target) return [];

	const candidates = [];
	if (/(^|\/)package\.json$/.test(target)) {
		candidates.push({
			kind: "project_fact",
			scope: "repo",
			text: "package.json is a relevant project entry point",
			confidence: 0.28,
			tags: ["package.json", ...tagsFromText(target)].slice(0, 12),
			observationKey: "read:package.json",
		});
	}
	if (/src\/schema|schema\//.test(target)) {
		candidates.push({
			kind: "decision",
			scope: "repo",
			text: "Schema files are an active area in this repo",
			confidence: 0.3,
			tags: ["schema", ...tagsFromText(target)].slice(0, 12),
			observationKey: "read:schema",
		});
	}
	return candidates;
}

export function extractObservedCandidates(toolName, input) {
	switch (toolName) {
		case "bash":
			return fromBashInput(input);
		case "read":
			return fromReadInput(input);
		default:
			return [];
	}
}

export function mergeObservedCandidates(existing, observed, minCount = 2) {
	const counts = new Map(existing);
	for (const candidate of observed) {
		counts.set(candidate.observationKey, (counts.get(candidate.observationKey) ?? 0) + 1);
	}

	const accepted = observed.filter((candidate) => (counts.get(candidate.observationKey) ?? 0) >= minCount);
	return { counts, accepted };
}
