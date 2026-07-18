# Bash Scripting Foundations

**Package:** 02 — Bash Scripting Interview Preparation  
**Level:** Foundation to Intermediate

---

## 1. What Is Bash Scripting?

Bash is a command language and shell. A Bash script is a text file containing commands and control logic executed by a Bash interpreter.

### Why Bash is used

- Automate repeated Linux administration
- Connect existing commands into workflows
- Validate servers and deployments
- Process files and command output
- Schedule backups, reports, and cleanup
- Support CI/CD and cloud operations
- Create lightweight operational tools

### When another language may be better

Bash is strong for command orchestration. Python or another language may be better for complex data structures, large applications, extensive API logic, portability beyond Unix-like systems, or sophisticated testing and error models.

---

## 2. Script Execution

Create `hello.sh`:

```bash
#!/usr/bin/env bash
printf 'Hello from Bash\n'
```

Execution methods:

```bash
bash hello.sh
chmod +x hello.sh
./hello.sh
```

### Shebang

```bash
#!/usr/bin/env bash
```

The shebang tells the kernel which interpreter to use when executing the file directly.

- `#!/bin/bash` uses a fixed path.
- `#!/usr/bin/env bash` searches for Bash through `PATH`.
- Choose according to environment and organizational standards.

### Source versus execute

```bash
./script.sh
source script.sh
. script.sh
```

- Executing normally starts a separate shell process.
- Sourcing runs commands in the current shell, so variable and directory changes can persist.
- Source only trusted content.

### Useful checks

```bash
bash --version
command -v bash
bash -n script.sh
bash -x script.sh
```

---

## 3. Variables and Environment

```bash
name="Khalid"
role="Linux Administrator"
printf 'Name: %s\nRole: %s\n' "$name" "$role"
```

Do not place spaces around `=` in an assignment.

```bash
# Correct
server="web01"

# Incorrect
server = "web01"
```

### Environment variables

```bash
export APP_ENV="production"
printenv APP_ENV
```

An exported variable is available to child processes. A normal shell variable is not automatically exported.

### Read-only variables

```bash
readonly CONFIG_FILE="/etc/myapp.conf"
```

### Unset variables

```bash
unset temporary_value
```

---

## 4. Quoting and Expansion

Quoting is one of the most important Bash interview topics.

### Double quotes

Variable and command substitutions occur, while word splitting and pathname expansion are prevented.

```bash
name="Muhammad Khalid Khan"
printf '%s\n' "$name"
```

### Single quotes

Content is treated literally.

```bash
printf '%s\n' '$HOME is not expanded here'
```

### Backslash

Escapes one character in many contexts.

```bash
printf "Price: \$20\n"
```

### Why quote variables?

```bash
file="Monthly Report.txt"
rm -- "$file"
```

Without quotes, the expansion can become multiple arguments. A leading dash in a filename can be interpreted as an option; `--` marks the end of options for commands that support it.

### Safe default values

```bash
environment="${APP_ENV:-development}"
```

| Expansion | Meaning |
|---|---|
| `${var:-default}` | Use default if unset or empty |
| `${var:=default}` | Assign default if unset or empty |
| `${var:?message}` | Exit with message if unset or empty |
| `${var:+alternate}` | Use alternate if set and non-empty |

---

## 5. Command and Arithmetic Substitution

### Command substitution

```bash
current_date="$(date +%F)"
kernel="$(uname -r)"
```

Command substitution captures stdout and removes trailing newline characters.

Always check whether the command can fail:

```bash
if hostname_value="$(hostname)"; then
    printf 'Hostname: %s\n' "$hostname_value"
else
    printf 'Unable to determine hostname\n' >&2
    exit 1
fi
```

### Arithmetic expansion

```bash
count=5
next=$((count + 1))
((count++))
```

Be careful using arithmetic commands with `set -e`: `((count++))` returns status 1 when the expression evaluates to zero.

---

## 6. Standard Streams and Redirection

