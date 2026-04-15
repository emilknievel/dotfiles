export const MEMORY_CUSTOM_TYPE = "memory-context";
export const MIN_CONFIDENCE = 0.35;
export const MAX_INJECTED_ITEMS = 5;
export const SOFT_TOKEN_BUDGET = 180;

export function nowIso() {
	return new Date().toISOString();
}

export function clamp(value, min, max) {
	return Math.min(max, Math.max(min, value));
}

export function estimateTokens(text) {
	return Math.ceil(text.length / 4);
}

export function normalizeText(text) {
	return text.replace(/\s+/g, " ").trim();
}

export function tokenize(text) {
	const matches = text.toLowerCase().match(/[a-z0-9_./-]{3,}/g) ?? [];
	return [...new Set(matches)];
}

export function tagsFromText(text) {
	return tokenize(text).slice(0, 12);
}

export function parseCommandText(args) {
	const text = normalizeText(args ?? "");
	return text.length > 0 ? text : undefined;
}

export function isExpired(item) {
	return !!item.expiresAt && Date.parse(item.expiresAt) <= Date.now();
}

export function isMemoryMessage(message) {
	return message.role === "custom" && message.customType === MEMORY_CUSTOM_TYPE;
}

export function getMessageText(message) {
	if (message.role === "custom") {
		if (typeof message.content === "string") return message.content;
		if (Array.isArray(message.content)) {
			return message.content
				.filter((part) => part.type === "text" && typeof part.text === "string")
				.map((part) => part.text)
				.join("\n");
		}
		return "";
	}

	const content = message.content;
	if (typeof content === "string") return content;
	if (!Array.isArray(content)) return "";

	return content
		.filter((part) => !!part && typeof part === "object" && part.type === "text" && typeof part.text === "string")
		.map((part) => part.text)
		.join("\n");
}

export function getLatestRelevantText(messages) {
	for (let i = messages.length - 1; i >= 0; i--) {
		const message = messages[i];
		if (isMemoryMessage(message)) continue;
		if (message.role === "user") {
			const text = normalizeText(getMessageText(message));
			if (text) return text;
		}
	}

	for (let i = messages.length - 1; i >= 0; i--) {
		const message = messages[i];
		if (isMemoryMessage(message)) continue;
		if (message.role === "assistant" || message.role === "custom") {
			const text = normalizeText(getMessageText(message));
			if (text) return text;
		}
	}

	return "";
}

export function dedupeItems(items) {
	const byKey = new Map();
	for (const item of items) {
		const key = `${item.scope}:${item.repoKey ?? ""}:${item.kind}:${item.text.toLowerCase()}`;
		const existing = byKey.get(key);
		if (!existing || item.updatedAt > existing.updatedAt) {
			byKey.set(key, item);
		}
	}
	return [...byKey.values()];
}

export function sortMemories(items) {
	return [...items].sort((a, b) => {
		const aUsed = a.lastUsedAt ?? a.updatedAt;
		const bUsed = b.lastUsedAt ?? b.updatedAt;
		if (aUsed !== bUsed) return bUsed.localeCompare(aUsed);
		if (a.confidence !== b.confidence) return b.confidence - a.confidence;
		return a.text.localeCompare(b.text);
	});
}

export function applicableMemories(items, repoKey, sessionFile) {
	return items.filter((item) => {
		if (isExpired(item)) return false;
		if (item.confidence < MIN_CONFIDENCE) return false;
		if (item.scope === "global") return true;
		if (item.scope === "repo") return item.repoKey === repoKey;
		if (item.scope === "session") return item.sessionFile === sessionFile;
		return false;
	});
}

export function overlapScore(a, b) {
	if (a.length === 0 || b.length === 0) return 0;
	const bSet = new Set(b);
	let hits = 0;
	for (const token of a) {
		if (bSet.has(token)) hits++;
	}
	return hits / Math.max(a.length, 1);
}

