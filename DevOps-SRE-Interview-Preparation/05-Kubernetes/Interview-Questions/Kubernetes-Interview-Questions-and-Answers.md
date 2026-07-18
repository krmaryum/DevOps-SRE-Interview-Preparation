# Kubernetes Interview Questions and Answers

## Architecture and API

### 1. What is Kubernetes?

Kubernetes is a declarative platform for orchestrating containerized workloads. It exposes an API and uses control loops to schedule, replicate, configure, connect, update, and recover workloads toward desired state.

### 2. Explain the Kubernetes control plane.

The API server accepts and validates API requests; etcd stores API data; the scheduler assigns unscheduled Pods; controller managers run reconciliation loops; an optional cloud controller integrates infrastructure services.

### 3. What runs on a worker node?

The kubelet ensures assigned Pods run, the container runtime starts containers, CNI implements Pod networking, and kube-proxy or another data plane commonly implements Service forwarding. Node-level agents may add logging, monitoring, storage, or security.

### 4. What happens after `kubectl apply`?

The client submits desired state to the API server. Authentication, authorization, and admission run; accepted state is persisted. Controllers create dependent objects, the scheduler binds Pods to nodes, and kubelets start containers. Status then converges asynchronously.

### 5. Why is etcd important?

etcd is the consistent backing store for Kubernetes API state. Its availability, latency, security, backup, and tested restore are critical to control-plane operation. Application data normally belongs in external or persistent workload storage, not etcd.

### 6. What is reconciliation?

A controller repeatedly compares desired and observed state and acts to reduce the difference. This makes operations event-driven and eventually consistent rather than a one-time script.

### 7. Explain spec and status.

`spec` expresses desired state submitted by users/controllers. `status` reports observed state and conditions, normally updated by controllers. A created object may have a valid spec while status still shows unavailable.

### 8. What are labels, selectors, and annotations?

Labels identify and group objects and are used by selectors. Selectors connect controllers and Services to Pods. Annotations store non-identifying metadata. Selector-label mismatches frequently produce zero endpoints or unmanaged Pods.

## Pods and Workloads

### 9. What is a Pod?

A Pod is the smallest deployable compute object. Its containers share a network namespace, IP/ports, and declared volumes. Pods are disposable and should usually be managed by a controller.

### 10. Why not deploy naked Pods in production?

A direct Pod has no higher-level controller to restore desired replicas, perform rollouts, or replace it after deletion/node loss. Deployments, StatefulSets, DaemonSets, or Jobs express the intended lifecycle.

### 11. Deployment versus ReplicaSet?

A ReplicaSet maintains a number of matching Pods. A Deployment manages ReplicaSets and adds declarative rollout, history, and rollback. Users normally manage the Deployment rather than its ReplicaSets.

### 12. When do you use a StatefulSet?

Use it for stable ordinal identity, stable network identity, persistent volume association, or ordered operations. It does not make an application stateful-safe automatically; replication, consistency, backup, and recovery remain application concerns.

### 13. When do you use a DaemonSet?

Use it for node-local agents such as log collectors, monitoring, CNI/CSI components, or security agents that must run on every or selected eligible node.

### 14. Job versus CronJob?

A Job manages Pods until required completions succeed. A CronJob creates Jobs on a schedule. Both need retry-safe behavior, deadlines/backoff, history/TTL cleanup, and intentional concurrency.

### 15. What are init and sidecar containers?

Init containers run sequentially before application containers and must complete. Sidecars run alongside application containers to provide tightly coupled support. Both share Pod scheduling and consume resources; their lifecycle must be designed carefully.

### 16. Is CrashLoopBackOff a Pod phase?

No. It is a CLI-displayed waiting reason indicating repeated container failure with restart backoff. Inspect last termination, exit code, previous logs, probes, configuration, resources, and Events for the cause.

## Configuration, Health, and Resources

### 17. ConfigMap versus Secret?

ConfigMaps hold non-confidential configuration. Secrets are intended for sensitive values but base64 is not encryption. Secrets still require strict RBAC, encryption at rest, safe runtime delivery, rotation, and log protection.

### 18. Why might a ConfigMap update not appear?

Environment variables do not update in running processes. Projected files update eventually but the application must reread them, while `subPath` mounts do not receive projected updates. Many teams trigger an explicit rollout on configuration change.

### 19. Compare startup, readiness, and liveness probes.

Startup protects slow initialization from premature liveness/readiness. Readiness controls traffic eligibility. Liveness restarts a stuck container. Misusing liveness for dependency failures can cause restart storms.

### 20. Requests versus limits?

Requests inform scheduling and capacity accounting. Limits constrain container use. CPU limits generally throttle; memory limits may cause OOM termination. Realistic requests are also important for HPA and node capacity.

### 21. Explain Kubernetes QoS classes.

