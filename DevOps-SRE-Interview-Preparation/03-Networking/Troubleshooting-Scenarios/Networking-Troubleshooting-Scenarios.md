# Networking Troubleshooting Scenarios

**Package:** 03 — Networking and Advanced Networking  
**Scenarios:** 15

---

## Layered Answer Framework

```text
Scope → Source/destination → Interface/address → Route → DNS
→ Port/transport → Firewall/policy → TLS → Proxy/LB → Application
→ Validation → Prevention
```

---

## Scenario 1 — Interface Has No Address

Check link state, assigned addresses, network-manager/systemd-network configuration, DHCP lease/logs, VLAN, virtual NIC attachment, and duplicate-address symptoms.

```bash
ip -br link
ip -br address
journalctl -u NetworkManager
networkctl status 2>/dev/null || true
```

Do not assign an address until subnet, ownership, and conflict risk are confirmed.

---

## Scenario 2 — Missing Default Route

The host reaches its local subnet but not remote networks.

```bash
ip route
ip route get <remote-ip>
```

Verify gateway address is on-link, interface is up, persistent configuration is correct, and upstream routing exists. Add only the intended route and validate return traffic.

---

## Scenario 3 — IP Works but Hostname Fails

Separate connectivity from resolution:

```bash
getent hosts name.example.com
dig name.example.com
cat /etc/resolv.conf
```

Check resolver reachability, record correctness, search suffixes, cache, split DNS, and `/etc/hosts`.

---

## Scenario 4 — DNS Returns Wrong Address

Compare answers from the system resolver, configured recursive resolver, and authoritative service. Check record type, view/split-horizon policy, stale cache, TTL, deployment automation, and recent changes. Correct the authoritative source and plan for cache expiration.

---

## Scenario 5 — Ping Fails but HTTPS Works

ICMP can be filtered independently. Confirm HTTPS with `curl` or a TCP port test. Treat ping as one signal, not a universal health check. Review policy only if ICMP is operationally required.

---

## Scenario 6 — Connection Refused

Refusal commonly means the destination actively rejected the connection or nothing listens on the address/port.

```bash
ss -lntp
curl -v http://127.0.0.1:<port>
tcpdump -ni any tcp port <port>
```

Check service state, bind address, port, and active reject rules.

---

## Scenario 7 — Connection Timeout

Check route, return route, firewall/security rules, NACL, service path, load balancer, and packet capture. A timeout often indicates dropped traffic or no response, but evidence must identify the hop/layer.

---

## Scenario 8 — Service Listens Only on Loopback

Evidence:

```text
LISTEN 0 128 127.0.0.1:8080
```

Local requests work while remote requests fail. Confirm the intended architecture. Bind to the approved interface or place a reverse proxy in front; do not expose an administrative service unintentionally.

---

## Scenario 9 — One-Way or Asymmetric Connectivity

Packets reach the server but replies follow another path or are filtered. Check source routing, multiple NICs, policy routing, NAT state, cloud routes, and both-direction captures. Stateful devices can reject asymmetric flows.

---

## Scenario 10 — TLS Certificate Failure

Check requested hostname, SNI, certificate SAN, validity, issuer chain, intermediate certificates, client trust, server time, and TLS compatibility.

```bash
date
openssl s_client -connect host:443 -servername host </dev/null
curl -v https://host
```

Do not make `-k`/insecure verification the permanent solution.

---

## Scenario 11 — Reverse Proxy Returns 502

Check proxy error log, upstream name resolution, route, port, bind address, service health, HTTP behavior, TLS expectation, and permissions/security policy. Test the upstream directly from the proxy host.

---

## Scenario 12 — Load Balancer Marks Targets Unhealthy

Confirm health-check protocol, port, path, Host header, expected code, timeout, thresholds, target bind address, firewall/security rules, and dependency behavior. A health endpoint should accurately represent readiness without being unnecessarily fragile.

---

## Scenario 13 — VPC Peering Does Not Work

Check peering state, non-overlapping CIDRs, route tables on both sides, security groups, NACLs, DNS options, source/destination addressing, and return path. Remember that basic peering is commonly non-transitive.

---

## Scenario 14 — Small Requests Work, Large Transfers Hang

Suspect MTU/path-MTU issues, especially with VPNs/tunnels. Use `tracepath`, controlled ping size, interface MTU, and packet capture. Correct tunnel/interface MTU or MSS handling rather than disabling validation globally.

---

## Scenario 15 — SYN Reaches Server, No Application Response

Packet capture determines whether the server returns SYN-ACK/RST. If the handshake completes, move to TLS/application evidence. If no response, inspect firewall, backlog/resource pressure, service bind, and kernel path. Correlate client and server captures using timestamps and tuples.

---

## Scenario Scorecard

| Area | Points |
|---|---:|
| Defines source, destination, protocol, and impact | 2 |
| Collects layered evidence | 2 |
| Identifies failing hop/layer | 2 |
| Proposes safe correction | 2 |
| Validates and prevents recurrence | 2 |

Maximum per scenario: **10 points**.

