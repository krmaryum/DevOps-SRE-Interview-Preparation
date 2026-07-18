# Linux Interview Questions and Model Answers

**Package:** 01 — Linux Interview Preparation  
**Questions:** 40  
**Levels:** Foundation, intermediate, advanced, and scenario-based

Use the model answers to check understanding. During practice, answer aloud before reading them.

---

# Foundation Questions

## 1. What is Linux?

Linux is an open-source operating-system kernel. A Linux distribution combines that kernel with system utilities, libraries, package-management tools, services, and applications.

## 2. What is the difference between the kernel, shell, and terminal?

The kernel manages hardware and system resources. The shell interprets commands and launches programs. The terminal is the interface through which a user interacts with a shell.

## 3. Explain the Linux boot process.

BIOS or UEFI initializes hardware and selects a boot device. GRUB loads the selected kernel and initramfs. The kernel initializes core subsystems and mounts the initial filesystem. Systemd normally starts as PID 1, activates targets and services, and presents a login interface.

## 4. What is PID 1?

PID 1 is the first userspace process started by the kernel. On many distributions it is systemd. It initializes services and adopts orphaned processes.

## 5. What is an inode?

An inode stores filesystem metadata such as ownership, permissions, timestamps, file type, and references to data blocks. The filename is stored in a directory entry that points to the inode.

## 6. What is the difference between a hard link and a symbolic link?

A hard link is another directory entry for the same inode and normally cannot cross filesystems. A symbolic link is a separate file containing a path, can cross filesystems, and can become broken if its target moves or is deleted.

## 7. What does permission `750` mean?

The owner has read, write, and execute permissions. The group has read and execute permissions. Others have no permissions.

## 8. How do directory permissions differ from file permissions?

For a directory, read lists names, write permits creation/deletion/renaming of entries, and execute permits traversal and access to entries. For a regular file, read accesses content, write modifies content, and execute permits running it as a program.

## 9. What are SUID, SGID, and the sticky bit?

SUID on an executable uses the file owner's effective identity. SGID on an executable uses the file group's effective identity; on a directory, it causes new entries to inherit the directory's group. The sticky bit on a shared directory restricts deletion to the file owner, directory owner, or root.

## 10. What is an ACL?

An access control list grants permissions to additional named users or groups beyond the standard owner, group, and others model. Default directory ACLs can be inherited by new entries.

---

# Process and Service Questions

## 11. What is the difference between a program and a process?

A program is executable code stored on disk. A process is a running instance of that program with a PID, memory, open files, credentials, and execution state.

## 12. What is the difference between a zombie and an orphan process?

A zombie has exited but its parent has not collected the exit status. An orphan remains running after its parent exits and is adopted by PID 1 or another subreaper.

## 13. What do process states `R`, `S`, `D`, and `Z` mean?

`R` is running or runnable, `S` is interruptible sleep, `D` is uninterruptible sleep commonly related to I/O, and `Z` is zombie.

## 14. Why should `SIGKILL` not be the first termination signal?

SIGKILL cannot be caught or handled, so a process cannot clean up files, locks, connections, or transactions. SIGTERM should normally be attempted first for graceful shutdown.

## 15. What is the difference between `systemctl start` and `enable`?

`start` launches the service now. `enable` configures it to start automatically at the appropriate boot target. `enable --now` performs both.

## 16. What is the difference between service reload and restart?

Reload asks a service to re-read supported configuration without fully stopping. Restart stops and starts the service, generally causing more disruption. Not every service supports reload.

## 17. What should you check when a service fails to start?

Check service status, journal logs, configuration validation, unit definition, required files and permissions, dependencies, ports, disk space, security policy, and recent changes.

---

# Performance and Storage Questions

## 18. What is load average?

Linux load average is the average number of runnable tasks plus tasks in uninterruptible sleep over 1, 5, and 15 minutes. It must be interpreted relative to CPU count, I/O, workload behavior, and baseline.

## 19. Can load be high while CPU usage is low?

Yes. Tasks waiting in uninterruptible sleep for disk, NFS, or another I/O dependency increase load while CPU can remain idle.

## 20. What is the difference between free and available memory?

Free memory is completely unused. Available memory estimates how much can be used without heavy swapping, including reclaimable cache.

