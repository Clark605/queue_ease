# Queue Ease - Feature Implementation Checklist

**Last Updated:** May 31, 2026
**Project:** Appointment & Queue Manager (Queue Ease)

---

## Legend
- ✅ **Completed** - Feature fully implemented and tested
- 🚧 **In Progress** - Currently being developed
- ⏳ **Pending** - Not started yet
- 📋 **Planned** - Post-MVP / Future enhancement
- ❌ **Removed** - Excluded from implementation
- 🔄 **Deferred** - Descoped from MVP, spec complete

---

## 🔧 Architectural Decisions

### Firebase Spark Plan Limitations
**Decision**: Queue Ease will NOT use Cloud Functions (Spark plan).
**Alternatives Implemented**:
1. **Queue Generation**: Client-side auto-generation when admin opens queue management
2. **No-Show Detection**: Client-side logic triggered by admin viewing queue
3. **Notifications**: FCM push notifications from Flutter client (Sprint 7)

---

## 1. Core Infrastructure & Setup ✅

- ✅ Flutter project with clean architecture
- ✅ Dependency injection (GetIt, injectable)
- ✅ App routing with GoRouter + RBAC guards
- ✅ Flavor configuration (dev/prod)
- ✅ Theme system (AppColors, AppTextStyles, AppTheme)
- ✅ Firebase project setup
- ✅ Error handling framework (Result type, AppException hierarchy)
- ✅ Logger setup (AppLogger with Talker, Crashlytics)
- ✅ Firestore security rules (78 tests passing, deployed dev & prod)
- ❌ **Cloud Functions** — REMOVED (Spark plan limitation)
- ⏳ Firebase Cloud Messaging (FCM) — Sprint 7

---

## 2. Authentication & User Management ✅

### 2.1 Authentication Core
- ✅ Login / signup pages
- ✅ Email/password authentication
- ✅ Google Sign-In
- ✅ Password reset (bottom sheet with success state)
- ✅ Auth state persistence (UserSessionService + SharedPreferences)
- ✅ Role-based access control (RBAC)
- ✅ AuthCubit (6 states, fully tested)

### 2.2 Roles
- ✅ Admin role
- ✅ Customer role
- ✅ Role assignment during signup (AuthRoleSelector)
- ✅ Role-based route protection (/a/, /c/)

### 2.3 UI Components
- ✅ AuthHeader, AuthTextField, PasswordField (show/hide toggle)
- ✅ GoogleSignInButton, AuthRoleSelector, AuthDivider, AuthFooterPanel
- ✅ ForgotPasswordBottomSheet

---

## 3. Onboarding Flow ✅

- ✅ 3-screen PageView (Skip the Wait, Real-Time Tracking, Fair Turns)
- ✅ Skip button, Next/Get Started buttons
- ✅ SmoothPageIndicator
- ✅ Completion persisted via SharedPreferences
- ✅ Router integration (checks on app launch)
- ✅ Custom illustrations (SVG-style Flutter widgets)
- ✅ Integration tests

---

## 4. Admin Features

### 4.1 Admin Dashboard ✅
- ✅ Greeting header with date/time salutation
- ✅ Management grid (Services, Working Hours, Queue, Summary)
- ✅ Share Access quick-action card
- ✅ Open/closed status toggle for organization
- ✅ First-time setup tutorial overlay (TutorialCubit, 3 steps)

### 4.2 Organization Setup ✅
- ✅ Organization entity/model (Firestore serialization)
- ✅ Org created atomically on admin signup (WriteBatch)
- ✅ Organization profile view and edit screens
- ✅ OrganizationCubit with real-time stream
- ✅ bookingLinkSlug for customer deep-link generation
- ✅ Error recovery for incomplete setup

### 4.3 Service Management ✅
- ✅ ServiceEntity/Model with full Firestore serialization
- ✅ Real-time service list (stream)
- ✅ Add / edit / delete with confirmation dialog
- ✅ Duration and time margin configuration (NumericStepperRow)
- ✅ Active/inactive toggle
- ✅ ServiceCubit + ServiceFormCubit

