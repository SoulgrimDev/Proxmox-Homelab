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