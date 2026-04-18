# Incident 004 — Disk usage full simulation and troubleshooting
 
**Date:**
18.04.2026

**VM / System affected:**
sre-fail

**Severity:**
High

## Problem
Disk is 96% full and i got paged to resolve this issue in this simulation

## Detection
While checking the root directory for disk usage using df -h   found that /var is using most of the space to dig deep down used du -sh /* 2>/dev/null | sort -rh | head -10 to find the exact file which was inside the /var/log/

## Root Cause
A large file accumulated in /var/log/ consuming 6GB of disk space with no cleanup policy in place.

## Resolution
du -sh /var/log/* | sort -rh → found fillfile → sudo rm -ri /var/log/fillfile → verified with df -h.

## Prevention
Initiate proper log rotation and routine check of disk usage 

## What I Learned
`df` vs `du` difference — filesystem vs directory level. `-h` human readable. `-s` summarize. `2>/dev/null` stderr to void. `sort -rh` reverse human sort. The full disk diagnosis pattern: `df → du /* → drill → find → delete`. `fallocate -l` for simulation. `-i` vs `-f` tradeoffs
