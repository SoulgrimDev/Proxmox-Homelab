# Fix: Debian cannot resolve domain names after setting a static IP

**Applies to:** Debian VMs (ifupdown, NetworkManager, or systemd-resolved; version tested: 12)
**Last tested:** 2026-10-14
**Related incident:** [Debian DNS Errors after Static IP](../incidents/2026-10-14-debian-dns-static-ip.md)

## Problem / Goal
After switching a Debian VM from DHCP to a static IP, `apt-get update`, `apt-get install`, and hostname pings fail with name resolution errors, even though the network itself is up. The goal is to set DNS servers correctly for the networking service the VM actually uses.

## Prerequisites
- Root or sudo access to the VM
- The DNS server addresses to use (for example `8.8.8.8` or your internal DNS)
- Console access in case network changes cut off your SSH session

## Steps
1. **Confirm it is a DNS problem, not a routing problem.**
```bash
   ping -c 3 8.8.8.8      # works = connectivity is fine
   ping -c 3 debian.org   # fails = DNS problem
```

2. **Find out what is managing networking.**
```bash
   systemctl is-active networking NetworkManager systemd-networkd systemd-resolved
   ls -l /etc/resolv.conf
```
   The service reporting `active` is the one in control. If `/etc/resolv.conf` is a symlink, another service manages it and will overwrite manual edits.

3. **Set DNS using the method that matches the active service.**

   **ifupdown, no `resolvconf` installed (Debian default):** edit `/etc/resolv.conf` directly.
```
   nameserver 8.8.8.8
   nameserver 1.1.1.1
```

   **ifupdown with `resolvconf`:** keep the `dns-nameservers` line in `/etc/network/interfaces` and install the package so it takes effect.
```bash
   sudo apt-get install resolvconf
   sudo systemctl restart networking
```

   **NetworkManager:** set DNS on the connection.
```bash
   nmcli connection show
   sudo nmcli connection modify "<connection name>" ipv4.dns "8.8.8.8 1.1.1.1"
   sudo nmcli connection up "<connection name>"
```

   **systemd-resolved:** set `DNS=` in `/etc/systemd/resolved.conf`, then run `sudo systemctl restart systemd-resolved`.

## Verification
```bash
cat /etc/resolv.conf          # shows the expected nameservers
ping -c 3 debian.org          # hostname resolves and replies
sudo apt-get update           # completes without resolution errors
```
Then reboot and re-run the checks to confirm the setting persisted.

## Prevention
- Build new VMs from a template with DNS already configured, and change only the hostname, users, and IP address after cloning.
- When setting a static IP, always set the DNS servers and gateway at the same time.
- Check which service manages networking before editing config files.
- Standardize on one approach across your VMs so the fix is the same everywhere.

## Troubleshooting
- **If `ping 8.8.8.8` also fails:** this is not DNS. Check the IP address, netmask, and gateway.
- **If DNS works, then stops after a reboot:** another service (NetworkManager, systemd-resolved, or a DHCP client) is overwriting `/etc/resolv.conf`. Set DNS in that service instead.
- **If `dns-nameservers` in `/etc/network/interfaces` has no effect:** `resolvconf` is probably not installed. Check with `dpkg -l resolvconf`.
- **If `/etc/resolv.conf` is a symlink:** don't edit it directly. Change the configuration of the service it points to.
- **If `nameserver 127.0.0.53` appears in `/etc/resolv.conf`:** systemd-resolved is in use, so configure DNS through it.