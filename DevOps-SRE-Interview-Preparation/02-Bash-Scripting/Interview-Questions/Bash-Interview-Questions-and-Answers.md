# Bash Interview Questions and Model Answers

**Package:** 02 — Bash Scripting Interview Preparation  
**Questions:** 40

Answer each question aloud before reading the model answer.

---

# Foundations

## 1. What is Bash?

Bash is a Unix shell and command language. It provides an interactive command environment and a scripting language for orchestrating programs and automating operating-system work.

## 2. What does a shebang do?

When a script is executed directly, the shebang identifies the interpreter. `#!/usr/bin/env bash` locates Bash through PATH, while `#!/bin/bash` uses a fixed path.

## 3. What is the difference between executing and sourcing a script?

Normal execution runs in a separate shell process, so directory and variable changes do not normally persist in the caller. Sourcing runs in the current shell, so changes can persist.

## 4. What is the difference between a shell variable and environment variable?

A shell variable exists in the current shell. An exported environment variable is included in the environment passed to child processes.

## 5. Why should variable expansions normally be quoted?

Quotes prevent unintended word splitting and pathname expansion, preserving the expanded value as one argument. This is essential for spaces, wildcard characters, and empty values.

## 6. Compare single and double quotes.

Single quotes preserve literal content. Double quotes allow parameter, command, and arithmetic substitution while preventing normal word splitting and glob expansion.

## 7. What is command substitution?

`$(command)` runs a command and substitutes its stdout, removing trailing newlines. Its failure must still be handled when the result is important.

## 8. What are stdin, stdout, and stderr?

They are standard streams represented by file descriptors 0, 1, and 2. stdin supplies input, stdout carries normal output, and stderr carries diagnostics.

## 9. What does `2>&1` mean?

It redirects file descriptor 2 to the current destination of file descriptor 1. Redirection order matters.

## 10. What is a pipeline's default exit status?

By default, Bash normally returns the status of the final command. With `set -o pipefail`, the pipeline is nonzero when any component fails.

---

# Arguments, Decisions, and Loops

## 11. What do `$0`, `$#`, `$?`, and `$!` represent?

`$0` is the script or shell name, `$#` is argument count, `$?` is the previous command's status, and `$!` is the PID of the most recent background command.

## 12. What is the difference between `$@` and `$*`?

Inside double quotes, `"$@"` preserves each argument separately. `"$*"` combines all arguments into one string separated by the first IFS character. Scripts usually want `"$@"`.

## 13. What does `shift` do?

It removes the first positional parameter and moves the remaining parameters down, useful for manual argument processing.

## 14. Why test a command directly instead of immediately checking `$?`?

`if command; then` is clearer and prevents another command from accidentally overwriting the status before it is tested.

## 15. Compare `[ ]` and `[[ ]]`.

`[ ]` is a command-like test syntax with broader shell portability and careful quoting requirements. `[[ ]]` is a Bash conditional construct with safer string handling, pattern matching, and regular-expression support.

## 16. When is `case` preferable to multiple `if` statements?

`case` is clearer for matching one value against several exact values or patterns, such as subcommands and environment names.

## 17. How do you safely read a file line by line?

Use `while IFS= read -r line || [[ -n "$line" ]]; do ...; done < file`. This preserves whitespace and backslashes and handles a final line without a newline.

## 18. Why should scripts avoid parsing `ls`?

Its output is formatted for humans and cannot reliably represent all valid filenames. Use globs, `find -print0`, or arrays.

## 19. What do `break` and `continue` do?

`break` exits the current loop; `continue` skips the rest of the current iteration and starts the next one.

## 20. How do you prevent an `until` or retry loop from running forever?

Add a maximum attempt count, deadline, or timeout; log attempts; sleep with an appropriate interval; and return a documented failure status.

---

# Functions and Data

## 21. How do Bash functions receive parameters?

Inside a function, `$1`, `$2`, `$#`, and `$@` refer to the function's arguments. Use local variables to prevent unintended global changes.

## 22. What is the difference between function output and return value?

Stdout carries data that can be captured. `return` provides a numeric status from 0 to 255. Diagnostic messages should normally go to stderr.

## 23. Why use `local` inside functions?

It limits variable scope, reduces accidental interaction between functions, and makes contracts easier to understand and test.

## 24. How do you iterate over an array safely?

Use `for item in "${array[@]}"; do ...; done`. Quoted `[@]` preserves every element as a separate value.

## 25. What is an associative array?

It is a Bash array indexed by string keys, declared with `declare -A`, useful for mappings such as service names to ports.

## 26. What does `getopts` provide?

It parses short command-line options and their arguments predictably. The script must still handle missing/unknown options and validate option values.

---

# Reliability and Security

## 27. What does `set -Eeuo pipefail` do?

It enables exit-on-certain-errors, ERR-trap inheritance, unset-variable errors, and pipeline failure propagation. Each behavior has contextual details and does not replace explicit validation.

## 28. Why can `set -e` be surprising?

Its behavior depends on syntactic context, including conditions, logical lists, pipelines, and arithmetic commands. Expected nonzero statuses must be handled explicitly.

## 29. Why can `((count++))` terminate a strict-mode script?

Post-increment evaluates to the old value. If that value is zero, the arithmetic command returns status 1. `((count += 1))` avoids that specific result.

## 30. What is a trap?

A trap registers commands or a function for signals or shell events such as EXIT, ERR, INT, and TERM. It is commonly used for cleanup and diagnostic context.

## 31. How do you preserve the original status in an EXIT trap?

Capture `$?` at the beginning of the cleanup function, perform safe cleanup, and exit or return using the captured status.

## 32. Why use `mktemp`?

It creates unique temporary files or directories safely, reducing predictable-name races and collisions. Combine it with restrictive permissions and cleanup traps.

## 33. What is idempotency?

An idempotent script can run repeatedly without creating unintended additional changes. It inspects current state and changes only what differs from desired state.

## 34. Why is `eval` risky?

It reparses constructed text as shell code. If any part is influenced by untrusted input, it can cause command injection. Prefer arrays and direct argument passing.

## 35. How should scripts handle secrets?

Use an approved secret mechanism and prevent secrets from entering source, arguments, history, logs, tracing, or world-readable files. Rotate any secret that is exposed.

## 36. How can you prevent concurrent instances?

Use a robust locking mechanism such as `flock` on a protected file descriptor, define behavior when the lock is held, and return a documented temporary-failure status.

---

# Debugging and Scenarios

## 37. A script says `bad interpreter: No such file or directory`. What do you check?

Check the shebang interpreter path and file line endings. `bash\r` in an error usually indicates CRLF endings. Use `file` or `sed -n '1l'` to verify.

## 38. Why might a variable modified in a piped `while` loop be unchanged afterward?

The loop may execute in a subshell. Use process substitution or input redirection so the loop runs in the current shell.

## 39. A script works manually but fails through cron. How do you troubleshoot?

Confirm the cron user, PATH, working directory, environment, shell, permissions, credentials, absolute command paths, and captured stdout/stderr. Reproduce using a minimal environment.

## 40. How do you review a Bash script before production?

Confirm purpose and privilege, validate inputs and dependencies, review quoting and destructive targets, handle failures and cleanup, verify idempotency and secret safety, run `bash -n` and ShellCheck, and test normal, boundary, failure, repeated, interrupted, and concurrent execution.

---

## Project Answer Template

Explain the Linux health-report script using:

1. Problem and users
2. Inputs and thresholds
3. Dependency and input validation
4. Function structure
5. Data collection
6. Logging and streams
7. Exit-code design
8. Failure testing
9. Security and privileges
10. Production improvements

