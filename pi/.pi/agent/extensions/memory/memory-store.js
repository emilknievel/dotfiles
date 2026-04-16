import { randomUUID } from "node:crypto";
import * as fs from "node:fs";
import * as path from "node:path";
import { addOrUpdateMemory, dedupeItems, sortMemories } from "./memory-lib.js";

export function findRepoRoot(startDir) {
  let current = path.resolve(startDir);
  while (true) {
    if (fs.existsSync(path.join(current, ".git"))) return current;
    const parent = path.dirname(current);
    if (parent === current) return path.resolve(startDir);
    current = parent;
  }
}

export function getStorePath(repoRoot) {
  return path.join(repoRoot, ".pi", "memory.jsonl");
}

export function readStore(storePath) {
  if (!fs.existsSync(storePath)) return [];

  const lines = fs.readFileSync(storePath, "utf8").split("\n");
  const items = [];
  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed) continue;
    try {
      const item = JSON.parse(trimmed);
      if (item && item.id && item.text && item.kind && item.scope)
        items.push(item);
    } catch {
      // Skip malformed lines.
    }
  }
  return items;
}

export function writeStore(storePath, items) {
  fs.mkdirSync(path.dirname(storePath), { recursive: true });
  const content = items.map((item) => JSON.stringify(item)).join("\n");
  fs.writeFileSync(storePath, content.length > 0 ? `${content}\n` : "", "utf8");
}

export function persistStore(storePath, items) {
  const next = sortMemories(dedupeItems(items));
  writeStore(storePath, next);
  return next;
}

export function addOrUpdateMemoryInStore(items, partial) {
  return addOrUpdateMemory(items, partial, () => randomUUID());
}