### 4.4 Working Hours ✅
- ✅ WorkingHoursEntity/Model
- ✅ 7-day schedule configuration (DayWorkingHoursTile)
- ✅ Break time configuration (BreakTimeSection)
- ✅ Break-end before break-start inline validation — `#27` fixed
- ✅ Batch save (Firestore WriteBatch)
- ✅ Schedule validation (open < close, break within hours)
- ✅ "Apply Monday to weekdays" shortcut
- ✅ WorkingHoursCubit with dirty-state tracking

### 4.5 Queue Management ✅
- ✅ QueueEntity/Model
- ✅ Daily queue auto-generation from `booked` appointments (idempotent)
- ✅ Admin queue view — current + waiting list
- ✅ Mark Next (advance + complete)
- ✅ Skip (move to end)
- ✅ Mark No-Show
- ✅ Rejoin (noShow → inQueue)
- ✅ Start Serving (explicit inQueue → serving)
- ✅ Real-time updates (Firestore stream)
- ✅ Countdown timer for current entry (booking-time based)
- ✅ Pre-booking action lock (notDueYet state)
- ✅ Auto no-show detection on overdue entries (client-side)
- ✅ Exponential backoff on auto no-show failures, keyed per appointment — `#29` fixed
- ✅ QueueManagementCubit with full action set
- ✅ Date picker for historical queue view
- ✅ Queue generation now skips ghost entries (completed/noShow) — `#21` fixed

### 4.6 Share Access (QR & Link) ✅
- ✅ QR code generation (qr_flutter)
- ✅ Unique booking URL from bookingLinkSlug
- ✅ Native share (share_plus)
- ✅ Download QR to gallery (gal)
- ✅ Copy link to clipboard
- ✅ ShareAccessCubit
- ✅ Platform permissions (Android + iOS)

### 4.7 Staff Management 🔄 DEFERRED to Post-MVP
- 🔄 StaffMemberEntity and CRUD operations — spec complete, implementation deferred
- 🔄 Service-staff assignment (one service → one staff)
- 🔄 Appointment staff inheritance from service
- 🔄 Queue UI staff column + filter dropdown
- 🔄 Firestore rules for staff subcollection
- **Spec**: `specs/007-staff-management/` (complete — tasks, quickstart, spec)

### 4.8 Daily Summary ⏳
- ⏳ Daily summary page (shell exists, data not wired)
- ⏳ Total appointments served, average wait, no-show rate

---

## 5. Customer Features

### 5.1 Customer Entry Point ✅
- ✅ CustomerHomePage with drawer
- ✅ Active queue status card (position, wait time)
- ✅ Upcoming appointment card with cancel action
- ✅ Empty state with info tiles + quick actions
- ✅ CustomerDashboardCubit with live streams

### 5.2 Access Portal ✅
- ✅ QR scanner (camera + gallery via mobile_scanner)
- ✅ Manual URL/slug entry (UrlEntryBottomSheet)
- ✅ ParseAccessUrlUseCase — now case-insensitive — `#19` fixed
- ✅ AccessPortalCubit, route `/c/access`

### 5.3 Organization Landing ✅
- ✅ OrganizationLandingPage (slug lookup, open/closed badge, CTA)
- ✅ Open/closed derived from server-normalized time — `#22` fixed
- ✅ Not-found screen
- ✅ OrganizationLandingCubit with working-hours stream

### 5.4 Service Selection & Details ✅
- ✅ ServiceSelectionPage (real-time active services)
- ✅ ServiceCard (name, duration, price, description)
- ✅ ServiceDetailsPage (stats grid)
- ✅ ServiceSelectionCubit

### 5.5 Booking Flow ✅
- ✅ CalculateAvailableSlotsUseCase (break exclusion, past filtering, conflict check)
- ✅ Cancelled appointments excluded from taken slots — `#18` fixed
- ✅ SlotPickerCubit refreshes when working-hours stream emits — `#20` fixed
- ✅ DateSelector (7-day row, closed days disabled)
- ✅ TimeSlotGrid (morning / afternoon / evening sections)
- ✅ BookingFormPage (name, phone, summary card)
- ✅ Transactional write with slot conflict detection
- ✅ Inline retry on network error; conflict → pop back to slot picker
- ✅ Retryable vs conflict error states separated — `#23` fixed
- ✅ CreateBookingUseCase — 30-day horizon enforced — `#28` fixed

