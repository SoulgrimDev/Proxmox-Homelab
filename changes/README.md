# Change history

## 2026-05-15 - Migrate VMs OffBoot

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

## 2026-05-10 - homlab upgrade v1

# Proxmox homelab hardware upgrade, 2.5 GbE network upgrade, and Proxmox 8 to 9 upgrade

| Field | Value |
|---|---|
| **Date** | 2026-05-10 |
| **Status** | Completed |
| **Type** | Upgrade |
| **Risk** | Low |
| **Systems affected** | Proxmox homelab host (Proxmox VE 8 → 9), all VMs on it, home network (new 2.5 GbE switch), main PC (network link only) |
| **Expected downtime** | 2 days - Move old parts from main PC into HomeLab.
| **Related incident** | N/A |

## Reason
A new motherboard was bought for the main PC, which already had a 2.5 GbE NIC. The homelab and home network were upgraded at the same time so the two machines could talk at 2.5 GbE instead of being limited to 1 GbE. The homelab also got a newer CPU and platform, dedicated NVMe storage for VM backups, and a move from Proxmox VE 8 to 9 to stay on a supported release.

## Plan
Four parts, done in one maintenance window:
1. **Platform swap:** ASRock H170 Pro4S + i5-6700K → MSI B450 GAMING PRO CARBON MAX WIFI + Ryzen 5 3600X. The 32 GB RAM and Proxmox boot disk are reused for the swap.
2. **Network:** Add a 2.5 GbE switch and a 2.5 GbE PCIe NIC in the homelab.
3. **Storage:** Add an NVMe SSD, configured in Proxmox as `vm-storage` and used for VM backups.
4. **Proxmox upgrade (8 → 9):** After the hardware was working on Proxmox 8, back up all VMs to `vm-storage`, install Proxmox 9, then restore the VMs from `vm-storage`.

## Pre-checks
- Backup of all VMs taken to `vm-storage` and verified
- Enough free space on `vm-storage` for full backups of every VM
- Current config recorded (`/etc/network/interfaces`, `/etc/pve/storage.cfg`, VM configs, hardware list)
- Host-level config saved off the host (users/permissions, firewall rules, backup job schedules, cron jobs), since VM backups don't include it
- Proxmox VE 9 installer downloaded and written to USB
- Maintenance window chosen
- BIOS version on the B450 board confirmed to support the Ryzen 5 3600X
- Display output available for first boot (the 3600X has no integrated graphics)

## Implementation steps
1. Gracefully shut down all VMs and power off the host
2. Remove the old ASRock H170 Pro4S and i5-6700K
3. Install the MSI B450 board and Ryzen 5 3600X, reusing the 32 GB RAM
4. Install the 2.5 GbE PCIe NIC and the NVMe SSD
5. Install the 2.5 GbE switch and connect the homelab and the uplink
6. Enable SVM Mode in BIOS (and IOMMU if used) and set boot order to the existing Proxmox 8 boot disk
7. Boot Proxmox 8 and identify the new NIC name
8. Update the `vmbr0` bridge port in `/etc/network/interfaces` to the new NIC and apply
9. Initialize the NVMe SSD and add it as Proxmox storage named `vm-storage`
10. Back up all VMs to `vm-storage` and verify the backups
11. Install Proxmox VE 9
12. Reconfigure networking (`vmbr0` on the 2.5 GbE NIC) and re-add `vm-storage`
13. Restore all VMs from `vm-storage`
14. Start VMs

## Rollback plan
1. Keep the old ASRock board and i5-6700K intact until validation is complete.
2. Do not delete or overwrite the backups on `vm-storage` until all restored VMs are confirmed working on Proxmox 9.
3. If the hardware or network changes fail before the Proxmox 9 install, shut down and move the Proxmox 8 boot disk and RAM back to the ASRock/i5-6700K system, then reconnect the host to the original 1 GbE connection.
4. If the Proxmox 9 install or restore fails, reinstall Proxmox 8 (on the new or old hardware), re-add the backup storage and restore the VMs from the Proxmox 8-era backups on `vm-storage`.
5. Restore the saved `/etc/network/interfaces` and `storage.cfg` as needed.
6. Boot and confirm all VMs start.

## Validation
- `pveversion` reports Proxmox VE 9.x
- Proxmox web UI and all VMs respond
- Restored VMs have the correct settings (CPU, network, start-at-boot, disks)
- Host NIC negotiates 2500 Mb/s (`ethtool`)
- 2.5 GbE confirmed between the homelab and main PC
- A new backup job to `vm-storage` completes successfully
- No new errors in `dmesg` or the Proxmox logs

## Outcome
Completed. The homelab now runs Proxmox VE 9 on the MSI B450 board with a Ryzen 5 3600X and the original 32 GB RAM. The home network is 2.5 GbE, with a new switch and a 2.5 GbE PCIe NIC in the host. The NVMe SSD is in service as `vm-storage`. It held the VM backups used to move from Proxmox 8 to 9 and is still used for VM backups. [Add actual downtime and any deviations from the plan.]

## Post-change notes
- The storage is named `vm-storage` but used for backups. Consider renaming it, or check that its content types are set the way you want.
- Backups on an NVMe in the same host won't survive host failure. Consider copying them to another machine or off-site.
- If any VM used CPU type `host`, or relied on Intel Quick Sync or iGPU passthrough, check that it still works on the AMD platform.
- Check that backup jobs, firewall rules, users and other host-level settings were recreated on the new install.
- Write a KB article on the backup, reinstall and restore method for future major upgrades.
- Record the 2.5 GbE NIC and switch models here for future reference.

