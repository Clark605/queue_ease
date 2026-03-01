# Feature Specification: Firestore Security Rules

**Feature Branch**: `001-firestore-security-rules`  
**Created**: February 25, 2026  
**Status**: Draft  
**Input**: User description: "Deploy and implement Firestore security rules for all collections (users, organizations, services, working_hours, appointments, queues) to ensure proper data access control based on user roles and ownership, with validation rules for data integrity"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Admin Data Protection (Priority: P1)

Business owners (admins) need assurance that only they can modify their organization's data, services, working hours, appointments, and queue entries. Other admins should not be able to interfere with data they don't own.

**Why this priority**: This is the foundation of data security. Without proper access control, the entire system is vulnerable to data tampering and unauthorized modifications. This protects the business's most critical asset - their operational data.

**Independent Test**: Can be fully tested by attempting to create/update/delete organization data with different user credentials and verifying that only the owning admin succeeds while other users are denied.

**Acceptance Scenarios**:

1. **Given** an authenticated admin user with orgId "ABC123", **When** they attempt to update their organization document at `organizations/ABC123`, **Then** the update succeeds
2. **Given** an authenticated admin user with orgId "ABC123", **When** they attempt to create a service under `organizations/ABC123/services`, **Then** the creation succeeds
3. **Given** an authenticated admin user with orgId "ABC123", **When** they attempt to update organization "XYZ789" owned by another admin, **Then** the operation is denied with permission error
4. **Given** an authenticated admin user, **When** they attempt to delete a service from another admin's organization, **Then** the operation is denied
5. **Given** an unauthenticated user, **When** they attempt to read or write any organization data, **Then** all operations are denied

---

### User Story 2 - Customer Access Control (Priority: P1)

Customers need to view organization information, services, and working hours to make booking decisions, but should only be able to create appointments under their own user ID and view their own queue positions.

**Why this priority**: Customers are the primary users of the booking system. They must have read access to make informed decisions, but write access must be strictly controlled to prevent impersonation or malicious bookings.

**Independent Test**: Can be tested by having a customer user attempt to read organization data (should succeed), create an appointment with their own userId (should succeed), and attempt to create an appointment with another user's ID (should fail).

**Acceptance Scenarios**:

1. **Given** an authenticated customer user, **When** they read an organization document, **Then** the read succeeds
2. **Given** an authenticated customer user, **When** they read services and working hours for any organization, **Then** the read succeeds
3. **Given** an authenticated customer with userId "customer123", **When** they create an appointment with customerId "customer123", **Then** the creation succeeds
4. **Given** an authenticated customer with userId "customer123", **When** they attempt to create an appointment with customerId "hacker456", **Then** the operation is denied
5. **Given** an authenticated customer with userId "customer123", **When** they read their own queue entry, **Then** the read succeeds
6. **Given** an authenticated customer, **When** they attempt to update or delete any appointment or queue entry, **Then** the operations are denied

---

### User Story 3 - User Profile Security (Priority: P1)

Users need to ensure their personal profile data (email, phone, display name, role) cannot be viewed or modified by other users, while being able to manage their own profile.

**Why this priority**: User profiles contain personally identifiable information (PII) that must be protected according to privacy regulations and user expectations. Profile tampering could lead to security breaches or identity theft.

**Independent Test**: Can be tested by attempting to read and write user documents with different credentials, verifying that users can only access their own profile and not others.

**Acceptance Scenarios**:

1. **Given** an authenticated user with uid "user123", **When** they read document `users/user123`, **Then** the read succeeds
2. **Given** an authenticated user with uid "user123", **When** they update their own document at `users/user123`, **Then** the update succeeds
3. **Given** an authenticated user with uid "user123", **When** they attempt to read document `users/user456`, **Then** the operation is denied
4. **Given** an authenticated user, **When** they attempt to update another user's profile, **Then** the operation is denied
5. **Given** an unauthenticated user, **When** they attempt to read any user document, **Then** the operation is denied

---

### User Story 4 - Data Validation and Integrity (Priority: P2)

The system needs to validate that all data written to Firestore meets required schema constraints (required fields, data types, field limits) to maintain database integrity and prevent application errors.

**Why this priority**: Data validation at the database level acts as a last line of defense against corrupt or invalid data, regardless of where it originates. This prevents bugs, crashes, and data inconsistencies.

**Independent Test**: Can be tested by attempting to create documents with missing required fields, invalid data types, or exceeding size limits, and verifying that Firestore rejects these writes.

