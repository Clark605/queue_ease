# Quickstart: Queue System (Sprint 5)

## Prerequisites

- Flutter SDK installed (project uses Flutter 3.9+)
- Firebase project configured for dev flavor
- Dependencies installed:

```bash
flutter pub get
```

- If DI annotations change, regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 1) Run the app (dev flavor)

```bash
flutter run --flavor dev -t lib/main_dev.dart
```

## 2) Seed/prepare runtime state

- Ensure one organization exists with admin account.
- Ensure today's appointments exist with status `booked`.
- Ensure services referenced by appointments have valid `durationMinutes`.

## 3) Admin queue flow verification

1. Sign in as admin and open Queue Management.
2. Trigger queue generation for today (if not auto-triggered).
3. Verify queue shows ordered entries by scheduled time.
4. Perform actions:
   - `Next` moves current entry to completed and promotes next.
   - `Skip` requeues current entry at end.
   - `No-show` marks current entry `noShow` and promotes next.
   - `Rejoin` appends a skipped entry to end.

Expected outcomes:
- No duplicate active entries.
- No conflicting transitions on repeated taps/retries.

## 4) Customer queue status verification

1. Sign in as a customer with an active queued appointment.
2. Open customer queue status screen.
3. Validate:
   - Own position shown.
   - Wait estimate shown.
   - Current-serving indicator updates after admin actions.
   - No other customer identities are visible.

## 5) Error/edge verification

- Empty queue: admin/customer empty-state messaging is clear.
- Retry behavior: reconnect after temporary offline state; queue remains consistent.
- Past-date access: customer receives no-active-queue message.

## 6) Test commands

Run targeted tests first:

```bash
flutter test test/admin/queue_management
flutter test test/customer/entry
flutter test test/shared/queue
```

Optionally run all tests:

```bash
flutter test
```

## 7) Analyze

```bash
flutter analyze
```
