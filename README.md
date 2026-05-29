```
                  __  _                 
   ____ ______/ /_(_)___  ____  _____
  / __ `/ ___/ __/ / __ \/ __ \/ ___/
 / /_/ / /__/ /_/ / /_/ / / / (__  ) 
 \__,_/\___/\__/_/\____/_/ /_/____/  
```

Shared GitHub Actions composite actions and reusable workflows for [Heiervang Technologies](https://github.com/heiervang-technologies).

This repo is public so it can be consumed from both public and private repos in the org. (GitHub blocks public repos from calling reusable workflows in private repos — that's why this one is public.)

## Layout

```
.github/
  actions/      composite actions (uses: heiervang-technologies/actions/.github/actions/<name>@main)
  workflows/    reusable workflows (uses: heiervang-technologies/actions/.github/workflows/<name>.yml@main)
```

Pin consumers to a tag or SHA in production, not `@main`.

## Available actions

| Action | Purpose |
|---|---|
| [`docs-drift`](.github/actions/docs-drift/) | Warn when a PR changes code paths without touching docs paths. |

## Consuming an action

Composite action:

```yaml
- uses: heiervang-technologies/actions/.github/actions/<name>@v1
  with:
    <input>: <value>
```

Reusable workflow:

```yaml
jobs:
  build:
    uses: heiervang-technologies/actions/.github/workflows/<name>.yml@v1
    with:
      <input>: <value>
    secrets: inherit
```

## Unleash — autonomous agent (`unleash.yml`)

Runs [Claude Code](https://github.com/anthropics/claude-code) as a fully autonomous agent inside the runner: it installs the CLI, launches it in a tmux session (PTY), and runs headless with `--dangerously-skip-permissions`. With no `task` it reviews the triggering PR and posts the review via `gh`; with a `task` it does whatever you tell it.

It's a reusable workflow — **the caller picks the trigger** (PR, `@claude` comment, label, schedule, manual) and passes inputs.

### Inputs

| Input | Default | Description |
|---|---|---|
| `task` | `""` | What the agent should do. Empty → review the triggering PR. |
| `model` | `sonnet` | Model alias or full ID (`sonnet`, `opus`, `haiku`, `claude-sonnet-4-6`, …). |
| `timeout_minutes` | `20` | Hard wall-clock cap on the run. |
| `runs_on` | `ubuntu-latest` | Runner label. |
| `claude_args` | `""` | Extra flags passed verbatim to `claude`, e.g. `--max-turns 30 --allowedTools Bash,Read,Edit`. |

Secret `anthropic_api_key` is **required**.

### Auto-review every PR

```yaml
# .github/workflows/review.yml — in the consuming repo
name: Claude review
on:
  pull_request:
    types: [opened, synchronize]
jobs:
  review:
    uses: heiervang-technologies/actions/.github/workflows/unleash.yml@v1
    permissions:
      contents: read
      pull-requests: write
    secrets:
      anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### On-demand via `@claude` comment

```yaml
on:
  issue_comment:
    types: [created]
jobs:
  agent:
    if: ${{ github.event.issue.pull_request && contains(github.event.comment.body, '@claude') }}
    uses: heiervang-technologies/actions/.github/workflows/unleash.yml@v1
    with:
      task: ${{ github.event.comment.body }}
    secrets:
      anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### Custom / scheduled task

```yaml
on:
  workflow_dispatch:
    inputs:
      task: { type: string }
jobs:
  run:
    uses: heiervang-technologies/actions/.github/workflows/unleash.yml@v1
    with:
      task: ${{ inputs.task }}
      model: opus
      timeout_minutes: 45
    secrets:
      anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
```

> ⚠️ **This gives an LLM broad permissions in CI.** PR/comment contents are untrusted and can attempt prompt injection. Wire it only to events you trust (avoid `pull_request_target` and untrusted forks), grant the calling job the *least* `permissions` the task needs, and pin to a tag or SHA — not `@main`. `issue_comment` runs on the default branch and doesn't check out the PR head; the agent still reads the diff via `gh pr diff`, but add a checkout of the PR ref if it needs the changed files on disk.

## Versioning

- Tag stable releases as `v1`, `v2`, etc.
- Move the major tag forward only for breaking changes.
- Consumers pin `@v1` for the major track; `@main` is acceptable for internal repos that want bleeding-edge.

## Contributing

- Feature branches + PRs against `main`.
- One action or workflow per PR.
- Include a usage snippet in the action's own `README.md` (under `.github/actions/<name>/README.md`).
