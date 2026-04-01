# Incident 001 — Gitea 502 No Home Directory

**Date:**
01.04.2026

**VM / System affected:**
sre-vm1

**Severity:**
High

## Problem
site error - git.anandar.dev (502 - bad gateway)

## Detection
while login site responded with 502,
Gitea service was down even after restart stating issue,
Gitea journalctl error log clearly showed permission issue for /home/git

## Root Cause
git user could not find /home/git because of git user has been provided with limited access with no home and shell

## Resolution
create /home/git and changed ownership to user git

## Prevention
routine check of gitea service with the help of scripts


## What I Learned
improper user permission can cause outage
