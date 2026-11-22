# Services Inventory

_Last updated: 2026-10-16_

| Service | Host | Type | Port | Purpose | Backed up? | Docs |
|---|---|---|---|---|---|---|
| Proxmox-VE | pve | Physical Homelab Server | 8006 | Hypervisor | Yes | [kb](../kb/...) |
| Pi-hole | Nick-Pi | Physical RaspberryPi | 53, 80 | DNS and ad blocking | No | [kb](../kb/...) |
| TrueNAS | VM100 | Virtual Machine | 80 | RAID Pools, SMB Shares, File Storage | Yes | [kb](../kb/...) |

## Dependencies

- Pi-hole -> required by all clients (DNS) that are configured to use the DNS. Not all services or host will use the DNS.

- RAID Storage -> required for any services that points to a pool. Ex. Media Pool is used by Jellyfin for streaming content.

- PCIE Passthrough -> required for devices that use pcie devices such as Windows 11 for graphics and gaming or Jellyfin for hardware accelerated encoding.

## Backup Strategy

| What | Method | Frequency | Destination |
|---|---|---|---|
| VMs | Backup NVME SSD | Once Monthly | PVE-Storage |
| Hypervisor | RAID Boot Drive | NA | Homelab Boot |