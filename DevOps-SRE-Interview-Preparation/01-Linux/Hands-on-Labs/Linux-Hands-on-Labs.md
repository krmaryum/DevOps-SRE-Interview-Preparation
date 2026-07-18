# Linux Hands-on Labs

**Package:** 01 — Linux Interview Preparation  
**Labs:** 12  
**Environment:** Disposable WSL distribution, VM, or cloud practice instance

> These labs use administrative commands. Confirm the hostname, user, path, disk, and service before every change. Do not run destructive or storage commands on production systems.

---

## Lab Method

For every lab:

1. Record the starting state.
2. Predict the expected result.
3. Perform the task.
4. Validate with an independent command.
5. Introduce one safe failure when instructed.
6. Troubleshoot using evidence.
7. Restore or clean up the practice environment.
8. Write a two-minute interview explanation.

---

# Lab 1 — Linux Environment Baseline

## Objective

Create a repeatable system snapshot for incident triage.

## Tasks

```bash
date
hostnamectl
cat /etc/os-release
uname -r
uptime
nproc
free -h
df -hT
df -i
lsblk -f
systemctl --failed
ip -br address
ip route
ss -lntup
```

## Validation

Document:

- Distribution and kernel
- CPU count and current load
- Available memory and swap
- Root filesystem utilization
- Failed services
- Primary IP address and default gateway
- Listening SSH port

## Interview Practice

Explain why a baseline is necessary before deciding that a value is abnormal.

---

# Lab 2 — Users, Groups, and Shared Access

## Objective

Create a secure team directory where new files inherit the project group.

## Tasks

```bash
sudo groupadd interview-devops
sudo useradd -m -s /bin/bash labuser1
sudo useradd -m -s /bin/bash labuser2
sudo usermod -aG interview-devops labuser1
sudo usermod -aG interview-devops labuser2

sudo mkdir -p /srv/interview-project
sudo chown root:interview-devops /srv/interview-project
sudo chmod 2770 /srv/interview-project
```

## Validation

```bash
id labuser1
id labuser2
ls -ld /srv/interview-project
sudo -u labuser1 touch /srv/interview-project/user1.txt
sudo -u labuser2 touch /srv/interview-project/user2.txt
ls -l /srv/interview-project
```

Expected directory permissions:

```text
drwxrws--- root interview-devops /srv/interview-project
```

## Failure Exercise

Remove execute permission from the group, test access, and explain why directory read permission alone is insufficient for traversal. Restore mode `2770` afterward.

---

# Lab 3 — ACL and Special Permissions

## Objective

Grant a named auditor read-only access without changing the directory's primary group.

## Tasks

```bash
sudo useradd -m -s /bin/bash auditor1
sudo setfacl -m u:auditor1:rx /srv/interview-project
sudo setfacl -m d:u:auditor1:r-X /srv/interview-project
getfacl /srv/interview-project
```

Test access:

```bash
sudo -u auditor1 ls -l /srv/interview-project
sudo -u auditor1 touch /srv/interview-project/auditor.txt
```

The listing should work, while file creation should fail.

## Questions

- What does the ACL mask control?
- What is the difference between an access ACL and a default ACL?
- Why is the sticky bit appropriate for shared directories such as `/tmp`?

---

# Lab 4 — Processes, Signals, and Priority

## Objective

Inspect a process and use graceful and forced termination correctly.

## Tasks

```bash
sleep 600 &
lab_pid=$!
ps -o pid,ppid,user,stat,ni,pri,cmd -p "$lab_pid"
kill -TERM "$lab_pid"
wait "$lab_pid" 2>/dev/null || true
```

Start another process with lower scheduling priority:

```bash
nice -n 10 sleep 600 &
lab_pid=$!
ps -o pid,ni,pri,cmd -p "$lab_pid"
kill -TERM "$lab_pid"
```

## Failure Exercise

Run a small script that ignores `SIGTERM` in the lab, attempt graceful termination, verify it remains, and use `SIGKILL` only after confirming the PID.

## Interview Practice

Explain why `kill -9` should not be the first action.

---

# Lab 5 — Custom systemd Service

## Objective

Create, validate, enable, monitor, break, and repair a systemd service.

