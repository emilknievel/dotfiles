/**
 * Protected Paths Extension
 *
 * Blocks write/edit operations to sensitive paths. Unlike permission-gate
 * (which asks), this denies outright — there is no good reason for the agent
 * to edit these files behind your back.
 *
 * Tuned copy of the upstream example (examples/extensions/protected-paths.ts)
 * with home-directory dotfiles and SSH keys added.
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

/** Substrings that mark a path as protected wherever they appear. */
const protectedSubstrings = [".env", `node_modules${S}`, `${S}.git${S}`];

/** Dotfiles (basename starting with ".") directly in HOME may not be written. */
function isHomeDotfile(path: string): boolean {
	const home = process.env.HOME ?? "";
	const norm = path.replaceAll("\\", "/");
	if (!home || !norm.startsWith(`${home.replaceAll("\\", "/")}/`)) return false;
	const rel = norm.slice(home.length + 1);
	return !rel.includes("/") && rel.startsWith(".");
}

function isProtected(path: string): boolean {
	const norm = path.replaceAll("\\", "/");
	if (protectedAbs.some((p) => norm.startsWith(p.replaceAll("\\", "/"))))
		return true;
	if (protectedSubstrings.some((s) => norm.includes(s.replaceAll("\\", "/"))))
		return true;
	return isHomeDotfile(norm);
}

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName !== "write" && event.toolName !== "edit") {
			return undefined;
		}

		const path = event.input.path as string;
		if (isProtected(path)) {
			if (ctx.hasUI) {
				ctx.ui.notify(`Blocked write to protected path: ${path}`, "warning");
			}
			return { block: true, reason: `Path "${path}" is protected` };
		}

		return undefined;
	});
}
