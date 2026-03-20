# sre-lab
Hands-on SRE learning lab — KVM virtualization, Linux automation, Bash scripting, monitoring, and intentional failure simulations on AlmaLinux.



# sre-lab

Personal SRE learning lab built on AlmaLinux with KVM virtualization.

This repo documents my journey from Linux sysadmin to Site Reliability Engineer —
every script, experiment, failure simulation, and incident report is committed here.

## Lab Environment

- **Host OS:** AlmaLinux 9 (RHEL clone)
- **Virtualization:** KVM + QEMU + libvirt
- **VMs:** AlmaLinux 9.7 minimal guests

## Lab Architecture
```
Host: sre-lab (AlmaLinux)
├── VM1: sre-vm1        — app node (Nginx + Node.js)
├── VM2: sre-db         — database node (MySQL)
├── VM3: sre-mon        — Prometheus + Grafana (planned)
└── VM4: failure-lab    — intentional system breaking (planned)
```

## Structure

| Folder | Purpose |
|---|---|
| `scripts/` | Bash automation scripts |
| `incident-notes/` | Incident reports from failure simulations |
| `monitoring/` | Prometheus configs, Grafana dashboards |
| `terraform/` | Infrastructure as Code (coming soon) |
| `experiments/` | Notes from breaking things intentionally |
| `progress/` | Lab progress log — what's been built and what's next |


## Scripts

| Script | Purpose |
|---|---|
| `scripts/check_services.sh` | Check status of services + log results with timestamp |

## Skills Being Built

- KVM virtualization and VM lifecycle management
- Bash scripting and Linux automation
- System monitoring and observability
- Failure simulation and incident response
- Containers, IaC, CI/CD (in progress)

## Goal
Becoming a production-grade SRE through deliberate practice —
building, breaking, and monitoring real systems.

---
> "How would you know if this broke at 3am?"