### 5.6 Booking Confirmation ✅
- ✅ BookingConfirmationPage (org/service/time/address)
- ✅ "Track Status" CTA → queue status page
- ✅ "Back to Home" clears booking stack

### 5.7 Queue Status Tracking ✅
- ✅ CustomerQueueStatusPage (live position, wait, serving indicator)
- ✅ WaitTimerCountdown widget — periodic ticking restored — `#30` fixed
- ✅ YourTurnQueueCard, WaitingQueueCard, NoShowQueueCard, ServiceCompletedQueueCard
- ✅ WaitTimeChip with urgency color coding
- ✅ CustomerQueueStatusCubit with refresh support
- ✅ Pull-to-refresh

### 5.8 Appointment Management ✅
- ✅ CustomerAppointmentsPage (full appointment list)
- ✅ WatchCustomerAppointmentsUseCase (30-day window)
- ✅ Cancel booking action (booked AND inQueue status) — `#31` fixed
- ✅ Orphaned inQueue appointments from prior day visible on dashboard — `#26` fixed
- ✅ Multiple active appointments from different orgs logged, not silently dropped — `#24` fixed
- ✅ CancelAppointmentUseCase
- ✅ CustomerAppointmentsCubit

### 5.9 Customer Dashboard ✅
- ✅ WatchCustomerDashboardUseCase (active + upcoming stream)
- ✅ CustomerDashboardCubit
- ✅ Active queue card with queue status inline
- ✅ Upcoming appointment card

---

## 6. Core Business Logic ✅

### 6.1 Appointment System
- ✅ Booking validation (name required, no past slots)
- ✅ Double booking prevention (transactional)
- ✅ Working hours enforcement (slot generation algorithm)
- ✅ Conflict detection (slot conflict → snackbar + pop)
- ✅ Appointment status lifecycle (booked → inQueue → serving → completed / noShow / cancelled)

### 6.2 Queue System
- ✅ Daily queue generation from `booked` appointments
- ✅ Queue ordering (scheduledAt ASC)
- ✅ Queue position calculation (1-based index)
- ✅ Estimated wait time (duration sum + updatedAt reference)
- ✅ Time margin / grace period per service
- ✅ Automatic no-show detection (client-side)
- ✅ Queue advancement skips completed/noShow entries — `#21` fixed
- ✅ Zero-duration service fallback (5 min minimum) — `#25` fixed

### 6.3 Firestore Rules ✅
- ✅ `cancelled` status whitelisted for admin and customer updates — `#32` fixed
- ✅ Service duration validation in rules — `#25` fixed
- ✅ Appointment booking horizon enforced — `#28` fixed
- ✅ 78+ tests passing

---

## 7. Real-Time Features ✅

- ✅ Firestore real-time listeners (queue, appointments, org, services, working hours)
- ✅ Queue updates propagate instantly
- ✅ Customer view auto-updates
- ✅ Admin view auto-updates
- ✅ Error mapping + retry UX in all cubits

---

## 8. Notifications ⏳ Sprint 7

- ⏳ FCM setup in Firebase Console
- ⏳ FCM configuration in Flutter (firebase_messaging package)
- ⏳ FCM token management and storage in Firestore
- ⏳ Admin-triggered notifications: turn approaching, your turn, missed turn, delayed
- ⏳ In-app notification UI
- ⏳ Push in foreground, background, and terminated states

---

## 9. Data Models ✅

- ✅ UserEntity / UserModel
- ✅ OrganizationEntity / OrganizationModel
- ✅ ServiceEntity / ServiceModel
- ✅ WorkingHoursEntity / WorkingHoursModel
- ✅ AppointmentEntity / AppointmentModel
- ✅ QueueEntity / QueueModel
- ✅ All 5 entity + 5 model unit tests (round-trip Firestore serialization)

---

## 10. Testing

