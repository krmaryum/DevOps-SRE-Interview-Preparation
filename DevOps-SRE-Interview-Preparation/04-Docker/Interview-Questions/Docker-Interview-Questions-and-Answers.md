# Docker Interview Questions and Answers

## Foundations and Architecture

### 1. What problem does Docker solve?

Docker packages an application, runtime, libraries, and configuration defaults into a portable image. It reduces environment drift and gives teams a repeatable way to build, distribute, and run isolated processes.

### 2. How is a container different from a virtual machine?

A VM virtualizes hardware and runs a full guest kernel. A container is an isolated host process and shares the host kernel. Containers normally start faster and use fewer resources, while VMs provide a stronger kernel boundary and can run different operating-system kernels.

### 3. Describe Docker architecture.

The CLI or another client calls the Docker daemon API. The daemon manages images, networks, volumes, and containers and delegates lower-level lifecycle work through components such as containerd and an OCI runtime. Registries store and distribute images.

### 4. What Linux features make containers possible?

Namespaces isolate views of processes, networking, mounts, IPC, hostname, and users. Cgroups account for and constrain resources. Capabilities split root privileges, while seccomp and LSMs such as AppArmor or SELinux restrict operations. Layered filesystems support efficient images.

### 5. What is the difference between an image and a container?

An image is an immutable template made from content-addressed layers and metadata. A container is a runtime instance with isolated configuration and a writable layer. Multiple containers can start from one image.

### 6. What are tags and digests?

A tag is a convenient, mutable name such as `app:1.4`. A digest identifies image content, such as `app@sha256:...`. Pinning a digest makes the selected content unambiguous, though update and vulnerability processes are still required.

### 7. What happens during `docker run`?

Docker resolves or pulls the image, creates the container configuration and writable layer, attaches networking and mounts, applies isolation and resource settings, and starts the configured process. `docker run` is essentially create plus start, with optional attachment.

### 8. Why does a container stop when its main process exits?

A container’s lifecycle is tied to PID 1 in its PID namespace. When that process exits, the container has no main workload and becomes stopped with its exit code.

## Images and Dockerfiles

### 9. What is a Docker image layer?

A layer is an immutable filesystem change produced by an image-building instruction. Layers are content-addressed and reusable across images. A container adds a writable layer above them.

### 10. How does the build cache work?

The builder reuses a previous result when an instruction and its relevant inputs match. Once a layer changes, dependent later layers are rebuilt. Stable, expensive steps should generally precede frequently changed source copies.

### 11. What is build context?

It is the set of files available to the builder, normally the final path in `docker build`. `COPY` cannot access arbitrary host paths outside it. A small context improves speed and reduces accidental secret exposure.

### 12. Why use `.dockerignore`?

It excludes unnecessary or sensitive files from the build context—for example `.git`, local dependencies, logs, test output, and secrets. This speeds transfers and prevents unintended files from becoming build inputs.

### 13. What is the difference between `COPY` and `ADD`?

`COPY` performs explicit local file copying and is usually preferred. `ADD` has extra behavior, including local archive extraction and URL/Git source capabilities in supported builders. Use the least surprising instruction.

### 14. What is the difference between `CMD` and `ENTRYPOINT`?

`ENTRYPOINT` defines the executable; `CMD` provides a default command or default arguments. Runtime arguments replace `CMD` but are appended to an exec-form `ENTRYPOINT`. Both can be overridden explicitly.

### 15. Why prefer exec-form commands?

`["program","arg"]` starts the program directly, avoiding an implicit shell. It handles arguments predictably and lets PID 1 receive signals directly. Shell form is useful only when shell expansion is intentionally required.

### 16. What is a multi-stage build?

It uses multiple `FROM` stages, builds artifacts in one stage, and copies only runtime output into the final stage. This removes compilers and source from the runtime image and usually improves size and security.

### 17. How would you optimize an image?

Use a suitable minimal trusted base, multi-stage builds, a small context, cache-aware ordering, pinned and cleaned dependencies, and only required runtime files. Then measure size, startup, compatibility, and vulnerabilities rather than optimizing by size alone.

### 18. Why should versions be pinned?

Mutable dependencies can make identical source build differently later. Pinning base content and application dependencies improves repeatability. A controlled update process must still rebuild with security fixes.

## Runtime Operations

### 19. How do `stop` and `kill` differ?

`stop` sends the configured stop signal, normally SIGTERM, waits for the timeout, then sends SIGKILL. `kill` sends a signal immediately—SIGKILL by default, though another signal can be selected.

### 20. Why is PID 1 special inside a container?

PID 1 must reap orphaned child processes and has special signal semantics. Applications should handle and forward termination correctly; otherwise use a minimal init with `--init` when appropriate.

### 21. How do you troubleshoot an exited container?