**Acceptance Scenarios**:

1. **Given** an authorized admin, **When** they create an organization without a required "name" field, **Then** the write is rejected
2. **Given** an authorized admin, **When** they create a service with durationMinutes as a string instead of integer, **Then** the write is rejected
3. **Given** an authorized customer, **When** they create an appointment with a service name exceeding 200 characters, **Then** the write is rejected
4. **Given** an authorized user, **When** they attempt to add unexpected fields not in the schema, **Then** the write is rejected
5. **Given** an authorized admin, **When** they create working hours with an invalid time format, **Then** the write is rejected

---

### User Story 5 - Role-Based Access Verification (Priority: P2)

The system needs to verify user roles stored in user documents to ensure role-based access control decisions are made correctly, preventing privilege escalation.

**Why this priority**: Role verification is critical for maintaining separation of concerns between admin and customer capabilities. Without proper verification, users could potentially access features beyond their authorization.

**Independent Test**: Can be tested by creating users with different roles and verifying that security rules correctly identify and enforce role-specific permissions.

**Acceptance Scenarios**:

1. **Given** a user with role "admin" who owns orgId "ORG1", **When** they attempt to modify data under `organizations/ORG1`, **Then** the operation succeeds
2. **Given** a user with role "customer", **When** they attempt to modify any organization data, **Then** the operation is denied
3. **Given** a user with role "admin" for orgId "ORG1", **When** they attempt to modify organization "ORG2", **Then** the operation is denied
4. **Given** a user document is updated to change role from "customer" to "admin", **When** authorization is checked, **Then** the new role is recognized within reasonable cache time

---

### Edge Cases

- What happens when a user's authentication token expires mid-operation? (Rules should deny based on lack of valid auth)
- What happens when an admin account is deleted but their organization still exists? (Orphaned data - requires Cloud Function cleanup, security rules block external access)
- What happens when a customer tries to book multiple appointments simultaneously? (Each write is evaluated independently; conflicts handled by application logic)
- What happens when a service is deleted but appointments still reference it? (Security rules allow reads of appointments; deletion logic is application responsibility)
- What happens when an admin tries to create an organization with a duplicate bookingLinkSlug? (Validation at application level; security rules focus on access control)
- What happens when someone attempts a batch write with mixed authorized and unauthorized operations? (Entire batch fails if any operation violates security rules)

## Clarifications

### Session 2026-02-25

- Q: What are the allowed status values for appointment and queue documents that security rules should validate? → A: Appointments use AppointmentStatus enum values (booked, inQueue, serving, completed, noShow); Queues use QueueStatus enum values (active, paused, closed) as defined in existing domain entities
- Q: What are the exact string values for user roles that security rules should validate in the users collection role field? → A: Role values are "admin" and "customer" (lowercase strings, matching UserRole enum .name property)
- Q: Can an admin own multiple organizations or is it limited to one? → A: One admin can own only ONE organization (1:1 relationship) - multi-branch support excluded from MVP scope
- Q: What format should dayOfWeek field use in working_hours documents? → A: Integer values 0-6 where 0=Monday, 1=Tuesday, 2=Wednesday, 3=Thursday, 4=Friday, 5=Saturday, 6=Sunday; time fields use "HH:mm" format (e.g., "09:00")
- Q: Should admins have access to read customer user profiles when managing appointments? → A: Admins can read ONLY customer profiles of users who have appointments/queues in their organization (verified by checking appointments/queues subcollections); no access to browse all user profiles

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Security rules MUST authenticate all requests - no public access allowed without valid Firebase Authentication
- **FR-002**: Security rules MUST enforce that users can read and update their own user document at `users/{uid}` only; admin access to customer profiles is handled at the application layer by querying appointments/queues subcollections for customer UIDs, then reading those specific customer documents individually (Firestore rules cannot efficiently query subcollections for authorization)
- **FR-003**: Security rules MUST verify that admin users can only create, read, update, and delete organizations they own (matching adminUid field)
- **FR-004**: Security rules MUST allow admins full CRUD access to all subcollections under their organization (services, working_hours, appointments, queues)
- **FR-005**: Security rules MUST allow customers to read any organization document, services, and working hours for booking decisions
- **FR-006**: Security rules MUST allow customers to create appointments only with their own userId as the customerId field
- **FR-007**: Security rules MUST prevent customers from updating or deleting any appointments or queue entries
- **FR-008**: Security rules MUST allow customers to read their own queue entries (where customerId matches their uid)
- **FR-009**: Security rules MUST validate that organization documents contain required fields: name, adminUid, bookingLinkSlug, isOpen, createdAt
- **FR-010**: Security rules MUST validate that service documents contain required fields: name, durationMinutes, timeMarginMinutes, isActive, createdAt
- **FR-011**: Security rules MUST validate that appointment documents contain required fields: customerId, serviceId, scheduledAt, status; and status MUST be one of: booked, inQueue, serving, completed, noShow
- **FR-012**: Security rules MUST validate that queue documents contain required fields: customerId, serviceId, status, queueNumber, createdAt; and status MUST be one of: active, paused, closed
- **FR-013**: Security rules MUST validate that working_hours documents contain required fields: dayOfWeek (integer 0-6), isOpen (boolean), openTime (string "HH:mm" format), closeTime (string "HH:mm" format); dayOfWeek MUST be between 0-6 inclusive
- **FR-014**: Security rules MUST enforce data type constraints (integers for durations, timestamps for dates, booleans for flags, strings for text)
- **FR-015**: Security rules MUST prevent modification of createdAt timestamps on existing documents
- **FR-016**: Security rules MUST validate string field length limits (e.g., name max 100 characters, description max 500 characters)
- **FR-017**: Security rules MUST reject writes containing unexpected fields not defined in the data model
- **FR-018**: Security rules MUST be deployed to both development (ease-queue-dev) and production (ease-queue) Firebase projects following the staged deployment procedure in plan.md Phase 4 (dev first with 24h monitoring, then production)
- **FR-019**: Security rules MUST be version controlled in the repository as `firestore.rules` file
- **FR-020**: Security rules MUST be tested using Firebase Emulator Suite before deployment to production

