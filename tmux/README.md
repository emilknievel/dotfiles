# tmux

Minimal tmux configuration, kept close to upstream defaults.

## Non-default behavior

This config intentionally changes only a few things:

- scrollback history is increased to `100000`
- windows and panes are 1-indexed
- windows are renumbered automatically
- new splits inherit the current pane's working directory
- pane navigation uses `<prefix> h/j/k/l`
- pane resizing uses `<prefix> H/J/K/L`
- mouse support is enabled
- `default-terminal` is set to `tmux-256color`

## Defaults kept

This config keeps tmux's default prefix:

- `<prefix>` is `C-b`

It also keeps tmux's default split bindings:

- `<prefix> %` for a vertical split
- `<prefix> "` for a horizontal split

## Stow

When stowed, this package installs:

- `~/.tmux.conf`
