# Bash Scripting Hands-on Labs

**Package:** 02 — Bash Scripting Interview Preparation  
**Labs:** 12

Use a disposable Linux, WSL, or cloud practice environment. Store every lab in its own directory and preserve test evidence.

---

## Lab Workflow

For every script:

```bash
bash -n script.sh
bash script.sh
printf 'exit=%d\n' "$?"
```

When available:

```bash
shellcheck script.sh
```

Test valid, invalid, empty, repeated, and failure inputs.

---

# Lab 1 — Interpreter and Execution

## Objective

Compare executing, invoking with Bash, and sourcing.

Create `environment-demo.sh`:

```bash
#!/usr/bin/env bash
DEMO_VALUE="created-inside-script"
cd /tmp || exit 1
printf 'shell=%s pid=%s directory=%s\n' "$BASH" "$$" "$PWD"
```

Test:

```bash
bash environment-demo.sh
chmod +x environment-demo.sh
./environment-demo.sh
source environment-demo.sh
```

Document which variable and directory changes persist after each method.

---

# Lab 2 — Variables, Quoting, and Filenames

## Objective

Demonstrate why expansions must be quoted.

```bash
mkdir -p /tmp/bash-quoting-lab
touch "/tmp/bash-quoting-lab/Monthly Report.txt"
touch "/tmp/bash-quoting-lab/--warning"
```

Write a script that accepts a filename and prints its size safely:

```bash
#!/usr/bin/env bash
set -u

file="${1:?Usage: $0 FILE}"
if [[ ! -f "$file" ]]; then
    printf 'Not a file: %s\n' "$file" >&2
    exit 1
fi

stat --printf='%n %s bytes\n' -- "$file"
```

Test spaces, wildcard characters, and a leading dash.

---

# Lab 3 — Input and Positional Parameters

## Objective

Create a script that accepts `USERNAME ROLE ENVIRONMENT`.

Requirements:

- Require exactly three arguments.
- Reject empty values.
- Allow environments `dev`, `test`, and `prod` only.
- Print a clear summary.
- Return 2 for invalid usage.

Test:

```bash
bash user-input.sh alice admin dev
bash user-input.sh "Alice Smith" developer test
bash user-input.sh alice admin invalid
bash user-input.sh alice
```

---

# Lab 4 — Exit Status and Decisions

## Objective

Build a service-status checker.

```bash
#!/usr/bin/env bash
service_name="${1:?Usage: $0 SERVICE}"

if systemctl is-active --quiet "$service_name"; then
    printf '%s is active\n' "$service_name"
    exit 0
else
    printf '%s is not active\n' "$service_name" >&2
    exit 3
fi
```

Enhance it to distinguish unknown, inactive, and active states without automatically restarting anything.

---

# Lab 5 — Loops and Safe File Processing

## Objective

Process `.log` files including names with spaces.

```bash
while IFS= read -r -d '' file; do
    size="$(stat -c '%s' -- "$file")"
    printf '%s\t%s\n' "$size" "$file"
done < <(find "${1:-.}" -type f -name '*.log' -print0)
```

Add:

- A processed-file counter
- A total-byte counter
- `continue` for empty files
- Maximum-file option that uses `break`

---

# Lab 6 — Reusable Functions

## Objective

Create `lib/common.sh` containing:

```bash
log_info()
log_warning()
log_error()
require_command()
is_positive_integer()
```

Source it from a separate script. Keep data output on stdout and error logs on stderr. Test function return statuses independently.

---

# Lab 7 — Indexed and Associative Arrays

## Objective

Map services to expected ports.

```bash
declare -A expected_ports=(
    [ssh]=22
    [http]=80
    [https]=443
)
```

Print a table, look up a requested key, reject an unknown key, and iterate safely over all keys.

---

# Lab 8 — `getopts` CLI

## Objective

Create a disk-check tool with:

```text
-p PATH
-t PERCENT
-q
-h
```

Requirements:

- `-p` defaults to `/`.
- Threshold defaults to 80.
- Validate path and numeric range.
- Quiet mode prints only errors.
- Return 3 when the threshold is exceeded.

---

# Lab 9 — Temporary Files and Traps

## Objective

Create a report in a secure temporary directory and guarantee cleanup.

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

Add a deliberate failure and a Ctrl+C test. Verify the directory is removed and the original exit status is preserved.

---

# Lab 10 — Idempotent Configuration

## Objective

Add a configuration line exactly once to a practice file.

```bash
config_file="/tmp/bash-idempotency.conf"
desired_line="feature_enabled=true"

touch "$config_file"
if ! grep -Fqx -- "$desired_line" "$config_file"; then
    printf '%s\n' "$desired_line" >> "$config_file"
fi
```

Run five times and prove there is exactly one matching line. Add validation and a message that distinguishes changed from already-correct state.

---

# Lab 11 — Cron Environment Failure

## Objective

Diagnose a script that works interactively but fails under cron.

Create a script that initially relies on:

- Relative paths
- An interactive PATH
- An environment variable from `.bashrc`

Schedule it, capture output and errors, then correct it using absolute paths, explicit environment, working directory, and logging.

Remove the practice cron entry after validation.

---

# Lab 12 — Linux Health Report Capstone

## Objective

Test and explain `Scripts/linux-health-report.sh`.

### Validation

```bash
bash -n Scripts/linux-health-report.sh
Scripts/linux-health-report.sh -h
Scripts/linux-health-report.sh -d 100 -m 100 -r 100
Scripts/linux-health-report.sh -d invalid
Scripts/linux-health-report.sh -d 1
Scripts/linux-health-report.sh -o ./health.log
```

### Failure injection

- Invalid threshold
- Missing log directory
- Inactive service
- Read-only output path
- Very low warning threshold
- Quiet mode without a log file

### Required project explanation

Explain purpose, option parsing, validation, functions, data collection, logging, exit codes, failure testing, idempotency, security, and production improvements.

---

# Lab Tracker

| Lab | Script Complete | Failure Tests | Explanation Ready |
|---:|---|---|---|
| 1 | ☐ | ☐ | ☐ |
| 2 | ☐ | ☐ | ☐ |
| 3 | ☐ | ☐ | ☐ |
| 4 | ☐ | ☐ | ☐ |
| 5 | ☐ | ☐ | ☐ |
| 6 | ☐ | ☐ | ☐ |
| 7 | ☐ | ☐ | ☐ |
| 8 | ☐ | ☐ | ☐ |
| 9 | ☐ | ☐ | ☐ |
| 10 | ☐ | ☐ | ☐ |
| 11 | ☐ | ☐ | ☐ |
| 12 | ☐ | ☐ | ☐ |

