# Kubernetes Troubleshooting Scenarios

Use **context → scope → desired/observed state → conditions → Events → logs/metrics → hypothesis → correction → verification → prevention**.

## Fast Triage

```bash
kubectl config current-context
kubectl get deploy,rs,pods,svc,endpointslice,pvc -n NAMESPACE -o wide
kubectl describe pod POD -n NAMESPACE
kubectl logs POD -n NAMESPACE --all-containers --previous
kubectl get events -n NAMESPACE --sort-by=.metadata.creationTimestamp
kubectl auth can-i VERB RESOURCE -n NAMESPACE
```

## 1. Wrong Context or Expired Credentials

**Symptoms:** unexpected objects, connection errors, or authentication prompts.

**Check:** current context, cluster endpoint, user, namespace, certificate/token expiration, identity provider, network path, and clock. Do not apply changes until the target identity is confirmed.

## 2. Pod Remains Pending

**Check:** scheduler Events, requests versus allocatable resources, node selectors/affinity, taints/tolerations, topology constraints, quota, PVC binding, and host ports.

**Correction:** address the exact unsatisfied constraint or add suitable capacity. Deleting the Pod does not fix a deterministic scheduling rule.

## 3. ImagePullBackOff or ErrImagePull

**Check:** exact image name/tag/digest, registry existence, pull secret, ServiceAccount, permission scope, node architecture, network/DNS, CA trust, and rate limits.

**Correction:** publish/select the right platform image, fix scoped credentials, or restore registry connectivity. Avoid `imagePullPolicy: Never` as a production workaround.

## 4. CrashLoopBackOff

```bash
kubectl get pod POD -n NS -o jsonpath='{.status.containerStatuses[*].lastState}'
kubectl logs POD -n NS --previous
```

**Causes:** bad command/configuration, missing dependency, permissions, application crash, failed liveness, or OOM. Backoff is restart pacing, not the root cause.

## 5. OOMKilled or CPU Throttling

Compare exit reason, requests/limits, usage trends, node pressure, application metrics, and QoS. Fix leaks or workload sizing, then use evidence-based requests/limits and scaling. CPU throttling may appear as latency without a restart.

## 6. Deployment Rollout Stuck

Inspect Deployment conditions, ReplicaSets, unavailable replicas, Events, image pulls, probes, quotas, scheduling, and `progressDeadlineSeconds`. Pause or roll back when appropriate while preserving working replicas.

## 7. Readiness Fails but Application Runs

Verify the exact probe from inside the Pod/network namespace, named port, scheme, path, headers, timeout, start timing, and dependency behavior. Readiness should represent traffic eligibility and should not restart the container.

## 8. Liveness Causes Restart Loop

Check restart count, last termination, probe Events, and previous logs. A remote dependency or overloaded endpoint should not normally be a liveness condition. Use startupProbe for slow starts and make liveness conservative.

## 9. Service Has No Endpoints

Compare Service selector with Pod labels and inspect EndpointSlices. Confirm Pods are Ready and ports align. Services route to selected ready endpoints; a Service does not create or repair Pods.

## 10. DNS or Service Connection Fails

Trace client DNS configuration, CoreDNS health/logs, Service record, EndpointSlice, `port`/`targetPort`, Pod IP connectivity, listener bind address, NetworkPolicy, and proxy/data-plane state. Test by name, Service IP, and Pod IP to isolate layers.

## 11. NetworkPolicy Blocks Traffic

Confirm CNI enforcement, selected source/destination Pods, ingress and egress isolation, namespace labels, ports/protocols, and DNS allowance. Policies are additive; both directions must allow when both Pods are isolated.

## 12. PVC Pending or Mount Failure

Check StorageClass, provisioner, access mode, requested size, binding mode, topology/zone, PV status, CSI controller/node logs, attachment limits, permissions, and node Events. Never delete storage resources before confirming reclaim policy and data ownership.

## 13. ConfigMap or Secret Change Not Reflected

Environment variables require Pod recreation. Projected volume files update eventually, but applications must reread them; `subPath` does not receive updates. Confirm object name/key, namespace, rollout trigger, mount, and application reload behavior.

## 14. RBAC Returns Forbidden

Identify the authenticated subject, verb, API group, resource/subresource, name, and namespace. Use `kubectl auth can-i`. Inspect Role/ClusterRole and bindings. Grant the smallest required permission; avoid cluster-admin or wildcard shortcuts.

## 15. Node NotReady

Inspect Node conditions and Lease, kubelet/runtime service, disk/memory/PID pressure, certificates, filesystem, CNI, DNS, routes, and API connectivity. Cordon for maintenance; drain only after reviewing PDBs, DaemonSets, local storage, stateful workloads, and replacement capacity.

## Interview Response Template

> I first confirm the cluster context, namespace, scope, and user impact. I preserve the workload spec, status, conditions, Events, current/previous logs, and relevant metrics. I trace ownership and dependencies, test one hypothesis at a time, apply the smallest reversible correction, verify both Kubernetes state and user behavior, then add prevention through policy, validation, alerting, capacity planning, or a runbook.

---

**Author:** Muhammad Khalid Khan  
**Repository:** DevOps & SRE Interview Preparation
