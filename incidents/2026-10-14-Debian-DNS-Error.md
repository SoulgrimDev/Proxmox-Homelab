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