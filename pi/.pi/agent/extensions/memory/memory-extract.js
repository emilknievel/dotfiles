import { getMessageText, normalizeText, tagsFromText } from "./memory-lib.js";

function splitSentences(text) {
  return text
    .split(/\n+/)
    .flatMap((line) => line.split(/(?<=[.!?])\s+/))
    .map((line) => normalizeText(line))
    .filter((line) => line.length >= 12 && line.length <= 180);
}

function cleanExtractedText(text) {
  return normalizeText(text.replace(/^[-*]\s*/, "").replace(/[.]+$/, ""));
}

function extractFromSentence(sentence, role) {
  const lower = sentence.toLowerCase();

  const projectPatterns = [
    /^(?:this repo|the repo|this project|the project) uses (.+)$/i,
    /^(tests?|test files) (?:live|are) in (.+)$/i,
    /^(generated files?) (?:live|are) in (.+)$/i,
    /^(?:package manager|package-manager) is (.+)$/i,
  ];
  for (const pattern of projectPatterns) {
    const match = sentence.match(pattern);
    if (match) {
      const text = cleanExtractedText(sentence);
      return { kind: "project_fact", scope: "repo", text, confidence: 0.72, tags: tagsFromText(text) };
    }
  }

  const decisionPatterns = [
    /^(?:we decided to|decision:?|use |keep |do not use |don't use |avoid using )/i,
    /^(?:auth|validation|schema|schemas|api|tests?|tooling)\b.+\b(?:use|uses|live|lives|stay|stays|belongs)\b/i,
  ];
  for (const pattern of decisionPatterns) {
    if (pattern.test(sentence)) {
      const text = cleanExtractedText(sentence);
      return { kind: "decision", scope: "repo", text, confidence: role === "user" ? 0.74 : 0.62, tags: tagsFromText(text) };
    }
  }

  if (role === "user") {
    const preferencePatterns = [
      /^(?:prefer |please |always |never |ask before |avoid )/i,
      /^i prefer /i,
    ];
    for (const pattern of preferencePatterns) {
      if (pattern.test(sentence)) {
        const text = cleanExtractedText(sentence);
        return { kind: "preference", scope: "global", text, confidence: 0.68, tags: tagsFromText(text) };
      }
    }
  }

  if (lower.startsWith("this repo uses ")) {
    const text = cleanExtractedText(sentence);
    return { kind: "project_fact", scope: "repo", text, confidence: 0.72, tags: tagsFromText(text) };
  }

  return undefined;
}

export function extractMemoryCandidatesFromMessages(messages) {
  const candidates = [];
  const seen = new Set();

  for (const message of messages) {
    if (message.role !== "user" && message.role !== "assistant" && message.role !== "custom") continue;
    if (message.role === "custom" && message.customType === "memory-context") continue;
    const text = getMessageText(message);
    if (!text) continue;
    for (const sentence of splitSentences(text)) {
      const candidate = extractFromSentence(sentence, message.role);
      if (!candidate) continue;
      const key = `${candidate.kind}:${candidate.scope}:${candidate.text.toLowerCase()}`;
      if (seen.has(key)) continue;
      seen.add(key);
      candidates.push(candidate);
    }
  }

  return candidates.slice(0, 6);
}
