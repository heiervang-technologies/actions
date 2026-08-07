# CLAUDE.md — actions

Shared GitHub Actions composite actions and reusable workflows.

## Validation & Linting

```bash
# Lint workflows using actionlint
actionlint

# Lint composite actions using shellcheck
bash .github/scripts/lint-actions.sh
```

CI runs `actionlint` and `.github/scripts/lint-actions.sh` on every push and pull request.

## Structure

```
.github/
  actions/      composite actions (docs-drift)
  workflows/    reusable workflows (ci.yml, rust-ci.yml, unleash.yml)
  scripts/      helper scripts for linting
```

## Conventions

- **No Co-Authored-By: Claude on commits.** Hook at `.git/hooks/commit-msg` strips them automatically.
- **Squash-merge PRs with `--admin`** (only merge strategy in use):
  `gh pr merge <n> --squash --admin --delete-branch`. This repo is in the
  org ruleset `gate-critical-branches`, which requires one approving review
  on `main`. All agents share the `marksverdhei` identity and GitHub blocks
  self-approval, so **that approval can never be obtained** and a plain
  `gh pr merge --squash` fails with `the base branch policy prohibits the
  merge` (verified 2026-08-08 on director#732, same ruleset). Every merge
  here is an admin bypass by construction, not by choice — so `--admin` is
  not evidence of a corner cut, and the assurance lives in the PR's
  `RECEIPT:` comment instead. No org-admin means you cannot merge here:
  escalate rather than improvise.
- Reusable workflows and actions must be pinned to stable major release tags (e.g. `@v1`).
- Pin third-party action dependencies in workflows to full SHAs for security, or major releases where trusted.
- All workflows must pass `actionlint` linting before merge.
- No literal secrets in workflow files.
