# Kubernetes Fundamentals

## 1. What Kubernetes Does

Kubernetes manages containerized workloads through a declarative API. A user states the desired condition; control loops continuously compare desired and observed state and take corrective action.

Kubernetes provides scheduling, replication, service discovery, configuration, rollout, health handling, and integration points for networking and storage. It does not build application images, automatically make applications stateless, or replace monitoring, backups, and secure software delivery.

## 2. Cluster Architecture

### Control Plane

| Component | Responsibility |
|---|---|
| `kube-apiserver` | Exposes the API; validates requests and is the front door to cluster state |
| `etcd` | Consistent key-value store containing Kubernetes API data |
| `kube-scheduler` | Assigns unscheduled Pods to suitable nodes |
| `kube-controller-manager` | Runs reconciliation controllers for built-in resources |
| `cloud-controller-manager` | Optional cloud-provider integration for nodes, routes, and load balancers |

### Worker Node

| Component | Responsibility |
|---|---|
| `kubelet` | Watches assigned PodSpecs and ensures containers run as required |
| Container runtime | Pulls images and runs containers through CRI-compatible integration |
| `kube-proxy` | Commonly programs node network rules for Service traffic; implementations vary |
| CNI plugin | Implements Pod networking according to the cluster network model |

### Deployment Flow

1. `kubectl` sends a request to the API server using kubeconfig credentials.
2. Authentication identifies the caller; authorization evaluates permission.
3. Admission may validate or mutate the request.
4. The accepted object is persisted through the API server in etcd.
5. Controllers notice desired replicas and create dependent objects.
6. The scheduler selects nodes for unscheduled Pods.
7. Each node’s kubelet asks the runtime to start containers and configure mounts/networking.
8. Status is reported through the API; controllers continue reconciling.

## 3. Declarative Kubernetes Objects

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: example
  labels:
    app: web
spec:
  containers:
    - name: web
      image: nginx:alpine
status: {}
```

- `apiVersion` selects the API group and version.
- `kind` identifies the resource type.
- `metadata` contains name, namespace, labels, annotations, owner references, and related identity.
- `spec` expresses desired state.
- `status` reports observed state and is normally maintained by Kubernetes controllers.

### Imperative and Declarative

Imperative commands are useful for exploration and generating examples. Declarative files are reviewable, repeatable, and appropriate for source control.

```bash
kubectl create deployment web --image=nginx:alpine --dry-run=client -o yaml
kubectl apply -f deployment.yaml
kubectl diff -f deployment.yaml
```

## 4. Namespaces, Labels, and Selectors

Namespaces scope names and help organize access, policy, and quotas. They are not a complete security boundary. Cluster-scoped objects such as Nodes and PersistentVolumes are not inside namespaces.

Labels are indexed key/value metadata used for grouping and selection. Annotations store non-identifying metadata. Selectors connect Services and controllers to Pods; an incorrect selector is a common outage cause.

```bash
kubectl get pods -A
kubectl get pods -l app=web,tier=frontend --show-labels
kubectl label pod example environment=lab
kubectl annotate pod example owner='platform-team'
```

## 5. Pods

A Pod is the smallest deployable Kubernetes compute object. Its containers share a network namespace, IP address, port space, and declared volumes. Containers in one Pod should be tightly coupled and share a lifecycle need.

Important Pod concepts:

- Pods are disposable; a replacement Pod receives a new identity and normally a new IP.
- Init containers run sequentially before app containers.
- Sidecars provide supporting behavior but add lifecycle and resource complexity.
- Restart policy applies through the kubelet to containers within a Pod.
- Directly created Pods lack a higher-level controller and are rarely the production choice.

### Pod Phase vs Container State

Pod phases include Pending, Running, Succeeded, Failed, and Unknown. Container states are Waiting, Running, and Terminated. CLI reasons such as CrashLoopBackOff are useful status presentations, not Pod phases.

## 6. Workload Controllers

| Workload | Best use |
|---|---|
| ReplicaSet | Maintains interchangeable Pod replicas; normally managed by a Deployment |
| Deployment | Stateless replicas with declarative rollout and rollback |
| StatefulSet | Stable identity, storage association, and ordered behavior |
| DaemonSet | Node-local agent on all or selected nodes |
| Job | Task that runs to completion |
| CronJob | Creates Jobs on a schedule |

### Deployment Relationships

```text
Deployment -> ReplicaSet -> Pods
```

A Deployment update normally creates a new ReplicaSet, scales it up, and scales the old ReplicaSet down according to `maxSurge` and `maxUnavailable`.

```bash
kubectl create deployment web --image=nginx:alpine --replicas=3
kubectl rollout status deployment/web
kubectl set image deployment/web nginx=nginx:stable-alpine
kubectl rollout history deployment/web
kubectl rollout undo deployment/web
kubectl scale deployment/web --replicas=5
```

## 7. ConfigMaps and Secrets

ConfigMaps hold non-confidential configuration. Secrets are a Kubernetes API type for sensitive data, but base64 encoding is not encryption. Protect Secrets with RBAC, encryption at rest, safe delivery, audit, and external secret management where appropriate.

Configuration can be injected as environment variables, command arguments, or mounted files. Environment values do not update inside an existing process. Mounted projected data can update eventually, but applications must reread it; `subPath` mounts do not receive projected updates.

```bash
kubectl create configmap web-config --from-literal=MODE=production
kubectl create secret generic app-secret --from-literal=token='example'
kubectl get configmap web-config -o yaml
```

Avoid printing or committing real Secret values.

## 8. Probes

| Probe | Meaning | Failure action |
|---|---|---|
| Startup | Has slow initialization completed? | Prevents liveness/readiness until success; eventually restarts on repeated failure |
| Readiness | Can this Pod receive Service traffic now? | Removes Pod from ready endpoints |
| Liveness | Is the process stuck and should it restart? | Kubelet restarts the container |

Good probes are local, meaningful, lightweight, and correctly timed. A liveness probe must not depend on a remote service whose failure would cause an unnecessary restart storm.

## 9. Services and DNS

A Service provides a stable virtual endpoint for a dynamic set of Pods selected by labels.

| Service type | Purpose |
|---|---|
| ClusterIP | Internal virtual IP; default type |
| NodePort | Opens a port on nodes and forwards to the Service |
| LoadBalancer | Requests an external load balancer through supported integration |
| ExternalName | DNS alias to an external name; no proxying |
| Headless (`clusterIP: None`) | DNS records point directly to selected endpoints |

`port` is the Service port; `targetPort` is the Pod/application port; `nodePort` is the optional port on nodes.

Typical DNS names:

```text
service-name
service-name.namespace
service-name.namespace.svc.cluster.local
```

An Ingress or Gateway routes application traffic, commonly HTTP/HTTPS, but requires a corresponding implementation/controller.

## 10. Kubernetes Network Model

The intended model gives each Pod its own cluster-reachable IP. Pods can communicate without application-level NAT, subject to policy and implementation. CNI plugins implement the data plane; NetworkPolicy defines permitted traffic only when the network plugin enforces it.

Service traffic is implemented through a data plane such as iptables, IPVS, nftables, eBPF, or another platform-specific mechanism.

## 11. Volumes and Persistent Storage

Ephemeral Pod volumes share data between containers or survive container restarts but generally do not survive Pod replacement. Persistent storage uses separate API objects:

```text
Pod -> PersistentVolumeClaim -> PersistentVolume -> storage system
                     ^
               StorageClass / dynamic provisioning
