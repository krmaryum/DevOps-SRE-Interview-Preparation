# Advanced Kubernetes

## 1. Reconciliation and API Mechanics

Controllers are control loops. They watch objects, compare desired and observed state, and make changes through the API until the two converge. This is asynchronous: a successful API request means the desired object was accepted, not that the application is ready.

Important metadata:

- `resourceVersion` supports concurrency and watches.
- `generation` changes when desired specification changes.
- `observedGeneration` indicates which desired generation a controller has processed.
- Owner references enable dependency relationships and garbage collection.
- Finalizers delay deletion until a controller completes cleanup.
- Conditions record meaningful aspects such as Available, Progressing, or Ready.

## 2. Advanced Workload Selection

### StatefulSet

Use when instances need stable ordinal identity, stable network identity, persistent volume association, or ordered operations. A StatefulSet commonly uses a headless Service and `volumeClaimTemplates`. Scaling down or deletion normally retains claims to protect data; define retention intentionally.

### DaemonSet

Runs one matching Pod per eligible node for log agents, monitoring agents, storage/network plugins, or node security tools. Tolerations and node selectors determine coverage.

### Job and CronJob

Jobs run Pods until successful completions are reached. Consider backoff, parallelism, completion mode, deadlines, retry-safe application behavior, and TTL cleanup. CronJobs create Jobs based on a schedule; concurrency policy, missed schedules, time zone, and idempotency matter.

## 3. Scheduling and Placement

### Affinity and Topology

- Required rules are hard scheduling constraints; preferred rules influence scoring.
- Pod anti-affinity can spread replicas across nodes or zones but may be expensive at scale.
- Topology spread constraints control skew across domains such as zone and hostname.
- `nodeName` bypasses normal scheduling and should rarely be used.

### Taints and Tolerations

Effects include `NoSchedule`, `PreferNoSchedule`, and `NoExecute`. A toleration allows a Pod to remain eligible; pair it with affinity or selectors when it must target a dedicated node group.

### Priority and Preemption

PriorityClasses express relative scheduling importance. The scheduler may preempt lower-priority Pods to make room. Use cautiously: priority does not create capacity and poor design can starve workloads.

## 4. Resource Management and Autoscaling

### HPA

Horizontal Pod Autoscaler changes replica count from metrics. CPU utilization is calculated relative to CPU requests, so missing or unrealistic requests undermine scaling. Stabilization windows and behavior policies reduce oscillation.

### VPA and Node Autoscaling

Vertical autoscaling recommendations adjust resource sizing, with modes and restart implications depending on implementation. Node autoscaling changes cluster capacity when Pods cannot schedule or nodes are underused. These loops interact; design and test them together.

### Common Resource Failure Modes

- Low request: overpacking and contention
- High request: Pending Pods and wasted capacity
- Low memory limit: OOMKills
- Low CPU limit: throttling and latency
- No limit: noisy-neighbor or runaway risk, depending on policy

## 5. Availability and Disruption

### PodDisruptionBudget

A PDB limits voluntary disruption to matching healthy Pods through `minAvailable` or `maxUnavailable`. It does not protect against node crashes, application bugs, direct Pod deletion, or every controller operation. An overly strict PDB can block node drains.

### Graceful Termination

1. Pod deletion timestamp is set.
2. Endpoint readiness and traffic removal begin through relevant controllers/data planes.
3. `preStop` runs if configured.
4. The runtime sends the container stop signal.
5. The grace period expires, then remaining processes are force-killed.

Applications should stop accepting new work, finish or hand off in-flight work, and exit within the grace period. Account for load-balancer and endpoint propagation.

### Deployment Strategy

`maxSurge` controls extra Pods during rollout; `maxUnavailable` controls allowed unavailable replicas. Readiness gates traffic, while `progressDeadlineSeconds` helps expose a stalled rollout. Rollback restores an earlier Pod template, not external database or configuration state.

## 6. Networking Deep Dive

### Components

- CNI configures Pod interfaces, addresses, routes, and possibly policy.
- CoreDNS provides cluster service discovery.
- Services select endpoints and provide stable virtual access.
- EndpointSlices scale backend endpoint representation.
- kube-proxy or an alternative data plane implements Service forwarding.

### NetworkPolicy

Policies are additive. A Pod becomes isolated for a direction when selected by a policy governing that direction. Allowed connections are the union of applicable rules; both source egress and destination ingress must permit a connection when both are isolated.

Default deny alone can break DNS, monitoring, control traffic, or dependencies. Inventory required flows, deploy observably, and verify enforcement by the CNI implementation.

### Ingress and Gateway

Ingress defines HTTP/HTTPS routing but requires an Ingress controller. The Gateway API provides role-oriented, extensible traffic configuration with resources such as GatewayClass, Gateway, and routes. Neither API is a load balancer implementation by itself.

## 7. Storage Deep Dive

### Binding and Provisioning

