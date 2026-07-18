# Docker Mock Interview

**Duration:** 60 minutes  
**Maximum score:** 100  
**Target:** 75+ with no critical security misconception

## Interviewer Instructions

Ask for reasoning before commands. Award full marks only when the candidate explains validation, risk, and prevention. For scenario questions, provide hints only after the candidate has stated an initial diagnostic plan.

## Round 1 — Rapid Foundations (10 minutes, 20 points)

Answer each in about one minute. **4 points each.**

1. Explain image versus container and tag versus digest.
2. Compare containers and virtual machines.
3. Describe namespaces, cgroups, and capabilities.
4. Walk through what occurs during `docker run`.
5. Explain why PID 1 and graceful signals matter.

**Scoring per answer:** 1 correct definition, 1 mechanism, 1 operational consequence, 1 clear example.

## Round 2 — Dockerfile Review (12 minutes, 20 points)

Review this file:

```dockerfile
FROM ubuntu:latest
COPY . /app
WORKDIR /app
RUN apt-get update && apt-get install -y python3 python3-pip
RUN pip3 install -r requirements.txt
ENV API_PASSWORD=production-secret
EXPOSE 5000
CMD python3 app.py
```

Identify at least eight concerns and propose a safer, cache-efficient design.

**Expected domains:** mutable base, oversized context, dependency ordering, package cleanup, dependency pinning, secret exposure, root runtime, shell-form command/signals, ownership, health check, multi-stage option, and metadata.

**Score:** 8 issue identification, 8 corrections with reasoning, 4 validation/reproducibility.

## Round 3 — Runtime Incident (15 minutes, 25 points)

An API container restarts every few minutes. Users see intermittent 502 errors. Evidence includes exit code 137, `.State.OOMKilled=true`, a 256 MiB memory limit, and increasing application memory.

Ask the candidate to:

1. Explain the evidence and immediate user impact.
2. State what additional evidence they would collect.
3. Propose safe mitigation and root-cause work.
4. Define verification and prevention.

**Score:** 6 diagnosis, 6 evidence, 6 corrective plan, 4 verification, 3 prevention.

**Red flag:** proposing unlimited memory or repeated restarts as the complete fix.

## Round 4 — Networking and Storage (10 minutes, 15 points)

### Scenario A (8 points)

Two Compose services share a network. The API tries `localhost:5432` and cannot connect to PostgreSQL. Explain the failure and correct connection design. Include readiness behavior.

### Scenario B (7 points)

Database data disappears after a container is replaced. Explain writable layers, volume design, permissions, and a credible backup/restore strategy.

## Round 5 — Production Design (10 minutes, 15 points)

Design how an application image moves from commit to production. Cover:

- Reproducible build and test
- Minimal runtime and non-root execution
- Registry, digest promotion, scan, SBOM, and signing concepts
- Runtime secrets, read-only filesystem, capabilities, and resources
- Health, shutdown, logs, metrics, rollback, and incident evidence

**Score:** 3 build, 3 supply chain, 3 runtime security, 3 reliability/observability, 3 trade-off explanation.

## Round 6 — Candidate Summary (3 minutes, 5 points)

“Explain the included Dockerized Health Web project as if you were presenting it to a hiring panel.”

**Score:** 2 architecture, 1 security, 1 health/operations, 1 concise delivery.

## Evaluation Rubric

| Score | Readiness |
|---:|---|
| 90–100 | Strong Docker interview performance; explains trade-offs and production risks |
| 75–89 | Interview ready; minor gaps should be reviewed |
| 60–74 | Developing; repeat labs and scenario practice |
| Below 60 | Rebuild foundations before a production-focused interview |

### Critical Misconceptions

Any of these should trigger remediation even if the total score is high:

- Treating containers as separate-kernel VMs
- Claiming `EXPOSE` publishes or secures a port
- Baking production secrets into images
- Recommending privileged mode or world-writable permissions by default
- Deleting/pruning resources before preserving evidence and confirming ownership
- Treating a volume as a backup

## Candidate Improvement Record

| Area | Evidence from answer | Improvement action | Retest date |
|---|---|---|---|
| Architecture | | | |
| Image builds | | | |
| Runtime operations | | | |
| Networking/storage | | | |
| Security | | | |
| Troubleshooting | | | |

---

**Author:** Muhammad Khalid Khan  
**Repository:** DevOps & SRE Interview Preparation
