# Bash cleanup future session checklist

## Session protocol
**Instruction:** Use `TODOs/bash-cleanup-session.md` as the source of truth for this work. Follow the session protocol, record the starting commit, work through the checklist one commit section at a time, and consult the rollback notes if needed.

- Open this file first and use it as the source of truth for the session.
- Work one commit section at a time, in the listed order unless there is a clear reason to reorder.
- Before each commit:
  - review the diff summary
  - run the listed tests for that section
  - verify the review focus items
- Update this file as part of the work: check off completed items before creating each commit.
- Keep this checklist synchronized with reality at all times.
- If scope changes during the session, update this file before continuing.
- When the done criteria are met, remove `TODOs/bash-cleanup-session.md` in the final cleanup commit.
- Do not move to the next commit section until the current one is implemented, validated, and committed.
- Keep behavior the same unless a change clearly improves robustness.

## Goal
Clean up the bash config without changing intended behavior, and produce a small series of logically grouped commits.

## Rollback / recovery notes
- Before starting the session, record the starting commit:
  - `git rev-parse --short HEAD`
- If you want to inspect what changed during the session:
  - `git log --oneline`
  - `git diff <starting-commit>..HEAD`
- If the current changes are not committed and should be discarded:
  - `git restore <file>`
- If the most recent commit should be redone but changes kept locally:
  - `git reset --soft HEAD~1`
- If the most recent commit should be undone and changes left unstaged:
  - `git reset HEAD~1`
- If a completed commit should be undone safely without rewriting history:
  - `git revert <commit>`
- If you want a safety marker before beginning, create a temporary branch or tag:
  - `git branch bash-cleanup-session-start`
  - or `git tag bash-cleanup-session-start`
- Prefer `git revert` for already-published history and `git reset` for local-only cleanup.

## Commit-by-commit checklist

### Commit 1 — startup robustness
**Commit message:** `bash: harden startup and clean up warnings`

#### Changes
- [ ] In `bash/.bashrc`, guard `~/.cargo/env` before sourcing
- [ ] In `bash/.bashrc`, send missing-tool warnings to `stderr`
- [ ] Add newlines to warning messages
- [ ] Decide whether warnings should only appear in interactive shells
- [ ] Review `.bash-preexec.sh` warning behavior and apply same policy

#### Test steps
- [ ] Run syntax check:
  - `bash -n bash/.bashrc bash/.bashrc.d/*.sh`
- [ ] Start a fresh interactive bash shell
- [ ] Confirm shell starts cleanly
- [ ] If a tool is missing, confirm warning formatting is readable
- [ ] Confirm warnings go to `stderr`, not `stdout`
- [ ] Temporarily simulate missing `~/.cargo/env` and confirm no startup error
- [ ] Confirm PATH still contains expected cargo bin path if that behavior is retained

#### Review focus
- [ ] No behavior change except cleaner startup
- [ ] No noisy output in non-interactive contexts, if that policy is chosen

---

### Commit 2 — prompt hook safety
**Commit message:** `bash: make prompt command composable`

#### Changes
- [ ] In `bash/.bashrc.d/prompt.sh`, move prompt update logic into a function
- [ ] Preserve current prompt appearance
- [ ] Preserve exit status display behavior
- [ ] Preserve `history -a`
- [ ] Compose with existing `PROMPT_COMMAND` rather than overwriting it

#### Test steps
- [ ] Run syntax check:
  - `bash -n bash/.bashrc.d/prompt.sh`
- [ ] Start a fresh interactive bash shell
- [ ] Confirm prompt still shows:
  - user
  - host
  - working directory
- [ ] Run a successful command like `true`
  - confirm no exit code is shown
- [ ] Run a failing command like `false`
  - confirm non-zero exit code is shown as expected
- [ ] Run a command, open another shell, and confirm history is appended as expected
- [ ] If any tool sets `PROMPT_COMMAND`, confirm it still works

#### Review focus
- [ ] Prompt visuals unchanged
- [ ] Exit status shown correctly
- [ ] No clobbering of preexisting prompt hooks

---

### Commit 3 — kubectl helper robustness
**Commit message:** `bash: make kroll argument handling safer`

#### Changes
- [ ] In `bash/.bashrc.d/kubectl.sh`, switch `kroll` optional namespace handling from string-based to array-based args
- [ ] Preserve help text and command UX

#### Test steps
- [ ] Run syntax check:
  - `bash -n bash/.bashrc.d/kubectl.sh`
- [ ] Source the file or start a fresh shell with `kubectl` available
- [ ] Run:
  - [ ] `kroll -h`
  - [ ] `kroll deployment/myapp`
  - [ ] `kroll -n mynamespace deployment/myapp`
- [ ] Confirm usage text still looks right
- [ ] Confirm command invocation order is still correct

