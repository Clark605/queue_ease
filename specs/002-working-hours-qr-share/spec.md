# Feature Specification: Working Hours Configuration & QR/Share Access

**Feature Branch**: `002-working-hours-qr-share`  
**Created**: March 9, 2026  
**Status**: Draft  
**Sprint**: Sprint 3 (Week 4)  
**Input**: User description: "Working Hours configuration and QR code share access for admin"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Admin Configures Weekly Working Hours (Priority: P1)

A signed-in admin opens the "Organization Settings" section on their dashboard and navigates to the Working Hours configuration page. They see all seven days of the week listed, each with a toggle (open/closed), opening time, and closing time. By default, Monday–Friday are set to open (09:00–17:00) and Saturday–Sunday are closed. The admin can enable or disable any day, change the open and close times, and save. Changes take effect immediately and are persisted for their organization.

**Why this priority**: Working hours define when customers can book appointments. Without working hours configured, the booking flow (Sprint 4) cannot determine available time slots. This is the foundational data that all downstream scheduling depends on.

**Independent Test**: An admin can navigate to Working Hours, toggle Saturday to open, set it to 10:00–14:00, save, and on returning to the screen see Saturday displayed as open from 10:00 to 14:00.

**Acceptance Scenarios**:

1. **Given** a signed-in admin with a linked organization, **When** they navigate to the Working Hours page for the first time, **Then** they see all seven days listed with sensible defaults (Mon–Fri open 09:00–17:00, Sat–Sun closed).
2. **Given** the admin is on the Working Hours page, **When** they toggle a day from closed to open, **Then** the time fields for that day become editable and show default values (09:00–17:00).
3. **Given** the admin sets Monday's hours to 08:00–20:00, **When** they save, **Then** the updated hours are persisted and reflected immediately without a manual refresh.
4. **Given** the admin sets a close time earlier than the open time (e.g., open 17:00, close 09:00), **When** they attempt to save, **Then** a validation error is displayed and the invalid schedule is not saved.
5. **Given** the admin toggles a day to closed, **When** they save, **Then** that day is marked closed and no time fields are shown for it.

---

### User Story 2 - Admin Configures Break Times (Priority: P2)

For any day that is marked as open, the admin can optionally add a break period (e.g., 12:00–13:00 lunch break). The break period splits the working day into two work windows. Break times are optional — if not set, the entire open-to-close window is considered available.

**Why this priority**: Many businesses have lunch or prayer breaks that must be excluded from booking availability. Without break support, the system would offer slots during closed periods, leading to customer frustration and no-shows.

**Independent Test**: An admin can open Monday's working hours, enable break time, set it to 12:00–13:00, save, and on returning see the break period displayed correctly.

**Acceptance Scenarios**:

1. **Given** an admin viewing a day that is marked as open, **When** they enable the break toggle, **Then** break start and break end time fields appear with sensible defaults (12:00–13:00).
2. **Given** the admin sets a break from 12:00 to 13:00 on a day open 09:00–17:00, **When** they save, **Then** the break period is persisted and displayed on that day.
3. **Given** the admin sets a break start time that is before the open time or after the close time, **When** they attempt to save, **Then** a validation error is displayed.
4. **Given** the admin sets a break end time after the close time, **When** they attempt to save, **Then** a validation error is displayed.
5. **Given** the admin disables the break toggle on a day that had a break, **When** they save, **Then** the break times are cleared and the full day window is available.

---

### User Story 3 - Admin Views and Shares QR Code (Priority: P3)

A signed-in admin opens the "Organization Settings" section on their dashboard and navigates to the Share Access page. This page displays a QR code that encodes their organization's unique booking link (based on the `bookingLinkSlug`). The admin can share this QR code via the device's native share sheet or copy the booking link to their clipboard.

**Why this priority**: QR codes and shareable links are the primary way customers discover and access the organization's booking page. This must be in place before the customer booking flow (Sprint 4) so that admins can start distributing access.

**Independent Test**: An admin can navigate to the Share Access page, see a QR code displayed, tap "Share" to open the native share sheet, and tap "Copy Link" to copy the URL to their clipboard.

**Acceptance Scenarios**:

