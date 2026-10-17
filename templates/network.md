# Network Overview

_Last updated: YYYY-MM-DD_  
_Addresses below are examples; real values are redacted._

## Summary
One paragraph: ISP, router/firewall, how traffic flows.

## Diagram
![Network diagram](diagrams/network.png)

## VLANs / Subnets

| VLAN | Name | Subnet | Gateway | Purpose |
|---|---|---|---|---|
| 10 | Servers | 10.0.10.0/24 | 10.0.10.1 | Lab VMs and containers |
| 20 | IoT | 10.0.20.0/24 | 10.0.20.1 | Isolated smart devices |
| 30 | Clients | 10.0.30.0/24 | 10.0.30.1 | Laptops, phones |

## Static IP Allocations

| Hostname | IP | VLAN | Purpose |
|---|---|---|---|
| pve01 | 10.0.10.5 | 10 | Proxmox host |
| pihole | 10.0.10.10 | 10 | DNS |

## DNS & DHCP
- **DHCP server:**
- **DNS resolver:**
- **Upstream DNS:**
- **Local domain:**

## Firewall Rules (summary)

| Source | Destination | Action | Reason |
|---|---|---|---|
| IoT | Servers | Block | Isolation |
| Clients | Servers | Allow 443 | Web UIs only |

## Remote Access
VPN type, what it reaches, what it doesn't.

## Known Issues / Quirks
-