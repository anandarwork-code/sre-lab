# Incident 001 — Gitea 502 (Missing /home/git)

**Date:** 01.04.2026
**VM / System affected:** sre-vm1
**Severity:** High (public-facing service down)
**Detection method:** Manual — noticed git.anandar.dev returning an error while browsing to the site, not caught by an automated check (multi_health_check.sh did not yet exist at this point in the build).

## Problem

git.anandar.dev returned a 502 Bad Gateway. The site was unreachable through the Cloudflare Tunnel / Nginx front end.

## Detection

Found manually — visited git.anandar.dev and got the 502 directly in-browser. No script or alert caught this ahead of time.

First step was checking Gitea's own service status:

```bash
systemctl status gitea
```

Gitea was not running, and restarting it (`systemctl restart gitea`) did not bring it back up — it immediately failed again.

## Root Cause

Checked the service logs:

```bash
journalctl -u gitea -n 50 --no-pager
```

> *[TODO: paste exact error line here — was a permission/path error referencing /home/git]*

The `git` system user had been created without a home directory and without a valid shell (a hardening choice, intentionally locked-down). Gitea expects `/home/git` to exist as its working directory and repo storage root. Since the directory didn't exist, Gitea couldn't initialize and crashed on every start attempt — this wasn't a transient failure, it failed consistently on every restart.

## Resolution

Created the missing home directory and fixed ownership so the `git` user could actually use it:

```bash
sudo mkdir -p /home/git
sudo chown git:git /home/git
sudo systemctl restart gitea
```

Confirmed recovery by checking service status and re-loading git.anandar.dev in-browser — 502 cleared, site back up.

## Prevention

- Routine service health checks (this predates check_services.sh / multi_health_check.sh — those scripts came later in the build specifically to catch this class of issue before a manual site visit does)
- When locking down a system user (no shell, no login) for security, still explicitly verify the service's expected home/working directory exists — a hardened user account isn't automatically a *complete* one from the service's perspective

## What I Learned

A security-motivated choice (no home dir, no shell for the `git` user) broke the service in a way that had nothing to do with security — it broke because the application layer assumed a filesystem structure the hardening step never accounted for. Locking down a user and fully provisioning a user for its intended service are two different jobs; doing one doesn't guarantee the other. This is also the incident that (indirectly) motivated later health-check scripting — 502 was only found because I happened to check the site by hand, not because anything was watching it.

---
*Note: this repo predates the S48 Gitea-retirement decision. Gitea is no longer used as a push target for any repo (see sre-lab README / context file), but this incident report is kept as-is since it documents a real historical outage on infrastructure that was, at the time, actively in use.*
