#!/bin/bash
# selinux_proof.sh
# Read-only SELinux diagnostic — prints enforcement mode, recent AVC
# denials, file context on sreapp's .env, relevant boolean state, and
# service status for sreapp/nginx. Intended to run ON sre-vm1 (checks
# a local path); not portable to other hosts as-is.
#
# Usage:   ./selinux_proof.sh
# Flags:   none
# Scope:   read-only — makes no changes (no chcon/setsebool/semanage).
#          Deliberate design choice: this script diagnoses, it does not
#          fix, so a human always reviews before any policy change.
# Exits:   dies (set -e) if the .env path is missing or getsebool is
#          given a bad boolean name — both signal a real, unexpected
#          state worth stopping for. Does NOT die on "no AVC denials
#          found" or a service being inactive — both are valid,
#          expected states this script should still report on.

set -euo pipefail

echo "=== SELinux Enforcement Mode ==="
getenforce

echo "=== Recent AVC Denials ==="
sudo ausearch -m avc -ts recent || true

echo "=== File Contexts ==="
ls -Z /home/anand/sreapp/.env

echo "=== Relevant Booleans ==="
getsebool httpd_can_network_connect

echo "=== Service Status ==="
echo "sreapp: $(systemctl is-active sreapp || true)"
echo "nginx: $(systemctl is-active nginx || true)"