A PVC can bind to a pre-created PV or trigger dynamic provisioning through a StorageClass. `volumeBindingMode: WaitForFirstConsumer` can delay provisioning/binding until scheduling context is known, important for zonal storage.

### Access and Lifecycle

- `ReadWriteOnce` is single-node read/write attachment, not necessarily one-Pod access.
- `ReadOnlyMany` allows many nodes read-only.
- `ReadWriteMany` allows many nodes read/write when supported.
- `ReadWriteOncePod` restricts to a single Pod where supported.
- Reclaim policy `Delete` removes backing storage after release; `Retain` requires manual recovery/cleanup.

Snapshots and backups depend on CSI/provider/application capability. A snapshot is not automatically application-consistent or a disaster-recovery strategy.

## 8. Identity, RBAC, and Admission

The request path is:

```text
TLS -> authentication -> authorization -> admission -> persistence
```

- Users are external identities; ServiceAccounts are namespaced workload identities.
- Role and ClusterRole contain permissions.
- RoleBinding grants a Role or ClusterRole inside one namespace.
- ClusterRoleBinding grants cluster-wide scope.
- RBAC permissions are additive; there are no deny rules.

Avoid wildcard verbs/resources, unnecessary Secret access, default ServiceAccount token use, and broad ClusterRoleBindings. Verify with `kubectl auth can-i` and impersonation where authorized.

Admission controllers can mutate or validate requests after authorization. Policy engines, built-in admission, resource policies, image verification, and Pod Security Admission create guardrails.

## 9. Workload Security

Pod Security Standards define Privileged, Baseline, and Restricted profiles. Production-minded controls include:

```yaml
securityContext:
  runAsNonRoot: true
  seccompProfile:
    type: RuntimeDefault
containers:
  - securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop: ["ALL"]
```

Also use trusted pinned images, image scanning/signing, minimal ServiceAccount permissions, secret protection, NetworkPolicy, node isolation where needed, and restricted access to privileged host namespaces, paths, devices, and the container runtime socket.

## 10. Observability

### Four Evidence Layers

| Layer | Examples |
|---|---|
| API state | Objects, status, conditions, generation, managed fields |
| Events | Scheduling, pulls, mounts, probes, controller messages |
| Workload | Current/previous logs, metrics, traces, application health |
| Platform | Node conditions, kubelet/runtime logs, CNI/CSI, DNS, API and etcd metrics |

Events are useful but temporary and rate-limited. Centralize logs and metrics; preserve audit logs according to policy. Avoid relying on `kubectl exec` as the only diagnostic method—minimal images may not contain tools, and production access should be controlled.

## 11. Troubleshooting Decision Tree

### Pod Pending

Inspect Events and scheduler messages. Check requests versus allocatable capacity, selectors/affinity, taints, topology, quotas, PVC binding, host ports, and scheduling gates.

### Waiting or Restarting

Inspect container waiting/terminated reason, exit code, current and previous logs, probes, command, environment, mounts, image, and OOM state.

### Service Failure

Trace client → DNS → Service → EndpointSlice → selected Pod IP/port → application listener. Compare `port`, `targetPort`, named ports, readiness, selectors, NetworkPolicy, and mesh/proxy behavior.

### Node Failure

Inspect Node conditions, Lease/heartbeat, capacity, pressure, kubelet/runtime, filesystem, CNI, certificates, and control-plane reachability. Cordon before maintenance and drain with explicit awareness of PDBs, DaemonSets, local storage, and stateful applications.

## 12. Cluster Reliability and Operations

- Use multiple control-plane instances and a supported etcd topology where availability requires it.
- Back up etcd and test restoration; include external state and workload data in disaster recovery.
- Monitor certificates, API latency/errors, etcd health, scheduler/controller work queues, node pressure, DNS, CNI, CSI, and application SLOs.
- Follow version-skew and upgrade policies; test API removals and add-on compatibility.
- Upgrade incrementally with rollback/recovery plans and validated backups.
- Keep manifests and policy in source control, reviewed and promoted through environments.

## 13. Strong Interview Framework

When asked to design Kubernetes for production, explain:

1. Workload characteristics and controller choice
2. Requests, limits, scheduling, scaling, and disruption
3. Service discovery, ingress, required flows, and policy
4. Storage, consistency, backup, and recovery objectives
5. Identity, RBAC, workload security, secrets, and supply chain
6. Probes, shutdown, rollout, rollback, and availability
7. Logs, metrics, traces, audit, alerts, runbooks, and SLOs
8. Cluster topology, capacity, upgrades, and disaster recovery

## Official References

- [Scheduling, Preemption and Eviction](https://kubernetes.io/docs/concepts/scheduling-eviction/)
- [Autoscaling Workloads](https://kubernetes.io/docs/concepts/workloads/autoscaling/)
- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)

---

**Author:** Muhammad Khalid Khan  
**Repository:** DevOps & SRE Interview Preparation
