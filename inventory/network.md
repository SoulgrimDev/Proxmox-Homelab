# Network Overview

_Last updated: 2026-10-17_  
## Summary
- Simple for now. Just a Unmanged Switch and a router. 
- Future plans for virtualized OPNsense or pfsense instance for firewall and segmentation.

## Static IP Allocations

| Name | IP | VM #| Purpose |
|---|---|---|---|
| ARRIS (SBG10-RB) - Modem Router Combo | 192.168.0.1 | NA | Router |
| Raspberry Pi | 192.168.0.2 | NA | DNS/AD-Blocking/Local-DNS Records/Scripting/Monitoring|
| Proxmox PE Hypervisor | 192.168.0.100 | 100 | Proxmox Hypervisor |

## Known Issues / Quirks
- No Firewall
- No VLANs or Subnets
