# Incident history

## 2026-10-14 - Debian DNS Error

# Debian DNS Errors after Static IP

| Field | Value |
|---|---|
| **Date** | 2026-10-14 |
| **Status** | Resolved |
| **Severity** | Low |
| **Affected systems** | Debian VMs |
| **Time to resolve** | 1 hour |
| **Category** | Network |

## Summary
After assigning a static IP on a Debian VM, the VM could no longer resolve domain names. `apt-get update` and `apt-get install` failed because they could not resolve repository hostnames.

## Symptoms
- `apt-get update` and `apt-get install` failed with name resolution errors.
- `ping` to an IP address worked, but `ping` to a hostname failed.

## Diagnosis
- Checked `/etc/network/interfaces` to confirm the nameservers were listed.
- Pinged Google DNS (`ping 8.8.8.8`) to confirm the VM had connectivity. This showed the problem was name resolution, not routing or the gateway.
- Checked the Debian documentation to confirm the static IP steps were followed correctly.

## Root cause
The DNS servers were configured in `/etc/network/interfaces`, but the VM was not reading them from there. The cause is likely that the `dns-nameservers` option in that file only takes effect when the `resolvconf` package is installed. Without it, the line is silently ignored. This Debian install did not have `resolvconf`, so DNS had to be set directly in `/etc/resolv.conf`.

Where DNS is configured, and which setting takes precedence, also depends on what manages networking on the system:

- **ifupdown** (Debian default): network settings live in `/etc/network/interfaces`, but DNS ends up in `/etc/resolv.conf` only if `resolvconf` is installed.
- **NetworkManager** (often present when GNOME or another desktop is installed): it ignores `/etc/network/interfaces`, and DNS is set with `nmcli` or the GUI.
- **systemd-networkd / systemd-resolved**: DNS comes from their own configuration and can overwrite manual edits to `/etc/resolv.conf`.

With DHCP, the DNS servers are supplied automatically. Switching to a static IP removed that, so DNS had to be set explicitly.

## Resolution
1. Edit `/etc/resolv.conf` and add the DNS entries, for example `nameserver 8.8.8.8`.
2. Test connectivity and name resolution with `ping 8.8.8.8` and `ping debian.org`.
3. Confirm `apt-get update` and `apt-get upgrade` work.

## Prevention / follow-ups
- Use a Debian VM template with DNS preconfigured. After cloning, update only the hostname, users, and IP address.
- Check what is managing networking before editing any config: `systemctl is-active networking NetworkManager systemd-networkd systemd-resolved`. The active service is the one that controls the settings.
- Check whether `/etc/resolv.conf` is a symlink (`ls -l /etc/resolv.conf`). If it is, another service manages it and will overwrite manual edits.
- If using ifupdown, either install `resolvconf` so `dns-nameservers` works as documented, or keep DNS in `/etc/resolv.conf` consistently across all VMs.

## Lessons learned
- **A static IP change affects more than the IP.** With DHCP, DNS and the gateway were supplied automatically. After switching to static, DNS, gateway, and search domain all need to be set explicitly.
- **Find out what manages networking before editing config.** Debian can use ifupdown, NetworkManager, or systemd-networkd, and each keeps DNS settings in a different place. Check which one is active rather than assuming from the docs.
- **Docs describe the default, not necessarily your install.** The documented `/etc/network/interfaces` approach didn't match how this VM was set up. Confirm against the running system (`cat /etc/resolv.conf`, `systemctl status networking`) instead of trusting the docs alone.
- **Testing by IP first isolates the problem quickly.** `ping 8.8.8.8` working while hostnames failed pointed straight at DNS rather than routing.
- **Record exact error messages.** Vague notes like "ping commands changed" aren't useful later. Capturing the exact output makes the write-up searchable.
- **Templates prevent repeat work.** A template with DNS preconfigured removes this manual step.

## Related
- Knowledge-Base: [Fix: Debian cannot resolve domain names after setting a static IP](../knowledge-base/debian-static-ip-dns.md)

## 2025-12-12 - HBA Errors

# Faulty HBA-bundled cables caused failed transfers and degraded TrueNAS pools

| Field | Value |
|---|---|
| **Date** | 2025-12-12 |
| **Status** | Resolved |
| **Severity** | High |
| **Affected systems** | TrueNAS server, HBA and its bundled cables, ZFS pools (multiple), SMB/file transfer clients |
| **Time to resolve** | 1 Week |
| **Category** | Storage |

## Summary
File transfers to the TrueNAS server began failing, and TrueNAS raised alerts that multiple pools were degraded and that several drives were failing. The cause was faulty cables that shipped with the HBA, which had failed after a few months of use. Replacing them resolved the issue permanently.

## Symptoms
- First sign: file transfers to/from the NAS were failing.
- TrueNAS alerts reporting pools as degraded and drives as failing, across **multiple drives at once**.

## Diagnosis
1. **Checked pool and drive status in TrueNAS.** Several pools and drives were reported as degraded/failing at the same time. Multiple unrelated drives failing together points to something shared (HBA, cabling, power, backplane) rather than independent disk failures.
2. **Looked at the common component.** All affected drives connected through the same HBA and its cables, which made the HBA the prime suspect.
3. **Researched the HBA.** An Amazon review on the HBA listing described the bundled cables failing after a few months, matching the timeline and symptoms here. Listing: <https://www.amazon.com/dp/B0BZVT2RPZ>
4. **Replaced the cables.** The faults stopped immediately and never returned, which confirms the cables were the cause.

## Root cause
The cables bundled with the HBA were defective and degraded over a few months of use. The unreliable connection caused drives to drop out or throw errors intermittently, which TrueNAS reported as degraded pools and failing drives, and which interrupted file transfers. The drives themselves were not the problem.

## Resolution
1. Identified the bundled HBA cables as the probable fault (via the Amazon review and the multi-drive failure pattern).
2. Powered down the server and replaced the HBA cables with new ones.
3. Brought the system back up, confirmed pools and drives came back healthy, and cleared any residual errors.
4. Verified file transfers worked normally.
5. Monitored afterward: no recurrence in the year since.

## Prevention / follow-ups
- Replaced the faulty bundled cables with new ones
- Check reviews and other online sources for products reporting issues.
- Keep a spare known-good cable on hand

## Lessons learned
- When multiple drives fail or degrade at the same time, suspect a shared component (HBA, cables, power, backplane) before assuming several disks died at once.
- Customer reviews on the product listing surfaced the issue faster than troubleshooting alone.
- Don't replace assume drives are failing until troubleshooting and investigation is completed.