1. **Given** a signed-in admin with a linked organization, **When** they navigate to the Share Access page, **Then** they see a QR code that encodes their organization's booking URL.
2. **Given** the admin is on the Share Access page, **When** they tap the "Share" button, **Then** the device's native share sheet opens with the booking link and QR code image.
3. **Given** the admin is on the Share Access page, **When** they tap "Copy Link", **Then** the booking URL is copied to the clipboard and a confirmation message is shown.
4. **Given** the organization's booking link slug is "acme-clinic-abc", **When** the QR code is scanned by any QR reader, **Then** it resolves to the full booking URL containing that slug.

---

### User Story 4 - Admin Downloads QR Code as Image (Priority: P4)

The admin can save the QR code as an image file to their device's gallery or downloads folder. This allows them to print the QR code and display it at their physical business location.

**Why this priority**: Physical QR code display at business locations is a common workflow for service-based businesses. This extends Story 3 with a downloadable artifact.

**Independent Test**: An admin taps "Download QR" on the Share Access page, the image is saved to their device, and a success message confirms the download.

**Acceptance Scenarios**:

1. **Given** the admin is on the Share Access page, **When** they tap the "Download QR" button, **Then** the QR code image is saved to the device's storage and a confirmation message is shown.
2. **Given** the admin downloads the QR code image, **When** they open it from their device's gallery/files, **Then** it displays a high-resolution QR code that scans correctly to the booking URL.

---

### Edge Cases

- What happens when working hours documents don't exist yet for a new organization? The system initializes all seven days with default values (Mon–Fri open 09:00–17:00, Sat–Sun closed) on first access.
- What happens if the admin sets identical open and close times (e.g., 09:00–09:00)? The system rejects this with a validation error — close time must be strictly after open time.
- What happens if break start equals break end? The system rejects this — break period must have a positive duration.
- What happens if the admin has no internet connection when saving working hours? The save operation fails with a clear error message; unsaved changes are preserved on screen so the admin can retry.
- What happens if two admins edit working hours simultaneously? Firestore's last-write-wins semantics apply; the real-time stream ensures both admins see the latest state after save.
- What happens if the booking link slug hasn't been generated? The slug is always generated at organization creation time (Sprint 2), so this should never occur. If it's missing, the Share Access page displays an error prompting the admin to contact support.
- What happens if the device doesn't support the native share functionality? The share button is always shown; if the platform share API fails, the fallback is copy-to-clipboard with a message.
## Requirements *(mandatory)*

### Functional Requirements

**Dashboard Navigation**

- **FR-000**: The Admin Dashboard MUST expose a new "Organization Settings" section that provides entry points to both the Working Hours configuration page and the Share Access page.

**Working Hours Configuration**

- **FR-001**: System MUST display all seven days of the week on the Working Hours configuration page, showing open/closed status, open time, and close time for each day.
- **FR-002**: System MUST provide sensible defaults for a new organization's working hours: Monday through Friday open 09:00–17:00, Saturday and Sunday closed.
- **FR-003**: If working hours documents do not exist in the database for an organization, the system MUST create all seven documents with default values on first access to the Working Hours page.
- **FR-004**: Admins MUST be able to toggle each day between open and closed.
- **FR-005**: When a day is toggled to open, the admin MUST be able to set the opening and closing times using a time picker.
- **FR-006**: The close time MUST be strictly later than the open time on the same day; the system MUST reject equal or inverted times with a validation error.
- **FR-007**: Working hours changes MUST be saved via a single "Save All" action that batches all 7 days into one operation; no per-day or auto-save mechanism is used.
- **FR-008**: The system MUST validate ALL open days' time ranges as a complete batch before persisting; if any day is invalid, the entire save is rejected and a specific validation error is displayed.

**Break Time Configuration**

- **FR-009**: For each open day, the admin MUST be able to optionally enable a break period with a start time and end time.
- **FR-010**: Break start MUST be at or after the day's open time, and break end MUST be at or before the day's close time.
- **FR-011**: Break end MUST be strictly after break start; zero-duration breaks MUST be rejected.
- **FR-012**: When the break toggle is disabled, the system MUST clear the break start and break end values for that day.
- **FR-013**: Break times MUST be persisted alongside working hours and reflected in real-time.

**QR Code & Share Access**

