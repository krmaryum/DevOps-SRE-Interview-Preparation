# Kubernetes Hands-on Labs

Use a disposable cluster. Before each lab, record the current context and namespace. Capture desired state, observed state, Events, logs, and verification evidence.

## Lab 1 — Context, API, and Architecture

```bash
kubectl config current-context
kubectl config get-contexts
kubectl cluster-info
kubectl get nodes -o wide
kubectl api-resources
kubectl get --raw=/readyz?verbose
```

**Explain:** control plane versus node components, namespaced versus cluster-scoped resources, and which requests go through the API server.

## Lab 2 — Declarative Pod Observation

Generate a manifest, review it, then apply it:

```bash
kubectl run pod-lab --image=nginx:alpine --port=80 \
  --dry-run=client -o yaml > pod-lab.yaml
kubectl apply -f pod-lab.yaml
kubectl get pod pod-lab -o wide
kubectl describe pod pod-lab
kubectl logs pod-lab
kubectl delete -f pod-lab.yaml
```

Identify spec, status, phase, conditions, container state, Pod IP, node, and Events.

## Lab 3 — Namespaces, Labels, and Selectors

```bash
kubectl create namespace selector-lab
kubectl create deployment web -n selector-lab --image=nginx:alpine --replicas=3
kubectl label deployment web tier=frontend -n selector-lab
kubectl get pods -n selector-lab --show-labels
kubectl get pods -n selector-lab -l app=web
kubectl annotate deployment web owner=platform -n selector-lab
```

Change a Service selector to a nonmatching value, observe endpoints disappear, then correct it.

## Lab 4 — Deployment Rollout and Rollback

```bash
kubectl set image deployment/web nginx=nginx:stable-alpine -n selector-lab
kubectl rollout status deployment/web -n selector-lab
kubectl rollout history deployment/web -n selector-lab
kubectl scale deployment/web --replicas=5 -n selector-lab
kubectl set image deployment/web nginx=nginx:does-not-exist -n selector-lab
kubectl rollout undo deployment/web -n selector-lab
```

Track Deployment, old/new ReplicaSets, Pod readiness, max surge, and unavailable replicas.

## Lab 5 — ConfigMaps and Secrets

```bash
kubectl create configmap app-config -n selector-lab --from-literal=MODE=interview
kubectl create secret generic app-secret -n selector-lab --from-literal=TOKEN=lab-only
kubectl get configmap app-config -n selector-lab -o yaml
kubectl describe secret app-secret -n selector-lab
```

Mount configuration as a volume and inject one key as environment. Update both objects and compare update behavior. Never use real credentials.

## Lab 6 — Startup, Readiness, and Liveness

Deploy the package project. Observe probe configuration and status:

```bash
kubectl apply -k Projects/production-ready-web-app
kubectl get pods -n interview-k8s -w
kubectl describe pod -n interview-k8s -l app.kubernetes.io/name=health-web
```

Break readiness, then liveness. Record endpoint removal versus container restart behavior and use `kubectl logs --previous`.

## Lab 7 — Services, EndpointSlices, and DNS

```bash
kubectl get service,endpointslice -n interview-k8s
kubectl run dns-client -n interview-k8s --rm -it --restart=Never \
  --labels=access=health-web --image=busybox:1.36 -- \
  nslookup health-web.interview-k8s.svc.cluster.local
kubectl port-forward -n interview-k8s service/health-web 8080:80
```

Trace Service `port` to named `targetPort`, EndpointSlice addresses, Pod port, and application listener.

## Lab 8 — NetworkPolicy

Confirm whether the CNI enforces policies. Test an unlabeled client and a client labeled `access=health-web`. Inspect both NetworkPolicies and document the additive rule model.

```bash
kubectl get networkpolicy -n interview-k8s -o yaml
kubectl describe networkpolicy -n interview-k8s
```

Temporarily remove DNS egress permission and observe name-resolution behavior; then restore safely.

## Lab 9 — Resources, QoS, and Scheduling

```bash
kubectl get pod -n interview-k8s -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass,NODE:.spec.nodeName
kubectl top pod -n interview-k8s
kubectl describe node
```

Create BestEffort, Burstable, and Guaranteed examples. Make one Pod unschedulable with excessive requests and diagnose scheduler Events. Remove only lab objects.

## Lab 10 — Persistent Storage

Create a PVC using the cluster’s available StorageClass, mount it in a Pod, write data, replace the Pod, and verify persistence.

```bash
kubectl get storageclass
kubectl get pv,pvc -A
kubectl describe pvc CLAIM -n NAMESPACE
```

Explain binding, dynamic provisioning, access mode, reclaim policy, topology, and tested backup/restore.

## Lab 11 — Workload Controller Comparison

Create and observe:

- A Job with intentional retry
- A CronJob with `concurrencyPolicy: Forbid`
- A DaemonSet scoped to eligible nodes
- A two-replica StatefulSet with a headless Service

For each, map the controller to Pods, completion/lifecycle semantics, stable identity, scheduling, and cleanup.

## Lab 12 — Project Failure Injection

Inject these failures one at a time:

1. Invalid image tag
2. Broken readiness path
3. Service selector mismatch
4. Impossible memory request
5. Denied network flow
6. Missing ConfigMap key

For each incident submit:

```text
Impact and scope
Desired state vs observed state
Conditions and Events
Current and previous logs
Root cause
Smallest reversible correction
Verification
Prevention/alert/runbook improvement
```

## Completion Checklist

- [ ] I confirmed context and namespace before every change.
- [ ] I can explain controller ownership rather than only list Pods.
- [ ] I traced traffic from DNS and Service to ready endpoints.
- [ ] I captured Events and previous logs before deleting Pods.
- [ ] I validated storage, security, resources, probes, and disruption behavior.
- [ ] I cleaned up only the disposable lab resources.

---

**Author:** Muhammad Khalid Khan  
**Repository:** DevOps & SRE Interview Preparation