Create `/usr/local/bin/interview-health.sh`:

```bash
#!/usr/bin/env bash
while true; do
    printf '%s service healthy\n' "$(date --iso-8601=seconds)"
    sleep 30
done
```

```bash
sudo chmod 755 /usr/local/bin/interview-health.sh
```

Create `/etc/systemd/system/interview-health.service`:

```ini
[Unit]
Description=Linux Interview Health Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/interview-health.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

## Start and Validate

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now interview-health.service
systemctl is-active interview-health.service
systemctl is-enabled interview-health.service
journalctl -u interview-health.service -n 20 --no-pager
```

## Failure Exercise

Temporarily change `ExecStart` to an invalid path. Run `daemon-reload`, restart, and diagnose with:

```bash
systemctl status interview-health.service --no-pager -l
journalctl -u interview-health.service -n 50 --no-pager
```

Restore the valid path and confirm recovery.

---

# Lab 6 — Disk Capacity and Inode Investigation

## Objective

Distinguish disk-block exhaustion, inode exhaustion, and deleted-but-open files.

## Tasks

```bash
df -hT
df -i
sudo du -xhd1 /var | sort -h
sudo find /var -xdev -type f -size +100M -ls
sudo lsof +L1
```

Create a safe practice filesystem if loop devices are permitted in the disposable lab, or use an instructor-provided small filesystem.

Generate many empty files to observe inode consumption:

```bash
mkdir -p /tmp/inode-lab
for number in $(seq 1 5000); do
    : > "/tmp/inode-lab/file-$number"
done
find /tmp/inode-lab -type f | wc -l
```

## Validation

Compare block and inode usage before and after. Remove only the explicitly created `/tmp/inode-lab` practice directory after confirming its path.

---

# Lab 7 — Persistent Mount Validation

## Objective

Mount a practice filesystem persistently using a UUID.

## Prerequisite

Use an instructor-provided disposable disk or loop-backed test device. Never format a device until its identity and lack of required data are confirmed.

## Workflow

```bash
lsblk -f
sudo blkid
sudo mkdir -p /mnt/interview-data
```

After the practice filesystem is prepared, add an entry using its actual UUID:

```fstab
UUID=<practice-filesystem-uuid> /mnt/interview-data <filesystem-type> defaults,nofail 0 2
```

## Mandatory Validation

```bash
sudo mount -a
findmnt /mnt/interview-data
df -hT /mnt/interview-data
```

## Failure Exercise

In a disposable environment, use an incorrect UUID, run `mount -a`, capture the error, and restore the correct entry before rebooting.

---

# Lab 8 — LVM Creation and Extension

## Objective

Understand the physical volume → volume group → logical volume → filesystem → mount relationship.

## Prerequisite

Use only an explicitly assigned disposable device.

## Tasks

```bash
lsblk -f
sudo pvcreate /dev/<practice-device>
sudo vgcreate vg_interview /dev/<practice-device>
sudo lvcreate -L 1G -n lv_data vg_interview
sudo mkfs.ext4 /dev/vg_interview/lv_data
sudo mkdir -p /mnt/lvm-data
sudo mount /dev/vg_interview/lv_data /mnt/lvm-data
```

Inspect layers:

```bash
sudo pvs
sudo vgs
sudo lvs
findmnt /mnt/lvm-data
```

Extend if the volume group has sufficient free space:

```bash
sudo lvextend -L +512M /dev/vg_interview/lv_data
sudo resize2fs /dev/vg_interview/lv_data
df -hT /mnt/lvm-data
```

## Interview Practice

Explain why extending the logical volume and growing the filesystem are separate concepts.

---

# Lab 9 — NFS Server and Client

## Objective

Export a shared directory and mount it from a second Linux system.

## Server Tasks

Install the distribution-appropriate NFS server package, then:

```bash
sudo mkdir -p /nfs/interview-share
sudo chown nobody:nogroup /nfs/interview-share 2>/dev/null || true
```

Example `/etc/exports`:

```exports
/nfs/interview-share 172.31.0.0/16(rw,sync,no_subtree_check)
```

```bash
sudo exportfs -rav
sudo exportfs -v
```

## Client Tasks

