# Commit Message Instructions

Use **detailed, structured commit messages** following Queue Ease's commit message style for clarity and maintainability.

## Format

```
type(scope): concise description

- Bullet point explaining what was added/changed
- Another bullet point with technical details
- Include business rationale and impact
- Mention test coverage when applicable
- Note any breaking changes or critical updates

Brief sentence explaining the business value or purpose.
```

## Valid Types

- `feat` - A new feature
- `fix` - A bug fix
- `docs` - Documentation only changes
- `style` - Changes that do not affect the meaning of the code (formatting, whitespace)
- `refactor` - A code change that neither fixes a bug nor adds a feature
- `perf` - A code change that improves performance
- `test` - Adding missing tests or correcting existing tests
- `chore` - Changes to the build process or auxiliary tools

## Key Principles

- **Detailed but focused** - Explain both "what" and "why"
- **Technical + business context** - Bridge implementation and business value
- **Bullet points** for clarity and scannability
- **Closing summary** explaining the overall purpose
- **Conventional commit types** - feat, fix, docs, refactor, test, chore, etc.
- **Meaningful scopes** - admin, customer, core, security, etc.

## Structure Rules

1. **Subject line**: Keep under 72 characters, use imperative mood
2. **Bullet points**: Each explains a specific change or impact
3. **Technical details**: Include file names, component names, method names
4. **Business rationale**: Explain why the change was needed
5. **Test coverage**: Mention test additions/updates when applicable
6. **Breaking changes**: Always highlight breaking changes
7. **Closing summary**: One sentence explaining the overall business value

## Examples

### ✅ Good Example - Feature Addition

```
feat(admin): implement staff member CRUD with validation

- Add StaffMemberEntity with required fields (name, orgId, role)
- Create StaffDatasource with real-time Firestore streams
- Implement StaffRepositoryImpl with Result<T> error handling
- Add staff validation preventing deletion when assigned to services
- Include 15 unit tests covering CRUD operations and edge cases

Enables multi-staff queue management for organizations with specialized services.
```

### ✅ Good Example - Bug Fix

```
fix(queue): resolve race condition in appointment status updates

- Add transaction-based status updates in admin_queue_datasource.dart
- Implement optimistic locking using document snapshots
- Update queue_management_cubit.dart to handle concurrent actions
- Add retry logic for failed transactions with exponential backoff
- Fix UI state inconsistencies when multiple admins work simultaneously

Prevents queue corruption when multiple staff members manage the same queue.
```

### ✅ Good Example - Breaking Change

```
feat(entities): add required staffId field to ServiceEntity and AppointmentEntity

- Update ServiceEntity with staffId (required) and staffName (optional)
- Modify ServiceModel.fromDoc() and toMap() for Firestore serialization
- Update AppointmentEntity with inherited staff information
- Modify booking flow to populate staffId from selected service
- ⚠️ BREAKING: All existing services require staffId assignment
- Add migration script for existing data in scripts/migrate_to_staff_model.ts

Enables staff assignment tracking for queue management and service specialization.
```

### ❌ Poor Example - Too Generic

```
feat(staff): add staff management

- Add staff features
- Update UI
- Fix bugs
- Add tests

Improves the app.
```

## Scope Guidelines by Feature Area

### Core Features
- `auth` - Authentication, login, signup, password reset
- `queue` - Queue management, ticket system, queue operations
- `appointment` - Appointment booking, scheduling, lifecycle
- `staff` - Staff member management, assignments
- `service` - Service CRUD, configuration, staff assignment

### User Interfaces
- `admin` - Admin dashboard, organization management
- `customer` - Customer features, booking interface
- `ui` - UI components, widgets, styling
- `router` - Navigation, routing, guards

### Technical Infrastructure
- `firestore` - Database rules, collections, queries, security
- `security` - Security rules, permissions, RBAC
- `api` - API integration, HTTP clients
- `core` - Core utilities, error handling, DI
- `config` - Configuration files, environment setup

### Development & Deployment
- `test` - Test files, test utilities, coverage
- `docs` - Documentation updates
- `chore` - Build process, CI/CD, tooling
- `deploy` - Deployment, environments

## Common Patterns

### Feature Implementation
```
feat(scope): implement [feature] with [key capability]

- Add [Entity/Model/Component] with [specific fields/methods]
- Create [Repository/UseCase/Cubit] implementing [interface/pattern]
- Update [UI component] to [specific behavior]
- Include [number] tests covering [scenarios]
- [Any breaking changes or special notes]

[Business value explanation].
```

### Bug Fixes
```
fix(scope): resolve [specific issue] causing [problem]

- Identify root cause in [component/file]
- Fix [specific technical issue]
- Add validation/error handling for [edge case]
- Update tests to cover [regression scenario]
- Verify fix with [manual test description]

[Impact on user experience or system reliability].
```

### Refactoring
```
refactor(scope): extract [component] to improve [quality aspect]

- Move [functionality] from [source] to [destination]
- Eliminate [number] code duplications
- Improve [performance/readability/maintainability] by [method]
- Update [number] calling sites
- Maintain backward compatibility for [interfaces]

[Technical debt reduction or architecture improvement explanation].
```

Remember: Every commit message should tell the story of the change clearly enough that a teammate can understand the impact without reading the code diff.