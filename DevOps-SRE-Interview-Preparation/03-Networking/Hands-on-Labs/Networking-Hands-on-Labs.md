# Networking Hands-on Labs

**Package:** 03 — Networking and Advanced Networking  
**Labs:** 12

Use disposable WSL distributions, VMs, containers, or cloud lab resources. Firewall, route, and packet-capture activities require authorization and careful cleanup.

---

## Lab 1 — Interface and Route Inventory

```bash
hostnamectl
ip -br link
ip -br address
ip route
ip -6 route
ip neigh
ss -lntup
```

Document interface state, IPv4/IPv6 addresses, default gateway, connected routes, neighbor entries, and listening services.

---

## Lab 2 — IPv4 Subnet Worksheet

For each address, calculate prefix mask, total addresses, network, broadcast, and traditional usable range:

```text
192.168.10.70/26
10.20.15.200/27
172.16.8.33/28
192.168.5.130/25
```

Validate with an available subnet calculator only after completing the work manually. Explain how cloud-reserved addresses affect usable totals.

---

## Lab 3 — Neighbor Discovery and Local Link

```bash
ip neigh
ping -c 1 <local-peer>
ip neigh
```

Observe how a peer moves through neighbor states. Explain why a remote Internet server does not appear in the local ARP table and why the gateway does.

---

## Lab 4 — DNS Resolution

```bash
getent hosts example.com
dig example.com A
dig example.com AAAA
dig example.com MX
dig +trace example.com
cat /etc/resolv.conf
```

Compare system resolver output with DNS-specific output. Test an invalid name and record error, timing, and exit status.

---

## Lab 5 — TCP Server and Socket States

Start a disposable listener:

```bash
python3 -m http.server 8080 --bind 127.0.0.1
```

From another terminal:

```bash
ss -lntp | grep ':8080'
curl -v http://127.0.0.1:8080
ss -tan | grep ':8080'
```

Change the bind address to an appropriate lab interface and compare local and remote access. Do not expose the service to an untrusted network.

---

## Lab 6 — UDP and Packet Capture

Use an authorized DNS server:

```bash
sudo tcpdump -ni any 'udp port 53'
dig example.com
```

Observe query and response tuples. Compare with a TCP DNS query:

```bash
dig +tcp example.com
```

Explain why generic UDP port scans cannot always confirm service health.

---

## Lab 7 — Route Selection and Path

```bash
ip route
ip route get 8.8.8.8
traceroute 8.8.8.8
tracepath 8.8.8.8
```

Identify selected source address, interface, next hop, and visible path changes. Explain why traceroute asterisks do not automatically mean the destination is unreachable.

---

## Lab 8 — Host Firewall

In a disposable VM, start a service on port 8080. Confirm access, add a narrowly scoped firewall rule that blocks the lab client, verify the timeout/rejection behavior, inspect counters/logs, then remove the exact practice rule.

Use the platform's configured firewall tool (`nft`, `firewalld`, or `ufw`). Save the existing rules before changes and never flush a remote host firewall blindly.

---

## Lab 9 — HTTP Behavior

```bash
curl -I http://example.com
curl -L -I http://example.com
curl -sS -o /dev/null -w 'code=%{http_code} remote=%{remote_ip} time=%{time_total}\n' https://example.com
```

Identify redirects, status, selected address, and response time. Compare HEAD and GET behavior.

---

## Lab 10 — TLS Inspection

```bash
openssl s_client -connect example.com:443 -servername example.com </dev/null
curl -v https://example.com
```

Document certificate subject/SAN, issuer, validity, chain, protocol, and hostname verification. Explain SNI and why connecting by IP can present a different certificate.

---

## Lab 11 — Nginx Reverse Proxy

Run a backend on `127.0.0.1:8080`, then configure an Nginx lab server to proxy `/app/` to it. Validate:

```bash
nginx -t
curl -v http://localhost/app/
ss -lntp
journalctl -u nginx
```

Stop the backend to reproduce a 502, inspect proxy logs, restore it, and validate recovery.

---

## Lab 12 — End-to-End Incident

Use `Tools/network-diagnostic.sh` against a lab service. Inject one failure at a time:

- Wrong DNS entry or hosts-file mapping
- Closed port
- Loopback-only bind
- Firewall block
- Incorrect URL path
- Expired/self-signed lab certificate

For each failure, record source, destination, protocol, evidence, failing layer, correction, validation, and prevention.

---

## Lab Tracker

| Lab | Complete | Evidence | Explanation Ready |
|---:|---|---|---|
| 1 | ☐ | ☐ | ☐ |
| 2 | ☐ | ☐ | ☐ |
| 3 | ☐ | ☐ | ☐ |
| 4 | ☐ | ☐ | ☐ |
| 5 | ☐ | ☐ | ☐ |
| 6 | ☐ | ☐ | ☐ |
| 7 | ☐ | ☐ | ☐ |
| 8 | ☐ | ☐ | ☐ |
| 9 | ☐ | ☐ | ☐ |
| 10 | ☐ | ☐ | ☐ |
| 11 | ☐ | ☐ | ☐ |
| 12 | ☐ | ☐ | ☐ |

