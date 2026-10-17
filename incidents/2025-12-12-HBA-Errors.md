# Faulty HBA-bundled cables caused failed transfers and degraded TrueNAS pools

| Field | Value |
|---|---|
| **Date** | 2025-12-12 |
| **Status** | Resolved |
| **Severity** | High |
| **Affected systems** | TrueNAS server, HBA and its bundled cables, ZFS pools (multiple), SMB/file transfer clients |
| **Time to resolve** | 1 Week |
| **Category** | Storage |

## Summary
File transfers to the TrueNAS server began failing, and TrueNAS raised alerts that multiple pools were degraded and that several drives were failing. The cause was faulty cables that shipped with the HBA, which had failed after a few months of use. Replacing them resolved the issue permanently.

## Symptoms
- First sign: file transfers to/from the NAS were failing.
- TrueNAS alerts reporting pools as degraded and drives as failing, across **multiple drives at once**.

## Diagnosis
1. **Checked pool and drive status in TrueNAS.** Several pools and drives were reported as degraded/failing at the same time. Multiple unrelated drives failing together points to something shared (HBA, cabling, power, backplane) rather than independent disk failures.
2. **Looked at the common component.** All affected drives connected through the same HBA and its cables, which made the HBA the prime suspect.
3. **Researched the HBA.** An Amazon review on the HBA listing described the bundled cables failing after a few months, matching the timeline and symptoms here. Listing: <https://www.amazon.com/dp/B0BZVT2RPZ>
4. **Replaced the cables.** The faults stopped immediately and never returned, which confirms the cables were the cause.

## Root cause
The cables bundled with the HBA were defective and degraded over a few months of use. The unreliable connection caused drives to drop out or throw errors intermittently, which TrueNAS reported as degraded pools and failing drives, and which interrupted file transfers. The drives themselves were not the problem.

## Resolution
1. Identified the bundled HBA cables as the probable fault (via the Amazon review and the multi-drive failure pattern).
2. Powered down the server and replaced the HBA cables with new ones.
3. Brought the system back up, confirmed pools and drives came back healthy, and cleared any residual errors.
4. Verified file transfers worked normally.
5. Monitored afterward: no recurrence in the year since.

## Prevention / follow-ups
- Replaced the faulty bundled cables with new ones
- Check reviews and other online sources for products reporting issues.
- Keep a spare known-good cable on hand

## Lessons learned
- When multiple drives fail or degrade at the same time, suspect a shared component (HBA, cables, power, backplane) before assuming several disks died at once.
- Customer reviews on the product listing surfaced the issue faster than troubleshooting alone.
- Don't replace assume drives are failing until troubleshooting and investigation is completed.