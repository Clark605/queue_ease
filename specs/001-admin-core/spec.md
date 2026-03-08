# Feature Specification: Admin Core — Organization Setup & Service Management

**Feature Branch**: `001-admin-core`  
**Created**: March 1, 2026  
**Completed**: March 8, 2026  
**Status**: ✅ Complete  
**Sprint**: Sprint 2 (Week 3)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Admin Signs Up and Organization Is Created (Priority: P1)

An admin user fills out the sign-up form with their name, email, password, and organization name. Upon submitting, the system creates their account, automatically creates a new Organization record linked to that admin, and updates the admin's profile to reference that Organization. The admin is then redirected to their dashboard.

**Why this priority**: Every downstream feature — service management, working hours, QR sharing, customer booking — requires an Organization to exist and be linked to the admin's account. Nothing else in the admin workflow can function without this foundation.

**Independent Test**: A new admin can register, and after sign-up completes, the admin can reach their dashboard. In the database, an Organization record exists with the admin's user ID, and the admin's user record contains the organization's ID reference.

**Acceptance Scenarios**:

1. **Given** a new user opens the admin sign-up form, **When** they provide a valid name, email, password, and organization name and submit, **Then** their account is created, an Organization record is created in the database linked to their account, and their profile record stores a reference to that Organization.
2. **Given** sign-up succeeds, **When** the admin is redirected, **Then** they land on their admin dashboard without any additional setup required.
3. **Given** a user attempts sign-up with an organization name that is blank, **When** they submit, **Then** the form displays a validation error and no records are created.
4. **Given** the account creation step succeeds but the organization creation step fails, **When** the error occurs, **Then** the partially created user account is cleaned up (or the failure is surfaced) and the admin sees a clear error message prompting them to try again.

---

### User Story 2 - Admin Views and Edits Organization Profile (Priority: P2)

After signing in, an admin can navigate to their organization profile page. They can view all current details about their organization (name, address, description, logo) and update any of those fields. Changes are reflected immediately throughout the app.

**Why this priority**: Admins need to present accurate business information to customers. Without the ability to manage their profile, the organization data would be frozen as entered at sign-up, preventing corrections or enrichment.

**Independent Test**: A signed-in admin can navigate to the organization profile screen, see the organization name set during sign-up, edit the description and address fields, save, and see the updated values on returning to the screen.

**Acceptance Scenarios**:

1. **Given** a signed-in admin with an existing organization, **When** they navigate to the organization profile, **Then** they see the organization's name, address, description, and logo (if set).
2. **Given** the admin is on the organization profile edit screen, **When** they update the organization name and save, **Then** the new name is persisted and displayed on returning to the profile.
3. **Given** the admin clears the organization name (required field) and tries to save, **When** they submit, **Then** the form displays a validation error and does not save.
4. **Given** the admin updates the organization address, **When** they save, **Then** only the address field is changed; other fields remain unchanged.

---

### User Story 3 - Admin Creates and Manages Services (Priority: P3)

A signed-in admin can view all services associated with their organization, add new services, edit existing ones, and delete services they no longer offer. Each service captures its name, duration, an optional price, description, and a time margin (the grace period before a customer is marked as a no-show).

**Why this priority**: Services are the bookable units that customers select when making appointments. Without at least one service defined, customers cannot book and the queue system has no work to process. Organization setup must precede this, hence P3.

**Independent Test**: A signed-in admin can open the services screen, add a service with a name and 30-minute duration, confirm it appears in the list, edit its duration to 45 minutes, confirm the update, then delete it and confirm the list is empty again.

**Acceptance Scenarios**:

1. **Given** a signed-in admin with a linked organization, **When** they navigate to the services screen, **Then** they see a list of all active and inactive services for their organization (or an empty state if none exist).
2. **Given** the admin opens the add-service form and provides a name and duration, **When** they save, **Then** the new service appears in the service list linked to their organization.
3. **Given** the admin opens an existing service and changes the duration, **When** they save, **Then** the updated duration is reflected in the service list.
4. **Given** the admin attempts to save a service with a name but zero or no duration, **When** they submit, **Then** a validation error appears and the service is not saved.
5. **Given** the admin deletes a service, **When** the deletion is confirmed, **Then** the service is removed from the list; a confirmation prompt is shown before permanent deletion.
6. **Given** the admin sets a service as inactive, **When** the change is saved, **Then** the service remains visible to the admin (with an inactive indicator) but is not available for customer booking.

---

### User Story 4 - First-Time Setup Tutorial (Priority: P4)

