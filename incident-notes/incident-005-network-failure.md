# Incident 005 — Network Interface Failure
**Date:** 31.05.2026
**VM:** sre-fail (192.168.122.224)
**Type:** Simulation
**Status:** Resolved

## What Happened
Network interface enp1s0 on sre-fail was brought down manually to simulate
a network failure. VM remained running but was unreachable via SSH and stopped
sending metrics to Prometheus.

## Detection
Prometheus alerted target 192.168.122.224:9100 (sre-fail_monitor) as DOWN.
Confirmed with ping from sre-lab — 100% packet loss, Destination Host Unreachable.

## Diagnosis
1. SSH attempt: `ssh sre-fail` → "No route to host"
2. Ping: `ping -c 3 192.168.122.224` → 100% packet loss
3. Prometheus API: health=down, lastError="no route to host"
4. All three signals confirmed: network layer failure, not application failure

## Resolution
1. Accessed VM via hypervisor console: `sudo virsh console sre-fail`
2. Brought interface up: `sudo ip link set enp1s0 up`
3. Verified SSH restored
4. Verified Prometheus target health=up, lastError=""

## Timeline
- 19:15 — Interface brought down (sudo ip link set enp1s0 down)
- 19:16 — SSH dropped, ping shows 100% packet loss
- 19:17 — Prometheus target showing health=down
- 19:20 — Interface restored via virsh console
- 19:20 — Prometheus scraping resumed (lastScrape confirmed)

## Lessons Learned
- Network failure looks identical from SSH and ping: "no route to host"
- Prometheus detects node failures within one scrape interval (15s)
- virsh console = out-of-band access when network is down (critical recovery tool)
- Distinguish failure types: "no route to host" (interface down) vs "timeout" (firewall) vs "connection refused" (service down)
