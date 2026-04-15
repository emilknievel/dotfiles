# pi config

This directory is managed from:

- `~/.dotfiles/pi/.pi/agent/`

Installed via stow to:

- `~/.pi/agent/`

## Files

- `extensions/memory/index.ts` — global memory extension for pi
- `extensions/memory/` — helper modules, extraction logic, and tests for the memory extension

## Memory extension

The memory extension is installed globally, but stores memory per repo in:

- `<repo>/.pi/memory.jsonl`

Commands:
- `/remember`
- `/remember-pref`
- `/remember-decision`
- `/remember-task`
- `/forget`
- `/memories`
- `/memory-debug`
- `/memory-prune`

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