| Stream | File descriptor | Purpose |
|---|---:|---|
| stdin | 0 | Input |
| stdout | 1 | Normal output |
| stderr | 2 | Error output |

```bash
command > output.log
command >> output.log
command 2> error.log
command > all.log 2>&1
command </path/to/input.txt
```

Send a message to stderr:

```bash
printf 'Error: configuration missing\n' >&2
```

Discard output:

```bash
command >/dev/null 2>&1
```

Use suppression only when output is genuinely unnecessary. Operational scripts should normally preserve useful errors.

### Pipes

```bash
journalctl -u nginx | tail -n 20
```

A pipeline connects stdout from one command to stdin of the next. By default, its exit status is usually the last command's status. `set -o pipefail` makes the pipeline fail if any component fails.

---

## 7. Reading User Input

```bash
read -r -p "Enter server name: " server
printf 'Server: %s\n' "$server"
```

- `-r` prevents backslash interpretation.
- Validate input before using it.
- Do not request secrets visibly.

```bash
read -r -s -p "Enter token: " token
printf '\n'
```

Avoid storing secrets longer than necessary, and do not print them.

---

## 8. Positional Parameters

```bash
#!/usr/bin/env bash

printf 'Script: %s\n' "$0"
printf 'First argument: %s\n' "${1:-}"
printf 'Argument count: %s\n' "$#"
```

| Parameter | Meaning |
|---|---|
| `$0` | Script or shell name |
| `$1`…`$9` | Positional arguments |
| `$#` | Number of arguments |
| `$@` | All arguments as separate values when quoted |
| `$*` | All arguments combined according to first IFS character when quoted |
| `$?` | Previous command exit status |
| `$$` | Current shell PID |
| `$!` | PID of most recent background command |

### Prefer quoted `$@`

```bash
for argument in "$@"; do
    printf 'Argument: %s\n' "$argument"
done
```

### Shift

```bash
while (($# > 0)); do
    printf '%s\n' "$1"
    shift
done
```

---

## 9. Exit Status

Linux commands normally return:

- `0` for success
- Nonzero for failure or another documented condition

```bash
mkdir -p /tmp/interview-demo
status=$?
printf 'Exit status: %s\n' "$status"
```

Prefer direct testing:

```bash
if mkdir -p /tmp/interview-demo; then
    printf 'Directory ready\n'
else
    printf 'Unable to create directory\n' >&2
    exit 1
fi
```

### Logical lists

```bash
command1 && command2
command1 || recovery_command
```

Use compact logical lists for simple operations. Use `if` when the workflow needs clear logging, multiple actions, or nuanced error handling.

---

## 10. Tests and Conditional Decisions

### `[ ]` and `[[ ]]`

```bash
if [[ -f "$config_file" ]]; then
    printf 'Configuration exists\n'
fi
```

`[[ ]]` is a Bash conditional construct and avoids many word-splitting and globbing problems. `[ ]` is broadly portable but requires careful quoting.

### File tests

| Test | Meaning |
|---|---|
| `-e` | Path exists |
| `-f` | Regular file |
| `-d` | Directory |
| `-r` | Readable |
| `-w` | Writable |
| `-x` | Executable |
| `-s` | File exists and is non-empty |

### String tests

```bash
[[ -n "$value" ]]
[[ -z "$value" ]]
[[ "$environment" == "production" ]]
[[ "$filename" == *.log ]]
```

### Numeric tests

```bash
[[ "$count" -eq 10 ]]
[[ "$count" -gt 5 ]]
((count >= 5))
```

### `if/elif/else`

```bash
if ((usage >= 90)); then
    printf 'Critical\n'
elif ((usage >= 80)); then
    printf 'Warning\n'
else
    printf 'Healthy\n'
fi
```

### `case`

```bash
case "${1:-}" in
    start)  start_service ;;
    stop)   stop_service ;;
    status) show_status ;;
    *)
        printf 'Usage: %s {start|stop|status}\n' "$0" >&2
        exit 2
        ;;
esac
```

