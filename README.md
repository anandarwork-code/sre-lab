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

- **KVM virtualization** — 5 VMs managed via virsh, autostart configured
- **3-tier app stack** — Nginx reverse proxy → Node.js → MySQL on separate DB node
- **CI/CD pipeline** — GitHub Actions, self-hosted runner on sre-vm1, push → test → deploy → systemctl restart end-to-end
- **Ansible IaC** — roles, vault, handlers, templates, Jinja2 across 4 nodes
- **Container workloads** — sreapp containerized via Podman, rootless quadlets, auto-starts at boot without login
- **Self-hosted monitoring** — Prometheus scraping all 5 targets, Grafana dashboards live
- **Cloudflare Tunnel** — public HTTPS with SSL, zero port forwarding
- **Self-hosted Git** — Gitea v1.25.5 running behind Nginx, backed by MySQL
- **Automated backups** — mysqldump cron job on sre-db, daily at 2am, 7-day retention
- **Health check automation** — multi-VM bash script via cron every 15 minutes
- **User management** — sradmin (full sudo), jradmin (limited systemctl), dev_user (no sudo)
- **Failure simulations** — disk full, service crash, network interface failure — all documented as incident reports
- **SELinux enforcing** — not disabled. Configured correctly throughout.
- **AWS** — custom VPC, subnet, IGW, route table, EC2, IAM role, S3 — built from scratch on own account
- **Docker Compose** — separate repo ([container-lab](https://github.com/anandarwork-code/container-lab)) — custom Dockerfile, healthcheck-gated service dependencies, env_file secrets management

---

## CI/CD Pipeline

**Stack:** GitHub Actions + self-hosted runner on sre-vm1

**Flow:** `git push` → checkout → `npm install` → `npm test` → deploy → `systemctl restart sreapp`

**Runner:** Installed as systemd service, survives reboot, polls GitHub outbound — no inbound ports required.

**Secrets:** DB credentials stored in GitHub Secrets, injected via `${{ secrets.DB_PASSWORD }}` into `.env` at deploy time. Never hardcoded. Never committed.

**SELinux:** `.env` file relabelled `etc_t` at deploy so systemd can read it — baked into the deploy step, not a manual fix.

```yaml
steps:
  - name: Checkout code
    uses: actions/checkout@v4
  - name: Install dependencies
    run: npm install
  - name: Test code
    run: npm test
  - name: Deploy
    run: |
      cp -r . /home/anand/sreapp/
      echo "DB_PASSWORD=${{ secrets.DB_PASSWORD }}" > /home/anand/sreapp/.env
      chcon -t etc_t /home/anand/sreapp/.env
      sudo systemctl restart sreapp
```

---

## Ansible

**Structure:** Full roles layout — `defaults/`, `vars/`, `tasks/`, `templates/`, `handlers/`, `files/`

**Vault:** AES256 encryption via `ansible-vault`. Secrets stored in `group_vars/all/vault.yml`. Never in plaintext.

**Playbooks:**

| Playbook | Purpose |
|----------|---------|
| `ansible/first_playbook.yml` | Package installation and file creation across VMs |
| `ansible/node_exporter.yml` | Node Exporter deployment — download, extract, systemd, firewall |
| `ansible/prometheus_config.yml` | Prometheus configuration management via Jinja2 template |
| `ansible/deploy_node_exporter.yml` | Role-based deployment — 5 lines, full Node Exporter stack |
| `ansible/create_mysql_user.yml` | MySQL user creation via vault-encrypted credentials |

**Key patterns:**
- Idempotent playbook design — safe to run multiple times
- Variables for version control — `ne_version` defined once, used everywhere
- Jinja2 templates — `prometheus.yml.j2` with dynamic target loops
- Handlers — config changes trigger service restarts only when state actually changes
- Vault — credentials never in plaintext, `--ask-vault-pass` always required

---

## AWS

**Account:** ap-south-1 (Mumbai) — personal account, built from scratch

```
sre-vpc (10.0.0.0/16)
└── sre-public-subnet (10.0.1.0/24) — ap-south-1a
     ├── sre-rtb: 10.0.0.0/16 → local, 0.0.0.0/0 → sre-igw
     └── sre-ec2 (t3.micro, Amazon Linux 2023)
          └── IAM role: sre-ec2-s3-role (AmazonS3FullAccess)
S3: sre-lab-anand-01072003 — SSE-S3 encryption, public access blocked
```

**What was built hands-on (not console wizard defaults):**
- Custom VPC with manually defined CIDR block
- Public subnet tied to a specific AZ
- Internet Gateway created and attached to VPC separately
- Route table with explicit `0.0.0.0/0 → IGW` entry, manually associated with subnet
- EC2 launched via CLI with security group restricting SSH to my IP only
- IMDSv2 enforced — metadata access requires token-based PUT/GET, not plain curl
- IAM role attached to EC2 — no `aws configure`, no static keys, temporary credentials via metadata service
- S3 bucket upload/download round-trip verified via `aws s3 cp` using role credentials


---

## Related Repos

| Repo | Purpose |
|------|---------|
| [container-lab](https://github.com/anandarwork-code/container-lab) | Docker Compose — custom Dockerfile, healthchecks, service dependencies, env-based secrets |

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
| `scripts/selinux_proof.sh` | SELinux context verification, service status, HTTP health check — enforcing mode proof |

---

## Monitoring Stack

```
Prometheus (sre-mon:9090) scraping 5 targets:
├── localhost:9090        (Prometheus self-monitoring)
├── 192.168.122.152:9100  (sre-vm1 Node Exporter)
├── 192.168.122.127:9100  (sre-db Node Exporter)
├── 192.168.122.224:9100  (sre-fail Node Exporter)
└── 192.168.122.218:9100  (sre-mon Node Exporter)
↓
Grafana (sre-mon:3000) — Node Exporter Full dashboard (ID 1860)
```

- All 5 targets healthy and reporting
- Scrape interval: 15 seconds
- Node Exporter deployed and configured via Ansible across all nodes

---

## Containers

**Runtime:** Podman v5.6.0 — rootless, no daemon

**sreapp container:**
- Custom image built from `Containerfile` — Node 18 Alpine + app code
- Managed as a systemd quadlet — `~/.config/containers/systemd/sreapp.container`
- Connects to MySQL on sre-db
- Restart policy: `on-failure` with `RestartSec=5` — handles DB boot race condition
- Lingering enabled — auto-starts at boot without login

**Nginx container:**
- Rootless quadlet on port 8080
- Auto-starts at boot

---

## Incident Reports

| Incident | Summary |
|----------|---------|
| [incident-001](incident-notes/incident-001-gitea-502-no-home-dir.md) | Gitea 502 — missing /home/git directory caused permission failure on startup |
| [incident-002](incident-notes/incident-002-disk-full-simulation.md) | Disk full simulation — fallocate test, df/du diagnosis |
| [incident-003](incident-notes/incident-003-rsyslog-crash.md) | rsyslog crash — missing config file |
| [incident-004](incident-notes/incident-004-disk-drill.md) | Disk control drill — full df/du/fallocate/rm diagnostic cycle |
| [incident-005](incident-notes/incident-005-network-failure.md) | Network interface failure — enp1s0 down on sre-fail, diagnosed and recovered via virsh console |

---

## Failure Simulations

| # | Simulation | Method | Outcome |
|---|-----------|--------|---------|
| 1 | Disk full | fallocate to fill /var | Diagnosed via df/du, recovered via rm |
| 2 | Service crash | rsyslog config removed | Diagnosed via journalctl, config restored |
| 3 | Disk control drill | fallocate + full diagnostic cycle | Full df/du/lsof/rm workflow under pressure |
| 4 | Network interface failure | ip link set enp1s0 down on sre-fail | SSH lost, recovered via virsh console out-of-band |

---

## Skills Demonstrated

- Linux system administration (AlmaLinux / RHEL)
- KVM virtualization and VM lifecycle management
- CI/CD pipeline — GitHub Actions, self-hosted runner, secrets management
- Ansible — roles, vault, handlers, templates, Jinja2, idempotent design
- Container orchestration — Podman, rootless quadlets, systemd integration
- Bash scripting — functions, cron, logging, SSH automation, exit code handling
- Docker Compose — multi-container orchestration, healthchecks, `depends_on: condition`, build vs image-pull tradeoffs
- Nginx reverse proxy configuration
- MySQL administration and automated backups
- Prometheus + Grafana monitoring stack
- SELinux — enforcing mode, context management, MAC vs DAC
- systemd service management and troubleshooting
- AWS — custom VPC networking, EC2, IAM roles, S3, IMDSv2, zero hardcoded credentials
- Git — feature branches, pull request workflow, merge conflict resolution (single and multi-hunk)
- Incident debugging and documentation
- Network troubleshooting — netcat, tcpdump, firewalld, virsh console recovery

---

## Repo Structure

| Folder | Purpose |
|--------|---------|
| `scripts/` | Bash automation scripts |
| `ansible/` | Playbooks, roles, inventory, vault |
| `incident-notes/` | Incident reports from real failures |
| `monitoring/` | Prometheus configs, Grafana dashboards, cloudflared config |
| `.github/workflows/` | GitHub Actions CI/CD pipeline |
| `sreapp/` | Node.js app with Containerfile |

---

## Goal

Becoming a production-grade SRE through deliberate practice —
building, breaking, and monitoring real systems on real infrastructure.

---

> "How would you know if this broke at 3am?"
