/**
 * Protected Paths Extension
 *
 * Blocks or asks before write/edit operations to sensitive paths, in two
 * tiers:
 *
 * - block: deny outright. SSH/GPG material, provider credentials, home
 *   dotfiles, node_modules, .git — no good reason for the agent to touch
 *   these behind your back.
 * - ask: confirm first (like permission-gate). Real .env* files and
 *   secret-ish configs — writing these is sometimes legitimate (project
 *   setup) but never silently. Template files (.env.example etc.) are
 *   freely writable: they contain placeholders, not secrets.
 *
 * Tuned copy of the upstream example (examples/extensions/protected-paths.ts)
 * with home-directory dotfiles, keys, and the two-tier split added.
 *
 * Hot-reload changes with /reload.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const S = process.platform === "win32" ? "\\" : "/";

/** Absolute paths that may never be written. */
const protectedAbs: string[] = [
	`${process.env.HOME}/.ssh`,
	`${process.env.HOME}/.gnupg`,
	`${process.env.HOME}/.config/gh`, // GitHub token
	`${process.env.HOME}/.aws`,
	`${process.env.HOME}/.pi/agent/auth.json`, // provider API keys
	`${process.env.HOME}/.pi/agent/trust.json`, // project trust decisions
];

/** Substrings that mark a path as blocked wherever they appear. */
const blockSubstrings = [`node_modules${S}`, `${S}.git${S}`];

/** Basename regexes that block a path wherever it appears. */
const blockBasenames: RegExp[] = [
	/^id_(rsa|ed25519|ecdsa|dsa)$/,
	/^authorized_keys$/,
	/\.(pem|p12|pfx)$/,
];

/**
 * Basename regexes that require confirmation.
 * Real env files: `.env` or `.env.<suffix>` except known template suffixes
 * (example/sample/template/dist hold placeholders, not secrets).
 */
const askBasenames: RegExp[] = [
	/^\.env(\.(?!example$|sample$|template$|dist$)[\w.-]+)?$/i,
	/^secrets\.(json|ya?ml|toml)$/,
	/^credentials\.json$/,
	/^\.netrc$/,
];

/** Dotfiles (basename starting with ".") directly in HOME may not be written. */
function isHomeDotfile(path: string): boolean {
	const home = process.env.HOME ?? "";
	const norm = path.replaceAll("\\", "/");
	if (!home || !norm.startsWith(`${home.replaceAll("\\", "/")}/`)) return false;
	const rel = norm.slice(home.length + 1);
	return !rel.includes("/") && rel.startsWith(".");
}

function basename(path: string): string {
	const norm = path.replaceAll("\\", "/");
	const idx = norm.lastIndexOf("/");
	return idx === -1 ? norm : norm.slice(idx + 1);
}

function isBlocked(path: string): boolean {
	const norm = path.replaceAll("\\", "/");
	if (protectedAbs.some((p) => norm.startsWith(p.replaceAll("\\", "/"))))
		return true;
	if (blockSubstrings.some((s) => norm.includes(s.replaceAll("\\", "/"))))
		return true;
	if (isHomeDotfile(norm)) return true;
	const base = basename(norm);
	return blockBasenames.some((re) => re.test(base));
}

function needsConfirm(path: string): boolean {
	const base = basename(path);
	return askBasenames.some((re) => re.test(base));
}

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName !== "write" && event.toolName !== "edit") {
			return undefined;
		}

		const path = event.input.path as string;

		if (isBlocked(path)) {
			if (ctx.hasUI) {
				ctx.ui.notify(`Blocked write to protected path: ${path}`, "warning");
			}
			return { block: true, reason: `Path "${path}" is protected` };
		}

		if (needsConfirm(path)) {
			if (!ctx.hasUI) {
				return {
					block: true,
					reason: `Sensitive path "${path}" blocked: no UI to confirm`,
				};
			}
			const ok = await ctx.ui.confirm(
				"⚠️ Sensitive file",
				`Allow writing ${path}? It may contain secrets.`,
			);
			if (!ok) {
				return { block: true, reason: `Blocked by user (sensitive path: ${path})` };
			}
		}

		return undefined;
	});
}
