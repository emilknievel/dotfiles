# pi config

This directory is managed from:

- `~/.dotfiles/pi/.pi/agent/`

Installed via stow to:

- `~/.pi/agent/`

## Files

- `prompts/plan.md` — reusable `/plan` prompt template for planning before edits
- `extensions/permission-gate.ts` — asks before destructive bash commands, and blocks them in non-interactive modes. Covers: recursive `rm`, `chmod/chown 777`, `dd`/`mkfs`, `sudo`, shutdown; git (`reset --hard`, force push, `clean -f`, `restore`, `checkout --`, `stash drop`, `filter-branch`, `push --mirror`); `find -delete`/`xargs rm`; docker (`prune`, `compose down -v`, `volume rm`); databases (`dropdb`, `DROP DATABASE/SCHEMA`, `TRUNCATE`, redis `FLUSHALL`, mongo `dropDatabase`, framework resets: rails/artisan/django/prisma/doctrine); infra (`terraform destroy`, `gh repo delete`, `kubectl delete ns/pvc`); immutable publishes (npm/cargo/twine/gem); `curl`/`wget` piped to a shell
- `extensions/protected-paths.ts` — guards `write`/`edit` in two tiers:
  - **block** — `node_modules/`, `.git/`, `~/.ssh`, `~/.gnupg`, `~/.aws`, `~/.config/gh`, `~/.pi/agent/{auth,trust}.json`, SSH keys (`id_rsa`/`id_ed25519`/...), `authorized_keys`, `*.pem|*.p12|*.pfx`, and any dotfile directly in `~`
  - **ask** — real env files (`.env`, `.env.local`, `.env.production`, ...) plus `secrets.{json,yml,yaml,toml}`, `credentials.json`, `.netrc`
  - template env files (`.env.example`, `.env.sample`, `.env.template`, `.env.dist`) are freely writable — placeholders, not secrets

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