### Key Entities

**Note**: These entities already exist in the codebase. Security rules will protect them.

- **users**: User profile documents containing uid, email, role (admin/customer), displayName, phone, orgName - only readable/writable by the owning user
- **organizations**: Organization documents containing name, adminUid, bookingLinkSlug, isOpen, address, logoUrl - writable only by owning admin, readable by all authenticated users
- **services**: Service subcollection under organizations containing name, durationMinutes, timeMarginMinutes, price, isActive - managed by organization owner, readable by all authenticated users
- **working_hours**: Working hours subcollection under organizations containing dayOfWeek, startTime, endTime, breaks - managed by organization owner, readable by all authenticated users
- **appointments**: Appointment subcollection under organizations containing customerId, serviceId, scheduledAt, status - created by customers (own userId only), managed by organization owner
- **queues**: Queue subcollection under organizations containing customerId, serviceId, status, queueNumber, waitEstimate - managed by organization owner, customers can read their own entries

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of unauthorized access attempts are blocked - verified through security rules unit tests covering all collections and operation types
- **SC-002**: Security rules deployment completes successfully to both dev and prod environments without errors
- **SC-003**: All 20 functional requirements pass validation tests using Firebase Emulator Suite
- **SC-004**: Security rules prevent cross-organization data access - verified by test scenarios where admin A cannot access admin B's data
- **SC-005**: Security rules prevent customer impersonation - verified by test scenarios where customer A cannot create appointments as customer B
- **SC-006**: Rules reject 100% of writes with missing required fields - verified through negative test cases for each collection
- **SC-007**: Rules reject 100% of writes with invalid data types - verified through type mismatch test cases
- **SC-008**: Security rules file is under 100KB to stay within Firestore limits and maintain performance
- **SC-009**: Rule evaluation completes in under 100ms for typical read/write operations to avoid performance degradation
- **SC-010**: Zero security vulnerabilities identified in peer review of rules before production deployment
- **SC-011**: Test coverage exceeds 80% as measured by Firebase Emulator coverage report (Constitution Principle III compliance)

## Assumptions

- Users are already authenticated through Firebase Authentication (implemented in Phase 1)
- User documents are created and maintained with accurate role information by the authentication system
- Organization documents contain accurate adminUid field that matches the creator's Firebase Auth uid
- The Firebase Emulator Suite is installed and configured for local testing
- Both development and production Firebase projects are accessible for deployment
- The existing data models define the complete schema - no additional fields will be introduced without updating security rules
- Application logic handles business rules (e.g., preventing double-booking) - security rules focus on access control and basic validation
- Cloud Functions (future phase) will handle complex validations and data consistency that cannot be expressed in security rules
- The `firebase.rules` file location will be at the repository root as `firestore.rules` referenced in `firebase.json`
