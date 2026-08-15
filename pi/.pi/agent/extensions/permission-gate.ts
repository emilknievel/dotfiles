/**
 * Permission Gate Extension
 *
 * Asks for confirmation before running potentially destructive bash commands,
 * and blocks them outright when there is no UI to ask (print/json modes).
 *
 * Tuned copy of the upstream example (examples/extensions/permission-gate.ts)
 * with additional git/docker patterns. These are heuristics — a seatbelt for
 * accidents and obvious prompt-injection weirdness, not a sandbox. The agent
 * can still bypass pattern matching (e.g. write a script, then run it).
 *
 * Hot-reload changes with /reload.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const rules: { name: string; pattern: RegExp }[] = [
	// filesystem destruction
	{ name: "recursive rm", pattern: /\brm\s+[^|;&]*-[a-zA-Z]*r/i },
	{ name: "chmod/chown 777", pattern: /\b(chmod|chown)\b[^|;&]*777/ },
	{ name: "dd to device", pattern: /\bdd\b[^|;&]*of=\/dev\// },
	{ name: "mkfs", pattern: /\bmkfs(\.\w+)?\b/ },

	// escalation / system
	{ name: "sudo", pattern: /\bsudo\b/ },
	{ name: "shutdown/reboot", pattern: /\b(shutdown|reboot|halt|poweroff)\b/ },

	// git history / worktree destruction (--force-with-lease is allowed)
	{
		name: "force push",
		pattern: /\bgit\s+push\b[^|;&]*(--force(?!-with-lease)|(?<![\w-])-f\b)/,
	},
	{ name: "git reset --hard", pattern: /\bgit\s+reset\b[^|;&]*--hard/ },
	{ name: "git clean -f", pattern: /\bgit\s+clean\b[^|;&]*-[a-z]*f/ },
	{
		name: "force-delete branch",
		pattern: /\bgit\s+branch\b[^|;&]*\s(-D\b|--delete-force\b)/,
	},

	// remote code execution
	{
		name: "curl|wget piped to shell",
		pattern: /\b(curl|wget)\b[^|]*\|\s*(sudo\s+)?(ba|z|fi)?sh\b/,
	},
];

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName !== "bash") return undefined;

		const command = event.input.command as string;
		const matched = rules.find((r) => r.pattern.test(command));

		if (matched) {
			if (!ctx.hasUI) {
				return {
					block: true,
					reason: `Dangerous command (${matched.name}) blocked: no UI to confirm`,
				};
			}

			const ok = await ctx.ui.confirm(
				`⚠️ ${matched.name}`,
				`Allow this command?\n\n  ${command}`,
			);
			if (!ok) {
				return { block: true, reason: `Blocked by user (${matched.name})` };
			}
		}

		return undefined;
	});
}
