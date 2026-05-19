# PM-A Infrastructure as Code

A comprehensive Infrastructure as Code (IaC) project for deploying AgileFlow on Hetzner Cloud using Terraform and Ansible. This repository contains all necessary configurations for production-grade infrastructure deployment with Docker Swarm, including database, caching, and monitoring solutions.

## 📋 Project Overview

**PM-A-infra** is an enterprise-ready infrastructure management solution that automates the provisioning and deployment of a multi-tier application stack on Hetzner Cloud. The project follows industry best practices for security, scalability, and maintainability.

### Key Features

- **Infrastructure as Code**: Terraform configurations for Hetzner Cloud resources
- **Container Orchestration**: Docker Swarm for service management and scaling
- **Configuration Management**: Ansible playbooks for server provisioning and deployment
- **High Availability**: Multi-node architecture with manager and worker nodes
- **Security-First Design**: SSH hardening, firewall configuration, and secrets management
- **Monitoring & Observability**: Prometheus and Grafana integration
- **Database Management**: PostgreSQL with backup and recovery capabilities
- **Caching Layer**: Redis for performance optimization

## 📊 Repository Composition

- **HCL**: 97% (Terraform Infrastructure as Code)
- **Jinja**: 3% (Template configurations)

## 📂 Directory Structure

```
PM-A-infra/
├── terraform/                    # Infrastructure provisioning code
│   ├── main.tf                  # Primary resource definitions
│   ├── variables.tf             # Input variable declarations
│   ├── outputs.tf               # Output value definitions
│   ├── hetzner.tf               # Hetzner-specific configurations
│   └── .terraform/              # Terraform state and provider cache
│
├── ansible/                      # Configuration management and deployment
│   ├── docker-compose.prod.yml  # Docker Swarm service stack definition
│   ├── inventories/
│   │   ├── dev/                 # Development environment configuration
│   │   ├── staging/             # Staging environment configuration
│   │   └── production/          # Production environment configuration
│   │       └── inventory.yml    # Server inventory with IP addresses
│   ├── playbooks/
│   │   ├── deploy.yml           # Main deployment orchestration
│   │   ├── rollback.yml         # Deployment rollback automation
│   │   └── backup.yml           # Database backup automation
│   └── roles/
│       ├── common/              # Common system configuration
│       ├── nginx/               # Reverse proxy and load balancing
│       ├── django/              # Backend application deployment
│       ├── celery/              # Asynchronous task workers
│       ├── postgresql/          # Database setup and configuration
│       ├── redis/               # Cache and message broker
│       └── monitoring/          # Prometheus and Grafana setup
│
└── README.md                    # This file
```

## 🏗️ Architecture

The infrastructure follows a three-tier architecture:

### Tier 1: Manager Node
- Docker Swarm Manager
- Central coordination point
- Orchestrates all service deployments

### Tier 2: Application Workers
- Docker Swarm Worker nodes
- Labels: `tier=app`
- Hosts backend services, frontend, and async workers

### Tier 3: Data Nodes
- Docker Swarm Worker nodes
- Labels: `tier=data`
- Dedicated to database and cache services

## ✅ Prerequisites

### System Requirements

- **Ansible**: 2.9+ installed on the control machine
- **Terraform**: 1.0+ (or OpenTofu) installed on the provisioning machine
- **SSH Access**: Configured with SSH keys (no password authentication)
- **Hetzner Cloud Account**: With valid API token for infrastructure provisioning

### Hetzner Cloud Resources

- Sufficient project quota for VM creation
- Network infrastructure (VPC/networks if using advanced networking)
- API token with read/write permissions

### Local Environment

- Python 3.8+ on control machine
- `netaddr` and `docker` Python packages for Ansible modules

## 🚀 Deployment Guide

### Step 1: Infrastructure Provisioning (Terraform)

```bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan infrastructure changes
terraform plan -out=tfplan

# Apply infrastructure changes
terraform apply tfplan

# Output server IPs and details
terraform output
```

### Step 2: Prepare Inventory

Update `ansible/inventories/production/inventory.yml` with the IPs output from Terraform:

```yaml
all:
  children:
    swarm_managers:
      hosts:
        manager-1:
          ansible_host: <MANAGER_IP>
    swarm_workers_app:
      hosts:
        worker-app-1:
          ansible_host: <WORKER_APP_1_IP>
        worker-app-2:
          ansible_host: <WORKER_APP_2_IP>
    swarm_workers_data:
      hosts:
        worker-data-1:
          ansible_host: <WORKER_DATA_IP>
  vars:
    ansible_user: deploy
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### Step 3: Run Ansible Deployment

```bash
# Navigate to ansible directory
cd ansible

# Validate playbook syntax
ansible-playbook --syntax-check -i inventories/production/inventory.yml playbooks/deploy.yml

# Execute deployment (dry-run first)
ansible-playbook -i inventories/production/inventory.yml playbooks/deploy.yml --check

# Execute actual deployment
ansible-playbook -i inventories/production/inventory.yml playbooks/deploy.yml -v
```

## 🔐 Security & Secrets Management

### Sensitive Information Handling

This project **does not store** sensitive credentials in version control:

- ✅ Database passwords
- ✅ Application secret keys
- ✅ API tokens and credentials
- ✅ Private encryption keys

### Secrets Creation

Create Docker Swarm secrets on the manager node before deployment:

```bash
# SSH to manager node
ssh deploy@<MANAGER_IP>

# Create database password secret
echo "your_secure_password" | docker secret create db_password -

# Create Django secret key
echo "your_django_secret_key" | docker secret create django_secret_key -

