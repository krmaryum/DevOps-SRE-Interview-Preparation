# Docker Hands-on Labs

These labs turn Docker interview topics into observable behavior. Run them on a disposable Docker host. Record commands, expected results, actual results, and one troubleshooting lesson for every lab.

> Safety: inspect resources before cleanup. Do not remove images, containers, or volumes that belong to other projects.

## Lab 1 — Inspect the Docker Environment

**Goal:** identify the client, daemon, runtime, storage driver, and host configuration.

```bash
docker version
docker info
docker context ls
docker system info --format '{{.ServerVersion}} {{.Driver}} {{.CgroupDriver}}'
```

**Verify:** explain which output comes from the client and which requires the daemon. Identify the storage and cgroup drivers.

## Lab 2 — Pull, Inspect, Tag, and Identify an Image

```bash
docker pull alpine:3.20
docker image inspect alpine:3.20
docker image history alpine:3.20
docker tag alpine:3.20 local/alpine:lab
docker images --digests
```

**Verify:** distinguish repository, tag, image ID, and registry digest. Explain why a digest is a stronger deployment reference than a mutable tag.

## Lab 3 — Container Lifecycle and PID 1

```bash
docker create --name lifecycle alpine:3.20 sleep 300
docker start lifecycle
docker ps
docker top lifecycle
docker inspect lifecycle --format '{{.State.Status}} PID={{.State.Pid}}'
docker stop --time 5 lifecycle
docker start lifecycle
docker kill --signal SIGTERM lifecycle
docker inspect lifecycle --format 'exit={{.State.ExitCode}}'
docker rm lifecycle
```

**Verify:** describe `create`, `start`, `run`, graceful stop, signal handling, and exit status.

## Lab 4 — Dockerfile Layers and Build Cache

Create a small Dockerfile whose dependency step appears before frequently changed source files.

```dockerfile
FROM alpine:3.20
RUN apk add --no-cache curl
WORKDIR /app
COPY message.txt .
CMD ["cat", "/app/message.txt"]
```

```bash
docker build --progress=plain -t cache-lab:v1 .
docker build --progress=plain -t cache-lab:v2 .
docker history cache-lab:v2
```

Change `message.txt`, rebuild, and identify which layer invalidates. Then change the `RUN` instruction and compare.

## Lab 5 — Commands, Environment, Logs, and Exit Codes

```bash
docker run --name env-lab -e APP_MODE=interview alpine:3.20 \
  sh -c 'echo "mode=$APP_MODE"; echo warning >&2; exit 7'
docker logs env-lab
docker inspect env-lab --format '{{.State.ExitCode}}'
docker rm env-lab
```

**Verify:** find stdout, stderr, configured environment, final command, and exit code with `docker inspect`.

## Lab 6 — Port Publishing and Bind Addresses

```bash
docker run -d --name web-lab -p 127.0.0.1:8081:80 nginx:alpine
docker port web-lab
curl -I http://127.0.0.1:8081
docker inspect web-lab --format '{{json .NetworkSettings.Ports}}'
docker rm -f web-lab
```

Repeat using `-p 8081:80`. Compare the host exposure. Explain why `EXPOSE 80` alone does not publish a port.

## Lab 7 — User-Defined Bridge Networking and DNS

```bash
docker network create interview-net
docker run -d --name web --network interview-net nginx:alpine
docker run --rm --network interview-net alpine:3.20 \
  wget -qO- http://web
docker network inspect interview-net
docker rm -f web
docker network rm interview-net
```

**Verify:** show name-based service discovery. Repeat on the default bridge and explain the difference.

## Lab 8 — Bind Mounts, Volumes, and tmpfs

```bash
docker volume create interview-data
docker run --rm -v interview-data:/data alpine:3.20 sh -c 'date > /data/proof'
docker run --rm -v interview-data:/data:ro alpine:3.20 cat /data/proof
docker run --rm --tmpfs /scratch alpine:3.20 sh -c 'echo temporary > /scratch/test; cat /scratch/test'
docker volume inspect interview-data
```

Also mount a known host directory with `--mount type=bind`. Compare ownership, portability, lifecycle, and use cases. Remove only the lab volume when finished.

## Lab 9 — Resource Limits and Statistics

```bash
docker run -d --name limits --memory 128m --cpus 0.50 alpine:3.20 \
  sh -c 'while true; do :; done'
docker stats --no-stream limits
docker inspect limits --format 'memory={{.HostConfig.Memory}} nanoCPUs={{.HostConfig.NanoCpus}}'
docker rm -f limits
```

**Verify:** explain hard memory limits, CPU scheduling, throttling, and how to identify an OOM termination.

## Lab 10 — Health Checks, Signals, and Restarts

Run the package project, observe health transitions, then make `/health` fail or stop its main process.

```bash
cd Projects/dockerized-health-web
docker compose up --build -d
docker compose ps
docker inspect docker-health-web --format '{{json .State.Health}}'
docker compose logs
docker compose down
```

**Verify:** distinguish running, ready, healthy, restarted, and exited. Explain why a restart policy does not repair an unhealthy process that remains alive.

## Lab 11 — Docker Compose Operations

```bash
docker compose config
docker compose build
docker compose up -d
docker compose ps
docker compose exec web id
docker compose logs --timestamps web
docker compose down
```

**Verify:** locate the service, image, container, network, published port, health check, mounts, and security settings generated by Compose.

## Lab 12 — Secure Image Review and Failure Injection

Build the included project and inspect it.

```bash
docker image history docker-interview-health-web:1.0
docker inspect docker-health-web --format 'user={{.Config.User}} readonly={{.HostConfig.ReadonlyRootfs}}'
docker inspect docker-health-web --format 'caps={{json .HostConfig.CapDrop}}'
curl -fsS http://127.0.0.1:8080/health
```

Inject three failures: invalid configuration, occupied host port, and failed health endpoint. For each, record:

1. Symptom and impact
2. Evidence from `ps`, `inspect`, `logs`, `events`, or host tools
3. Root cause
4. Corrective action
5. Prevention or monitoring improvement

## Completion Checklist

- [ ] I can explain every command instead of only copying it.
- [ ] I captured evidence for successful and failed states.
- [ ] I compared image, container, network, and volume lifecycle.
- [ ] I can explain the project in less than three minutes.
- [ ] I cleaned up only the resources created by these labs.

---

**Author:** Muhammad Khalid Khan  
**Repository:** DevOps & SRE Interview Preparation
