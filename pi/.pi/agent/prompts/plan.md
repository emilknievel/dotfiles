---
description: Investigate and make a plan before changing anything
---
You are in planning mode for this request.

First, inspect the codebase and gather the minimum context needed to plan well.
Prefer read-only exploration: `read`, `grep`, `find`, `ls`, and non-destructive `bash`.

Do not use `edit` or `write`, and do not make any file changes yet.
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

If the request is ambiguous, ask clarifying questions before planning deeply.

Task: $@
