# AgileFlow Infrastructure Deployment (Ansible & Docker Swarm)

This directory contains all the Infrastructure as Code (IaC) necessary to configure the servers and deploy the AgileFlow platform in production. The architecture has been designed to strictly comply with the "Cahier des Charges" requirements (stateful/stateless separation, high availability, security).

## 📂 Directory Structure

The structure follows Ansible best practices:

```text
ansible/
├── docker-compose.prod.yml  # Full Docker Swarm stack definition (services, networks, constraints)
├── inventories/
│   ├── dev/
│   ├── staging/
│   └── production/          # Contains inventory.yml with IP addresses and server groups
├── playbooks/
│   ├── deploy.yml           # Main playbook: OS Hardening + Swarm Init + Stack Deployment
│   ├── rollback.yml         # Playbook to rollback a faulty deployment
│   └── backup.yml           # Playbook for database backups (PostgreSQL)
└── roles/
    ├── common/              # Common tasks (e.g., SSH hardening, firewall)
    ├── nginx/               # Reverse proxy configuration
    ├── django/              # Backend deployment
    ├── celery/              # Async workers
    ├── postgresql/          # Database
    ├── redis/               # Cache and message broker
    └── monitoring/          # Observability stack (Prometheus + Grafana)
```

## ⚙️ Prerequisites

1. **Ansible** must be installed on the machine running the scripts.
2. The target servers must be accessible via **SSH** using the `deploy` user.
3. Server IPs must be correctly populated in `inventories/production/inventory.yml`.

## 🚀 How to Deploy

The `deploy.yml` file handles the entire lifecycle:
1. **Server Hardening** (`common` role: disabling root login, enforcing SSH keys, etc.)
2. **Docker Swarm Initialization** on the Manager node.
3. **Attaching Workers** (App and Data) to the cluster.
4. **Applying Placement Labels** (`tier=app` and `tier=data`) to enforce service separation.
5. **Final Deployment** of the stack via `docker stack deploy`.

**Production Deployment Command:**
```bash
ansible-playbook -i inventories/production/inventory.yml playbooks/deploy.yml
```

## 🔒 Secrets Management

For security reasons, passwords and API keys (like `db_password` and `django_secret_key`) are **never** stored in this source code.
Before deploying, you must create these secrets directly in Docker Swarm on the manager node:

```bash
echo "your_real_password" | docker secret create db_password -
echo "your_real_secret_key" | docker secret create django_secret_key -
```

## 🛠️ Local Simulation / Testing

If you want to test this configuration locally (without remote servers) using **Docker Desktop**:
1. Initialize a local Swarm: `docker swarm init`
2. Simulate a hybrid node: `docker node update --label-add tier=app docker-desktop` (Adjust constraints in `docker-compose.prod.yml` if you want to test all services on a single machine).
3. Create mock secrets (see the section above).
4. Deploy the stack: `docker stack deploy -c docker-compose.prod.yml agileflow`