The very first time a newly registered admin lands on their dashboard after organization creation, the app guides them through the three core setup steps in order: (1) confirm their organization profile, (2) add their first service, and (3) acknowledge their organization is ready for customers. Each step is presented as a focused prompt or overlay that highlights the relevant section of the app. The admin can skip the tutorial at any point, and it never re-appears after it has been completed or explicitly dismissed.

**Why this priority**: The tutorial depends on all three prior stories being complete — the organization must exist, the profile must be editable, and the service management screen must be functional. It adds no new data or business logic; it is purely a discoverability aid that lowers the time-to-first-value for new admins.

**Independent Test**: A freshly registered admin can be walked through the tutorial from the dashboard, complete all three steps, and reach a "You're all set" confirmation. On signing out and back in, the tutorial does not reappear.

**Acceptance Scenarios**:

1. **Given** an admin who just completed sign-up for the first time, **When** they land on the dashboard, **Then** the tutorial is automatically presented, starting with Step 1 (confirm organization profile).
2. **Given** the admin is on tutorial Step 1, **When** they navigate to the organization profile and return, **Then** Step 1 is marked complete and Step 2 (add first service) is presented.
3. **Given** the admin is on tutorial Step 2, **When** they create at least one service, **Then** Step 2 is marked complete and Step 3 (organization ready acknowledgement) is presented.
4. **Given** the admin reaches Step 3, **When** they confirm, **Then** the tutorial closes and a completion indicator is shown; the tutorial is permanently marked as done for this account.
5. **Given** the admin clicks "Skip" at any tutorial step, **When** they confirm the skip, **Then** the tutorial is dismissed and permanently marked as done; it does not reappear on subsequent sign-ins.
6. **Given** an admin who has previously completed or skipped the tutorial signs in again, **When** they reach the dashboard, **Then** no tutorial is shown.

---

### Edge Cases

- What happens when the network drops during sign-up after the user account is created but before the Organization document is written? The system keeps the account, surfaces a retryable error, and on next sign-in detects the missing organization and guides the admin to complete setup (see FR-005).
- What happens if an admin tries to access the services screen when their account has no linked organization ID? The router detects the missing organization on sign-in and redirects the admin to a dedicated "Complete Your Setup" screen; all other admin routes are blocked until setup completes successfully.
- What happens if two admins sign up simultaneously and generate the same booking link slug? The system must handle uniqueness conflicts gracefully and assign a distinct slug.
- What happens when an admin attempts to delete the last remaining service? The deletion proceeds normally; it is the admin's responsibility to maintain at least one active service for bookings.
- What happens if the admin closes the app mid-tutorial? The tutorial resumes from the last incomplete step on the next session, as long as the tutorial has not been completed or skipped.
- What happens if the organization name or service name contains special characters or very long text? Organization names are capped at 100 characters and service names are capped at 100 characters; the system rejects inputs exceeding these limits with a validation error.

## Requirements *(mandatory)*

### Functional Requirements

**Organization Setup**

- **FR-001**: System MUST create an Organization record automatically when an admin completes sign-up, using the organization name provided during registration.
- **FR-002**: System MUST update the admin's user profile to replace the `orgName` text field with an `organizationId` reference pointing to the newly created Organization record immediately after sign-up.
- **FR-003**: The Organization record MUST be linked to the admin's account and inaccessible to other organizations' admins.
- **FR-004**: System MUST generate a unique booking link slug for each new Organization at creation time.
- **FR-005**: If Organization creation fails after account creation succeeds, the system MUST keep the Firebase Auth account intact, surface a clear retryable error to the admin, and on the admin's next sign-in detect the missing organization and redirect them to a dedicated "Complete Your Setup" screen. The system MUST NOT attempt to delete the Firebase Auth account as a rollback strategy.
- **FR-005a**: The router MUST block all admin-area routes (dashboard, services, profile) when the signed-in admin has no linked organization ID, allowing only the "Complete Your Setup" screen until setup succeeds.

**Organization Profile Management**

- **FR-006**: Admins MUST be able to view their organization's profile (name, address, description, logo URL, open/closed status).
- **FR-007**: Admins MUST be able to edit organization details: name, address, description, and logo URL.
- **FR-008**: The organization name field MUST be required, cannot be saved as empty, and MUST NOT exceed 100 characters.
- **FR-009**: System MUST deliver the organization profile via a real-time stream so that changes are reflected immediately on all active sessions without requiring a manual refresh.

**Service Management**