# Verify secrets were created
docker secret ls
```

### Environment Variables

Set required environment variables on your control machine before running Ansible:

```bash
# Database Configuration
export DB_PASSWORD="secure_database_password"
export DB_USER="appuser"
export DB_NAME="agileflow_db"

# Django Configuration
export DJANGO_SECRET_KEY="unique_secret_key_for_django"

# Container Registry Credentials
export GHCR_USER="your_github_username"
export GHCR_TOKEN="your_github_pat_token"

# Image References
export BACKEND_IMAGE="ghcr.io/your-org/pm-a-backend:latest"
export FRONTEND_IMAGE="ghcr.io/your-org/pm-a-frontend:latest"
export AI_IMAGE="ghcr.io/your-org/pm-a-ai:latest"
```

## 📦 Deployment Workflow

### deploy.yml Execution Flow

1. **System Hardening** (common role)
   - Disable root SSH login
   - Enforce SSH key-based authentication
   - Configure firewall rules
   - Update system packages

2. **Docker Swarm Initialization**
   - Initialize Swarm on manager node
   - Configure Swarm networking

3. **Worker Node Registration**
   - Join app worker nodes to Swarm
   - Join data worker nodes to Swarm
   - Apply node labels for service placement

4. **Service Deployment**
   - Deploy PostgreSQL on data nodes
   - Deploy Redis on data nodes
   - Deploy backend services on app nodes
   - Deploy frontend services on app nodes
   - Deploy Celery workers for async tasks
   - Configure Nginx reverse proxy

5. **Monitoring Setup**
   - Deploy Prometheus for metrics collection
   - Deploy Grafana for visualization
   - Configure alerting rules

### Rollback Procedure

If deployment encounters issues:

```bash
# Execute rollback playbook
ansible-playbook -i inventories/production/inventory.yml playbooks/rollback.yml -v

# This restores the previous known-good deployment state
```

## 💾 Backup & Recovery

### Database Backups

Automated PostgreSQL backups are configured via the backup.yml playbook:

```bash
# Execute backup on-demand
ansible-playbook -i inventories/production/inventory.yml playbooks/backup.yml -v

# Backups are stored on the data nodes with retention policies
```

## 🧪 Local Testing

### Docker Desktop Simulation

Test the configuration locally without cloud infrastructure:

```bash
# Initialize local Docker Swarm
docker swarm init

# Label the local node as app and data tier
docker node update --label-add tier=app docker-desktop
docker node update --label-add tier=data docker-desktop

# Create mock secrets
echo "test_password" | docker secret create db_password -
echo "test_secret" | docker secret create django_secret_key -

# Deploy stack
docker stack deploy -c ansible/docker-compose.prod.yml agileflow

# Verify services
docker service ls
docker service ps agileflow_backend
```

## 🔄 Service Management

### View Service Status

```bash
# SSH to manager node
ssh deploy@<MANAGER_IP>

# List all services
docker service ls

# View service tasks and deployment status
docker service ps agileflow_backend

# View service logs
docker service logs agileflow_backend
```

### Scale Services

```bash
# Scale backend services to 3 replicas
docker service scale agileflow_backend=3

# Update service configuration
docker service update --env-add NEW_VAR=value agileflow_backend
```

## 📊 Monitoring

### Prometheus

- **URL**: `http://<MANAGER_IP>:9090`
- **Metrics**: Collected from all nodes and services
- **Retention**: Configured via prometheus role

### Grafana

- **URL**: `http://<MANAGER_IP>:3000`
- **Default Credentials**: Set during initial deployment
- **Dashboards**: Pre-configured for infrastructure and application metrics

## 🛠️ Maintenance

### System Updates

```bash
# Update specific host
ansible -i inventories/production/inventory.yml <hostname> -m apt -a "update_cache=yes upgrade=dist"

# Run maintenance playbook (if available)
ansible-playbook -i inventories/production/inventory.yml playbooks/maintenance.yml
```

### Node Drain (Graceful Shutdown)

```bash
# SSH to manager
ssh deploy@<MANAGER_IP>

# Drain node before maintenance
docker node update --availability drain <NODE_NAME>

# Restore node to active
docker node update --availability active <NODE_NAME>
```

## 🐛 Troubleshooting

### Common Issues

#### SSH Connection Failures
- Verify SSH key permissions: `chmod 600 ~/.ssh/id_rsa`
- Ensure deploy user exists on target servers
- Check firewall rules allow SSH (port 22)

#### Ansible Module Errors
- Ensure Python 3.8+ is installed on remote hosts
- Install required Python packages: `pip install netaddr docker`

#### Docker Swarm Issues
- Verify network connectivity between nodes
- Check Docker daemon is running: `systemctl status docker`
- Review Swarm logs: `journalctl -u docker`

#### Service Deployment Failures
- Verify container images are accessible from registry
- Check node resource constraints (memory, disk)
- Review service logs: `docker service logs <SERVICE_NAME>`

## 📚 Documentation References

- [Terraform Documentation](https://www.terraform.io/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Docker Swarm Documentation](https://docs.docker.com/engine/swarm/)
- [Hetzner Cloud API](https://docs.hetzner.cloud/)

## 📝 Contributing

When contributing to this infrastructure code:

1. Test changes in the development environment first
2. Validate Terraform and Ansible syntax
3. Document any new variables or configurations
4. Never commit sensitive credentials
5. Follow existing code structure and naming conventions

## 📧 Support

For infrastructure-related issues or questions, refer to the project documentation or contact the infrastructure team.