### 10.1 Completed
- ✅ AuthCubit unit tests
- ✅ Result type, AppException hierarchy
- ✅ All 5 entities (equality, props)
- ✅ All 5 Firestore models (fromDoc, toMap round-trips)
- ✅ Onboarding integration test
- ✅ P1 regression: whereIn chunking, cancelled slots, slug case — `#17 #18 #19`
- ✅ P2 regression: working-hours refresh, transactionNext, server time, countdown, cancellation, rules — `#20–22 #30–32`
- ✅ P3 regression implementations verified

### 10.2 Pending (Sprint 8)
- ⏳ P3 regression test coverage — `#23–29` (tests, not implementations)
- ⏳ Auth repository tests
- ⏳ Service / booking / queue repository tests
- ⏳ Widget tests for complex stateful components
- ⏳ Integration tests for end-to-end flows

---

## 11. UI/UX Polish ⏳ Sprint 7

- ✅ Color palette, typography, theme
- ✅ Loading / error / empty states (all major screens)
- ✅ Animations (onboarding, form transitions, queue cards)
- ⏳ Accessibility audit (screen reader, contrast, tap targets)
- ⏳ Final responsive design pass

---

## 12. DevOps & Deployment ⏳ Sprint 8

- ✅ Android build configuration
- ✅ Firebase Crashlytics
- ⏳ iOS build configuration
- ⏳ Code signing
- ⏳ Version management
- ⏳ CI/CD pipeline

---

## 13. Documentation ✅

- ✅ PRD.md
- ✅ ENTITIES.md
- ✅ ARCHITECTURE.md
- ✅ FEATURE_CHECKLIST.md (this document)
- ✅ PROJECT_TIMELINE.md
- ✅ ADR/001-role-based-repositories.md
- ✅ README.md
- ⏳ API documentation
- ⏳ User guide / Admin guide

---

## 14. Post-MVP Features

- 📋 Staff management (spec complete in `specs/007-staff-management/`) — single queue + staff filter
- 📋 Separate queues per staff member (v1.1)
- 📋 Staff-specific working hours (v1.1)
- 📋 Customer staff preferences (v1.1)
- 📋 Online payments
- 📋 Multi-branch support
- 📋 Advanced analytics dashboards
- 📋 Customer loyalty programs

---

## MVP Completion Criteria

- [x] Admin can manage a full day without manual tools
- [x] Customers always know their queue position
- [x] System handles delays and no-shows correctly
- [x] Appointment conflict prevention works
- [x] QR/link-based customer access works
- [x] Time margin policy enforced client-side
- [x] All P1/P2/P3 known bugs fixed
- [ ] FCM push notifications functional (Sprint 7)
- [ ] Daily summary data wired (Sprint 8)
- [ ] Comprehensive test coverage (Sprint 8)
- [ ] App deployed to internal testing (Sprint 8)

---

## Current Progress Summary

**Completed:** ~82%
**In Progress:** Sprint 7 preparation
**Pending:** ~18% (Notifications, full test suite, deployment)

### Sprint History

| Sprint | Status | Key Deliverables |
|--------|--------|-----------------|
| 1 | ✅ | Auth, onboarding, data models, Firestore rules |
| 2 | ✅ | Org setup, service management |
| 3 | ✅ | Working hours, QR/share access |
| 4 | ✅ | Customer booking flow end-to-end |
| 5 | ✅ | Queue system, customer dashboard, access portal |
| 6/7 | ✅ | Business automation (countdown, auto no-show) |
| 009 | ✅ | 16 GitHub issues resolved (P1+P2+P3) |
| 6A | 🔄 | Staff management — deferred to post-MVP |
| **7** | ⏳ | **FCM notifications + UI polish — NEXT** |
| **8** | ⏳ | **Testing + deployment — UPCOMING** |

### Critical Path — Next Steps

1. **Sprint 7** — FCM integration (`firebase_messaging`), admin-triggered push notifications, UI/UX accessibility pass
2. **Sprint 8** — P3 regression test suite, repository unit tests, widget tests, production deployment prep
3. **Post-MVP** — Staff management (spec ready in `specs/007-staff-management/`), advanced analytics, multi-branch