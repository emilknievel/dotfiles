# pi config

This directory is managed from:

- `~/.dotfiles/pi/.pi/agent/`

Installed via stow to:

- `~/.pi/agent/`

## Files

- `prompts/plan.md` — reusable `/plan` prompt template for planning before edits
- `extensions/permission-gate.ts` — asks before destructive bash commands (`rm -r*`, `sudo`, force push, `git reset --hard`, curl-to-shell, ...); blocks them in non-interactive modes
- `extensions/protected-paths.ts` — blocks `write`/`edit` to `.env*`, `node_modules/`, `.git/`, `~/.ssh`, `~/.config/gh`, `~/.pi/agent/auth.json`, and any dotfile directly in `~`

Both extensions are tuned copies of the upstream examples in
`<pi install>/examples/extensions/`. They are heuristics (a seatbelt, not a
sandbox) — for genuinely untrusted work, run pi in a container instead.
Edit the rule lists in the files; `/reload` picks up changes.

## Prompt templates

### `/plan`

Expands to a planning prompt that asks pi to:

- think through the task step by step
- avoid making changes yet
- outline what to read first
- describe intended changes and where
- call out risks, side effects, and open questions

Installed at:

- `~/.pi/agent/prompts/plan.md`

## Update flow

From `~/.dotfiles`:

```bash
stow pi -t ~
```

Then reload in pi:

```text
/reload
```
