# Linux Mock Interview

**Package:** 01 — Linux Interview Preparation  
**Duration:** 60 minutes  
**Maximum score:** 100

---

## Instructions

- Answer without opening study notes.
- Speak aloud as if the interviewer is present.
- Explain reasoning, not only commands.
- State safety checks before disruptive actions.
- Use the scenario framework consistently.
- Record weak areas immediately after the session.

---

## Round 1 — Rapid Fundamentals (15 minutes, 20 points)

Answer each in approximately one minute. Each question is worth 2 points.

1. Explain the relationship between terminal, shell, kernel, and hardware.
2. Walk through the Linux boot process.
3. What is PID 1?
4. Explain file and directory permissions using mode `2750`.
5. Compare a hard link and symbolic link.
6. Compare a zombie and orphan process.
7. What is load average?
8. Why can `df` and `du` disagree?
9. Compare `systemctl start`, `enable`, `reload`, and `restart`.
10. Why can a cron job fail when manual execution works?

### Scoring

- 2: Accurate, clear, and includes an example
- 1: Partially correct or incomplete
- 0: Incorrect or unable to answer

---

## Round 2 — Command Interpretation (10 minutes, 20 points)

Each exercise is worth 4 points.

### Exercise 1

```text
load average: 8.20, 7.90, 6.50
CPU: 72% idle
Several processes: state D
```

What does this suggest, and what would you inspect next?

### Exercise 2

```text
Filesystem  Size  Used Avail Use% Mounted on
/dev/xvda1   40G   38G  2.0G  95% /

du reports only 21G under /
```

Give a likely cause and verification command.

### Exercise 3

```text
LISTEN 0 128 127.0.0.1:8080 0.0.0.0:* users:(("app",pid=1200,fd=5))
```

Why might remote clients be unable to connect?

### Exercise 4

```text
MemAvailable: 210000 kB
SwapTotal:   2097148 kB
SwapFree:      82000 kB
```

What additional evidence is required before declaring memory pressure?

### Exercise 5

```text
Permission denied (publickey)
```

List the client and server checks in the correct order.

---

## Round 3 — Troubleshooting Scenarios (20 minutes, 40 points)

Each scenario is worth 10 points.

### Scenario 1 — Slow Production Server

Users report severe application latency. Restarting is not approved. Walk through your investigation, mitigation, validation, and prevention.

### Scenario 2 — Service Fails After Deployment

An Nginx configuration deployment completed, but Nginx will not start. Explain exactly how you would respond.

### Scenario 3 — Emergency Mode After Reboot

A server enters emergency mode after a storage change. Describe the likely evidence, repair, validation, and preventive process.

### Scenario 4 — SSH Access Lost for One User

All other users can connect, but one user receives `Permission denied`. Isolate account, key, permissions, SSH policy, and security-context possibilities.

### Scenario Scoring

| Area | Points |
|---|---:|
| Clarifies scope and impact | 1 |
| Checks recent changes | 1 |
| Captures relevant evidence | 2 |
| Isolates the failing layer | 2 |
| Proposes safe mitigation | 1 |
| Corrects root cause | 1 |
| Validates recovery | 1 |
| Prevents recurrence | 1 |

---

## Round 4 — Project and Behavioral (15 minutes, 20 points)

### Question 1 — Two-Minute Project Explanation (8 points)

Explain one Linux project using:

- Business or learning problem
- Environment
- Your responsibility
- Implementation
- Failure encountered
- Troubleshooting method
- Result
- Production improvement

### Question 2 — Incident Ownership (4 points)

Tell me about a technical problem you owned from detection through prevention.

### Question 3 — Disagreement During an Incident (4 points)

How would you respond if another engineer wanted to reboot immediately but you believed evidence should be captured first?

### Question 4 — Unknown Answer (4 points)

How do you respond when an interviewer asks about a Linux feature you have not used?

Strong approach: state what you know, avoid inventing experience, connect it to related knowledge, and explain how you would verify and test it safely.

---

## Final Score

| Round | Maximum | Score |
|---|---:|---:|
| Rapid fundamentals | 20 | |
| Command interpretation | 20 | |
| Troubleshooting scenarios | 40 | |
| Project and behavioral | 20 | |
| **Total** | **100** | |

## Readiness Levels

| Score | Result | Action |
|---:|---|---|
| 90–100 | Interview ready | Maintain revision and project storytelling |
| 80–89 | Nearly ready | Repair two weakest areas and repeat scenarios |
| 70–79 | Developing | Repeat labs and targeted questions |
| Below 70 | Foundation gaps | Revisit notes, commands, and guided labs |

---

## Post-Interview Review

| Question or Scenario | What Went Well | Weak Area | Correct Answer or Evidence | Next Practice Date |
|---|---|---|---|---|
| | | | | |
| | | | | |
| | | | | |

## Completion Checklist

- [ ] Completed under timed conditions
- [ ] Recorded the session or wrote complete notes
- [ ] Calculated the score honestly
- [ ] Identified the three weakest areas
- [ ] Repeated the related hands-on labs
- [ ] Scheduled a second mock interview

