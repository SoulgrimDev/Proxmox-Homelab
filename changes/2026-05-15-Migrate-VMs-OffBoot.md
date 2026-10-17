# Move VM storage off the boot SSD mirror to VM-Storage

| Field | Value |
|---|---|
| **Date** | 2026-05-15 |
| **Status** | Completed |
| **Type** | Normal |
| **Risk** | Medium (VM disks were relocated; no data loss expected with a backup in place) |
| **Systems affected** | Proxmox host, all VMs/CTs whose disks were moved, ZFS boot pool (2x SATA SSD mirror), VM-Storage |
| **Expected downtime** | 1 hour - migrate VMs off ZFS-Boot to PVE-Storage and conduct testing. |
| **Related incident** | High I/O delay and intermittent Proxmox web UI unavailability while the host was still running |

## Reason
The node showed consistently high I/O delay, and the web UI occasionally became unresponsive even though the host was up. VM disks were stored on the same SATA SSD ZFS mirror that the Proxmox OS boots from, so the VMs and the hypervisor were competing for the same I/O. ZFS adds overhead on top of this (checksumming, copy-on-write, sync writes, ARC memory pressure), which makes the contention worse on SATA SSDs. The likely explanation for the web UI dropouts is that the Proxmox management services (`pveproxy`, `pvedaemon`) were being starved by I/O wait.

## Plan
Separate the VM workload from the boot pool by hosting VM disks on VM-Storage instead of the boot mirror. The boot mirror then only handles the OS, logs, and Proxmox config, which keeps the host and web UI responsive under VM load.

## Pre-checks
- VM-Storage has enough free space for all VM disks and VM backups.
- VM-Storage is enabled for content type "Disk image" and "Container" in Datacenter > Storage

## Implementation steps
1. Backup all VMs to PVE-Storage, remove any PCIe devices before backing up due to issues with backng up PCIe configuration on VMs.
2. Remove VMs from ZFS-Boot Pool.
3. Restore backups, selecting VM-Storage as the location. Re-add any PCIe devices needed,
4. Test start all VMs including ones that aren't supposed to have 100% uptime.
5. Monitor I/O delay using Proxmox webUI.
6. Start baseline 100% uptime VMs.
7. Repeat step 5.


## Validation
- I/O delay at idle is not 90% or low.
- WebUI doesn't shutdown during idle or mid workloads.

## Outcome
VM disks are now hosted on VM-Storage instead of the boot SSD mirror.
- I/O delay idle is at 0% and never around 90%.
- Web UI dropouts only occur when VMs are stressing the system; AI inferencing, high CPU ultilization, VM misconfigured.

## Post-change notes
- VM-Storage now holds the live VM disks, so make sure backups go to a separate device. A backup on the same drive as the data it protects isn't a backup.
- Keep the boot mirror for the OS only. Avoid putting new VMs on it.
- Consider another drive for VM Backups as VMs and Backups are ont he same drive. No redundency. 