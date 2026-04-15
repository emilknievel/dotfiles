import test from "node:test";
import assert from "node:assert/strict";
import os from "node:os";
import path from "node:path";
import fs from "node:fs";

const extensionModulePath = new URL("./index.ts", import.meta.url).pathname;

function createMockPi() {
	const commands = new Map();
	const handlers = new Map();
	const sentMessages = [];
	const appendedEntries = [];

	return {
		commands,
		handlers,
		sentMessages,
		appendedEntries,
		on(eventName, handler) {
			handlers.set(eventName, handler);
		},
		registerCommand(name, config) {
			commands.set(name, config);
		},
		sendMessage(message, options) {
			sentMessages.push({ message, options });
		},
		appendEntry(customType, data) {
			appendedEntries.push({ customType, data });
		},
	};
}

function createMockContext(cwd, notifications) {
	return {
		cwd,
		hasUI: true,
		sessionManager: {
			getSessionFile: () => path.join(cwd, ".pi", "sessions", "test.jsonl"),
			getBranch: () => [],
		},
		ui: {
			notify(message, level) {
				notifications.push({ message, level });
			},
			setStatus() {},
		},
	};
}

async function loadExtensionFactory() {
	return (await import(`file://${extensionModulePath}?t=${Date.now()}-${Math.random()}`)).default;
}

test("memory extension registers commands and injects memory into context", async () => {
	const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "pi-memory-ext-"));
	fs.mkdirSync(path.join(tempDir, ".git"));

	const notifications = [];
	const ctx = createMockContext(tempDir, notifications);
	const pi = createMockPi();
	const extensionFactory = await loadExtensionFactory();
		extensionFactory(pi);

	assert.ok(pi.commands.has("remember"));
	assert.ok(pi.commands.has("memory-debug"));
	assert.ok(pi.handlers.has("session_start"));
	assert.ok(pi.handlers.has("context"));
	assert.ok(pi.handlers.has("session_before_compact"));

	await pi.handlers.get("session_start")({ type: "session_start", reason: "startup" }, ctx);

	await pi.commands.get("remember-pref").handler("Prefer minimal diffs", ctx);
	await pi.commands.get("remember-decision").handler("Use zod for schema validation", ctx);

	const contextResult = await pi.handlers.get("context")(
		{ type: "context", messages: [{ role: "user", content: "Update the zod schema", timestamp: Date.now() }] },
		ctx,
	);

	assert.equal(Array.isArray(contextResult.messages), true);
	assert.equal(contextResult.messages[0].role, "custom");
	assert.equal(contextResult.messages[0].display, false);
	assert.match(String(contextResult.messages[0].content), /Use zod for schema validation/);
	assert.equal(pi.appendedEntries.length >= 2, true);
	assert.equal(notifications.some((entry) => /Memory ready/.test(entry.message)), true);

	fs.rmSync(tempDir, { recursive: true, force: true });
});

test("memory-debug emits a visible summary message", async () => {
	const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "pi-memory-debug-"));
	fs.mkdirSync(path.join(tempDir, ".git"));

	const notifications = [];
	const branchMessages = [{ role: "user", content: "Please use pnpm in this repo", timestamp: Date.now() }];
	const ctx = {
		...createMockContext(tempDir, notifications),
		sessionManager: {
			getSessionFile: () => path.join(tempDir, ".pi", "sessions", "test.jsonl"),
			getBranch: () => branchMessages.map((message) => ({ type: "message", message })),
		},
	};
	const pi = createMockPi();
	const extensionFactory = await loadExtensionFactory();
		extensionFactory(pi);

	await pi.handlers.get("session_start")({ type: "session_start", reason: "startup" }, ctx);
	await pi.commands.get("remember").handler("Use pnpm for package commands", ctx);
	await pi.commands.get("memory-debug").handler("", ctx);

	assert.equal(pi.sentMessages.length > 0, true);
	const last = pi.sentMessages.at(-1);
	assert.equal(last.message.display, true);
	assert.match(last.message.content, /Query text:/);
	assert.match(last.message.content, /Selected:/);
	assert.match(last.message.content, /Skipped:/);
	assert.match(last.message.content, /score=/);
	assert.match(last.message.content, /Use pnpm for package commands/);

	fs.rmSync(tempDir, { recursive: true, force: true });
});

test("session_before_compact extracts durable memory candidates", async () => {
	const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "pi-memory-compact-"));
	fs.mkdirSync(path.join(tempDir, ".git"));

	const notifications = [];
	const ctx = createMockContext(tempDir, notifications);
	const pi = createMockPi();
	const extensionFactory = await loadExtensionFactory();
		extensionFactory(pi);

	await pi.handlers.get("session_start")({ type: "session_start", reason: "startup" }, ctx);
	await pi.handlers.get("session_before_compact")(
		{
			type: "session_before_compact",
			preparation: {
				messagesToSummarize: [
					{ role: "user", content: "Prefer minimal diffs.", timestamp: Date.now() },
					{ role: "assistant", content: "This repo uses pnpm. Keep schemas in src/schema.", timestamp: Date.now() },
				],
				turnPrefixMessages: [],
			},
		},
		ctx,
	);

	const memoryPath = path.join(tempDir, ".pi", "memory.jsonl");
	assert.equal(fs.existsSync(memoryPath), true);
	const raw = fs.readFileSync(memoryPath, "utf8");
	assert.match(raw, /Prefer minimal diffs/);
	assert.match(raw, /This repo uses pnpm/);
	assert.equal(pi.appendedEntries.some((entry) => entry.data?.action === "compact-extract"), true);

	fs.rmSync(tempDir, { recursive: true, force: true });
});
