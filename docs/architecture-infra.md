# Production Infrastructure Architecture

## 1) Architecture Overview

Production deployment targets a Docker Swarm cluster on Hetzner Cloud with strict separation between stateless compute services and stateful data services.

- Orchestration: Docker Swarm (`1 manager + N workers`)
- Edge: Nginx reverse proxy with TLS termination
- Application tier (stateless): React, Django REST, FastAPI AI, Celery workers
- Data tier (stateful): PostgreSQL, Redis
- Networking: Hetzner private network + Swarm overlay networks

Diagram reference: `docs/architecture-diagram.md`

---

## 2) Network Flow

1. Client requests enter through `HTTPS 443` on Nginx.
2. Nginx routes by path/host:
   - `/` -> React frontend
   - `/api/*` -> Django REST
   - `/ai/*` -> FastAPI AI service
3. Django and FastAPI access PostgreSQL (`5432`) and Redis (`6379`) via private internal network only.
4. Celery workers consume asynchronous jobs from Redis and persist task state in PostgreSQL when required.

---

## 3) Ports and Exposure

### Public exposure

- `443/tcp`: Nginx (mandatory)
- `80/tcp`: Nginx (HTTP to HTTPS redirect only)
- `22/tcp`: SSH (restricted by source IP)

### Private-only service ports (no Internet exposure)

- `3000/tcp`: React runtime container (if not purely static)
- `8000/tcp`: Django REST
- `8001/tcp`: FastAPI AI
- `5432/tcp`: PostgreSQL
- `6379/tcp`: Redis

---

## 4) Service Distribution by Node

Production baseline topology:

- `manager-1` (control + edge)
  - Swarm manager
  - Nginx reverse proxy
  - No database workloads
- `worker-app-1`
  - React replicas
  - Django replicas
  - FastAPI replicas
  - Celery workers
- `worker-app-2`
  - React replicas
  - Django replicas
  - FastAPI replicas
  - Celery workers
- `worker-data-1`
  - PostgreSQL primary
  - Redis primary
  - Dedicated persistent volumes

Rationale:
- Isolates stateful components for deterministic storage and backup operations.
- Supports independent horizontal scaling of application workloads.
- Reduces node-level blast radius.

---

## 5) Stateless vs Stateful Separation

### Stateless services

- Nginx
- React
- Django REST
- FastAPI AI
- Celery workers

Characteristics:
- Horizontally scalable
- Re-schedulable across worker nodes
- No local persistent data dependency

### Stateful services

- PostgreSQL
- Redis

Characteristics:
- Pinned to data nodes via placement constraints
- Backed by persistent volumes
- Private network access only

---

## 6) Scaling Strategy

### Horizontal scaling

- **React**: 2-3 replicas for HA, scale on request volume.
- **Django REST**: start with 2 replicas, scale on CPU/RPS/latency.
- **FastAPI AI**: scale by CPU/RAM and inference latency.
- **Celery workers**: scale by queue depth and job duration.

### Vertical scaling

- **PostgreSQL**: prioritize CPU/RAM/IOPS and storage throughput.
- **Redis**: prioritize RAM and network throughput.

### Placement policy

- Enforce Swarm placement constraints:
  - `node.role == manager` for control/edge services as needed
  - `node.labels.tier == app` for stateless app services
  - `node.labels.tier == data` for PostgreSQL/Redis

---

## 7) Security Baseline

## Network and firewall

- Attach all nodes to a Hetzner private network for east-west traffic.
- Permit inbound public traffic only to `80/443` on Nginx nodes.
- Restrict SSH (`22`) to trusted admin IP ranges (or move to custom SSH port policy).
- Deny public access to `5432`, `6379`, `8000`, `8001`.

## Secrets and credentials

- Store secrets in Docker Swarm Secrets (never in container images).
- Rotate DB passwords, Django secret keys, and API tokens periodically.
- Separate secrets by environment (staging/production).

## Host hardening

- Disable password SSH auth; use key-based auth only.
- Apply regular OS security patching and kernel updates.
- Run minimal base images and drop unnecessary Linux capabilities.

## TLS and HTTP hardening (Nginx)

- Enforce TLS 1.2+ (TLS 1.3 preferred).
- Enable HSTS, secure headers, and request size limits.
- Configure ingress rate limiting and basic bot/threat controls.

## Data protection

- Run daily PostgreSQL backups and enable point-in-time recovery where feasible.
- Redis persistence mode aligned to workload (AOF/RDB).
- Encrypt backup artifacts and validate restore procedures regularly.

---

## 8) Swarm Network Model

Two overlay networks are required:

- `public_net`:
  - Nginx <-> frontend/backend/ai
  - carries north-south proxied application traffic
- `backend_net`:
  - backend/ai/celery <-> postgres/redis
  - strictly internal east-west traffic

PostgreSQL and Redis are not attached to `public_net`.

---

## 9) Operations

- Define health checks for all services (`/healthz` where applicable).
- Configure restart policies (`on-failure`) and rolling update strategy.
- Centralize logs, metrics, and alerting before go-live.
- Apply CPU/memory reservations and limits per service.

---

## 10) HA Evolution

- Upgrade from 1 manager to 3 managers for control-plane high availability.
- Add PostgreSQL replica(s) and automated failover tooling.
- Add Redis Sentinel/Cluster if availability requirements increase.
