# Networking Interview Questions and Model Answers

**Package:** 03 — Networking and Advanced Networking  
**Questions:** 40

---

## Fundamentals

### 1. What is the purpose of the OSI model?

It provides a conceptual framework for understanding network functions in layers, helping engineers describe protocols and isolate failures systematically.

### 2. What is encapsulation?

Each networking layer adds control information around data: application data becomes a transport segment/datagram, IP packet, link-layer frame, and physical transmission.

### 3. What is the difference between a MAC and IP address?

A MAC address identifies an interface on a local link. An IP address provides logical addressing used for communication and routing across networks.

### 4. What does ARP do?

ARP maps an on-link IPv4 address to a MAC address. For remote destinations, the host typically resolves the gateway's MAC.

### 5. Compare a switch and router.

A switch forwards frames inside a Layer 2 network using MAC information. A router forwards IP packets between networks using routes.

### 6. What does `/24` mean?

The first 24 bits form the network prefix, leaving 8 host bits and 256 total IPv4 addresses.

### 7. What are the private IPv4 ranges?

`10.0.0.0/8`, `172.16.0.0/12`, and `192.168.0.0/16`.

### 8. What is a default gateway?

It is the next-hop router used when no more-specific route matches the destination.

### 9. What is longest-prefix matching?

When multiple routes match a destination, the route with the most specific prefix is normally selected.

### 10. Why is a return route important?

The response must reach the source. Missing or asymmetric return paths can break communication even when forward traffic arrives.

---

## Transport, DNS, and Services

### 11. Compare TCP and UDP.

TCP establishes connection state and provides ordered reliable byte delivery. UDP sends independent datagrams without TCP's built-in delivery and ordering guarantees.

### 12. Explain the TCP three-way handshake.

The client sends SYN, server replies SYN-ACK, and client sends ACK. This establishes initial sequence and connection state.

### 13. What is a port?

A port identifies an application endpoint within a host for a transport protocol. Protocol, IP, and port together identify a socket endpoint.

### 14. What does `0.0.0.0:8080` mean in a listening socket?

The service is listening on port 8080 across all IPv4 interfaces, subject to system behavior and policy.

### 15. What is the difference between connection refused and timeout?

Refused often means an active rejection or no listener. Timeout often suggests dropped traffic, routing failure, filtering, or no response. Packet evidence should confirm.

### 16. What does DNS do?

DNS provides distributed name and service information, including mapping names to addresses and mail/name-server metadata.

### 17. Compare A, AAAA, CNAME, and PTR records.

A maps to IPv4, AAAA to IPv6, CNAME aliases one name to another, and PTR supports reverse address-to-name lookup.

### 18. What is DNS TTL?

TTL is how long a DNS result may be cached. It affects propagation and failover timing.

### 19. Why use both `getent hosts` and `dig`?

`getent` tests the system's configured name-service path. `dig` provides DNS-specific query details. Differences help isolate resolver configuration versus DNS data.

### 20. Explain DHCP DORA.

An IPv4 client commonly sends Discover, receives Offer, sends Request, and receives Acknowledge to obtain a lease and network options.

---

## Advanced Networking

### 21. What is NAT?

NAT changes address and sometimes port information across a device, with state commonly used to translate responses back to the original endpoint.

### 22. Compare stateful and stateless filtering.

Stateful filtering tracks connection state and can allow established return traffic. Stateless filtering evaluates packets independently and often requires rules in both directions.

### 23. What is MTU?

MTU is the largest Layer 3 packet size an interface/path segment can carry without fragmentation. Tunnels reduce effective payload capacity.

### 24. Why can small requests work while large transfers fail?

Path MTU discovery or fragmentation can be broken, especially across tunnels. Large packets are dropped while small ones pass.

### 25. What does TLS provide?

TLS provides peer authentication, confidentiality, and integrity for application data.

### 26. What is SNI?

Server Name Indication lets a TLS client send the requested hostname during the handshake, allowing one address to host multiple certificates/sites.

### 27. Compare forward and reverse proxies.

A forward proxy acts for clients accessing destinations. A reverse proxy acts for servers, accepting client traffic and routing to backends.

### 28. Compare Layer 4 and Layer 7 load balancing.

Layer 4 uses transport information such as IP and port. Layer 7 understands application data such as HTTP hostname, path, headers, and cookies.

### 29. What is a health check?

A load balancer periodically tests whether a target is ready to serve traffic using configured protocol, port, path, timeout, and success criteria.

### 30. What are sticky sessions?

They keep a client associated with one target. They can support stateful applications but reduce distribution flexibility and resilience.

### 31. What is VPC peering?

It provides private routing between two cloud networks. Common limitations include overlapping CIDRs and non-transitive routing.

### 32. What is a transit gateway/hub?

It centrally connects multiple networks and can simplify routing, inspection, and hybrid connectivity compared with many peerings.

### 33. What is a private endpoint?

It provides private network access to a service without using its public access path, depending on the cloud service design.

### 34. What is BGP used for?

BGP exchanges prefixes and applies routing policy between autonomous systems and in large/hybrid networks. Path choice is policy-driven.

---

## Troubleshooting

### 35. What is your first step in a network incident?

Define source, destination, protocol, port, exact error, scope, timing, expected path, and recent changes.

### 36. A host works by IP but not by name. What do you check?

Check system resolver output, DNS query results, resolver configuration/reachability, record correctness, caches, search domains, and hosts-file entries.

### 37. A service is active but remote clients cannot connect. What do you check?

Verify bind address/port, local connection, route, host firewall, cloud policy, return path, load balancer, and application logs.

### 38. What does a 502 from a reverse proxy suggest?

The proxy could not obtain a valid upstream response. Check upstream DNS, route, port, service, protocol/TLS expectation, timeout, and logs.

### 39. How do you use tcpdump during a TCP failure?

Capture the authorized interface/host/port and determine whether SYN leaves, SYN-ACK or RST returns, handshake completes, and application data follows.

### 40. What happens after recovery?

Validate end-to-end behavior, document root cause and timeline, and add specific prevention through monitoring, testing, policy, automation, capacity, or architecture.

