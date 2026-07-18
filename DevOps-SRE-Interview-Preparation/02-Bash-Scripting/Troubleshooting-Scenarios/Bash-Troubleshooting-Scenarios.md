# Bash Troubleshooting Scenarios

**Package:** 02 — Bash Scripting Interview Preparation  
**Scenarios:** 15

---

## Debugging Framework

```text
1. Capture the exact command, input, output, error, and status.
2. Confirm interpreter, permissions, path, and line endings.
3. Run bash -n and ShellCheck when available.
4. Reproduce with the smallest safe input.
5. Trace only the failing section.
6. Correct the root cause.
7. Test normal, boundary, failure, repeated, and interrupted runs.
```

---

# Scenario 1 — Permission Denied

## Symptom

```text
bash: ./backup.sh: Permission denied
```

## Isolation

```bash
ls -l backup.sh
file backup.sh
namei -l ./backup.sh
mount | grep ' relevant-mount '
```

The execute bit may be missing, a parent directory may lack traversal permission, or the filesystem may be mounted `noexec`. `bash backup.sh` does not require the script's execute bit because Bash reads it as input.

---

# Scenario 2 — Bad Interpreter

## Symptom

```text
/usr/bin/env: 'bash\r': No such file or directory
```

## Cause

Windows CRLF line endings add `\r` to the interpreter name.

```bash
file script.sh
sed -n '1l' script.sh
dos2unix script.sh
```

Configure Git line-ending behavior appropriately and validate scripts in CI.

---

# Scenario 3 — Wrong Interpreter

## Symptom

A script using arrays or `[[ ]]` fails when invoked with `sh script.sh`.

## Explanation

`sh` may be another shell such as dash and does not guarantee Bash features. Execute with the documented Bash interpreter and correct the caller.

---

# Scenario 4 — Unquoted Variable Breaks Filename

## Fault

```bash
file="Monthly Report.txt"
cp $file /backup
```

## Fix

```bash
cp -- "$file" /backup
```

Quoting prevents word splitting and pathname expansion. `--` protects supported commands from leading-dash option injection.

---

# Scenario 5 — Empty Variable Creates Dangerous Target

## Fault

```bash
rm -rf "$work_directory"/*
```

If the variable is empty or unexpected, the target can broaden dangerously.

## Defensive approach

- Require the variable with `${work_directory:?}`.
- Compare it with an expected base path.
- Resolve and validate the exact target.
- Refuse `/`, `$HOME`, or a broad project root.
- Prefer a dedicated temporary directory created by `mktemp`.

---

# Scenario 6 — Pipeline Hides Failure

## Fault

```bash
generate_report | tee report.txt
```

If generation fails but `tee` succeeds, the pipeline may report success.

## Fix

```bash
set -o pipefail
if ! generate_report | tee report.txt; then
    printf 'Report generation failed\n' >&2
    exit 1
fi
```

---

# Scenario 7 — `set -e` Exits on Counter Increment

## Fault

```bash
set -e
count=0
((count++))
```

The arithmetic command returns status 1 when the expression evaluates to zero.

## Fix

```bash
((count += 1))
```

Understand command statuses instead of treating strict mode as automatic error handling.

---

# Scenario 8 — Expected Command Failure Terminates Script

## Symptom

With `set -e`, a command that is allowed to return “not found” stops the workflow.

## Fix

Place expected failure in an explicit conditional:

```bash
if grep -Fqx -- "$entry" "$file"; then
    printf 'Already present\n'
else
    printf '%s\n' "$entry" >> "$file"
fi
```

---

# Scenario 9 — Cron Failure

## Symptom

The script succeeds manually but produces no scheduled output.

## Checks

- Cron user and permissions
- Absolute script and command paths
- Working directory
- Minimal PATH
- Environment variables and credentials
- Executable permission
- Captured stdout and stderr
- Cron or journal logs

Do not depend on interactive shell startup files.

---

# Scenario 10 — Function Output Is Corrupted

## Fault

```bash
get_value() {
    echo "INFO: calculating"
    echo "42"
}
value="$(get_value)"
```

`value` contains both lines.

## Fix

Write logs to stderr and data to stdout:

```bash
printf 'INFO: calculating\n' >&2
printf '42\n'
```

---

# Scenario 11 — Variable Lost After Loop

## Fault

```bash
count=0
printf '%s\n' a b | while read -r item; do
    ((count += 1))
done
```

The loop may execute in a pipeline subshell.

## Fix

```bash
while read -r item; do
    ((count += 1))
done < <(printf '%s\n' a b)
```

---

# Scenario 12 — Temporary Files Remain

## Cause

The script exits or receives a signal before manual cleanup.

## Fix

Create resources with `mktemp`, store the exact path, and install an EXIT cleanup trap immediately after successful creation. Preserve the original exit status.

---

# Scenario 13 — Duplicate Configuration on Every Run

## Fault

```bash
printf '%s\n' "$entry" >> "$config_file"
```

## Fix

Inspect current state and change only when required:

```bash
grep -Fqx -- "$entry" "$config_file" || printf '%s\n' "$entry" >> "$config_file"
```

Validate repeated execution and concurrency behavior.

---

# Scenario 14 — Secret Appears in Logs

## Causes

- Token passed as a command-line argument
- `set -x` enabled
- Variable printed during debugging
- Environment dump captured
- World-readable output file

## Response

Stop further exposure, rotate the credential, restrict or remove exposed data according to policy, correct the input mechanism, disable sensitive tracing, and add tests that prevent secret logging.

---

# Scenario 15 — Script Reports Failure but Exits 0

## Fault

```bash
if ! deploy; then
    printf 'Deployment failed\n' >&2
fi
printf 'Done\n'
```

The final successful `printf` makes the script return 0.

## Fix

Return or exit with a documented nonzero status on failure, and test the status from the caller.

---

# Scenario Scorecard

| Area | Points |
|---|---:|
| Exact symptom and reproduction | 2 |
| Interpreter/environment checks | 2 |
| Root-cause explanation | 2 |
| Safe correction | 2 |
| Failure and regression tests | 2 |

Maximum per scenario: **10 points**.

