# Docker Troubleshooting Scenarios

Use the sequence **scope → inspect → form a hypothesis → test → correct → prevent**. Preserve evidence before restarting or deleting resources.

## Fast Triage

```bash
docker version
docker ps -a --no-trunc
docker inspect CONTAINER
docker logs --timestamps --tail 100 CONTAINER
docker events --since 30m
docker stats --no-stream
docker system df
```

## 1. Docker Daemon Unavailable or Permission Denied

**Symptoms:** “Cannot connect to the Docker daemon” or permission denied on the socket.

**Investigate:** run `docker context show`, `docker version`, inspect the daemon service, socket ownership, and the `DOCKER_HOST` variable. Do not blindly change socket permissions.

**Likely causes:** daemon stopped, wrong context, invalid remote endpoint, or user lacks approved group/rootless access.

**Resolution:** start/fix the daemon, select the intended context, or grant access through the organization’s supported method. Re-login after group changes.

## 2. Build Cannot Find a File

**Symptoms:** `COPY` fails although the file exists on the host.

**Investigate:** confirm the final build-context argument, relative path, case, `.dockerignore`, and BuildKit output.

**Root cause:** Docker can copy only from the build context, and ignored files are excluded.

**Resolution:** build from the correct directory, adjust `COPY`, or narrowly correct `.dockerignore`. Never expand context to sensitive parent directories without review.

## 3. Unexpected Content After Rebuild

**Investigate:** use `docker build --progress=plain`, inspect the Dockerfile order, build arguments, source timestamps, and image ID.

**Resolution:** fix missing inputs or Dockerfile ordering; use `--no-cache` once to prove a cache hypothesis, not as the default solution. Pin remote dependencies.

## 4. Container Exits Immediately

```bash
docker ps -a --no-trunc
docker logs CONTAINER
docker inspect CONTAINER --format '{{json .State}}'
```

**Likely causes:** main process completed, invalid command, missing file, configuration error, permissions, or application crash.

**Resolution:** correct the foreground PID 1 command and configuration. A container stays alive only while its main process runs.

## 5. Published Port Is Unreachable

**Check:** `docker port`, `docker inspect`, application logs, host listener/firewall, routing, and `curl` from both host and container network.

**Common causes:** reversed `host:container` port, application not listening, wrong protocol, host port conflict, firewall, or binding only to loopback.

## 6. Application Binds to Container Loopback

**Symptom:** `curl localhost` works inside the container but the published port fails externally.

**Cause:** the process listens on `127.0.0.1` inside its own network namespace.

**Resolution:** configure it to listen on `0.0.0.0` or the appropriate container interface; restrict external exposure using the host publish address and firewall.

## 7. Containers Cannot Resolve Each Other

**Check:** both containers’ networks, aliases, embedded DNS, requested service name, and whether the application uses `localhost` incorrectly.

**Resolution:** attach services to the same user-defined network and connect to the service/container DNS name and container port.

## 8. Data Disappears After Replacement

**Cause:** data was written to the ephemeral writable container layer.

**Investigate:** inspect mounts and application data path. Determine whether an anonymous volume was silently created.

**Resolution:** use a named volume or explicit bind mount, verify the actual path, and implement tested backups. Do not treat a volume as a backup.

## 9. Bind-Mounted File Permission Failure

**Investigate:** compare numeric UID/GID inside and outside, mount mode, parent-directory traversal permissions, SELinux label, and read-only state.

**Resolution:** align IDs and least-privilege permissions; on SELinux hosts use the approved relabeling approach. Avoid `chmod 777` as a shortcut.

## 10. Container Is Running but Unhealthy

```bash
docker inspect CONTAINER --format '{{json .State.Health}}'
docker exec CONTAINER COMMAND_USED_BY_HEALTHCHECK
```

**Causes:** missing health-check binary, wrong URL/port, inadequate start period, dependencies unavailable, or genuine application failure.

**Resolution:** make the probe test a meaningful local capability, use realistic timing, and ensure the probe tool exists. Running and healthy are different states.

## 11. OOMKilled or CPU Throttling

**Check:** `.State.OOMKilled`, exit code, configured limits, `docker stats`, host pressure, and application metrics.

**Resolution:** correct memory leaks or workload sizing, then set evidence-based limits. For CPU, distinguish quota throttling from host contention. Do not merely increase limits without understanding demand.

## 12. Docker Disk Usage Keeps Growing

```bash
docker system df -v
docker ps -a --size
docker volume ls
```

**Causes:** unused images/layers, stopped containers, build cache, unused volumes, or unbounded JSON logs.

**Resolution:** identify owners and retention requirements, configure log rotation, and remove only confirmed unused resources. Never start incident response with an indiscriminate prune.

## 13. ENTRYPOINT and CMD Behave Unexpectedly

**Investigate:** inspect `.Config.Entrypoint` and `.Config.Cmd`; compare exec and shell forms; review Compose `entrypoint` and `command` overrides.

**Resolution:** use exec form for predictable signal delivery. Treat `ENTRYPOINT` as the executable and `CMD` as default arguments when that model suits the image.

## 14. Registry Authentication or Platform Error

**Check:** exact registry/repository/tag, credentials helper, token scope, manifest platforms, host architecture, proxy, certificate trust, and pull rate limits.

**Resolution:** authenticate to the correct registry, request the right repository permission, publish/select a supported platform, or use an approved trusted registry certificate configuration.

## 15. Compose Dependency Is Started but Not Ready

**Symptom:** an application fails during startup although the dependency container exists.

**Cause:** start order is not readiness. A TCP listener may also appear before the service is usable.

**Resolution:** add a meaningful dependency health check, use supported health-based dependency conditions, and make clients retry transient failures with bounded backoff.

## Interview Response Template

> I first confirm scope and preserve evidence. I compare desired configuration with runtime state using `docker ps`, `inspect`, logs, events, network/mount inspection, and host signals. I test one hypothesis at a time, apply the smallest reversible correction, verify service health, and then add a prevention measure such as a health check, resource alert, pinned image, safer Dockerfile, or runbook update.

---

**Author:** Muhammad Khalid Khan  
**Repository:** DevOps & SRE Interview Preparation
