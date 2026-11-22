![Proxmox Homelab Documentation](images/banner.svg)

# Proxmox Homelab Documentation

I use this repository to document my Proxmox-based homelab. It covers hardware and network inventory, the services I run, incident write-ups with root cause analysis, change records, and reusable knowledge base articles. I follow an ITIL-style workflow to practice how professional IT support teams document incidents, changes, and fixes.

> **Note:** IP addresses, hostnames, and other sensitive details are placeholders or have been redacted.

## 🚧 Work in Progress

- Build a homelab rack with sections for the router, switch, and hosts.
- Upgrade to a two-node cluster using old homelab parts for the second node.
- Segment mass storage RAID pools and homelab services.
- Find a use for an old laptop, possibly as an extra host or monitoring panel.

## Repository Structure

```text
PROXMOX-HOMELAB/
├── changes/          # Planned upgrades, migrations, and other changes
├── incidents/        # Symptoms, diagnosis, root cause, and fixes
├── inventory/        # Hardware, services, and network snapshots
├── knowledge-base/   # Reusable how-tos and fixes
└── templates/        # Starting points for new entries
```

## Contents

| Folder | What's in it |
| --- | --- |
| [Incidents](incidents/) | Troubleshooting reports covering symptoms, timeline, diagnosis, root cause, resolution, and prevention. |
| [Changes](changes/) | Planned work with backup, rollback, and validation steps. |
| [Knowledge base](knowledge-base/) | Reusable how-tos and fixes distilled from incidents. |
| [Inventory](inventory/) | Current [hardware](inventory/hardware.md), [services](inventory/services.md), and [network](inventory/network.md) references, with links to earlier snapshots in the inventory README. |
| [Templates](templates/) | Starting points for incidents, changes, knowledge base articles, and network documentation. |

## README Generators

I write each record in its own Markdown file. After adding or editing a record, I double-click the matching Windows `.cmd` script to rebuild that folder’s `README.md`. The scripts use Windows PowerShell and can run from their matching folder or the repository root. I make edits in the source records because each run replaces the generated README.

| Script | Generated README | What it produces |
| --- | --- | --- |
| `Generate-ChangesReadme.cmd` | [Change history](changes/README.md) | Combines the full text of each change record into one history, newest first by the date in its filename. |
| `Generate-IncidentsReadme.cmd` | [Incident history](incidents/README.md) | Combines the full incident reports, newest first by filename date, so I can read the diagnosis and resolution together. |
| `Generate-KnowledgeBaseReadme.cmd` | [Article index](knowledge-base/README.md) | Lists articles alphabetically. Each link uses the first line of its file as the title, or the filename if that line is blank. |
| `Generate-InventoryReadme.cmd` | [Inventory overview](inventory/README.md) | Shows the full current snapshots in the order **Hardware**, **Services**, **Network**. Each section links to its older snapshot files. |

For inventory, I can keep `hardware.md`, `services.md`, and `network.md` as the current copies in `inventory/` or in their matching category subfolders. When a category has no current copy with that name, the generator selects its newest dated filename and uses the version number to break date ties.

## How I Document

1. **Incident** — When something breaks, I record the symptoms, timeline, diagnostic steps, root cause, resolution, and prevention.
2. **Knowledge base** — When a fix is reusable, I turn it into a how-to and link the article and incident to each other.
3. **Change** — I document the planned work, backup and rollback steps, and how I validated the result.

## Conventions

- Name incident and change records `YYYY-MM-DD-short-title.md`.
- Record the root cause of each incident alongside the fix.
- Include a “last tested” date and applicable versions in knowledge base articles.
- Remove sensitive information before committing.
