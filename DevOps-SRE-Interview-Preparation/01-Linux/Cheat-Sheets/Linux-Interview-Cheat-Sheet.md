# Linux Interview Cheat Sheet

**Package:** 01 — Linux Interview Preparation  
**Purpose:** Fast revision before labs, assessments, and interviews

---

## Architecture and Boot

```text
User → Terminal → Shell → Libraries/System Calls → Kernel → Hardware
BIOS/UEFI → GRUB → Kernel → initramfs → systemd (PID 1) → Services → Login
```

```bash
uname -r
cat /etc/os-release
systemctl get-default
systemd-analyze
journalctl -b
journalctl -b -1
```

## Important Directories

| Path | Purpose |
|---|---|
| `/etc` | System configuration |
| `/var` | Logs and changing application data |
| `/home` | Regular user homes |
| `/root` | Root user's home |
| `/boot` | Kernel and boot files |
| `/usr` | Applications, libraries, shared data |
| `/proc` | Virtual process/kernel information |
| `/sys` | Virtual device/kernel interface |
| `/dev` | Device files |
| `/run` | Runtime state since boot |
| `/tmp` | Temporary data |

## Users and Permissions

```bash
id user
getent passwd user
useradd -m -s /bin/bash user
usermod -aG group user
passwd -S user
chown user:group file
chmod 750 script.sh
getfacl file
setfacl -m u:user:rw file
```

```text
r=4  w=2  x=1
SUID=4xxx  SGID=2xxx  Sticky=1xxx
```

## Processes and Signals

```bash
ps aux
ps -ef
pgrep -a process
pstree -p
top
kill -TERM PID
kill -KILL PID
nice -n 10 command
renice 5 -p PID
```

| State | Meaning |
|---|---|
| `R` | Running/runnable |
| `S` | Interruptible sleep |
| `D` | Uninterruptible sleep |
| `T` | Stopped/traced |
| `Z` | Zombie |

## systemd and Logs

```bash
systemctl status service
systemctl enable --now service
systemctl restart service
systemctl reload service
systemctl --failed
systemctl cat service
journalctl -u service
journalctl -p err -b
journalctl -k
journalctl -f
```

## CPU and Load

```bash
uptime
nproc
top
mpstat -P ALL 1 5
pidstat 1 5
vmstat 1 5
ps aux --sort=-%cpu | head
```

```text
Load includes runnable tasks + uninterruptible tasks.
Compare load with CPU count, I/O wait, blocked tasks, duration, and baseline.
```

## Memory

```bash
free -h
vmstat 1 5
swapon --show
ps aux --sort=-%mem | head
journalctl -k | grep -i -E 'oom|out of memory|killed process'
```

```text
RSS = resident RAM
VSZ = virtual address space
si/so = swap in/out in vmstat
```

## Disk and Filesystems

```bash
df -hT
df -i
du -xhd1 /var | sort -h
find /var -xdev -type f -size +500M -ls
lsof +L1
lsblk -f
blkid
findmnt
mount -a
```

```text
df high + du low → check deleted-but-open files
Free blocks + file creation failure → check inodes
```

## Disk I/O

```bash
iostat -xz 1 5
pidstat -d 1 5
iotop
vmstat 1 5
```

```text
IOPS = operations/second
Throughput = data/second
Latency = time per operation
```

## LVM

```text
Disk → PV → VG → LV → Filesystem → Mount
```

```bash
pvs
vgs
lvs
pvcreate /dev/device
vgcreate vg_name /dev/device
lvcreate -L 5G -n lv_name vg_name
lvextend -L +2G /dev/vg_name/lv_name
xfs_growfs /mountpoint
resize2fs /dev/vg_name/lv_name
```

## NFS

```bash
exportfs -v
exportfs -rav
showmount -e server
mount -t nfs server:/export /mnt/path
findmnt /mnt/path
```

## Package Management

| Task | Ubuntu/Debian | RHEL family |
|---|---|---|
| Refresh metadata | `apt update` | `dnf makecache` |
| Install | `apt install pkg` | `dnf install pkg` |
| Query installed | `dpkg -l` | `rpm -q pkg` |
| List package files | `dpkg -L pkg` | `rpm -ql pkg` |

## SSH

```bash
ssh -vvv user@server
ssh-keygen -t ed25519
ssh-copy-id user@server
sshd -t
systemctl status sshd
journalctl -u sshd
```

```text
~/.ssh                 700
authorized_keys        600
private key            600
public key             644
```

## Scheduling and Rotation

```bash
crontab -l
systemctl list-timers --all
logrotate -d /etc/logrotate.d/name
```

```text
Cron failures: PATH, user, working directory, environment, shell, permissions, credentials.
```

## Networking

```bash
ip -br link
ip -br address
ip route
ip route get 8.8.8.8
ss -lntup
getent hosts example.com
dig example.com
ping -c 4 host
traceroute host
curl -v https://host
nc -vz host 443
tcpdump -ni any port 443
```

```text
IP works, name fails → DNS
Refused → active rejection/no listener
Timeout → dropped traffic/routing/filtering/nonresponse
Service active, remote fails → bind address, firewall, route, security rules
```

## Incident Answer Order

```text
1. Scope and impact
2. Recent changes
3. Evidence
4. Isolation
5. Safe mitigation
6. Root-cause fix
7. Recovery validation
8. Prevention
```

## Five Commands to Avoid Using Blindly

```text
kill -9
rm -rf
chmod -R 777
reboot
systemctl restart
```

Confirm target and impact, capture evidence, use the least disruptive action, and keep rollback available.

