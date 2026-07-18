# Bash Interview Cheat Sheet

**Package:** 02 — Bash Scripting Interview Preparation

---

## Script Skeleton

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

usage() { printf 'Usage: %s ...\n' "${0##*/}"; }

main() {
    # validate → work → verify
}

main "$@"
```

## Execution

```bash
bash script.sh       # Bash reads the file
./script.sh          # Kernel uses shebang; execute bit required
source script.sh     # Current shell; changes can persist
bash -n script.sh    # Syntax check
bash -x script.sh    # Execution trace
```

## Quoting

```bash
"$variable"           # Expand safely
'$variable'           # Literal text
"${array[@]}"         # Preserve separate elements
command -- "$value"   # End options where supported
```

## Parameter Expansion

```bash
${var:-default}
${var:=default}
${var:?required}
${var:+alternate}
${var##*/}           # basename-like
${var%/*}            # dirname-like
${#var}              # length
```

## Special Parameters

| Parameter | Meaning |
|---|---|
| `$0` | Script name |
| `$1` | First argument |
| `$#` | Argument count |
| `"$@"` | All arguments, preserved separately |
| `$?` | Previous status |
| `$$` | Current shell PID |
| `$!` | Last background PID |

## Streams

```bash
command >out.log
command >>out.log
command 2>error.log
command >all.log 2>&1
printf 'error\n' >&2
```

```text
stdin=0 stdout=1 stderr=2
```

## Tests

```bash
[[ -f "$file" ]]
[[ -d "$directory" ]]
[[ -n "$value" ]]
[[ -z "$value" ]]
[[ "$name" == *.log ]]
[[ "$number" -gt 10 ]]
((number >= 10))
```

## Decisions

```bash
if command; then
    success
elif other_condition; then
    alternate
else
    failure
fi

case "$value" in
    start) start_action ;;
    stop) stop_action ;;
    *) usage >&2; exit 2 ;;
esac
```

## Loops

```bash
for item in "${array[@]}"; do
    printf '%s\n' "$item"
done

while IFS= read -r line || [[ -n "$line" ]]; do
    printf '%s\n' "$line"
done < file

while ((attempt <= 3)); do
    ((attempt += 1))
done
```

## Functions

```bash
check_file() {
    local file="${1:?file required}"
    [[ -f "$file" ]]
}
```

```text
stdout = data
stderr = diagnostics
return = numeric status 0–255
```

## Arrays

```bash
items=(one "two words" three)
items+=(four)
printf '%s\n' "${items[@]}"

declare -A ports=([ssh]=22 [https]=443)
printf '%s\n' "${ports[ssh]}"
```

## `getopts`

```bash
while getopts ':t:o:h' option; do
    case "$option" in
        t) threshold="$OPTARG" ;;
        o) output="$OPTARG" ;;
        h) usage; exit 0 ;;
        :) exit 2 ;;
        \?) exit 2 ;;
    esac
done
shift "$((OPTIND - 1))"
```

## Defensive Settings

```bash
set -e              # contextual exit on failure
set -u              # unset variable error
set -o pipefail     # pipeline propagates failures
set -E              # ERR trap inheritance
```

Expected failures still require explicit handling.

## Cleanup

```bash
temporary_directory="$(mktemp -d)"
cleanup() {
    local status=$?
    rm -rf -- "$temporary_directory"
    exit "$status"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
```

Validate every destructive target.

## Idempotency

```bash
if ! grep -Fqx -- "$entry" "$file"; then
    printf '%s\n' "$entry" >> "$file"
fi
```

```text
Read current state → compare → change only if needed → validate
```

## Debugging Order

```text
Exact error/status
Interpreter and permissions
Line endings
bash -n
ShellCheck
Small reproduction
Targeted bash -x
Normal + boundary + failure + repeated tests
```

## Common Problems

| Symptom | Check |
|---|---|
| Permission denied | Execute bit, directory traversal, `noexec` |
| `bash\r` interpreter | CRLF line endings |
| Works in Bash, fails in sh | Bash-specific syntax/wrong interpreter |
| Words split | Missing quotes |
| Pipeline falsely succeeds | `pipefail` |
| Counter exits with `set -e` | `((count++))` status |
| Variable lost after loop | Pipeline subshell |
| Works manually, not cron | PATH, user, cwd, environment, credentials |
| Duplicate configuration | Not idempotent |
| Secret in logs | Args, trace, environment, permissions |

## Exit Codes

```text
0 success
1 runtime failure
2 invalid usage
3 warning/defined condition
126 cannot execute
127 command not found
130 interrupted by Ctrl+C
```

Document application-specific codes.

