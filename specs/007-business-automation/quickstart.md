# Quickstart: Business Logic & Automation

## Purpose

Validate Sprint 6 queue automation in the Flutter + Firebase app using the clarified booking-time rules.

## Prerequisites

- Flutter SDK `>=3.9.0`
- Firebase project configured for the dev flavor
- At least one admin account and one organization with services
- Firestore data containing:
  - one service with a valid `timeMarginMinutes`
  - one service with an intentionally invalid or missing margin to validate the `2-minute` fallback
  - appointments scheduled before, at, and after the current time

## Setup

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run --flavor dev -t lib/main_dev.dart
```

## Manual Verification Flow

### Scenario 1: Pre-booking lock

1. Open admin queue management for a day where the front entry is scheduled in the future.
2. Verify the current card shows `Not due yet` and the scheduled booking time.
3. Verify `skip`, `served/next`, and `no-show` are disabled or unavailable.

### Scenario 2: Countdown starts at booking time

1. Wait until the front entry reaches its `scheduledAt`.
2. Verify the UI switches from `Not due yet` to an active countdown.
3. Verify the countdown uses the service-specific margin when valid.

### Scenario 3: Fallback margin

1. Use an appointment whose service margin is missing or invalid.
2. Verify the countdown uses `2 minutes`.
3. Verify the no-show deadline matches `scheduledAt + 2 minutes`.

### Scenario 4: Auto no-show

1. Leave the front entry unattended until its deadline passes.
2. Open or revisit queue management.
3. Verify the system auto-marks the entry as `noShow`, shows a brief notification, and advances the queue.

### Scenario 5: Serving stops automation

1. Reach a due queue entry.
2. Mark the customer as `serving` using the new attendance/start-service flow.
3. Verify auto no-show no longer applies to that entry.

### Scenario 6: Rejoin

1. Use a customer auto-marked as `noShow`.
2. Rejoin the customer.
3. Verify they return to `inQueue` at the end of the waiting list and receive a fresh booking-time-based eligibility window when they reach the front again.

### Scenario 7: Customer queue-status messaging

1. Open the customer queue status screen for an affected appointment.
2. Trigger a no-show.
3. Verify the customer UI updates in real time to a distinct `No Show` state with guidance text.

## Recommended Test Commands

```bash
flutter test test/shared/booking/domain/entities/appointment_entity_test.dart
flutter test test/shared/booking/data/models/appointment_model_test.dart
flutter test test/admin/queue_management
flutter test test/customer
flutter test test/firestore_rules
```

## Expected Implementation Touchpoints

- `lib/features/admin/queue_management/`
- `lib/features/shared_domain/entities/appointment_entity.dart`
- `lib/features/shared_domain/models/appointment_model.dart`
- `lib/features/shared_domain/entities/service_entity.dart`
- `firestore.rules`
- `test/admin/queue_management/`
- `test/customer/`
- `test/firestore_rules/`