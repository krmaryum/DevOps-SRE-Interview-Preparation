# Linux Troubleshooting Scenarios

**Package:** 01 — Linux Interview Preparation  
**Scenarios:** 15  
**Method:** Symptom → Evidence → Isolation → Mitigation → Root Cause → Validation → Prevention

---

## Interview Answer Framework

Use this structure when answering every scenario:

1. Clarify scope, timeline, and business impact.
2. Ask about recent changes.
3. Capture evidence before restarting or changing the system.
4. Isolate the failing layer.
5. Mitigate safely.
6. Correct the root cause.
7. Validate technical and user-facing recovery.
8. Add prevention, monitoring, or automation.

---

# Scenario 1 — Server Is Slow

## Ticket

Users say a Linux application server is slow, but no specific alert is available.

## Isolation

```bash
uptime
nproc
top
free -h
vmstat 1 5
iostat -xz 1 5
df -hT
ps aux --sort=-%cpu | head
ps aux --sort=-%mem | head
```

## Strong Interview Answer

First define what “slow” means, which users and services are affected, and when it started. Check changes, then compare CPU, runnable tasks, memory, swap, disk capacity, I/O latency, and responsible processes against normal baselines. Mitigate only after identifying the constrained resource, validate application recovery, and document capacity or monitoring improvements.

---

# Scenario 2 — High Load but Low CPU

## Evidence

- Load average: `12.0`
- CPU idle: `75%`
- Several processes show state `D`

## Likely Direction

Tasks in uninterruptible sleep may be waiting for disk, NFS, or another I/O dependency.

## Commands

```bash
vmstat 1 5
ps -eo state,pid,ppid,wchan:32,cmd | awk '$1 ~ /D/'
iostat -xz 1 5
mount
```

Do not conclude that additional CPU will solve the incident until the waiting dependency is identified.

---

# Scenario 3 — Memory Exhaustion and OOM Kill

## Evidence

An application disappeared, and kernel logs mention `Killed process`.

## Commands

```bash
free -h
vmstat 1 5
ps aux --sort=-%mem | head
swapon --show
journalctl -k | grep -i -E 'oom|out of memory|killed process'
```

## Resolution Approach

Identify the killed process and memory growth pattern. Determine whether the cause was a leak, load spike, missing limit, or insufficient capacity. Restore service safely, confirm recovery, then add memory limits, leak correction, capacity, and early-warning monitoring as appropriate.

---

# Scenario 4 — Root Filesystem Is 100% Full

## Commands

```bash
df -hT /
df -i /
sudo du -xhd1 / | sort -h
sudo find /var -xdev -type f -size +500M -ls
sudo lsof +L1
journalctl --disk-usage
```

## Key Point

Check both blocks and inodes. Do not delete unknown data blindly. Investigate log growth, temporary files, application output, package cache, and deleted-but-open files. Correct rotation, retention, or capacity after restoring safe free space.

---

# Scenario 5 — `df` and `du` Disagree

## Evidence

`df` reports 95% usage, while `du` finds much less data.

## Likely Cause

A process may still hold a deleted file open.

```bash
sudo lsof +L1
```

Identify the owning process and use the application's supported reopen, reload, or restart procedure. Verify the space is released and correct the log-rotation workflow.

---

# Scenario 6 — Filesystem Has Space but Cannot Create Files

## Evidence

The filesystem has free gigabytes, but applications report `No space left on device`.

## Check

```bash
df -h
df -i
```

## Likely Cause

Inodes may be exhausted by a very large number of small files. Identify the responsible directory and application, remove data only according to retention policy, and redesign cleanup or filesystem capacity.

---

# Scenario 7 — Service Will Not Start

## Isolation

```bash
systemctl status <service> --no-pager -l
journalctl -u <service> -n 100 --no-pager
systemctl cat <service>
ss -lntup
df -hT
```

Also run the application's configuration validator.

Investigate invalid configuration, missing files, permissions, occupied ports, dependencies, full storage, security policy, and recent changes. After repair, validate the service locally, remotely, and through monitoring.

