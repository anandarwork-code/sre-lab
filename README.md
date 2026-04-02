# sre-lab

Personal SRE learning lab built on AlmaLinux with KVM virtualization.  
Every script, incident report, and config committed here is from real hands-on work —
not tutorials, not copy-paste. Built, broken, and fixed by hand.

## Live Infrastructure

| URL | Purpose |
|-----|---------|
| [anandar.dev](https://anandar.dev) | Node.js app — live with SSL |
| [grafana.anandar.dev](https://grafana.anandar.dev) | Grafana monitoring dashboard — live with SSL |
| [git.anandar.dev](https://git.anandar.dev) | Self-hosted Gitea — live with SSL |

> All services exposed publicly via Cloudflare Tunnel — no port forwarding, no VPS, no public IP.

---

## Lab Architecture

```
Host: sre-lab (AlmaLinux 9.7)
│
├── VM1: sre-vm1  (192.168.122.152)  — Nginx + Node.js + Gitea + cloudflared + Node Exporter
├── VM2: sre-db   (192.168.122.127)  — MySQL 8.0 + Node Exporter
├── VM3: sre-mon  (192.168.122.218)  — Prometheus v2.51.0 + Grafana v12.4.2
├── VM4: container-node              — Docker / Podman (planned)
└── VM5: failure-lab                 — Intentional failure simulations (planned)
```

**Hypervisor stack:** KVM → QEMU → libvirt → virsh

---

## What's Built

- **KVM virtualization** — 3 VMs running, managed via virsh
- **3-tier app stack** — Nginx reverse proxy → Node.js → MySQL on separate DB node
- **Self-hosted monitoring** — Prometheus scraping all 3 VMs, Grafana dashboards live
- **Cloudflare Tunnel** — public HTTPS with SSL, zero port forwarding
- **Self-hosted Git** — Gitea v1.25.5 running behind Nginx, backed by MySQL
- **Automated backups** — mysqldump cron job on sre-db, daily at 2am, 7-day retention
- **Health check automation** — multi-VM bash script via cron every 15 minutes
- **User management** — sradmin (full sudo), jradmin (limited systemctl), dev_user (no sudo)
- **Incident response** — real incidents debugged and documented

---

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/check_services.sh` | Service status check with timestamps and tee logging |
| `scripts/check_mysql.sh` | MySQL health check via systemctl with logging |
| `scripts/check_sreapp.sh` | Full stack health check — Nginx, Node.js, MySQL via HTTP |
| `scripts/multi_health_check.sh` | Multi-VM SSH health check — 5 services, color-coded output, cron every 15m |
| `scripts/mysql_backup.sh` | Automated mysqldump backup — timestamped, 7-day cleanup, credentials in .my.cnf |

---

## Monitoring Stack

```
sre-vm1 (Node Exporter :9100) ──→ Prometheus (sre-mon:9090) ──→ Grafana (sre-mon:3000)
sre-db  (Node Exporter :9100) ──→ Prometheus (sre-mon:9090) ──→ Grafana (sre-mon:3000)
```

- Prometheus scraping 3 targets every 15 seconds
- Node Exporter Full dashboard imported (ID 1860)
- All targets health: up

---

## Incident Reports

| Incident | Summary |
|----------|---------|
| [incident-001](incident-notes/incident-001-gitea-502-no-home-dir.md) | Gitea 502 — missing /home/git directory caused permission failure on startup |

---

## Skills Demonstrated

- Linux system administration (AlmaLinux / RHEL)
- KVM virtualization and VM lifecycle management
- Bash scripting — functions, cron, logging, SSH automation
- Nginx reverse proxy configuration
- MySQL administration and automated backups
- Prometheus + Grafana monitoring stack
- Cloudflare Tunnel for secure public exposure
- SELinux troubleshooting
- systemd service management
- Incident debugging and documentation

---

## Repo Structure

| Folder | Purpose |
|--------|---------|
| `scripts/` | Bash automation scripts |
| `incident-notes/` | Incident reports from real failures |
| `monitoring/` | Prometheus configs, Grafana dashboards, cloudflared config |
| `terraform/` | Infrastructure as Code (coming soon) |
| `experiments/` | Notes from intentional failure simulations |
| `logs/` | Health check cron output |
| `progress/` | Full lab progress log |

---

## Goal

Becoming a production-grade SRE through deliberate practice —
building, breaking, and monitoring real systems on real infrastructure.

---

> "How would you know if this broke at 3am?"
