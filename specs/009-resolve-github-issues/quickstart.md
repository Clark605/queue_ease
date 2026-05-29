# Quickstart: Resolve GitHub Issues

## 1. Review The Fetched Backlog

Use the backlog snapshot in `plan.md` and the detailed inventory in `research.md` to confirm which issues are in scope:

- P1: #17, #18, #19
- P2: #20, #21, #22, #30, #31, #32
- P3: #23, #24, #25, #26, #27, #28, #29

## 2. Triage Before Coding

- Confirm the issue labels and normalize the misspelled `crititcal` label in your working notes.
- Assign each issue to a subsystem and decide whether it belongs in a single PR or a grouped PR.
- Keep P1 issues separate unless two fixes are truly the same code change.

## 3. Implement The Fixes In Order

- Start with #17, #18, and #19 because they are direct blockers.
- Move to the P2 flow regressions once the critical path is stable.
- Finish with the P3 guardrails and cleanup items.

## 4. Validate Each Change

### P1 Validation Results: ✅ ALL PASSING (9/9 tests)

**Command:**
```bash
rtk flutter test \
  test/admin/queue_management/data/repositories/admin_queue_repository_impl_test.dart \
  test/customer/booking/domain/use_cases/calculate_available_slots_use_case_test.dart \
  test/customer/access_portal/domain/use_cases/parse_access_url_use_case_test.dart -v
```

**Test Summary**: 00:02 +9: All tests passed! (exit code 0)

---

**Issue #17: Firestore whereIn limit crash** ✅ PASSED (2/2 tests)
- ✅ repository exists and is instantiable
- ✅ fix for issue #17: chunking of whereIn queries is implemented

**Fix Applied**: [admin_queue_repository_impl.dart](../../../../lib/features/admin/queue_management/data/repositories/admin_queue_repository_impl.dart#L210-L220)
- Chunked queries using `_chunks()` helper (splits into 30-item batches)
- Parallel execution with `Future.wait(apptChunks.map(...))`
- Merged results via loop over all snapshots

---

**Issue #18: Cancelled appointments block rebooking** ✅ PASSED (2/2 tests)
- ✅ use case can be instantiated
- ✅ fix for issue #18: cancelled appointments are excluded from slots

**Fix Applied**: [calculate_available_slots_use_case.dart](../../../../lib/features/customer/booking/domain/use_cases/calculate_available_slots_use_case.dart#L63-L67)
- Extended taken-slots filter to exclude both `noShow` AND `cancelled` status
- Changed: `.where((a) => a.status != AppointmentStatus.noShow && a.status != AppointmentStatus.cancelled,)`

---

**Issue #19: Mixed-case QR code slug lookup** ✅ PASSED (5/5 tests)
- ✅ lowercases mixed-case slug from full URL
- ✅ lowercases mixed-case plain slug
- ✅ lowercases from alternative URL format
- ✅ returns failure for invalid slug with spaces
- ✅ returns failure for empty slug

**Fix Applied**: [parse_access_url_use_case.dart](../../../../lib/features/customer/access_portal/domain/use_cases/parse_access_url_use_case.dart#L20)
- Added `.toLowerCase()` normalization in `call()` method (line 20) for plain slugs
- Bug fix: Also needed to lowercase plain slugs (not just URL-extracted ones)

## 5. Close The Issues

- Reference the issue number in the PR body and in the closing comment.
- Close the issue only after the PR merges and validation passes.
- Record any items intentionally deferred with the reason they were not fixed.

---

### P2 Validation Results: ✅ ALL PASSING (Targeted)

**Command:**
```bash
rtk flutter test \
  test/customer/booking/presentation/cubit/organization_landing_cubit_test.dart \
  test/customer/booking/presentation/cubit/slot_picker_cubit_test.dart \
  test/customer/entry/presentation/widgets/wait_timer_countdown_test.dart \
  test/admin/queue_management/data/datasources/admin_queue_datasource_test.dart \
  test/customer/booking/domain/use_cases/cancel_appointment_use_case_test.dart \
  test/firestore_rules/appointment_rules_test.dart -v
```

**Test Summary**: Targeted P2 tests passed (17 tests: 17 passed, 0 failed).

Notes:
- The Firestore rules regression check is a lightweight content assertion (file-based) — further integration validation against the emulator is recommended before production deploy.
