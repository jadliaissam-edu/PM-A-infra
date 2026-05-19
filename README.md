# AgileFlow Production Deployment Guide

This document outlines the manual steps and environment configurations required to successfully deploy the AgileFlow infrastructure on Hetzner Cloud using Ansible and Docker Swarm.

## 1. Environment Variables
Before running the Ansible deploy playbook locally, you must export the required environment variables in your terminal so they can be securely injected into the server:

```bash
export DB_PASSWORD="YourSecurePassword"
export DJANGO_SECRET_KEY="YourDjangoSecret"
export GHCR_TOKEN="YourGitHubPersonalAccessToken"
export GHCR_USER="jadliaissam-edu"
export GITHUB_REPOSITORY_OWNER="jadliaissam-edu"
export BACKEND_IMAGE="ghcr.io/jadliaissam-edu/pm-a-backend:latest"
export FRONTEND_IMAGE="ghcr.io/jadliaissam-edu/pm-a-frontend:latest"
export AI_IMAGE="ghcr.io/jadliaissam-edu/pm-a-ai:latest"
```