Guaranteed Pods meet equal CPU/memory request-limit criteria for their containers; Burstable Pods define some resources without meeting Guaranteed; BestEffort defines none. QoS influences eviction under node pressure but is not the only factor.

### 22. How does HPA work?

HPA periodically compares observed metrics with targets and changes workload replicas within configured bounds. CPU utilization targets depend on resource requests. Scaling needs reliable metrics, readiness, capacity, stabilization, and load testing.

## Scheduling and Availability

### 23. How does the scheduler choose a node?

It filters nodes that violate constraints and scores feasible nodes using configured plugins. Inputs include resource requests, selectors/affinity, taints/tolerations, topology, volumes, and policy.

### 24. Taint versus toleration?

A taint repels Pods from a node. A matching toleration permits scheduling or continued execution but does not force placement. Pair toleration with affinity/selector for dedicated nodes.

### 25. Node affinity versus Pod anti-affinity?

Node affinity places Pods based on node labels. Pod anti-affinity separates Pods based on other Pod labels and topology. Required rules are hard constraints; preferred rules affect scoring.

### 26. What is a PodDisruptionBudget?

A PDB limits supported voluntary disruption for matching healthy Pods using `minAvailable` or `maxUnavailable`. It does not prevent node crashes or all forms of deletion, and an overly strict PDB can block drains.

### 27. Explain graceful Pod termination.

Deletion begins endpoint removal, runs `preStop` if set, sends the stop signal, and waits for the grace period before force-killing. Applications should stop new work, finish in-flight requests, and exit within that window.

### 28. How does a rolling Deployment update work?

A new ReplicaSet is created from the new Pod template. Kubernetes scales new Pods up and old Pods down according to surge and unavailable limits. Readiness controls availability; rollout conditions reveal progress or failure.

## Networking and Storage

### 29. Explain the Kubernetes network model.

Each Pod receives its own IP and Pods are intended to communicate across nodes without application-level NAT, subject to policy. CNI implements the Pod data plane, while Services provide stable virtual access to changing ready endpoints.

### 30. Service types?

ClusterIP is internal and default; NodePort exposes a node port; LoadBalancer requests external infrastructure; ExternalName provides a DNS alias; a headless Service returns endpoint identities directly.

### 31. Service `port` versus `targetPort`?

`port` is where the Service is addressed. `targetPort` is the selected Pod/application port and may be a number or named container port. NodePort additionally uses `nodePort` on cluster nodes.

### 32. A Service has no endpoints. What do you check?

Compare the Service selector with Pod labels, inspect EndpointSlices, confirm Pod readiness, namespace, and port naming. A Service only routes to selected eligible endpoints; it does not create Pods.

### 33. How do NetworkPolicies work?

They select Pods and define allowed ingress/egress. Once selected for a direction, non-allowed traffic is denied. Rules are additive, and both source egress and destination ingress must allow traffic when both sides are isolated. Enforcement requires compatible CNI.

### 34. PV versus PVC versus StorageClass?

A PV represents cluster storage; a namespaced PVC requests it; a StorageClass defines dynamic provisioning and parameters. CSI integrates storage systems. Binding considers size, access modes, class, selectors, and topology.

### 35. What can make a PVC Pending?

No matching PV, missing/default StorageClass, provisioner failure, unsupported access mode/size, delayed binding awaiting a consumer, topology conflict, quota, or cloud/storage errors. Events usually reveal the current blocker.

## Security and Troubleshooting

### 36. Authentication, authorization, and admission?

Authentication establishes identity. Authorization decides whether that identity may perform the verb on the resource. Admission mutates or validates an otherwise authorized request before persistence.

### 37. RoleBinding versus ClusterRoleBinding?

A RoleBinding grants permissions within one namespace and can reference a Role or ClusterRole. A ClusterRoleBinding grants a ClusterRole at cluster scope. Choose the narrowest scope.

### 38. How do you secure a Pod?

Run non-root, disable privilege escalation, drop capabilities, use runtime-default seccomp, use a read-only root filesystem, avoid host namespaces/paths and privileged mode, minimize ServiceAccount permissions, protect secrets, restrict networking, and use trusted verified images.

### 39. How do you troubleshoot a Pending Pod?

Confirm context/namespace, describe the Pod, and read scheduler Events. Check resource requests, selectors/affinity, taints, topology, quotas, PVCs, host ports, and capacity. Fix the unmet constraint instead of repeatedly deleting the Pod.

### 40. How would you design production Kubernetes operations?

I would cover HA control plane and etcd recovery, reviewed declarative delivery, workload security, realistic resources, probes and graceful shutdown, disruption and placement, autoscaling/capacity, network and storage policy, observability/audit, tested backups, controlled upgrades, rollback, SLOs, and incident runbooks.

---

**Author:** Muhammad Khalid Khan  
**Repository:** DevOps & SRE Interview Preparation
