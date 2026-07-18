# Bash Scripting Mock Interview

**Package:** 02 — Bash Scripting Interview Preparation  
**Duration:** 60 minutes  
**Maximum score:** 100

---

## Round 1 — Rapid Concepts (15 minutes, 20 points)

Each question is worth 2 points.

1. Compare executing and sourcing a script.
2. Explain single quotes, double quotes, and unquoted expansion.
3. Compare `"$@"` and `"$*"`.
4. Explain file descriptors 0, 1, and 2.
5. Compare `[ ]` and `[[ ]]`.
6. Explain function output versus return status.
7. What does `set -Eeuo pipefail` do?
8. What makes a script idempotent?
9. Why use `mktemp` and traps?
10. Why can a script work manually but fail in cron?

---

## Round 2 — Code Reading (15 minutes, 25 points)

Each exercise is worth 5 points.

### Exercise 1

```bash
files="report one.txt report-two.txt"
for file in $files; do
    rm $file
done
```

Identify the data-model, quoting, and safety problems.

### Exercise 2

```bash
set -e
count=0
((count++))
printf 'count=%d\n' "$count"
```

Explain why output may never be printed and correct it.

### Exercise 3

```bash
get_value() {
    echo "INFO starting"
    echo 42
}
value="$(get_value)"
```

Explain the output-channel design problem.

### Exercise 4

```bash
count=0
printf '%s\n' a b c | while read -r value; do
    ((count += 1))
done
printf '%d\n' "$count"
```

Explain the subshell problem and provide a safe alternative.

### Exercise 5

```bash
generate_report | tee report.txt
printf 'Success\n'
```

Explain how report generation can fail while the workflow reports success.

---

## Round 3 — Troubleshooting (15 minutes, 30 points)

Each scenario is worth 10 points.

### Scenario 1 — Cron Failure

A backup script succeeds interactively but fails through cron. Walk through user, environment, PATH, working directory, permissions, credentials, output capture, and validation.

### Scenario 2 — Dangerous Cleanup

A script contains `rm -rf "$WORK_DIR"/*`, and `WORK_DIR` is set from configuration. Explain how you would redesign validation and cleanup.

### Scenario 3 — Secret Exposure

A deployment token appears in CI logs after `set -x` was enabled. Explain immediate response, credential rotation, code correction, and preventive testing.

---

## Round 4 — Production Project (15 minutes, 25 points)

Present `linux-health-report.sh`.

### Two-minute explanation — 10 points

Cover:

- Problem
- Inputs and outputs
- Checks performed
- Exit-code contract
- How automation consumes it

### Technical deep dive — 10 points

Explain:

- `getopts`
- Input validation
- Dependency checks
- Function design
- Quoting
- Threshold comparison
- Logging
- Failure tests

### Production improvement — 5 points

Discuss structured output, configuration files, tests, packages, systemd integration, metrics export, and monitoring-system integration.

---

## Scorecard

| Round | Maximum | Score |
|---|---:|---:|
| Rapid concepts | 20 | |
| Code reading | 25 | |
| Troubleshooting | 30 | |
| Production project | 25 | |
| **Total** | **100** | |

## Readiness

| Score | Result |
|---:|---|
| 90–100 | Interview ready |
| 80–89 | Nearly ready; repair two weak areas |
| 70–79 | Repeat labs and code reading |
| Below 70 | Revisit foundations and guided practice |

## Review

- [ ] Completed without notes
- [ ] Explained reasoning aloud
- [ ] Stated safety checks
- [ ] Used meaningful exit statuses
- [ ] Identified three weak areas
- [ ] Repeated related labs
- [ ] Scheduled another attempt

