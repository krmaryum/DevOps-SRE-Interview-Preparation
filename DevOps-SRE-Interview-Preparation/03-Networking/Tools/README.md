# Network Diagnostic Tool

`network-diagnostic.sh` is a read-only Bash tool for layered connectivity checks.

## Features

- Local interface and route context
- System resolver lookup
- Optional detailed DNS query when `dig` exists
- ICMP test treated as advisory
- TCP/UDP port probe
- Optional HTTP/HTTPS response check
- Configurable timeout and log file
- PASS, WARN, and FAIL results
- Monitoring-friendly exit codes

## Usage

```bash
chmod +x network-diagnostic.sh
./network-diagnostic.sh -H localhost
```

TCP port:

```bash
./network-diagnostic.sh -H server.example.com -p 443
```

HTTP/TLS:

```bash
./network-diagnostic.sh \
    -H app.example.com \
    -p 443 \
    -u https://app.example.com/health \
    -t 8
```

UDP probe:

```bash
./network-diagnostic.sh -H dns-server.example.com -p 53 -P udp
```

UDP is connectionless; a silent probe cannot reliably prove service failure.

## Exit Codes

| Code | Meaning |
|---:|---|
| 0 | Required checks passed without warnings |
| 1 | Runtime or dependency error |
| 2 | Invalid usage or input |
| 3 | Required checks passed with warnings |
| 4 | One or more required checks failed |

## Validation

```bash
bash -n network-diagnostic.sh
shellcheck network-diagnostic.sh
./network-diagnostic.sh -h
./network-diagnostic.sh -H localhost
./network-diagnostic.sh -H localhost -p 1
./network-diagnostic.sh -H invalid.invalid
./network-diagnostic.sh -H localhost -p invalid
```

## Interview Explanation

Explain why resolution, ICMP, port connectivity, and HTTP are separate checks; why ping failure is advisory; why UDP is difficult to prove with a generic probe; and how exit statuses support automation.

