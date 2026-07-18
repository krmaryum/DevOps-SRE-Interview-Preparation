# Networking Mock Interview

**Package:** 03 — Networking and Advanced Networking  
**Duration:** 60 minutes  
**Maximum score:** 100

---

## Round 1 — Fundamentals (15 minutes, 20 points)

1. Explain encapsulation through the TCP/IP stack.
2. Compare MAC addresses and IP addresses.
3. Explain ARP for local and remote destinations.
4. Calculate the network and broadcast for `192.168.10.70/26`.
5. Explain longest-prefix routing.
6. Compare TCP and UDP.
7. Explain the TCP handshake.
8. Compare `127.0.0.1` and `0.0.0.0` listeners.
9. Explain DNS resolution and TTL.
10. Explain why ping failure does not prove application failure.

Each answer: 2 points.

---

## Round 2 — Command Interpretation (15 minutes, 25 points)

### Exercise 1

```text
default via 10.0.1.1 dev eth0
10.20.0.0/16 via 10.0.1.5 dev eth0
10.20.30.0/24 via 10.0.1.6 dev eth0
```

Which next hop is selected for `10.20.30.40`, and why?

### Exercise 2

```text
LISTEN 0 128 127.0.0.1:8080
```

Explain local and remote behavior.

### Exercise 3

```text
SYN →
     no response
```

List the next evidence you need.

### Exercise 4

```text
HTTP/1.1 502 Bad Gateway
```

Walk through proxy-to-upstream checks.

### Exercise 5

Small requests work through a VPN; large transfers hang. Explain the likely direction and tests.

Each exercise: 5 points.

---

## Round 3 — Scenarios (20 minutes, 35 points)

### Scenario 1 — IP Works, Name Fails (10 points)

Provide system resolver, DNS, cache, record, and split-horizon checks.

### Scenario 2 — Service Active, Remote Timeout (10 points)

Move from bind address and local port through route, firewall, cloud rules, return path, and capture.

### Scenario 3 — Load Balancer Unhealthy (10 points)

Analyze protocol, port, path, Host header, status, timeout, target policy, and application readiness.

### Safety and validation (5 points)

Explain how you avoid broad firewall changes and confirm end-to-end recovery.

---

## Round 4 — Architecture and Project (10 minutes, 20 points)

### Architecture (10 points)

Design highly available public access to private application servers using DNS, TLS, load balancing, health checks, firewalls, NAT for outbound access, and observability.

### Diagnostic Tool (10 points)

Explain `network-diagnostic.sh`: inputs, layered checks, why ICMP is advisory, UDP limitations, outputs, exit statuses, and production improvements.

---

## Scorecard

| Round | Maximum | Score |
|---|---:|---:|
| Fundamentals | 20 | |
| Command interpretation | 25 | |
| Scenarios | 35 | |
| Architecture/project | 20 | |
| **Total** | **100** | |

| Score | Readiness |
|---:|---|
| 90–100 | Interview ready |
| 80–89 | Nearly ready |
| 70–79 | Repeat weak labs/scenarios |
| Below 70 | Revisit foundations |

## Review Checklist

- [ ] Completed without notes
- [ ] Defined source, destination, protocol, and port
- [ ] Used layered isolation
- [ ] Explained return traffic
- [ ] Avoided guessing from ping alone
- [ ] Included safe validation and prevention
- [ ] Scheduled a second attempt

