# Kubernetes Interview Cheat Sheet

## Architecture

```text
client -> API server <-> etcd
              |-> controllers -> desired reconciliation
              |-> scheduler -> Pod-to-node binding
node: kubelet -> runtime -> containers
      CNI -> Pod network | kube-proxy/data plane -> Services
```

| Component | One-line answer |
|---|---|
| API server | Authenticated, authorized, admitted front door to API state |
| etcd | Consistent Kubernetes API backing store |
| Scheduler | Assigns unscheduled Pods to suitable nodes |
| Controllers | Reconcile actual state toward desired state |
| kubelet | Ensures assigned Pod containers run on a node |
| CNI / CSI | Network / storage integrations |

## Workload Choice

| Need | Object |
|---|---|
| Stateless replicas and rollout | Deployment |
| Stable identity/storage | StatefulSet |
| One agent per eligible node | DaemonSet |
| Run-to-completion task | Job |
| Scheduled repeated task | CronJob |

## Essential Commands

```bash
kubectl config current-context
kubectl get nodes -o wide
kubectl api-resources
kubectl get deploy,rs,pods,svc,endpointslice,pvc -n NS -o wide
kubectl describe pod POD -n NS
kubectl logs POD -n NS --all-containers --previous
kubectl get events -n NS --sort-by=.metadata.creationTimestamp
kubectl rollout status deployment/APP -n NS
kubectl rollout history deployment/APP -n NS
kubectl rollout undo deployment/APP -n NS
kubectl scale deployment/APP --replicas=3 -n NS
kubectl top pod,node
kubectl auth can-i get secrets -n NS
kubectl explain deployment.spec.template.spec.containers
kubectl diff -f FILE
kubectl apply --dry-run=server -f FILE
```

## Probes

| Probe | Question | Failure |
|---|---|---|
| Startup | Has initialization finished? | Eventually restart; suppresses other probes first |
| Readiness | Should it receive traffic? | Removed from ready endpoints |
| Liveness | Is it irrecoverably stuck? | Container restart |

## Resources and Scheduling

- Request = scheduler input/capacity accounting.
- Limit = runtime constraint; CPU throttles, memory can OOMKill.
- Taint repels; toleration permits but does not attract.
- Required affinity is a hard rule; preferred affinity influences score.
- Topology spread controls replica skew across domains.
- PDB protects against supported voluntary disruption, not every failure.

## Networking Trace

```text
client -> DNS -> Service -> EndpointSlice -> ready Pod IP:targetPort
       -> NetworkPolicy/CNI -> application listener
```

- `ClusterIP`: internal stable virtual endpoint.
- `NodePort`: node address plus allocated port.
- `LoadBalancer`: external infrastructure integration.
- Headless: direct endpoint discovery.
- Ingress/Gateway resources require implementations/controllers.
- NetworkPolicies are additive and require enforcing CNI.

## Storage

```text
Pod -> PVC -> PV -> CSI/storage
             ^
        StorageClass
```

- PVC Pending: class/provisioner, size/access, topology, quota, consumer.
- `ReadWriteOnce` means one-node attachment, not universally one Pod.
- Reclaim `Delete` vs `Retain` changes data lifecycle.
- Persistent volume is not a tested backup.

## Security

```yaml
securityContext:
  runAsNonRoot: true
  seccompProfile: {type: RuntimeDefault}
# container:
allowPrivilegeEscalation: false
readOnlyRootFilesystem: true
capabilities: {drop: ["ALL"]}
```

- Request path: authentication → authorization → admission.
- RoleBinding is namespaced; ClusterRoleBinding is cluster-wide.
- RBAC is additive; avoid wildcards and cluster-admin shortcuts.
- Base64 Secret data is not encryption.
- Avoid default token mounting when API access is unnecessary.
- Pin/verify images, scan, protect CI and registry, enforce policy.

## Fast Failure Map

| Symptom | First evidence |
|---|---|
| Pending | Scheduler Events, requests, constraints, PVC |
| ImagePullBackOff | Image name, secret, registry/platform/network |
| CrashLoopBackOff | Last state, exit code, previous logs, probes |
| OOMKilled | Limits, metrics, node pressure, QoS |
| No endpoints | Service selector, Pod labels/readiness, EndpointSlice |
| DNS failure | CoreDNS, resolv.conf, Service record, policy |
| PVC Pending | StorageClass, provisioner, topology, Events |
| Forbidden | Subject, verb, group/resource, namespace, bindings |
| NotReady node | Conditions/Lease, kubelet/runtime, pressure, CNI |

## Strong Interview Phrases

- “API acceptance is not application readiness.”
- “CrashLoopBackOff is a symptom and retry state, not the root cause.”
- “A toleration permits; it does not force placement.”
- “A Service routes to selected ready endpoints; it does not create Pods.”
- “Base64 is encoding, not Secret encryption.”
- “I preserve Events and previous logs before deleting the Pod.”

---

**Author:** Muhammad Khalid Khan  
**Repository:** DevOps & SRE Interview Preparation
