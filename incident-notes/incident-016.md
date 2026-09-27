# Incident 016: Liveness Probe CrashLoopBackOff from Non-Image-Persisted Health Endpoint

**Date:** 24.09.2026
**Severity:** Self-inflicted (lab), production-realistic failure pattern
**Status:** Resolved

## Summary
A liveness probe pointed at `/healthz` on an nginx Deployment caused a
permanent CrashLoopBackOff after a routine `kubectl apply`. The endpoint
had been created manually via `kubectl exec` on a running pod — not
baked into the container image — so it did not survive the fresh pods
spun up by the rollout.

## Timeline
1. `/healthz` created manually inside a running pod via `kubectl exec`,
   as a known, flagged shortcut ("this needs to be baked into the image").
2. A liveness probe config change was applied (`kubectl apply`) to point
   at `/healthz`.
3. `kubectl apply` on a changed Deployment spec triggers a full rollout:
   new ReplicaSet, brand-new pods created fresh from the image.
4. New pods came from the ORIGINAL image — no `/healthz` file, since it
   was never in the image itself, only in the old pod's writable layer.
5. Liveness probe hit `/healthz`, got a 404, failed 3 consecutive checks
   (default threshold) → kubelet killed and restarted the container.
6. New pod: same original image, same missing file, same 404 → repeat.
   Result: permanent CrashLoopBackOff (13+ restarts observed).

## Root Cause
A restart cannot fix a problem that lives in the image itself. Any
runtime-only change to a pod (files created via `kubectl exec`, etc.)
is lost on the next rollout — pods are ephemeral, the image is the
only durable source of truth. Pointing a liveness check at something
that only exists in a pod's writable layer means every future rollout
recreates the exact failure condition.

## Fix
Built the health endpoint properly into the image instead of patching
around it at runtime:

1. `Dockerfile`: `FROM nginx:alpine` + `COPY ./healthz /usr/share/nginx/html/`
2. Verified the file was genuinely present in the built image —
   `docker run --rm <image> cat /usr/share/nginx/html/healthz` —
   rather than trusting the build log alone.
3. Pushed to `ghcr.io/anandarwork-code/k3s-pod-image:latest`, set
   package visibility to Public (GitHub UI — no CLI equivalent for
   this step).
4. Pull-verified from the cluster node BEFORE touching the Deployment:
   `sudo /usr/local/bin/crictl pull <image>` (needed sudo + the full
   explicit binary path — `sudo crictl` alone failed on this node due
   to a `secure_path` PATH mismatch).
5. Updated `nginx_deploy.yaml`'s `image:` field, re-applied.
6. Result: clean rollout, 0 restarts, 0 warning events, both probes
   confirmed correctly configured and passing.

## Lesson
Liveness and readiness probes should check *different* things, for a
reason that only becomes obvious once you've been burned by it:

- **Readiness** should check something meaningful and deep (real
  content, dependency reachability) — a failure here correctly pulls
  the pod from traffic without touching it. Self-correcting, safe.
- **Liveness** should check something minimal and *image-guaranteed*
  to exist — specifically so it can never restart-loop on a problem
  a restart is powerless to fix.

Pointing both at the same shallow check (e.g. `GET /`) means a single
content-level problem fails both simultaneously — and if the pod is
ever recreated fresh from a genuinely broken image, liveness will loop
forever instead of surfacing the real problem clearly.

## Related
- `k8s/nginx_deploy.yaml`, `nginx-healthz` repo (this incident's fix)
- Incident 006 (systemd `restartPolicy` equivalent — different failure
  class: hard crash-and-exit, not "alive but stuck")
