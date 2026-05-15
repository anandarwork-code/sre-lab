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
Host: sre-lab (AlmaLinux 9.7) — 16GB RAM, 80GB /var
│
├── sre-vm1       (192.168.122.152) — Nginx + Node.js + Gitea + cloudflared + Node Exporter
├── sre-db        (192.168.122.127) — MySQL 8.0 + Node Exporter
├── sre-mon       (192.168.122.218) — Prometheus + Grafana + Node Exporter
├── sre-fail      (192.168.122.224) — Failure simulations + Node Exporter
└── sre-container (192.168.122.73)  — Podman containers (rootless quadlets)
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

## Automation with Ansible

**Playbooks:**
- `ansible/first_playbook.yml` — Package installation and file creation across 3 VMs
- `ansible/node_exporter.yml` — Full Node Exporter deployment (download, extract, systemd service, firewall config)

**Key concepts mastered:**
- Inventory management (4 VMs managed via SSH)
- Idempotent playbook design (safe to run multiple times)
- Variables for version control (`ne_version` defined once, used everywhere)
- Multi-host parallel execution
- Production patterns: tarball extraction, binary placement, systemd services, firewall rules

**Current state:** Node Exporter v1.11.1 running on all 4 VMs, fully automated deployment.

---
## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/check_services.sh` | Service status check with timestamps and tee logging |
| `scripts/check_mysql.sh` | MySQL health check via systemctl with logging |
| `scripts/check_sreapp.sh` | Full stack health check — Nginx, Node.js, MySQL via HTTP |
| `scripts/multi_health_check.sh` | Multi-VM SSH health check — 5 services, color-coded output, cron every 15m |
| `scripts/mysql_backup.sh` | Automated mysqldump backup — timestamped, 7-day cleanup, credentials in .my.cnf |
| `scripts/user_add.sh` | User creation with validation, SSH key setup, sudoers config |
| `scripts/process_check.sh` | Process validation with pgrep, ps aux output, exit code handling |
| `scripts/disk_alert.sh` | Disk usage monitoring with threshold alerts, cron every 15m |
| `scripts/port_scan.sh` | Network port scanner using netcat, 6 common ports, timestamped logging |

---

## Monitoring Stack
Prometheus (sre-mon:9090) scraping 5 targets:
├── localhost:9090        (Prometheus self-monitoring)
├── 192.168.122.152:9100  (sre-vm1 Node Exporter)
├── 192.168.122.127:9100  (sre-db Node Exporter)
├── 192.168.122.224:9100  (sre-fail Node Exporter)
└── 192.168.122.218:9100  (sre-mon Node Exporter)
↓
Grafana (sre-mon:3000)

- All 5 targets healthy and reporting
- Node Exporter Full dashboard (ID 1860)
- Scrape interval: 15 seconds
- Automated deployment via Ansible playbook
---

## Incident Reports

| Incident | Summary |
|----------|---------|
| [incident-001](incident-notes/incident-001-gitea-502-no-home-dir.md) | Gitea 502 — missing /home/git directory caused permission failure on startup |
| [incident-002](incident-notes/incident-002-disk-full-simulation.md) | Disk full simulation — fallocate test, df/du diagnosis |
| [incident-003](incident-notes/incident-003-rsyslog-crash.md) | rsyslog crash — missing config file |
| [incident-004](incident-notes/incident-004-disk-drill.md) | Disk control drill — full df/du/fallocate/rm diagnostic cycle |
---

## Skills Demonstrated

- Linux system administration (AlmaLinux / RHEL)
- KVM virtualization and VM lifecycle management
- Bash scripting — functions, cron, logging, SSH automation, exit code handling
- Ansible automation — playbooks, variables, idempotence, multi-host orchestration
- Container orchestration — Podman, rootless quadlets, systemd integration
- Nginx reverse proxy configuration
- MySQL administration and automated backups
- Prometheus + Grafana monitoring stack
- Cloudflare Tunnel for secure public exposure
- SELinux troubleshooting
- systemd service management
- Incident debugging and documentation
- Network troubleshooting — netcat, tcpdump, firewalld
---

## Repo Structure

| Folder | Purpose |
|--------|---------|
| `scripts/` | Bash automation scripts (9 production scripts) |
| `ansible/` | Ansible playbooks and inventory |
| `incident-notes/` | Incident reports from real failures (4 documented) |
| `monitoring/` | Prometheus configs, Grafana dashboards, cloudflared config |
| `logs/` | Health check cron output |
---

## Goal

Becoming a production-grade SRE through deliberate practice —
building, breaking, and monitoring real systems on real infrastructure.

---

> "How would you know if this broke at 3am?"
