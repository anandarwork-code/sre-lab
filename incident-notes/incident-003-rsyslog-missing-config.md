# Incident 003 — rsyslog Service Fails to Start Due to Missing Config

**Date:** 05.04.2026

**VM / System affected:** sre-fail

**Severity:** High

## Problem

The rsyslog service failed to start, resulting in loss of system logging functionality.

## Detection

* Initial attempt to restart rsyslog after stopping it resulted in failure.
* `systemctl start rsyslog` returned an exit-code failure.
* systemd attempted automatic restarts (due to `Restart=on-failure`) but stopped after hitting the restart limit.
* Checked logs using `journalctl -u rsyslog`, which showed repeated failures but did not clearly indicate the root cause.
* Running `sudo rsyslogd -n 2>&1` exposed the actual error:
  **"could not open config file: No such file or directory"**

## Root Cause

The rsyslog configuration file `/etc/rsyslog.conf` was intentionally renamed to simulate a missing/corrupt configuration scenario, causing the service startup failure.

## Resolution

* Located the backup configuration file using:
  `sudo find /etc -name "*rsyslog*"`
* Restored the configuration:
  `mv /etc/rsyslog.conf.bak /etc/rsyslog.conf`
* Restarted the service successfully:
  `systemctl start rsyslog`
* Verified that rsyslog was active and running.

## Prevention

* Ensure configuration file integrity checks before restarting critical services.
* Maintain proper backup and version control of configuration files.
* Implement monitoring to alert when critical services like rsyslog fail repeatedly.

## How would you know at 3am?

* Alert from monitoring systems (Prometheus/Grafana) indicating rsyslog service failure.
* systemd service failure alerts or log pipeline disruption notifications.

## What I Learned

* systemd restart limits can mask the root issue if not investigated deeper.
* `journalctl` may not always show the full root cause; direct binary execution (`rsyslogd -n`) can reveal more detailed errors.
* Missing configuration files can completely prevent service startup.
* Importance of validating configs and keeping backups before making changes.