- **FR-014**: The Share Access page MUST generate and display a QR code that encodes the organization's full booking URL (derived from `bookingLinkSlug`).
- **FR-015**: The QR code MUST be generated client-side without requiring a backend service.
- **FR-016**: Admins MUST be able to share the booking link and QR code image via the device's native share sheet.
- **FR-017**: Admins MUST be able to copy the booking URL to the clipboard with a single tap, accompanied by a confirmation message.
- **FR-018**: Admins MUST be able to download the QR code as a high-resolution image file to their device's storage.
- **FR-019**: The booking URL displayed and encoded in the QR code MUST use the organization's `bookingLinkSlug` and follow the format `https://queueease.app/org/{bookingLinkSlug}`. The URL is the intended entry point to the Organization Landing Screen (showing org profile and all active services); in-app deep link routing to that screen is implemented in Sprint 4. Sprint 3 verification is limited to confirming the encoded URL contains the correct slug.

### Key Entities

- **WorkingHours**: Represents a single day's schedule for an organization. Key attributes: organization ID, day of week (0=Monday through 6=Sunday, also serves as the document ID), open/closed flag, opening time, closing time, optional break start time, optional break end time. Stored as a subcollection under the organization document (7 documents per organization).
- **Organization (extended)**: The existing `bookingLinkSlug` (immutable, set at creation) provides the base for the QR code URL. The existing nullable `qrCodeUrl` field is not used — QR codes are generated client-side on demand rather than stored remotely.

### Assumptions

- Each organization has exactly 7 working hours documents (one per day of the week), stored as a Firestore subcollection under the organization document.
- The `dayOfWeek` field (0–6) serves as both a logical identifier and the Firestore document ID (stored as a string).
- Time values are stored as "HH:mm" strings in 24-hour format.
- Only one break period per day is supported in this sprint. Multiple breaks per day are out of scope.
- The QR code is generated client-side using a Dart/Flutter package — no server-side QR generation or storage is needed.
- The "Save All" batch operation writes to 7 separate Firestore documents (one per day), each identified by the string representation of `dayOfWeek` ("0"–"6"), matching the existing `WorkingHoursModel.fromDoc` and Firestore security rules.
- The booking URL format is `https://queueease.app/org/{bookingLinkSlug}`. This URL is the intended entry point to the Organization Landing Screen, which shows the organization profile and all active services. The actual in-app deep link routing to that screen is out of scope for this sprint and is implemented in Sprint 4.
- The `qrCodeUrl` field on OrganizationEntity is not used in this sprint; QR codes are rendered on-the-fly from the slug.
- No tests are written in this sprint (deferred to Sprint 8 per team decision).
- Special hours and holidays (e.g., closing early on a specific date) are out of scope for this sprint.
- Working hours are per-organization, not per-service. All services under an organization share the same working hours.

## Clarifications

### Session 2026-03-09

- Q: How should the admin save working hours changes — one "Save All" batch, per-day individual save, or auto-save? → A: Single "Save All" button that saves all 7 days as one batch.
- Q: How does the admin reach the Working Hours and Share Access pages from the dashboard — direct dashboard cards, nested under a settings section, or mixed? → A: Both screens are nested under a new "Organization Settings" section on the Admin Dashboard.
- Q: Does the "Save All" batch write to 7 separate Firestore documents or to a single document? → A: 7 separate documents, one per day, with `dayOfWeek` (0–6) as the document ID — matching the existing WorkingHoursModel and Firestore security rules.
- Q: How is the generated booking link verified to redirect to the organization profile with all services when clicked? → A: The link encodes the org’s `bookingLinkSlug` and is intended to open the Organization Landing Screen (which shows the org profile + all active services). In Sprint 3 the link is constructed and shared only; in-app routing to the Organization Landing Screen is implemented in Sprint 4. Sprint 3 verification is limited to confirming the link encodes the correct slug.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An admin can configure working hours for all seven days of the week and save successfully in under 3 minutes.
- **SC-002**: When an admin saves updated working hours, the changes are reflected on the Working Hours page within 3 seconds via real-time stream.
- **SC-003**: 100% of saved working hours pass validation rules — no invalid time ranges (close before open, break outside working window) are persisted.
- **SC-004**: An admin can view, share, and copy their organization's QR code and booking link in under 30 seconds.
- **SC-005**: The QR code, when scanned by any standard QR reader, correctly resolves to the organization's booking URL.
- **SC-006**: An admin can download the QR code as an image and the resulting file is scannable and high-resolution.
- **SC-007**: All working hours data is scoped per organization — no admin can read or modify another organization's schedule, as enforced by existing Firestore security rules.
- **SC-008**: The complete flow is demoable end-to-end: navigate to Working Hours → configure schedule with breaks → save → navigate to Share Access → view QR → share → copy link → download QR image.
