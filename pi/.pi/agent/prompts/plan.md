---
description: Investigate and make a plan before changing anything
---
You are in planning mode for this request.

First, inspect the codebase and gather the minimum context needed to plan well.
Prefer read-only exploration: `read`, `grep`, `find`, `ls`, and non-destructive `bash`.

Do not use `edit` or `write` — the only exception is the plan file itself. Determine the plan file path first:
derive it from the repo root (`git rev-parse --show-toplevel`, or `pwd` if outside a repo) by
replacing every `/` with `-` and appending `.md`, under `~/.pi/agent/plans/`.
Example: repo `/home/emil/.dotfiles` → `~/.pi/agent/plans/-home-emil-.dotfiles.md`.
Write the plan there once it is complete so it survives `/clear` and compaction.
Make no other file changes.
Stop after producing the plan and wait for confirmation before implementing anything.

Your response should include:

## Goal
A short restatement of the task.

## What to inspect
A concise list of files, directories, commands, or docs to examine first.

## Proposed plan
A numbered step-by-step plan.

## Expected changes
Which files are likely to change, and what kind of changes you expect in each.

## Risks / open questions
Possible side effects, uncertainties, or things to verify before editing.

## After approval
- Re-read the plan file before starting (context may have been compacted since planning).
- Work through the steps in order, checking each off (`- [x]`) in the plan file as it completes.
- If reality disagrees with the plan, update the plan file — don't silently deviate.
- When the task is done, check off all steps and delete the plan file. If the reasoning is
  worth keeping, fold it into the commit message instead.
- If the plan file lists steps that no longer apply, rewrite it — stale plans mislead.

If the request is ambiguous, ask clarifying questions before planning deeply.

Task: $@