Start with `docker ps -a`, logs, and `.State` from inspect. Check exit code, OOM state, error, command, environment, mounts, and permissions. Reproduce with the same configuration and change one hypothesis at a time.

### 22. What is a health check?

It periodically runs a probe and records starting, healthy, or unhealthy state. It should test a meaningful local capability with realistic interval, timeout, retries, and start period. It does not automatically restart an unhealthy container in plain Docker.

### 23. What are restart policies?

They define when Docker restarts a stopped container: `no`, `on-failure`, `always`, or `unless-stopped`. They improve recovery from process failure but do not replace health checks, dependency retries, or orchestration.

### 24. How are CPU and memory controlled?

Cgroups apply configured limits and accounting. CPU quota affects scheduling and can cause throttling. A hard memory limit can lead to an OOM kill when the workload cannot reclaim enough memory.

### 25. What commands do you use for live diagnosis?

`docker ps`, `inspect`, `logs`, `top`, `stats`, `events`, `port`, network/volume inspection, and carefully scoped `exec`. I correlate these with host resource, firewall, filesystem, and daemon evidence.

## Networking and Storage

### 26. Explain Docker bridge networking.

A bridge network provides an isolated Layer 2 segment on the host. Containers receive interfaces and IPs; host NAT commonly provides outbound access and published-port ingress. User-defined bridges also provide automatic DNS-based discovery.

### 27. What does `-p 8080:80` mean?

Docker publishes host TCP port 8080 and forwards it to container port 80. It does not change the port on which the application listens. A host IP may be added, such as `127.0.0.1:8080:80`.

### 28. Does `EXPOSE` publish a port?

No. `EXPOSE` documents intended listening ports in image metadata. Publishing occurs at runtime through `-p`, `-P`, Compose, or orchestration configuration.

### 29. Why can’t one container reach another using `localhost`?

Each container has its own network namespace, so `localhost` refers to itself. On a shared user-defined network, connect using the other service’s DNS name and container port.

### 30. Compare bind mounts, named volumes, and tmpfs.

A bind mount maps a specific host path and is tightly host-coupled. A named volume is managed by Docker and is usually preferred for persistent application data. A tmpfs resides in memory and is ephemeral, useful for temporary or sensitive runtime data.

### 31. Why can bind mounts cause permission problems?

The kernel evaluates numeric UID/GID and host security labels. A username inside the image may map to an unexpected host ID. Read-only flags, parent permissions, and SELinux labels can also block access.

### 32. How do you back up a Docker volume?

First obtain an application-consistent state, then mount the volume read-only into a controlled backup process or use the storage platform’s snapshot mechanism. Encrypt, retain, and regularly test restores. Copying live files without application coordination may be inconsistent.

## Compose, Security, and Production

### 33. What does Docker Compose provide?

Compose declaratively defines related services, networks, volumes, health checks, environment, and runtime settings. It supports repeatable local or single-host workflows; it is not itself a full multi-node orchestrator.

### 34. Does `depends_on` guarantee application readiness?

Start order alone does not mean ready. Use a meaningful dependency health check and a supported health-based condition, while keeping clients resilient with bounded retries because dependencies can fail later too.

### 35. Why run containers as non-root?

It reduces the impact of application compromise and accidental writes. Use a known UID/GID, grant only needed file ownership, drop capabilities, and avoid privilege escalation. Non-root is one control, not a complete boundary.

### 36. What is a privileged container?

Privileged mode grants broad device and kernel access and disables important isolation controls. It substantially increases host risk and should be replaced with narrowly scoped devices, capabilities, and security-profile exceptions where possible.

### 37. How should secrets be provided?

Do not bake secrets into image layers, source, build arguments, or ordinary environment variables when a safer secret mechanism exists. Use an approved secret manager or runtime-mounted secret, narrow access, rotate credentials, and prevent log exposure.

### 38. How do you secure a container image supply chain?

Use trusted minimal bases, pin and regularly update dependencies, scan images, generate an SBOM, sign and verify artifacts where supported, restrict registry permissions, protect CI credentials, and promote the same tested digest between environments.

### 39. What is rootless Docker?

Rootless mode runs the daemon and containers without host root, using user namespaces and unprivileged components. It reduces daemon compromise impact, though some networking, port, cgroup, or device capabilities may differ by host.

### 40. How would you explain a production-ready Docker design?

I would cover reproducible multi-stage builds, trusted pinned inputs, non-root execution, minimal privileges, read-only filesystems, explicit writable mounts, health and graceful shutdown, resource limits, structured logs, secure secrets, immutable image promotion, scanning, monitoring, rollback, backup, and tested incident procedures.

---

**Author:** Muhammad Khalid Khan  
**Repository:** DevOps & SRE Interview Preparation