---

# Scenario 8 — Service Is Active but Application Is Unreachable

## Checks

```bash
systemctl is-active <service>
ss -lntp
curl -v http://127.0.0.1:<port>
ip route
sudo nft list ruleset
```

Determine whether the application listens only on loopback, the wrong port, or the wrong interface. Then inspect host firewall, cloud security rules, routes, load balancer health, and application-layer errors.

---

# Scenario 9 — SSH Permission Denied

## Client

```bash
ssh -vvv user@server
```

## Server

```bash
getent passwd user
passwd -S user
sudo sshd -t
journalctl -u sshd
sudo ls -ld /home/user /home/user/.ssh
sudo ls -l /home/user/.ssh/authorized_keys
```

Check username, account status, expiration, login shell, key placement, ownership, permissions, SSH rules, and SELinux context. Keep an existing session open while testing corrections.

---

# Scenario 10 — Host Works by IP but Not by Name

## Commands

```bash
getent hosts server.example.com
dig server.example.com
cat /etc/resolv.conf
ip route
```

## Isolation

Separate DNS resolution from network reachability. Verify configured resolvers, resolver reachability, record accuracy, search domains, cache, and `/etc/hosts` entries.

---

# Scenario 11 — Cron Job Fails but Manual Run Works

## Investigation

- Confirm the cron user.
- Use absolute paths.
- Capture stdout and stderr.
- Set required environment variables.
- Set the working directory explicitly.
- Verify executable permissions and credentials.

Example diagnostic entry:

```cron
* * * * * /usr/bin/env > /tmp/cron-environment.txt 2>&1
```

Do not leave diagnostic jobs or sensitive environment output after testing.

---

# Scenario 12 — NFS Mount Hangs or Fails

## Isolation

```bash
getent hosts nfs-server
showmount -e nfs-server
rpcinfo -p nfs-server
mount -v -t nfs nfs-server:/export /mnt/test
journalctl -k --since '10 minutes ago'
```

Confirm network reachability, exports, client subnet authorization, NFS services, firewall rules, protocol version, mount options, permissions, and UID/GID mapping.

---

# Scenario 13 — Package Installation Fails

## Possible Causes

- Repository metadata is stale.
- DNS or network access fails.
- Proxy or TLS trust is incorrect.
- Another package manager holds a lock.
- Disk or inodes are full.
- Dependencies conflict.

## Commands

```bash
df -hT
df -i
date
getent hosts repository-host
ps aux | grep -E 'apt|dpkg|dnf|yum|rpm'
```

Read the exact package-manager error before clearing caches or removing locks. Confirm no legitimate package operation is active.

---

# Scenario 14 — System Boots into Emergency Mode

## Common Direction

An invalid `/etc/fstab` entry or unavailable required filesystem may block normal boot.

## Investigation

```bash
journalctl -xb
systemctl --failed
cat /etc/fstab
lsblk -f
```

Correct the invalid UUID, filesystem type, mount option, or device dependency. Use `nofail` only when the mount is genuinely optional. Validate with `mount -a` before the next reboot.

---

# Scenario 15 — Application Log Grows Without Limit

## Investigation

```bash
du -h /var/log/application.log
sudo logrotate -d /etc/logrotate.d/application
lsof /var/log/application.log
```

Confirm whether logrotate configuration matches the actual file, whether ownership permits rotation, and whether the application reopens the file after rotation. Add retention, compression, alerting, and supported reload behavior.

---

# Scenario Practice Scorecard

Score each response from 0 to 2:

| Area | 0 | 1 | 2 |
|---|---|---|---|
| Clarification | None | Partial | Scope, time, and impact established |
| Evidence | Guessing | Some commands | Focused, layered evidence |
| Isolation | No structure | General direction | Failing layer identified logically |
| Safety | Risky action | Limited caution | Safe mitigation and rollback |
| Validation | Not mentioned | Technical only | Technical and user-facing validation |
| Prevention | Not mentioned | Generic | Specific monitoring or engineering action |

Maximum per scenario: **12 points**.

