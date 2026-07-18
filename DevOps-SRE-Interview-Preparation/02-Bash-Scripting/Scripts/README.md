# Bash Production Project — Linux Health Report

`linux-health-report.sh` is a read-only operational health-check tool created for Bash interview preparation.

## Features

- Configurable disk, memory, and load-per-CPU thresholds
- Optional systemd service checks
- Optional append-only log file
- Quiet mode for scheduled execution
- Dependency and input validation
- Functions with local variables
- Quoted expansions and safe option parsing
- Meaningful exit statuses
- No external services or third-party libraries

## Usage

```bash
chmod +x linux-health-report.sh
./linux-health-report.sh
```

Show help:

```bash
./linux-health-report.sh -h
```

Custom thresholds and services:

```bash
./linux-health-report.sh \
    -d 85 \
    -m 90 \
    -r 1.25 \
    -s sshd,nginx
```

Write a log:

```bash
./linux-health-report.sh -o ./health-report.log
```

Quiet scheduled execution:

```bash
./linux-health-report.sh -q -o /var/log/linux-health-report.log
```

## Exit Codes

| Code | Meaning |
|---:|---|
| 0 | All checks healthy |
| 1 | Runtime or dependency failure |
| 2 | Invalid usage or input |
| 3 | One or more warnings detected |

Capture the status:

```bash
./linux-health-report.sh
status=$?
printf 'Exit status: %d\n' "$status"
```

## Validation

```bash
bash -n linux-health-report.sh
shellcheck linux-health-report.sh
```

Test normal and failure paths:

```bash
./linux-health-report.sh -d 100 -m 100 -r 100
./linux-health-report.sh -d 1
./linux-health-report.sh -d invalid
./linux-health-report.sh -s service-that-does-not-exist
./linux-health-report.sh -o /directory/that/does/not/exist/report.log
```

## Interview Explanation

Explain:

1. The operational problem
2. Inputs and defaults
3. Validation and dependency checks
4. Function design
5. Threshold comparison
6. Logging behavior
7. Exit-code contract
8. Failure-path testing
9. Security and privilege decisions
10. Improvements for production monitoring

