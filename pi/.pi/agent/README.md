# pi config

This directory is managed from:

- `~/.dotfiles/pi/.pi/agent/`

Installed via stow to:

- `~/.pi/agent/`

## Files

- `prompts/plan.md` — reusable `/plan` prompt template for planning before edits
- `extensions/permission-gate.ts` — prompts before destructive bash commands (rm, chmod 777, sudo, docker, DB drops, infra teardown, immutable publishes, piped curl/wget). Blocks in non-interactive mode. Git message text is stripped so prose matching doesn't trigger.
- `extensions/protected-paths.ts` — guards `write`/`edit` in two tiers:
  - **block** — `node_modules/`, `.git/`, `~/.ssh`, `~/.gnupg`, `~/.aws`, `~/.config/gh`, `~/.pi/agent/{auth,trust}.json`, SSH keys (`id_rsa`/`id_ed25519`/...), `authorized_keys`, `*.pem|*.p12|*.pfx`, and any dotfile directly in `~`
  - **ask** — real env files (`.env`, `.env.local`, `.env.production`, ...) plus `secrets.{json,yml,yaml,toml}`, `credentials.json`, `.netrc`. Template env files (`*.example`, `*.sample`, `*.template`, `*.dist`) are allowed freely.

Tuned copies of upstream examples (`<pi install>/examples/extensions/`). Seatbelt, not sandbox. Edit rules in the files; `/reload` picks up changes.

## Packages

npm pi-packages (the `packages` list in `~/.pi/agent/settings.json`). Install them with the following one-liner:

```bash
for p in pi-hermes-memory pi-web-access pi-mcp-adapter pi-lens pi-subagents; do pi install "npm:$p"; done
```

## Prompt templates

### `/plan`

Expands to a planning prompt that asks pi to:

- think through the task step by step
- avoid making changes yet
- outline what to read first
- describe intended changes and where
- call out risks, side effects, and open questions

## Update flow

From `~/.dotfiles`:

```bash
stow pi -t ~
```

Then reload in pi:

```text
/reload
```