- **FR-010**: Admins MUST be able to view all services belonging to their organization via a real-time stream; additions, edits, and deletions MUST be reflected immediately without a manual refresh.
- **FR-011**: Admins MUST be able to create a new service by providing at minimum a name and a duration in minutes.
- **FR-012**: Each service MUST be linked to the admin's organization and not visible to admins of other organizations.
- **FR-013**: Admins MUST be able to edit any field of an existing service.
- **FR-014**: Admins MUST be able to toggle a service between active and inactive; inactive services do not appear in customer-facing flows.
- **FR-015**: Admins MUST be able to permanently delete a service after confirming the action.
- **FR-016**: Service duration MUST be a positive integer (minutes); the system MUST reject zero or negative values.
- **FR-016a**: Service name MUST be required and MUST NOT exceed 100 characters.
- **FR-017**: The time margin field (no-show grace period) MUST default to a sensible value (5 minutes) if not explicitly set by the admin.
- **FR-018**: Admins MUST be able to configure a price for a service; price is optional and display-only at this stage.

**First-Time Tutorial**

- **FR-019**: The tutorial MUST be shown automatically the first time an admin lands on the dashboard after completing sign-up; it MUST NOT be shown on any subsequent session once completed or skipped.
- **FR-020**: The tutorial MUST present three sequential steps in order: (1) confirm organization profile, (2) add first service, (3) acknowledge readiness. Each step is presented only after the previous one is actioned.
- **FR-021**: The admin MUST be able to skip the tutorial at any step; skipping permanently dismisses it for that account.
- **FR-022**: Tutorial completion state MUST be persisted per user account so that it survives sign-out, reinstall, or switching devices.

### Key Entities

- **Organization**: Represents a business using Queue Ease. Key attributes: unique identifier, name, owning admin's user ID, unique booking link slug, open/closed status, optional address, optional description, optional logo URL, creation timestamp.
- **Service**: Represents a bookable offering of an organization. Key attributes: unique identifier, parent organization ID, name, duration in minutes, time margin in minutes, active/inactive status, optional price, optional description, creation timestamp.
- **User (extended)**: An admin user account. The existing `orgName` plain-text field is replaced by an `organizationId` reference field that links the user record to their Organization document. The Organization document is the sole authoritative source for the organization name.

### Assumptions

- A single admin account owns exactly one organization. One-to-many (one admin, multiple organizations) is out of scope for this sprint.
- The `orgName` field currently on the admin user profile is replaced by `organizationId`; the Organization document is the sole source of truth for the organization name. Any UI needing the org name reads from the Organization document via the ID reference.
- Google Sign-In is not modified; organization creation only applies to the email/password admin sign-up path. Google-authenticated users are always customers.
- The booking link slug is auto-generated at organization creation; manual slug customization is out of scope (Sprint 3 or later).
- No tests are written in this sprint (deferred to Sprint 8 per team decision).
- The open/closed toggle on the organization profile is visible to the admin but its real-time effect on customer-facing UI is delivered in a later sprint.

## Clarifications

### Session 2026-03-01

- Q: When Organization creation fails after account creation, should the system delete the Auth account (force re-register) or keep it and recover on next sign-in? → A: Keep the account; show a retryable error; detect the missing org on next sign-in and prompt the admin to complete setup.
- Q: How is the missing-org recovery presented — dedicated blocking screen, dashboard banner, or blocking modal? → A: Redirect to a dedicated "Complete Your Setup" screen that blocks all admin-area routes until org creation succeeds.
- Q: Should org profile and service list use a real-time Firestore stream or a one-time fetch? → A: Real-time stream for both org profile and service list.
- Q: What are the maximum character limits for organization name and service name? → A: 100 characters for both organization name and service name.
- Q: Should `orgName` on the user profile be kept (as a cache or synced copy) now that a full Organization document exists? → A: Replace `orgName` with `organizationId`; the Organization document is the sole source of truth for the organization name.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: An admin can complete the full sign-up flow — from opening the registration screen to landing on their dashboard with an organization created — in under 2 minutes under normal network conditions.
- **SC-002**: 100% of new admin sign-ups result in a matching Organization record and a linked organization ID on the user profile; no orphaned accounts exist.
- **SC-003**: An admin can create, edit, and delete a service within the services screen in under 90 seconds per operation.
- **SC-004**: An admin can update their organization profile and have changes reflected on the profile screen within 3 seconds of saving.
- **SC-005**: All organization and service data is correctly scoped — no admin can read or modify another organization's data, as enforced by existing security rules.
- **SC-006**: The complete flow is demoable end-to-end: sign-up → organization created → profile viewed and edited → service added → service edited → service deleted.
- **SC-007**: A new admin who has never used the app encounters the tutorial on their first dashboard visit and can complete all three steps in under 3 minutes; the tutorial does not reappear on any subsequent visit.
