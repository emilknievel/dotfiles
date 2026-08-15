/**
 * Permission Gate Extension
 *
 * Asks for confirmation before running potentially destructive bash commands,
 * and blocks them outright when there is no UI to ask (print/json modes).
 *
 * Tuned copy of the upstream example (examples/extensions/permission-gate.ts),
 * broadened for polyglot/multi-repo work. These are heuristics — a seatbelt
 * for accidents and obvious prompt-injection weirdness, not a sandbox. The
 * agent can still bypass pattern matching (e.g. write a script, then run it).
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
	// --staged is safe (index only); anything else discards worktree changes
	{
		name: "git restore (worktree)",
		pattern: /\bgit\s+restore\b(?![^|;&]*--staged)/,
	},
	{
		name: "git checkout -- discard",
		pattern: /\bgit\s+checkout\b[^|;&]*(\s--(?!\s*-b)\s|\s\.(\s|$)|\s--$)/,
	},
	{
		name: "git stash drop/clear",
		pattern: /\bgit\s+stash\b[^|;&]*\b(drop|clear)\b/,
	},
	{ name: "git filter-branch", pattern: /\bgit\s+filter-branch\b/ },
	{ name: "git reflog expire", pattern: /\bgit\s+reflog\b[^|;&]*expire/ },
	{ name: "git push --mirror", pattern: /\bgit\s+push\b[^|;&]*--mirror/ },

	// remote code execution
	{
		name: "curl|wget piped to shell",
		pattern: /\b(curl|wget)\b[^|]*\|\s*(sudo\s+)?(ba|z|fi)?sh\b/,
	},

	// deletion via find/xargs (bypasses the rm rules)
	{ name: "find -delete", pattern: /\bfind\b[^|;&]*\s-delete\b/ },
	{ name: "xargs rm", pattern: /\bxargs\b[^|;&]*\brm\b/ },

	// docker
	{
		name: "docker prune",
		pattern:
			/\bdocker\s+(system|volume|image|container|builder|network)\s+prune\b/,
	},
	{
		name: "docker compose down -v",
		pattern: /\bdocker(-compose)?\s+compose\s+down\b[^|;&]*(-v\b|--volumes\b)/,
	},
	{
		name: "docker-compose down -v",
		pattern: /\bdocker-compose\s+down\b[^|;&]*(-v\b|--volumes\b)/,
	},
	{ name: "docker volume rm", pattern: /\bdocker\s+volume\s+rm\b/ },

	// databases
	{ name: "dropdb", pattern: /\bdropdb\b/ },
	{ name: "DROP DATABASE/SCHEMA", pattern: /\bDROP\s+(DATABASE|SCHEMA)\b/i },
	{ name: "TRUNCATE TABLE", pattern: /\bTRUNCATE\s+TABLE\b/i },
	{
		name: "redis FLUSHALL/FLUSHDB",
		pattern: /\bredis-cli\b[^|;&]*FLUSH(ALL|DB)/,
	},
	{ name: "mongo dropDatabase", pattern: /\bdb\.dropDatabase\s*\(/ },
	{ name: "rails db drop/reset", pattern: /\brails\s+db:(drop|reset)\b/ },
	{
		name: "laravel db wipe/fresh",
		pattern: /\bartisan\s+(migrate:fresh|db:wipe)\b/,
	},
	{ name: "django flush", pattern: /\bmanage\.py\s+flush\b/ },
	{ name: "prisma migrate reset", pattern: /\bprisma\s+migrate\s+reset\b/ },
	{
		name: "doctrine database drop",
		pattern: /\bdoctrine:database:drop\b/,
	},

	// infra
	{ name: "terraform destroy", pattern: /\bterraform\b[^|;&]*\bdestroy\b/ },
	{ name: "gh repo delete", pattern: /\bgh\s+repo\s+delete\b/ },
	{
		name: "kubectl delete ns/pvc",
		pattern: /\bkubectl\b[^|;&]*delete\b[^|;&]*\s(ns|namespace|pvc|pv)\b/,
	},

	// publish (immutable registries — cannot be undone)
	{ name: "npm publish", pattern: /\bnpm\s+publish\b/ },
	{ name: "cargo publish", pattern: /\bcargo\s+publish\b/ },
	{ name: "twine upload", pattern: /\btwine\s+upload\b/ },
	{ name: "gem push", pattern: /\bgem\s+push\b/ },
];

/**
 * Replace git commit/tag/merge -m/--message payloads with a placeholder:
 * message text is metadata git never executes, so regex-matching it only
 * produces false positives (e.g. a commit message mentioning "sudo").
 */
function stripGitMessages(cmd: string): string {
	return cmd
		.replace(
			/(\s--message\s+|\s-[a-z]*m\s+)("[^"\\]*(\\.[^"\\]*)*"|'[^'\\]*(\\.[^'\\]*)*')/gi,
			'$1"<msg>"',
		)
		.replace(/(--message=)("[^"]*"|'[^']*'|[^\s&|;]+)/gi, '$1"<msg>"');
}

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		if (event.toolName !== "bash") return undefined;

		const command = stripGitMessages(event.input.command as string);
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
