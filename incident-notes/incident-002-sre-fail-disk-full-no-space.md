# Incident 002 — Disk Full on sre-fail

**Date:** 03.04.2026

**VM / System affected:** sre-fail

**Severity:** High

## Problem
System cannot perform write to disk or install any package because disk is full

## Detection
Ran "du -sh /* 2>/dev/null | sort -rh | head -10" to find the filled directory
 which causing the issue 
Found /tmp file is the culprit with 100% usage
"du -sh /tmp/* 2>/dev/null | sort -rh | head -10" clearly showed the specific files causing the issue

## Root Cause
Intentionally ran "fallocate -l 6G /tmp/diskfill.img" command to fill the disk and simulate production disk fill failure.

## Resolution
deleted the diskfill.img and resolved the issue 

## Prevention
Continues monitoring of disk storage and creating alerts when the disk usgae is greater than the threshold of 70% through promethues and grafana 

##How would you know at 3am?
Alert from prometheus or grafana webhook on slack or other platform 

## What I Learned
when the disk is full system cant function basic operation like instal update , how to find the most used disk easyly with du -sh command , verify and remove the high imapcted file/directory.


