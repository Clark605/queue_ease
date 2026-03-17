# Admin Queue Automation Contract

## Purpose

Define the state and action contract for the admin queue-management UI and the customer queue-status UI during Sprint 6.

## Admin Current Entry Contract

The front queue entry must map to one of these operational states.

| State | Entry Condition | Visible UI | Allowed Actions | Forbidden Actions |
|------|-----------------|------------|-----------------|------------------|
| `not_due_yet` | `now < scheduledAt` and status is non-terminal | `Not due yet` + scheduled booking time | none | `skip`, `served/next`, `no-show` |
| `awaiting_arrival` | `scheduledAt <= now < noShowDeadline` and status is not `serving` | live countdown + remaining time | `start serving`, `skip`, `no-show` | `served/next` |
| `overdue` | `now >= noShowDeadline` and status is not `serving` | `Overdue` indicator until write succeeds | manual `no-show`, optional retry path | `served/next` |
| `serving` | status is `serving` | serving header / no no-show countdown | `served/next`, optionally existing skip flow | auto no-show |

## Admin Action Contract

| Action | Preconditions | Persistence Effect |
|--------|---------------|--------------------|
| `start serving` | front entry is due and not already serving | appointment `inQueue -> serving` |
| `served/next` | front entry is `serving` | current appointment `serving -> completed`, advance pointer |
| `skip` | front entry is due | reorder entry to end; preserve or update status according to attendance state |
| `no-show` | front entry is due and not terminal | appointment becomes `noShow`, advance pointer |
| `rejoin` | entry is `noShow` | appointment `noShow -> inQueue`, append to end |

## Auto No-Show Contract

- Trigger source: queue screen mount, active countdown expiry, or re-evaluation after each automated action.
- Guard conditions:
  - front entry exists
  - entry is not terminal
  - entry has not been marked `serving`
  - `now >= noShowDeadline`
- Effect:
  - mark entry `noShow`
  - advance queue pointer
  - recalculate automation state for the new front entry
  - show a brief admin notification

## Service Margin Contract

| Source | Effective Value |
|--------|-----------------|
| valid `service.timeMarginMinutes` | use service value |
| missing or invalid service margin | use global fallback `2 minutes` |

## Customer Queue Status Contract

| Status | Customer UI |
|--------|-------------|
| queued / active | existing queue position and wait messaging |
| `noShow` | explicit `No Show` state + guidance to contact the business |

## Notes

- This contract intentionally treats "front of queue" and `serving` as distinct concepts.
- The current implementation auto-promotes entries to `serving`; Sprint 6 implementation must remove that implicit assumption to satisfy the clarified specification.