## 21. What are RSS and VSZ?

RSS is a process's resident memory currently held in RAM. VSZ is its total virtual address space. A large VSZ alone does not prove equivalent physical-memory use.

## 22. What is swap, and is swap usage always a problem?

Swap is disk-backed space for inactive memory pages. Some swap use is not automatically a problem. Sustained swap-in/out combined with latency and low available memory indicates pressure.

## 23. What is the OOM killer?

When memory is critically exhausted, the kernel may select and terminate a process to preserve system operation. Kernel logs show which process was killed and why.

## 24. Why can `df` and `du` report different usage?

`df` reports allocated filesystem blocks, while `du` counts visible files. A deleted file held open by a process remains allocated but is invisible to `du`. Use `lsof +L1` to investigate.

## 25. How can a filesystem have free space but still reject new files?

Its inodes may be exhausted. Use `df -i` to check inode utilization.

## 26. What are IOPS, throughput, and latency?

IOPS measures operations per second, throughput measures data transferred per unit of time, and latency measures how long an operation takes. Different workloads can be constrained by different metrics.

## 27. What is LVM?

LVM is a flexible storage layer. Physical volumes contribute storage to volume groups; logical volumes allocate space from those pools and hold filesystems or other data.

## 28. Why use a UUID in `/etc/fstab`?

UUIDs identify filesystems reliably even if kernel device names change between boots.

---

# Networking, SSH, and Automation Questions

## 29. What is the difference between `127.0.0.1`, `0.0.0.0`, and a server IP in a listening socket?

`127.0.0.1` accepts local loopback connections only. `0.0.0.0` generally listens on all IPv4 interfaces. A specific server IP listens only on that assigned interface/address.

## 30. What is the difference between connection refused and timeout?

Refused usually means the destination actively rejected the connection or nothing listens on the port. Timeout often suggests dropped traffic, routing failure, filtering, or a nonresponsive path. Packet evidence should confirm the interpretation.

## 31. Which commands help diagnose DNS?

`getent hosts` tests system resolver behavior, while `dig` or `nslookup` queries DNS details. Also inspect resolver configuration and network reachability.

## 32. How do you safely change SSH configuration remotely?

Keep the current session open, validate with `sshd -t`, apply the change carefully, test a second connection, and close the original session only after successful validation.

## 33. Why can a script work manually but fail through cron?

Cron normally uses a minimal environment, different PATH, working directory, user, shell, permissions, and credentials. Use absolute paths, explicit environment, logging, and the correct execution user.

## 34. What are the advantages of systemd timers over cron?

Timers integrate with services, dependencies, journal logging, missed-run handling, status inspection, and resource controls.

## 35. What does logrotate do?

It controls log growth by rotating, retaining, compressing, and recreating logs according to policy. Applications may require a supported signal or reload to reopen a rotated file.

---

# Scenario Questions

## 36. A server is slow. What do you do first?

Clarify the symptom, scope, timeline, and recent changes. Capture CPU, load, memory, swap, disk capacity, I/O, processes, services, logs, and network evidence. Isolate the bottleneck before taking disruptive action.

## 37. The root filesystem is full. How do you respond?

Check blocks and inodes, identify large directories and files without crossing filesystems, inspect logs and deleted-but-open files, restore safe capacity through an approved action, and correct retention, rotation, or provisioning.

## 38. A service is active but clients cannot connect. What do you check?

Confirm the application listens on the expected IP and port, test locally, inspect host firewall and cloud rules, validate routes and load balancer health, then review application responses and logs.

## 39. SSH says `Permission denied (publickey)`. What do you check?

Confirm user, server, port, and key with verbose client output. On the server, verify account state, home and `.ssh` ownership, permissions, authorized key content, SSH access rules, logs, and SELinux context where applicable.

## 40. What should happen after an incident is resolved?

Validate recovery technically and with affected users, document timeline and root cause, capture lessons learned, and add specific prevention through code, automation, monitoring, capacity, testing, or operational standards.

---

# Personal Project Answer Template

Use STAR plus technical depth:

- **Situation:** Environment and business problem
- **Task:** Your responsibility
- **Action:** Evidence, commands, decisions, and collaboration
- **Result:** Measurable recovery or improvement
- **Prevention:** Automation, monitoring, documentation, or design improvement

