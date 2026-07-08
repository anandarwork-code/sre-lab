# Incident 007: Docker port 3000 bind conflict after failed compose up

**Date:** 25.06.2026
**Severity:** Low — blocked local dev/testing, no prod impact
**Where:** sre-container

## Summary
`docker compose up` failed with a port-already-in-use error on 3000
after a prior container start had failed, despite no container
actually appearing to hold the port.

## Diagnosis
Checked for an orphaned process/container holding the port:
- `ss -tlnp | grep 3000` — nothing came up
- `podman ps` / `docker ps` — no container listed
- Checked docker-proxy and rootlesskit process state — clean, nothing
  holding the port at the OS level

All standard suspects (orphan container, rootless networking leak,
stale docker-proxy) were ruled out.

## Root Cause
Delayed kernel-level port release after the previous container's
failed start/teardown — the port "looked" free at the process level
before the kernel had actually released it.

Same category of issue as MySQL's InnoDB buffer flush delay on
restart: state reports as released/complete before it truly is.

## Fix
Retried `docker compose down` followed by `docker compose up -d
--build` after a short pause — succeeded once the kernel had actually
released the port.

## Lessons
- Not every "port in use" error means an orphan container — can be a
  timing issue at the kernel level
- Retry-with-delay is a valid diagnostic step when all process-level
  checks come back clean