export function kindBonus(kind) {
	switch (kind) {
		case "preference":
			return 0.16;
		case "decision":
			return 0.14;
		case "project_fact":
			return 0.1;
		case "task_note":
			return 0.06;
		default:
			return 0;
	}
}

export function scoreMemory(item, queryText, queryTokens) {
	const memoryTokens = item.tags.length > 0 ? item.tags : tagsFromText(item.text);
	const memoryTokenSet = new Set(memoryTokens);
	const exactMatches = queryTokens.filter((token) => memoryTokenSet.has(token));
	const exactMatchScore = exactMatches.length > 0 ? Math.min(0.5, exactMatches.length * 0.18) : 0;
	const overlap = overlapScore(queryTokens, memoryTokens);
	const contains = queryText && item.text.toLowerCase().includes(queryText.toLowerCase()) ? 0.4 : 0;
	const confidence = item.confidence * 0.2;
	const repoBoost = item.scope === "repo" ? 0.08 : 0;
	const sessionBoost = item.scope === "session" ? 0.04 : 0;
	const decisionBoost = item.kind === "decision" && exactMatches.length > 0 ? 0.12 : 0;
	const taskBoost = item.kind === "task_note" && exactMatches.length > 0 ? 0.08 : 0;
	const preferenceFallback = !queryText && item.kind === "preference" ? 0.35 : 0;
	const genericPreferencePenalty = item.kind === "preference" && exactMatches.length === 0 && queryTokens.length > 0 ? 0.18 : 0;
	const score =
		exactMatchScore +
		overlap * 0.38 +
		contains +
		confidence +
		kindBonus(item.kind) +
		repoBoost +
		sessionBoost +
		decisionBoost +
		taskBoost +
		preferenceFallback -
		genericPreferencePenalty;
	return {
		score,
		reasons: {
			exactMatches,
			exactMatchScore,
			overlap,
			contains,
			confidence,
			repoBoost,
			sessionBoost,
			decisionBoost,
			taskBoost,
			preferenceFallback,
			genericPreferencePenalty,
		},
	};
}

export function formatKind(kind) {
	switch (kind) {
		case "preference":
			return "Preference";
		case "project_fact":
			return "Project fact";
		case "decision":
			return "Decision";
		case "task_note":
			return "Task note";
		default:
			return String(kind);
	}
}

export function formatMemoryLine(item) {
	return `- ${formatKind(item.kind)}: ${item.text}`;
}

export function chooseMemories(items, repoKey, sessionFile, messages) {
	const queryText = getLatestRelevantText(messages);
	const queryTokens = tokenize(queryText);
	const scoredCandidates = applicableMemories(items, repoKey, sessionFile)
		.map((item) => {
			const scored = scoreMemory(item, queryText, queryTokens);
			return { item, score: scored.score, reasons: scored.reasons };
		})
		.sort((a, b) => b.score - a.score);
	const candidates = scoredCandidates.filter(({ score }) => score > 0.18);

	const chosen = [];
	const skipped = [];
	const kindCounts = { preference: 0, decision: 0, project_fact: 0, task_note: 0 };
	const kindLimits = { preference: 2, decision: 2, project_fact: 2, task_note: 1 };
	let tokenBudget = 0;
	const strongestSpecific = candidates.find((candidate) => candidate.item.kind !== "preference");

	for (const candidate of candidates) {
		if (chosen.length >= MAX_INJECTED_ITEMS) {
			skipped.push({ ...candidate, skippedReason: "max items reached" });
			continue;
		}
		if (
			candidate.item.kind === "preference" &&
			strongestSpecific &&
			candidate.score + 0.12 < strongestSpecific.score
		) {
			skipped.push({ ...candidate, skippedReason: "preference weaker than repo-specific hit" });
			continue;
		}
		if (kindCounts[candidate.item.kind] >= kindLimits[candidate.item.kind]) {
			skipped.push({ ...candidate, skippedReason: `kind limit reached for ${candidate.item.kind}` });
			continue;
		}
		const line = formatMemoryLine(candidate.item);
		const cost = estimateTokens(line);
		if (chosen.length > 0 && tokenBudget + cost > SOFT_TOKEN_BUDGET) {
			skipped.push({ ...candidate, skippedReason: "token budget exceeded" });
			continue;
		}
		chosen.push(candidate);
		kindCounts[candidate.item.kind]++;
		tokenBudget += cost;
	}

	if (chosen.length === 0) {
		const preferences = applicableMemories(items, repoKey, sessionFile)
			.filter((item) => item.kind === "preference")
			.slice(0, 2)
			.map((item) => ({
				item,
				score: 0.2,
				reasons: {
					exactMatches: [],
					exactMatchScore: 0,
					overlap: 0,
					contains: 0,
					confidence: item.confidence * 0.2,
					repoBoost: 0,
					sessionBoost: 0,
					decisionBoost: 0,
					taskBoost: 0,
					preferenceFallback: 0.2,
					genericPreferencePenalty: 0,
				},
				skippedReason: undefined,
			}));
		for (const pref of preferences) chosen.push(pref);
	}

	const filteredOut = scoredCandidates.filter(({ score }) => score <= 0.18).map((candidate) => ({
		...candidate,
		skippedReason: "below score threshold",
	}));

	return { queryText, chosen, skipped: [...skipped, ...filteredOut], tokenBudget, kindCounts };
}

