# Executive Summary

Between December 2021 and September 2026, the legacy web application `septober.palladius.it` became completely unavailable. The incident had two distinct layers: an underlying systemd emergency mode lockup caused by an unmounted secondary disk without `nofail` in `/etc/fstab` on the GCE virtual machine `septober-docker-zrh-202112`, combined with a DNS A record pointing to a decommissioned ephemeral IP address (`35.207.84.98`). Recovery was achieved first by mounting the boot disk to a rescue VM and sanitizing `/etc/fstab`, verifying that the VM can boot and start Docker, and subsequently executing a modernization migration (Option 2) by deploying the container to Cloud Run with native Cloud SQL Proxy connectivity and binding the domain via Cloud DNS.

## Impact

The service `septober.palladius.it` was completely inaccessible (connection timeouts on ports 80 and 443). As Septober is a vintage personal archive application, external business impact was zero, but internal usability and web presence for `septober.palladius.it` was interrupted until reported on 2026-09-06.

## Background

Septober is a vintage Rails web application (`Septober v2.5.04`). Originally hosted on Google Compute Engine in `us-central1-c` (`septober-docker`), in December 2021 a migration to Zurich (`europe-west6-b`) was initiated. During the migration, the root disk was replicated to `septober-docker-zrh-202112`, but a secondary 500 GB data volume (`septober-docker-discone`) remained in the US region.

## Root Causes and Trigger

### Root Causes
1. **Fstab Missing `nofail` Flag**: An entry in `/etc/fstab` referencing `UUID=b758f53a` (the absent US secondary volume) was set with `defaults 1 1`. On systemd systems, any missing filesystem without `nofail` or `x-systemd.device-timeout` causes the local-fs target to fail after a 90-second timeout, dropping the system into Emergency Mode.
2. **Locked Root Account on GCE Image**: The Debian 9 stretch GCE image has the root password disabled by default. When systemd invokes `sulogin` in Emergency Mode, it fails with *"Cannot open access to console, the root account is locked"*. Consequently, `multi-user.target` is never reached, preventing SSH, Docker, and networking daemons from launching.
3. **DNS Pointing to Ephemeral IP**: The Cloud DNS zone `palladius-it` had an A record pointing to an unreserved, ephemeral external IP (`35.207.84.98`) which was released when the VM stopped.
4. **Cloud SQL Egress & Scope Limitations**: The legacy GCE VM lacked Cloud SQL OAuth scopes, and the Cloud SQL database (`ric-cccwiki:europe-west3:prod`) restricted incoming TCP traffic, preventing direct container database access on GCE without external proxy instances.

### Trigger
On **2021-12-22 09:12:00 UTC**, a manual system reboot (`sudo reboot`) was issued on `septober-docker-zrh-202112` following Docker installation. The reboot triggered the fstab evaluation which entered Emergency Mode.

## Detection and Monitoring

The incident was detected manually by ricc@ on **2026-09-06 09:36:34 UTC** when attempting to browse to `http://septober.palladius.it` and finding it unresponsive. No automated uptime check or SLO alert was attached to this specific vintage domain.

## Mitigation

1. **GCE Boot Disk Rescue**: Stopped `septober-docker-zrh-202112`, detached its root disk, and attached it as a secondary disk to a temporary Debian 12 micro VM (`rescue-septober`).
2. **Sanitize Fstab**: Commented out the non-existent `/mnt/septober` disk mount in `/etc/fstab`.
3. **Verification**: Deleted the rescue instance, reattached the boot disk, and booted `septober-docker-zrh-202112`. Confirmed successful transition to `multi-user.target` and verified the Docker daemon started cleanly.
4. **Modernization to Cloud Run (Option 2)**: Due to legacy OS obsolescence (Debian 9 Stretch EOL) and Cloud SQL access constraints on GCE, deployed the application container (`gcr.io/ric-cccwiki/septober-mysql:2026-patch`) to Cloud Run (`septober-mysql` in `europe-west1`) with native Cloud SQL integration (`/cloudsql/ric-cccwiki:europe-west3:prod`).
5. **DNS Realignment**: Bound `septober.palladius.it` to Cloud Run via custom domain mapping and updated Cloud DNS with `CNAME ghs.googlehosted.com.`.

## Customer Comms

No external customer notification was required. Incident status and post-mortem communicated directly to ricc@ via pair-programming chat.

## Lessons Learned

### Things That Went Well
* Serial console output provided unambiguous evidence of the exact line in `/etc/fstab` and the 90-second systemd timeout.
* The rescue VM disk detachment technique allowed safely fixing `/etc/fstab` without data loss or root credentials.
* The modern container image `septober-mysql:2026-patch` had already been prepared and validated, making the transition to Cloud Run instantaneous.

### Things That Went Poorly
* A secondary storage mount in `/etc/fstab` did not have `nofail`, causing a catastrophic boot halt that required out-of-band disk detachment to resolve.
* Ephemeral IPs were used in DNS records instead of reserved Static External IPs or CNAMEs to managed services.
* The legacy GCE instance had been stuck in emergency mode unobserved for an extended duration due to lack of uptime checks.

### Where We Got Lucky
* Cloud SQL instance `prod` in Frankfurt was still running and intact with valid database credentials.
* Cloud Run supports native Unix socket proxying to Cloud SQL without needing local proxy VMs or modifying database network ACLs.

## Action Items

| Action Item | Owner | Priority | Type | Bug_id |
|-------------|-------|----------|------|--------|
| Add `nofail` option to any non-root mount entries in GCE template fstab files | ricc@ | **P2** | Prevent | [b/fstab-nofail](https://github.com/palladius/septober/issues) |
| Decommission or suspend orphaned GCE instances (`septober-docker-zrh-202112`, `septober-docker`) to reduce waste | ricc@ | **P2** | Mitigate | [b/gce-decom](https://github.com/palladius/septober/issues) |
| Configure Cloud Monitoring Uptime Check for `septober.palladius.it` | ricc@ | **P3** | Detect | [b/uptime-check](https://github.com/palladius/septober/issues) |

## Timeline

Day: **2021-12-22**  TZ=US/Pacific
* `00:40:54`: ricc@ clones US boot disk and creates `septober-docker-zrh-202112` in Zurich.
* `01:10:00`: ricc@ updates `/etc/fstab` referencing missing disk UUID without `nofail`.
* `01:12:00`: ricc@ executes `sudo reboot`. <== <span style="color:red">Start of Incident</span>

Day: **2026-09-06**  TZ=US/Pacific
* `02:36:34`: ricc@ detects `septober.palladius.it` is offline. <== <span style="color:red">Incident Detected</span>
* `02:39:15`: SRE investigation analyzes serial port logs and identifies systemd emergency mode lockup.
* `03:07:02`: Hard reset attempted; reproduces 90s systemd timeout on `dev-disk-by-uuid-b758f53a`.
* `22:48:44`: VM stopped and boot disk mounted to temporary rescue VM.
* `22:50:08`: `/etc/fstab` amended on rescue mount; rescue VM destroyed.
* `22:51:18`: Boot disk reattached; Zurich GCE VM boots cleanly with Docker active.
* `22:53:15`: Architectural audit confirms Cloud SQL connectivity barriers on legacy GCE.
* `22:55:38`: `septober-mysql` deployed to Cloud Run with native Cloud SQL connection.
* `22:56:04`: Cloud DNS updated with CNAME `ghs.googlehosted.com.` for `septober.palladius.it`. <== <span style="color:red">End of Incident</span>

## IMPORTANT

This PostMortem is AI-generated. Please review it carefully before submitting.