#### Review focus
- [ ] No user-facing behavior change
- [ ] Safer shell argument handling

---

### Commit 4 — macOS command detection cleanup
**Commit message:** `bash: improve macos command detection`

#### Changes
- [ ] In `bash/.bashrc.d/macos.sh`, replace `which dotnet` with `command -v`
- [ ] Guard `DOTNET_ROOT` assignment if `dotnet` is absent
- [ ] Optionally simplify duplicate brew completion loading if included in this commit

#### Test steps
- [ ] Run syntax check:
  - `bash -n bash/.bashrc.d/macos.sh`
- [ ] On macOS, start a fresh interactive shell
- [ ] Confirm shell startup still works
- [ ] If `dotnet` exists:
  - [ ] confirm `DOTNET_ROOT` is set correctly
- [ ] If `dotnet` does not exist:
  - [ ] confirm no startup error occurs
- [ ] If brew completion logic changed:
  - [ ] confirm bash completion still works for brew-installed tools

#### Review focus
- [ ] More robust command detection
- [ ] No macOS startup regressions

---

### Commit 5 — helper/path cleanup
**Commit message:** `bash: tidy helper functions and path setup`

#### Changes
- [ ] Review PATH additions in `bash/.bashrc` and `bash/.bashrc.d/macos.sh`
- [ ] Remove obvious duplicate PATH entries if safe
- [ ] Consider removing `exec` from `copy()` and `pasta()` in `bash/.bashrc.d/custom.sh`
- [ ] Review GNU-specific assumptions such as `ls --color`
- [ ] Optionally guard aliases for non-universal tools

#### Test steps
- [ ] Run syntax check:
  - `bash -n bash/.bashrc bash/.bashrc.d/*.sh`
- [ ] Start a fresh interactive shell
- [ ] Check command resolution:
  - [ ] `command -v ls`
  - [ ] `command -v grep`
  - [ ] `command -v dotnet`
  - [ ] `command -v brew`
- [ ] Confirm expected PATH precedence still holds
- [ ] Test helper functions:
  - [ ] `copy`
  - [ ] `pasta`
  - [ ] `cdls`
- [ ] Confirm aliases still behave as expected

#### Review focus
- [ ] Cleanup only, no surprise behavior changes
- [ ] PATH ordering remains intentional

---

### Optional Commit 6 — alias organization
**Commit message:** `bash: reorganize aliases by category`

#### Changes
- [ ] Split `bash/.bashrc.d/aliases.sh` into smaller files if it still feels worthwhile
- [ ] Keep behavior unchanged

#### Test steps
- [ ] Run syntax check:
  - `bash -n bash/.bashrc bash/.bashrc.d/*.sh`
- [ ] Start a fresh shell
- [ ] Confirm aliases are still available:
  - [ ] git aliases
  - [ ] brew aliases
  - [ ] tmux aliases
  - [ ] apt aliases
  - [ ] exa aliases
- [ ] Confirm file load order still behaves as intended

#### Review focus
- [ ] Organization-only change
- [ ] No semantic behavior changes

---

## Whole-session final checks
- [ ] Run:
  - `bash -n bash/.bashrc bash/.bashrc.d/*.sh`
  - `sh -n bash/.local/bin/find-kobo-guid`
- [ ] Start a brand new bash session
- [ ] Confirm prompt looks correct
- [ ] Confirm history append behavior still works
- [ ] Confirm PATH order is still intentional
- [ ] Confirm platform-specific files still early-return correctly
- [ ] If on macOS, confirm brew/dotnet behavior
- [ ] If on Linux, confirm completion and SSH agent behavior
- [ ] If in WSL, confirm WSL-specific aliases/env still work

## Done criteria and cleanup
- [ ] All intended commit sections are completed, intentionally skipped, or revised in this file
- [ ] The whole-session final checks pass
- [ ] Any deviations from the original plan are documented in this file or in commit messages
- [ ] The bash cleanup work is considered complete
- [ ] Remove `TODOs/bash-cleanup-session.md` once the work is done

## Recommended commit sequence
1. `bash: harden startup and clean up warnings`
2. `bash: make prompt command composable`
3. `bash: make kroll argument handling safer`
4. `bash: improve macos command detection`
5. `bash: tidy helper functions and path setup`

## Suggested session prompt
```text
Let's implement the bash cleanup plan in small commits.

Constraints:
- keep behavior the same unless clearly improving robustness
- make one pragmatic commit per concern
- run syntax checks after each commit-sized change
- show the diff summary before each commit
- work from TODOs/bash-cleanup-session.md and check items off as you go

Commits to make:
1. bash: harden startup and clean up warnings
2. bash: make prompt command composable
3. bash: make kroll argument handling safer
4. bash: improve macos command detection
5. bash: tidy helper functions and path setup

Also run final validation after all commits.
```
