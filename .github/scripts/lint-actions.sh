#!/usr/bin/env bash
# Shellcheck the bash `run:` steps embedded in composite action.yml files.
#
# actionlint lints workflows (and shellchecks their run blocks) but does NOT
# understand composite actions, so we extract their bash steps here and run
# them through shellcheck directly. Requires python3 with PyYAML and shellcheck.
set -euo pipefail

status=0
mapfile -t actions < <(find .github/actions -name action.yml -type f | sort)

if [ "${#actions[@]}" -eq 0 ]; then
  echo "No composite actions found."
  exit 0
fi

for action in "${actions[@]}"; do
  script="$(mktemp)"
  python3 - "$action" > "$script" <<'PY'
import sys, yaml
doc = yaml.safe_load(open(sys.argv[1])) or {}
steps = (doc.get("runs") or {}).get("steps") or []
print("#!/usr/bin/env bash")
for s in steps:
    if isinstance(s, dict) and str(s.get("shell", "")).startswith("bash") and "run" in s:
        print()
        print(s["run"])
PY
  # First line is the shebang; only lint when there's actual script below it.
  if [ "$(grep -cve '^[[:space:]]*$' "$script")" -gt 1 ]; then
    echo "::group::shellcheck ${action}"
    # SC2154: composite scripts read inputs via each step's `env:` block, which
    # isn't visible to shellcheck on the extracted snippet.
    shellcheck -S warning -e SC2154 "$script" || status=1
    echo "::endgroup::"
  else
    echo "No bash run steps in ${action}; skipping."
  fi
  rm -f "$script"
done

exit "$status"