```bash
showmount -e <nfs-server>
sudo mkdir -p /mnt/interview-nfs
sudo mount -t nfs <nfs-server>:/nfs/interview-share /mnt/interview-nfs
findmnt /mnt/interview-nfs
```

Create a test file, verify it on both systems, and document UID/GID behavior.

## Failure Exercise

Use a client address outside the permitted export network or temporarily test an invalid export path. Diagnose connectivity, exports, firewall, permissions, and logs in order.

---

# Lab 10 — SSH Key Authentication

## Objective

Configure and troubleshoot public-key authentication safely.

## Client Tasks

```bash
ssh-keygen -t ed25519 -C 'linux-interview-lab'
ssh-copy-id labuser@server
ssh -vv labuser@server
```

## Server Validation

```bash
getent passwd labuser
sudo ls -ld /home/labuser /home/labuser/.ssh
sudo ls -l /home/labuser/.ssh/authorized_keys
sudo sshd -t
sudo systemctl status sshd
```

Service names may be `ssh` or `sshd` depending on the distribution.

## Failure Exercise

Set an intentionally incorrect permission on `.ssh`, test the connection, inspect authentication logs, restore secure permissions, and retest.

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

Keep an existing session open while testing SSH configuration changes.

---

# Lab 11 — Cron, systemd Timer, and Logrotate

## Objective

Schedule an operational script and control its log growth.

Create `/usr/local/bin/interview-report.sh`:

```bash
#!/usr/bin/env bash
set -u
printf '%s load=%s disk=%s\n' \
    "$(date --iso-8601=seconds)" \
    "$(cut -d' ' -f1 /proc/loadavg)" \
    "$(df -P / | awk 'NR==2 {print $5}')" \
    >> /var/log/interview-report.log
```

Schedule with cron in the lab:

```cron
*/5 * * * * /usr/local/bin/interview-report.sh
```

Create `/etc/logrotate.d/interview-report`:

```text
/var/log/interview-report.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 0640 root adm
}
```

Validate:

```bash
sudo logrotate -d /etc/logrotate.d/interview-report
```

## Failure Exercise

Use a relative command path or remove execute permission temporarily. Compare the cron environment with the interactive shell and correct the script.

---

# Lab 12 — Slow Server Incident

## Objective

Perform a timed, evidence-driven incident investigation.

## Incident Ticket

Users report that the application server became slow during the last 20 minutes. Restarting the server is not approved until evidence is collected.

## Investigation Commands

```bash
date
uptime
nproc
top
free -h
vmstat 1 5
iostat -xz 1 5
df -hT
df -i
ps aux --sort=-%cpu | head
ps aux --sort=-%mem | head
systemctl --failed
journalctl -p err --since '30 minutes ago'
ss -s
```

## Required Incident Report

Record:

- Symptoms and business impact
- Start time and recent changes
- CPU and run-queue evidence
- Memory and swap evidence
- Disk capacity and latency evidence
- Responsible process or dependency
- Immediate mitigation
- Root cause
- Recovery validation
- Prevention and monitoring improvements

## Time Target

- 5 minutes: establish scope and snapshot
- 10 minutes: classify the bottleneck
- 10 minutes: isolate the responsible process or dependency
- 5 minutes: present mitigation and prevention

---

# Lab Completion Tracker

| Lab | Status | Evidence Saved | Interview Explanation Ready |
|---:|---|---|---|
| 1. Environment baseline | Not Started | ☐ | ☐ |
| 2. Users and shared access | Not Started | ☐ | ☐ |
| 3. ACL and special permissions | Not Started | ☐ | ☐ |
| 4. Processes and signals | Not Started | ☐ | ☐ |
| 5. systemd service | Not Started | ☐ | ☐ |
| 6. Capacity and inodes | Not Started | ☐ | ☐ |
| 7. Persistent mount | Not Started | ☐ | ☐ |
| 8. LVM | Not Started | ☐ | ☐ |
| 9. NFS | Not Started | ☐ | ☐ |
| 10. SSH | Not Started | ☐ | ☐ |
| 11. Scheduling and rotation | Not Started | ☐ | ☐ |
| 12. Slow server incident | Not Started | ☐ | ☐ |

