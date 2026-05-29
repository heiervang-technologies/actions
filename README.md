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

## Versioning

- Tag stable releases as `v1`, `v2`, etc.
- Move the major tag forward only for breaking changes.
- Consumers pin `@v1` for the major track; `@main` is acceptable for internal repos that want bleeding-edge.

## Contributing

- Feature branches + PRs against `main`.
- One action or workflow per PR.
- Include a usage snippet in the action's own `README.md` (under `.github/actions/<name>/README.md`).
