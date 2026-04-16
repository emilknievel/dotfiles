import { normalizeText, tagsFromText } from "./memory-lib.js";

const SAFE_PACKAGE_MANAGER_COMMANDS =
  /\b(pnpm|npm|yarn)\s+(test|run|exec|dlx|list|ls|why|lint|check|typecheck|build)\b/;
const PACKAGE_MANAGER_INSTALL_COMMANDS =
  /\b(pnpm|npm|yarn)\s+(install|add|remove|unlink|link|upgrade|up|update)\b/;
const NOISY_READ_PATHS =
  /(^|\/)(node_modules|dist|build|coverage|\.git|\.next|target)\//;

function compact(text) {
  return normalizeText(text).replace(/[.]+$/, "");
}

function fromBashInput(input) {
  const command = compact(String(input?.command ?? ""));
  if (!command) return [];
  if (/[|;&><`]/.test(command)) return [];
  if (PACKAGE_MANAGER_INSTALL_COMMANDS.test(command)) return [];
  if (!SAFE_PACKAGE_MANAGER_COMMANDS.test(command) && !/\bzod\b/.test(command))
    return [];

  const candidates = [];
  if (/\bpnpm\b/.test(command) && SAFE_PACKAGE_MANAGER_COMMANDS.test(command)) {
    candidates.push({
      kind: "project_fact",
      scope: "repo",
      text: "This repo uses pnpm",
      confidence: 0.45,
      tags: ["pnpm", ...tagsFromText(command)].slice(0, 12),
      observationKey: "bash:pnpm",
      minCount: 2,
    });
  }
  if (
    /\bzod\b/.test(command) &&
    /\b(test|lint|check|typecheck|build|run|exec)\b/.test(command)
  ) {
    candidates.push({
      kind: "decision",
      scope: "repo",
      text: "Zod is part of the active workflow in this repo",
      confidence: 0.38,
      tags: ["zod", ...tagsFromText(command)].slice(0, 12),
      observationKey: "bash:zod",
      minCount: 3,
    });
  }
  return candidates;
}

function fromReadInput(input) {
  const target = compact(String(input?.path ?? ""));
  if (!target) return [];
  if (NOISY_READ_PATHS.test(target)) return [];

  const candidates = [];
  if (/(^|\/)package\.json$/.test(target)) {
    candidates.push({
      kind: "project_fact",
      scope: "repo",
      text: "package.json is a relevant project entry point",
      confidence: 0.24,
      tags: ["package.json", ...tagsFromText(target)].slice(0, 12),
      observationKey: "read:package.json",
      minCount: 3,
    });
  }
  if (
    /src\/schema|schema\//.test(target) &&
    /\.(ts|tsx|js|jsx|json|zod)$/.test(target)
  ) {
    candidates.push({
      kind: "decision",
      scope: "repo",
      text: "Schema files are an active area in this repo",
      confidence: 0.28,
      tags: ["schema", ...tagsFromText(target)].slice(0, 12),
      observationKey: "read:schema",
      minCount: 3,
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
    counts.set(
      candidate.observationKey,
      (counts.get(candidate.observationKey) ?? 0) + 1,
    );
  }

  const accepted = observed.filter(
    (candidate) =>
      (counts.get(candidate.observationKey) ?? 0) >=
      (candidate.minCount ?? minCount),
  );
  return { counts, accepted };
}
