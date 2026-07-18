# Kubernetes Mock Interview

**Duration:** 60 minutes  
**Maximum score:** 100  
**Target:** 75+ with no critical security misconception

## Round 1 — Architecture (10 minutes, 20 points)

Answer each in about two minutes. **4 points each.**

1. Trace `kubectl apply` to running Pods.
2. Explain API server, etcd, scheduler, controllers, kubelet, runtime, and CNI.
3. Compare Pod, Deployment, StatefulSet, and DaemonSet.
4. Explain desired state, status, conditions, and reconciliation.
5. Compare startup, readiness, and liveness probes.

Score each for definition, mechanism, operational consequence, and example.

## Round 2 — Manifest Review (12 minutes, 20 points)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: payment
spec:
  containers:
    - name: payment
      image: company/payment:latest
      env:
        - name: PASSWORD
          value: production-password
      ports:
        - containerPort: 80
      securityContext:
        privileged: true
```

Identify at least ten production concerns and propose a corrected workload design.

Expected domains: controller, replicas/rollout, mutable image, exposed secret, privileged/root, capabilities/seccomp, ServiceAccount, resources, probes, graceful termination, configuration, labels/Service, availability, and policy.

## Round 3 — Incident (15 minutes, 25 points)

A Deployment rollout stalls. New Pods show readiness failures; the Service has only old endpoints; one new container later restarts because liveness calls a remote database that is unavailable.

Explain:

1. User impact and why old replicas may remain
2. Evidence collection order
3. Readiness versus liveness design error
4. Safe mitigation/rollback
5. Verification and prevention

**Score:** diagnosis 6, evidence 6, correction 6, verification 4, prevention 3.

## Round 4 — Networking and Storage (10 minutes, 15 points)

### A. Service Failure (8 points)

The Service exists but EndpointSlices are empty. Trace labels, selectors, readiness, ports, DNS, and policy.

### B. PVC Failure (7 points)

A zonal PVC remains Pending. Explain StorageClass, delayed binding, scheduler topology, CSI evidence, data lifecycle, and safe correction.

## Round 5 — Production Design (10 minutes, 15 points)

Design a customer-facing Kubernetes workload. Cover controller, resources/scaling, placement/disruption, probes/shutdown, network, storage, RBAC/Pod security, secret/image supply chain, observability, rollout/rollback, backup, and recovery.

## Round 6 — Project Summary (3 minutes, 5 points)

Explain the included Production-Ready Web App to a hiring panel in two minutes.

## Evaluation

| Score | Readiness |
|---:|---|
| 90–100 | Strong production Kubernetes reasoning |
| 75–89 | Interview ready with minor review areas |
| 60–74 | Repeat labs and scenario practice |
| Below 60 | Rebuild architecture and operations foundations |

### Critical Misconceptions

- Treating Kubernetes as an image builder or separate-VM system
- Claiming readiness failure restarts a container
- Storing plain production secrets in manifests
- Granting privileged mode or cluster-admin as a default fix
- Deleting Pods/PVCs before preserving evidence and data ownership
- Assuming a PDB prevents all downtime
- Assuming NetworkPolicy works without CNI enforcement

## Improvement Record

| Area | Evidence | Improvement action | Retest date |
|---|---|---|---|
| Architecture | | | |
| Workloads | | | |
| Networking/storage | | | |
| Security | | | |
| Reliability | | | |
| Troubleshooting | | | |

---

**Author:** Muhammad Khalid Khan  
**Repository:** DevOps & SRE Interview Preparation
