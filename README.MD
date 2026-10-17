![Proxmox Homelab Documentation](images/banner.svg)
# Proxmox Homelab Documentation
Documentation for my Proxmox-based homelab: hardware and network inventory, incident write-ups with root cause analysis, change records, and reusable knowledge base articles. I keep it in an ITIL-style format (incident, change, knowledge) to practice the same workflow used in professional IT support.

> **Note:** IP addresses, hostnames, and other sensitive details are placeholders or redacted.

---

## 🚧 Work in Progress
 - Homelab Rack with sections for the Router, Switch, and Hosts.
 - Upgrade to a two-node cluster using old homelab parts for the second node.
 - Segment Mass Storage RAID Pools and Homelab services.
 - Some sort of implementation with old laptop. Extra host, Monitor Panel, etc.


---

## Repository Structure

```
PROXMOX-HOMELAB/
├── changes/          # Planned changes: upgrades, migrations
├── incidents/        # Things that broke: symptoms, diagnosis, root cause, fix
├── inventory/        # Hardware, network, and services reference
├── knowledge-base/   # Reusable how-tos and fixes
└── templates/        # Starting points for new entries
```

---

## Contents

| Folder | What's in it |
|---|---|
| [`incidents/`](incidents/) | Troubleshooting write-ups: symptoms, timeline, diagnosis, root cause, resolution, prevention |
| [`changes/`](changes/) | Planned work with backup, rollback, and validation steps |
| [`knowledge-base/`](knowledge-base/) | Reusable how-tos and fixes distilled from incidents |
| [`inventory/`](inventory/) | [Hardware](inventory/hardware.md), [network](inventory/network.md), and [services](inventory/services.md) reference |
| [`templates/`](templates/) | Templates for incidents, changes, KB articles, and network documentation |

---

## How I Document

1. **Incident:** when something breaks, I record symptoms, timeline, diagnosis steps, root cause, resolution, and prevention.
2. **Knowledge base:** I distill a reusable how-to or fix from the incident and link the two.
3. **Change:** Documented change history.

---

## Conventions

- Incidents and changes are named `YYYY-MM-DD-short-title.md`
- Every incident states a root cause, not just the fix
- KB articles include a "last tested" date and the versions they apply to
- Sensitive information is removed before committing