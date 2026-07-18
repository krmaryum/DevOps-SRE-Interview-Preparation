# Networking Interview Cheat Sheet

**Package:** 03 — Networking and Advanced Networking

---

## Models

```text
Application → Transport → Internet/Network → Link → Physical
Data → Segment/Datagram → Packet → Frame → Bits
```

## IPv4

```text
Private: 10.0.0.0/8
         172.16.0.0/12
         192.168.0.0/16
Loopback: 127.0.0.0/8
Link-local: 169.254.0.0/16
Default route: 0.0.0.0/0
```

| Prefix | Addresses | Traditional hosts |
|---:|---:|---:|
| /24 | 256 | 254 |
| /25 | 128 | 126 |
| /26 | 64 | 62 |
| /27 | 32 | 30 |
| /28 | 16 | 14 |
| /29 | 8 | 6 |
| /30 | 4 | 2 |

## IPv6

```text
::1/128 loopback
fe80::/10 link-local
fc00::/7 unique local
2000::/3 global unicast allocation space
```

## Interface and Routing

```bash
ip -br link
ip -br address
ip route
ip route get 8.8.8.8
ip neigh
```

```text
Most specific route wins.
Remote destination → resolve gateway MAC.
Always verify return path.
```

## TCP/UDP

```text
TCP: connection, reliability, ordering, flow/congestion control
UDP: datagrams, lower overhead, app handles reliability if needed
TCP handshake: SYN → SYN-ACK → ACK
```

## Sockets

```bash
ss -lntup
ss -tan
ss -s
```

```text
127.0.0.1 = local only
0.0.0.0 = all IPv4 interfaces
LISTEN = awaiting connection
SYN-SENT = waiting for SYN-ACK
ESTABLISHED = connected
CLOSE-WAIT = app has not closed after peer closure
```

## Common Ports

```text
22 SSH       53 DNS       80 HTTP      443 HTTPS
123 NTP      25 SMTP      3306 MySQL   5432 PostgreSQL
```

## DNS

```bash
getent hosts example.com
dig example.com
dig +short example.com
dig example.com A
dig example.com AAAA
dig +trace example.com
cat /etc/resolv.conf
```

```text
A IPv4 | AAAA IPv6 | CNAME alias | MX mail | PTR reverse | TXT text
TTL controls caching duration.
```

## Connectivity

```bash
ping -c 4 host
traceroute host
tracepath host
nc -vz host 443
curl -v https://host
```

```text
Ping failure ≠ application failure.
Refused → active rejection/no listener.
Timeout → drop/route/filter/no response.
```

## HTTP/TLS

```bash
curl -I URL
curl -v URL
openssl s_client -connect host:443 -servername host </dev/null
```

```text
2xx success | 3xx redirect | 4xx client/request | 5xx server/upstream
502 invalid/failed upstream response
504 upstream timeout
TLS: hostname + validity + chain + trust + time + protocol
```

## Firewall/NAT

```text
Stateful → tracks connection/return traffic
Stateless → each direction evaluated independently
SNAT → source changed
DNAT → destination changed
NAT is not authentication or encryption.
```

## Load Balancing

```text
L4: IP/port/transport
L7: hostname/path/header/cookie
Algorithms: round robin, weighted, least connections, hash
Health: protocol + port + path + status + timeout + thresholds
```

## Cloud Connectivity

```text
Peering: direct, commonly non-transitive, no overlapping CIDRs
Transit: hub for many networks
Private endpoint: private service access
VPN: encrypted tunnel + routes + MTU + redundancy
```

## Packet Capture

```bash
sudo tcpdump -ni any host 10.0.0.25
sudo tcpdump -ni eth0 tcp port 443
sudo tcpdump -ni any -w capture.pcap
```

```text
SYN, no response → path/filter/destination
RST → reachable, rejected/no listener
Handshake complete → inspect TLS/application
```

## Troubleshooting Order

```text
1 Source/destination/protocol/error
2 Interface/link/address
3 Subnet/route/gateway/return route
4 DNS
5 Port/socket/transport
6 Firewall/SG/NACL/policy
7 TLS/proxy/load balancer
8 Application
9 Validate and prevent
```