---

## 11. Loops

### `for`

```bash
for service in nginx sshd docker; do
    systemctl is-active --quiet "$service" \
        && printf '%s active\n' "$service" \
        || printf '%s inactive\n' "$service"
done
```

### Reading a file safely

```bash
while IFS= read -r line || [[ -n "$line" ]]; do
    printf '%s\n' "$line"
done < servers.txt
```

### `while`

```bash
attempt=1
while ((attempt <= 3)); do
    printf 'Attempt %d\n' "$attempt"
    ((attempt += 1))
done
```

### `until`

```bash
until curl -fsS http://localhost:8080/health >/dev/null; do
    sleep 2
done
```

Add a timeout or maximum attempt count to prevent infinite waiting.

### `break` and `continue`

```bash
for file in *.log; do
    [[ -e "$file" ]] || continue
    [[ -s "$file" ]] || continue
    process_file "$file" || break
done
```

### Filenames and parsing

Avoid parsing `ls`. Use globs, `find` with safe delimiters, or arrays.

```bash
while IFS= read -r -d '' file; do
    printf '%s\n' "$file"
done < <(find /var/log -type f -name '*.log' -print0)
```

---

## 12. Functions

```bash
log_info() {
    local message="$1"
    printf '[INFO] %s\n' "$message"
}
```

### Parameters

Functions use positional parameters independently.

```bash
check_file() {
    local path="${1:?path required}"
    [[ -f "$path" ]]
}
```

### Output versus return status

```bash
get_hostname() {
    hostname
}

if host="$(get_hostname)"; then
    printf 'Host: %s\n' "$host"
fi
```

- `return` supplies a numeric status from 0 to 255.
- stdout supplies data.
- Keep diagnostic logging on stderr if stdout is used as function output.

### Local variables

```bash
calculate_usage() {
    local mount_point="$1"
    local usage
    usage="$(df -P "$mount_point" | awk 'NR==2 {gsub(/%/, "", $5); print $5}')" || return 1
    printf '%s\n' "$usage"
}
```

---

## 13. Starter Script Design

```bash
#!/usr/bin/env bash

set -u

readonly SCRIPT_NAME="${0##*/}"

usage() {
    printf 'Usage: %s DIRECTORY\n' "$SCRIPT_NAME"
}

main() {
    if (($# != 1)); then
        usage >&2
        return 2
    fi

    local directory="$1"
    if [[ ! -d "$directory" ]]; then
        printf 'Error: not a directory: %s\n' "$directory" >&2
        return 1
    fi

    printf 'Directory: %s\n' "$directory"
    find "$directory" -maxdepth 1 -type f -print
}

main "$@"
```

### Why use `main`?

- Separates definitions from execution
- Makes flow easier to understand
- Allows local variables
- Supports testing and sourcing patterns
- Makes the final exit status explicit

---

## 14. Foundation Interview Questions

1. What is the difference between executing and sourcing a script?
2. Why should variable expansions usually be quoted?
3. What is the difference between `$@` and `$*`?
4. How do stdout and stderr differ?
5. What does `2>&1` mean?
6. Why is direct command testing preferable to immediately reading `$?`?
7. How do `[ ]` and `[[ ]]` differ?
8. How do you safely read a file line by line?
9. What is the difference between function output and return status?
10. Why should scripts avoid parsing `ls`?

---

## 15. Foundation Checklist

- [ ] I can create and execute a script with the correct interpreter.
- [ ] I understand sourcing and child-process execution.
- [ ] I can explain shell and environment variables.
- [ ] I quote expansions correctly.
- [ ] I use command and arithmetic substitution.
- [ ] I redirect stdin, stdout, and stderr intentionally.
- [ ] I use `$@`, `$#`, `$?`, and `shift` correctly.
- [ ] I build decisions from exit statuses and tests.
- [ ] I use `if`, `case`, `for`, `while`, and `until`.
- [ ] I write functions with local variables and clear contracts.

