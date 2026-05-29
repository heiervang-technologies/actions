# docs-drift

Composite action that warns when a pull request changes code paths without touching docs paths. Posts a GitHub Actions `::warning::` annotation; never fails the job.

Originally inlined in `director/.github/workflows/ci.yml`; lifted here so every repo with a docs/ tree can opt in.

## Usage

```yaml
jobs:
  docs-drift:
    name: Docs drift check
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: heiervang-technologies/actions/.github/actions/docs-drift@v1
        with:
          code-paths: '^(bin/|crates/)'
```

## Inputs

| Input | Required | Default | Notes |
|---|---|---|---|
| `code-paths` | yes | — | Extended regex (`grep -E`) matching code paths to monitor. |
| `docs-paths` | no | `^docs/` | Extended regex matching docs paths. Any match counts as a corresponding docs update. |
| `base-ref` | no | `${{ github.base_ref }}` | Base ref to diff against. Override when not running on `pull_request`. |

## Behaviour

The action runs `git diff --name-only origin/<base-ref>...HEAD` and inspects the changed paths:

- If at least one changed file matches `code-paths` and **no** changed file matches `docs-paths`, the action emits a `::warning::` and prints the list of changed code files.
- Otherwise, it prints `Docs drift check passed.` and exits 0.

The action never fails the job. The signal is a warning annotation on the PR; reviewers decide whether to act on it.

## Checkout requirements

The action needs the base ref available in the local repo to compute the diff. Either:

- Check out with `fetch-depth: 0` (recommended, simplest), **or**
- Pre-fetch the base ref before invoking the action.

If the base ref is missing, the action attempts one `git fetch --depth=1 origin <base-ref>` as a fallback before erroring.

## Examples

### Director repo

```yaml
- uses: heiervang-technologies/actions/.github/actions/docs-drift@v1
  with:
    code-paths: '^(bin/|crates/)'
```

### Repo with a `src/` layout and `documentation/` tree

```yaml
- uses: heiervang-technologies/actions/.github/actions/docs-drift@v1
  with:
    code-paths: '^src/'
    docs-paths: '^documentation/'
```

### Comparing against `main` from a push event

```yaml
- uses: heiervang-technologies/actions/.github/actions/docs-drift@v1
  with:
    code-paths: '^lib/'
    base-ref: 'main'
```
