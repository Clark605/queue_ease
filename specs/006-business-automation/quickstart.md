# Sprint 6: Business Logic & Automation - Quick Reference

## Overview

Sprint 6 adds time margin enforcement and automatic no-show detection to the queue management system. This is a **client-side** automation feature triggered by the admin viewing the queue.

## Key Concepts

| Concept | Description |
|---------|-------------|
| Time Margin | Grace period (minutes) between the booked appointment time and when the customer is considered a no-show |
| Booking Time | The scheduled appointment time used as the reference point for no-show evaluation |
| Auto No-Show | Client-side detection of overdue customers; triggers existing `markNoShow` |
| Countdown Timer | Real-time UI showing remaining grace period before the front-of-queue customer becomes a no-show |

## User Stories (Priority Order)

1. **P1 - Countdown Timer UI**: Admin sees live countdown for current customer
2. **P2 - Auto No-Show Detection**: Overdue customers auto-marked on screen mount
3. **P3 - Reversible via Rejoin**: Admin can undo auto no-show using existing rejoin
4. **P4 - Customer No-Show State**: Customer sees clear "No Show" message

## Sprint Scope

### In Scope
- Time margin evaluation based on booked appointment time
- Countdown timer UI on admin queue management screen
- Auto no-show detection when admin opens queue screen
- Integration with existing `markNoShow` transaction
- Customer-facing no-show state display

### Out of Scope (Sprint 7+)
- Push notifications when marked as no-show
- Cloud Functions / server-side automation
- Historical no-show analytics
- Configurable auto no-show behavior per org

## Dependencies

- **Sprint 5 Complete**: Queue management (next, skip, markNoShow, rejoin) functional
- **Service Entity**: `timeMarginMinutes` field already exists and is configurable
- **Appointment Data**: Each queued customer has a reliable booked appointment time

## Files to Modify (Expected)

| Area | Files |
|------|-------|
| Entity | `appointment_entity.dart` (expose booked appointment time to queue logic) |
| Model | `appointment_model.dart` (ensure booked appointment time is available for evaluation) |
| Datasource | `admin_queue_datasource.dart` (apply no-show deadline checks using booked appointment time) |
| Repository | `admin_appointment_repository.dart` (provide `timeMarginMinutes` and booking time to queue view) |
| Cubit | `queue_management_cubit.dart` (auto no-show logic) |
| UI | `current_queue_card.dart` (countdown timer widget) |
| Customer UI | `queue_position_card.dart` (no-show state) |

## Success Metrics

- Countdown visible within 1 screen transition
- 100% overdue entries auto-detected on mount
- Auto no-show + advancement < 3 seconds
- Zero duplicate no-show triggers