```

| Concept | Meaning |
|---|---|
| PV | Cluster storage resource with capacity and access characteristics |
| PVC | Namespaced request for storage by a workload |
| StorageClass | Provisioning class and parameters |
| CSI | Standard integration between Kubernetes and storage providers |
| Reclaim policy | What happens to storage after the claim is released |

Access modes describe intended attachment semantics and depend on the driver. They are not general filesystem access controls.

## 12. Requests, Limits, and QoS

- A request informs scheduling and represents reserved/accounted demand.
- A limit constrains maximum use for a container.
- CPU over-limit behavior is generally throttling.
- Memory over-limit can lead to OOM termination.

QoS classes:

- **Guaranteed:** supported containers have equal CPU/memory requests and limits.
- **Burstable:** at least one request/limit exists but Guaranteed criteria are not met.
- **BestEffort:** no CPU or memory requests/limits.

Under node pressure, QoS and actual usage relative to requests influence eviction priority, along with other scheduling priorities and conditions.

## 13. Basic Scheduling

The scheduler filters unsuitable nodes and scores feasible nodes. Factors include resource requests, constraints, affinity, taints/tolerations, topology, and plugins/policies.

- `nodeSelector`: simple label equality placement.
- Node affinity: expressive required or preferred node rules.
- Pod affinity/anti-affinity: co-locate or separate workloads based on labels/topology.
- Taint: repels Pods.
- Toleration: permits scheduling despite a matching taint; it does not force placement.

## 14. Essential kubectl Workflow

```bash
kubectl config current-context
kubectl config get-contexts
kubectl cluster-info
kubectl api-resources
kubectl get deploy,rs,pods,svc -n NAMESPACE -o wide
kubectl describe pod POD -n NAMESPACE
kubectl logs POD -n NAMESPACE --all-containers --previous
kubectl get events -n NAMESPACE --sort-by=.metadata.creationTimestamp
kubectl explain deployment.spec.template.spec.containers
kubectl auth can-i get secrets -n NAMESPACE
kubectl apply --server-side -f FILE
```

Use explicit namespaces and contexts. Preserve evidence before deleting or restarting resources.

## 15. Foundation Troubleshooting Method

1. Confirm cluster, context, namespace, object name, and incident scope.
2. Compare desired spec with current status and conditions.
3. Inspect owner relationships and rollout state.
4. Read recent relevant Events, then logs including `--previous`.
5. Check scheduling, image, configuration, probes, resources, networking, storage, and authorization.
6. Test one hypothesis at a time with the smallest reversible correction.
7. Verify user behavior and add prevention through tests, policy, alerts, or runbooks.

## Official References

- [Kubernetes Components](https://kubernetes.io/docs/concepts/overview/components/)
- [Kubernetes Objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/)
- [Workloads](https://kubernetes.io/docs/concepts/workloads/)
- [Services and Networking](https://kubernetes.io/docs/concepts/services-networking/)
- [Storage](https://kubernetes.io/docs/concepts/storage/)

---

**Author:** Muhammad Khalid Khan  
**Repository:** DevOps & SRE Interview Preparation
