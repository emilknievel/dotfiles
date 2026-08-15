# pi config

This directory is managed from:

- `~/.dotfiles/pi/.pi/agent/`

Installed via stow to:

- `~/.pi/agent/`

## Files

- `prompts/plan.md` — reusable `/plan` prompt template for planning before edits

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
