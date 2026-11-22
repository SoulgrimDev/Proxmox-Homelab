# Inventory

## Hardware

Current snapshot: [2026-10-16-hardware.md](./2026-10-16-hardware.md)

# Hardware Inventory

_Last updated: 2026-10-16_

## Hosts

| Hostname | Role | Make / Model | CPU | RAM | Storage | OS | Notes |
|---|---|---|---|---|---|---|---|
| pve | Hypervisor | MSI B450 Gaming Pro Carbon Max WiFi  | AMD Ryzen 5 3600X | 32 GB DDR4 (2x16) | 2x 256 GB T-FORCE SATA SSD Boot, 1x 500 GB Crucial P3 NVMe pve-storage | Proxmox VE | PCIe Devices: GeForce RTX 3060 12GB, LSI SAS2008 HBA, 2.5GbE PCIe Adapter|

## Network Hardware

| Device | Role | Notes |
|---|---|---|
| ARRIS (SBG10-RB) - Modem Router Combo | DOCSIS 3.0 Router | 2 Gigabit Ports |
| UGREEN 2.5Gb Switch | Unmanaged Switch | 5 - 2.5Gb Ports |

## Storage

| Pool / Volume | Type | Capacity | Disks | Redundancy | Backed up to |
|---|---|---|---|---|---|
| rpool | ZFS | 256 GiB usable | 2x 256 GB T-FORCE SATA SSD | RAID Mirror | NA |
| nvme0n1p1 | ext4 | 500 GiB | 1x Crucial P3 500 GB NVMe | None | NA |


## Hardware Change History

| Date | Change | Link |
|---|---|---|
| 2026-05-10 | Upgraded homelab build using old PC parts, Old CPU was i5-6700k. | [Changes: Debian cannot resolve domain names after setting a static IP](../changes/2026-05-10-homlab-upgrade-v1.md) |

## Services

Current snapshot: [2026-10-16-services.md](./2026-10-16-services.md)

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

## Network

Current snapshot: [2026-10-17-network.md](./2026-10-17-network.md)

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


