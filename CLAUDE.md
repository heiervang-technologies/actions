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
- **Squash-merge PRs** (only merge strategy in use).
- Reusable workflows and actions must be pinned to stable major release tags (e.g. `@v1`).
- Pin third-party action dependencies in workflows to full SHAs for security, or major releases where trusted.
- All workflows must pass `actionlint` linting before merge.
- No literal secrets in workflow files.
