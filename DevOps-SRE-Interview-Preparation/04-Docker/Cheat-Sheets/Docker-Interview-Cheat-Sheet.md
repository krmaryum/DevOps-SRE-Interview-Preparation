# Docker Interview Cheat Sheet

## Mental Model

```text
Dockerfile + build context -> image layers -> registry -> container
container = image + writable layer + process + isolation + runtime config
```

| Object | Purpose | Lifecycle clue |
|---|---|---|
| Image | Immutable application template | Content-addressed layers |
| Container | Runtime instance of an image | Stops when PID 1 exits |
| Network | Container connectivity and isolation | User-defined bridge provides DNS |
| Volume | Docker-managed persistent data | Survives container replacement |
| Registry | Image distribution | Repository + tag or digest |

## Essential Commands

```bash
# Environment and inventory
docker version
docker info
docker ps -a --no-trunc
docker images --digests

# Images
docker pull IMAGE
docker build --progress=plain -t NAME:TAG .
docker image inspect IMAGE
docker image history IMAGE
docker tag SOURCE TARGET

# Containers
docker run --name NAME -d -p 127.0.0.1:8080:80 IMAGE
docker stop --time 10 NAME
docker start NAME
docker rm NAME
docker exec -it NAME sh

# Evidence
docker logs --timestamps --tail 100 NAME
docker inspect NAME
docker top NAME
docker stats --no-stream NAME
docker events --since 30m
docker port NAME

# Networks and volumes
docker network create NET
docker network inspect NET
docker volume create VOL
docker volume inspect VOL
docker run --mount type=volume,src=VOL,dst=/data IMAGE

# Compose
docker compose config
docker compose up --build -d
docker compose ps
docker compose logs -f SERVICE
docker compose exec SERVICE sh
docker compose down

# Usage—inspect before deleting
docker system df -v
```

## Dockerfile Quick Reference

| Instruction | Meaning |
|---|---|
| `FROM` | Select base or begin build stage |
| `ARG` | Build-time variable; not for secrets |
| `ENV` | Image/runtime environment default |
| `WORKDIR` | Set directory for later instructions/runtime |
| `COPY` | Copy files from build context/stage |
| `RUN` | Create a build layer by executing a command |
| `USER` | Set runtime/build user for later instructions |
| `EXPOSE` | Document intended port; does not publish |
| `HEALTHCHECK` | Define container health probe |
| `ENTRYPOINT` | Main executable |
| `CMD` | Default command or arguments |

```dockerfile
FROM builder-image AS build
WORKDIR /src
COPY dependency-files ./
RUN install-dependencies
COPY . .
RUN build-application

FROM trusted-runtime
COPY --from=build /src/output /app
USER 10001:10001
ENTRYPOINT ["/app/server"]
```

## Storage

| Type | Best fit | Main caution |
|---|---|---|
| Writable layer | Disposable runtime changes | Lost with container removal |
| Bind mount | Host source/config integration | Host coupling and UID/label issues |
| Named volume | Persistent app data | Needs backup and lifecycle ownership |
| tmpfs | Temporary sensitive/high-speed data | Lost on stop and consumes memory |

## Networking

- `-p HOST_IP:HOST_PORT:CONTAINER_PORT`
- `EXPOSE` is metadata, not a firewall or publish action.
- `localhost` inside a container means that container.
- Use a shared user-defined network and service DNS names.
- Application must listen on the expected interface, commonly `0.0.0.0`.
- Publishing on `127.0.0.1` limits host-side reachability; `0.0.0.0` is broader.

## Signals, Health, and Resources

- `docker stop`: graceful signal, timeout, then SIGKILL.
- PID 1 must handle signals and reap children; consider `--init` when needed.
- Running is not the same as ready or healthy.
- Restart policies act after process exit; plain Docker does not restart solely for unhealthy state.
- Memory exhaustion may set `.State.OOMKilled=true` and exit 137.
- CPU quota causes throttling rather than a guaranteed CPU reservation.

## Security Checklist

- Trusted, minimal, maintained base image
- Pinned dependencies/digests plus scheduled updates
- Multi-stage build and small `.dockerignore` context
- Non-root user and correct file ownership
- Drop capabilities; no privileged mode
- Read-only root filesystem and explicit writable mounts
- No secrets in image layers, build args, source, or logs
- Resource limits and meaningful health check
- Image scan, SBOM, signing/verification where supported
- Restricted daemon socket and registry permissions

## Troubleshooting Order

```text
scope -> ps -> inspect -> logs -> events -> network/mount/resource checks
      -> one hypothesis -> smallest correction -> verify -> prevent
```

| Symptom | First evidence |
|---|---|
| Exited | State, exit code, logs, OOM flag |
| Unhealthy | Health log and exact probe command |
| Port failure | Published mapping, process listener, bind address |
| DNS failure | Attached networks, service name, DNS config |
| Missing data | Mount destination and volume identity |
| Permission error | UID/GID, mode, read-only flag, SELinux label |
| Disk growth | `docker system df -v`, logs, volumes, cache |
| Build mismatch | Context, `.dockerignore`, cache output, image ID |

## Strong Interview Phrases

- “I compare desired configuration with runtime state.”
- “A tag is mutable; a digest identifies content.”
- “Start order is not readiness.”
- “A volume provides persistence, not a backup.”
- “I preserve evidence before restarting or pruning.”
- “I use the smallest privilege and the smallest reversible correction.”

---

**Author:** Muhammad Khalid Khan  
**Repository:** DevOps & SRE Interview Preparation