export function formatInjectedMemory(items) {
	const lines = items.map(formatMemoryLine);
	return [
		"Relevant persistent memory:",
		...lines,
		"",
		"Use these as soft constraints and context. Ignore any item that is clearly irrelevant or stale.",
	].join("\n");
}

export function formatMemoryList(items) {
	if (items.length === 0) return "No stored memories.";
	return items
		.map(
			(item) =>
				`- [${item.kind}] ${item.text} (scope=${item.scope}, confidence=${item.confidence.toFixed(2)}, id=${item.id})`,
		)
		.join("\n");
}

export function addOrUpdateMemory(items, partial, createId) {
	const normalizedText = normalizeText(partial.text);
	const existing = items.find(
		(item) =>
			item.kind === partial.kind &&
			item.scope === partial.scope &&
			item.repoKey === partial.repoKey &&
			item.sessionFile === partial.sessionFile &&
			item.text.toLowerCase() === normalizedText.toLowerCase(),
	);

	if (existing) {
		const updated = {
			...existing,
			text: normalizedText,
			tags: [...new Set([...(existing.tags ?? []), ...(partial.tags ?? [])])].slice(0, 12),
			confidence: clamp(Math.max(existing.confidence, partial.confidence), 0, 1),
			source: partial.source,
			updatedAt: nowIso(),
			expiresAt: partial.expiresAt,
			supersedes: partial.supersedes,
		};
		const next = items.map((item) => (item.id === existing.id ? updated : item));
		return { items: dedupeItems(next), memory: updated, created: false };
	}

	const memory = {
		id: createId(),
		createdAt: nowIso(),
		updatedAt: nowIso(),
		...partial,
		text: normalizedText,
		tags: [...new Set(partial.tags)].slice(0, 12),
		confidence: clamp(partial.confidence, 0, 1),
	};
	return { items: dedupeItems([...items, memory]), memory, created: true };
}

export function forgetByQuery(items, query, repoKey) {
	const normalized = query.toLowerCase();
	const removed = [];
	const kept = items.filter((item) => {
		const matchesScope = item.scope === "global" || item.repoKey === repoKey;
		const matchesText = item.text.toLowerCase().includes(normalized) || item.id.toLowerCase().includes(normalized);
		if (matchesScope && matchesText) {
			removed.push(item);
			return false;
		}
		return true;
	});
	return { items: kept, removed };
}

export function markMemoriesUsed(items, chosen, timestamp = nowIso()) {
	const chosenIds = new Set(chosen.map(({ item }) => item.id));
	let touched = false;
	const updated = items.map((item) => {
		if (!chosenIds.has(item.id)) return item;
		touched = true;
		return { ...item, lastUsedAt: timestamp };
	});
	return { items: updated, touched };
}
