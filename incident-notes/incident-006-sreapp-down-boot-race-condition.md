# Incident 006: sreapp down 4 days — boot race condition

**Date:** 11.06.2026
**Severity:** High — production app unreachable
**Where:** sre-vm1

## Summary
sreapp failed to come up reliably after VM/host reboot, staying down
for an extended period before being caught and fixed.

## Root Cause
sreapp.service started before its dependency (MySQL on sre-db) was
actually ready to accept connections. Without a retry/backoff policy,
the initial failed connection caused the service to exit and stay
down rather than retry.

## Diagnosis
- journalctl -u sreapp — showed repeated failed connection attempts
  to MySQL, then no further restart attempts
- systemctl status sreapp — confirmed service in failed state, not
  actively retrying
- Identified the failure as a timing/race issue, not a config or code bug

## Fix
Added restart policy to sreapp.service:
```
Restart=on-failure
RestartSec=10
StartLimitBurst=10
StartLimitIntervalSec=120
```
This gives the service repeated retry attempts with backoff instead of
failing permanently on first boot-time connection failure.

## Lessons
- Services with a network dependency (DB, cache, etc.) need explicit
  restart/backoff policy — systemd does not retry by default
- Caught manually, not via monitoring — no alert existed for a
  service stuck in a failed/stopped state. 

```

