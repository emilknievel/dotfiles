# pi config

This directory is managed from:

- `~/.dotfiles/pi/.pi/agent/`

Installed via stow to:

- `~/.pi/agent/`

## Files

- `extensions/memory/index.ts` — global memory extension for pi
- `extensions/memory/` — helper modules, extraction logic, and tests for the memory extension
- `prompts/plan.md` — reusable `/plan` prompt template for planning before edits

## Memory extension

The memory extension is installed globally, but stores memory per repo in:

- `<repo>/.pi/memory.jsonl`

Commands:
- `/remember`
- `/remember-pref`
- `/remember-decision`
- `/remember-task`
- `/replace-memory` — replace matching active memories with a new one and supersede the old facts
- `/forget`
- `/memories` — opens an interactive list in TUI mode, falls back to a visible message otherwise
- `/memory-debug`
- `/memory-prune` — remove expired and very stale low-confidence memories

## Memory cheat sheet

### Save memory

Repo fact:

```text
/remember This repo uses pnpm
```

Global preference:

```text
/remember-pref Prefer minimal diffs
```

Repo decision:

```text
/remember-decision Keep schemas in src/schema
```

Session task note:

```text
/remember-task Need to rerun tests after config changes
```

### Inspect memory

Open the memory list:

```text
/memories
```

Debug what would be injected:

```text
/memory-debug
```

### Update memory

Replace an old fact with a new one:

```text
/replace-memory pnpm => This repo uses bun
```

### Delete memory

Remove by substring or id:

```text
/forget pnpm
```

### Clean up

Remove expired or stale low-confidence memories:

```text
/memory-prune
```

### Good starter set

```text
/remember-pref Prefer minimal diffs
/remember-pref Ask before destructive commands
/remember This repo uses pnpm
/remember-decision Keep schemas in src/schema
```

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

## Tests

Run the memory extension tests with:

```bash
node --experimental-strip-types --test \
  ~/.dotfiles/pi/.pi/agent/extensions/memory/memory-lib.test.mjs \
  ~/.dotfiles/pi/.pi/agent/extensions/memory/memory-extract.test.mjs \
  ~/.dotfiles/pi/.pi/agent/extensions/memory/memory-observe.test.mjs \
  ~/.dotfiles/pi/.pi/agent/extensions/memory/memory-extension.test.mjs
```
