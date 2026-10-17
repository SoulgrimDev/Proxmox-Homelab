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