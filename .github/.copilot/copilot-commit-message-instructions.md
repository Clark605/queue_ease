# Commit Message Instructions

Use **Conventional Commits** format for all commit messages with meaningful, descriptive messages.

## Format

```
type(scope): what changed and why/impact
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

## Rules for Meaningful Commits

1. **Include a scope** in parentheses targeting the specific area affected
2. **Keep subject line under 72 characters** but use full line for clarity
3. **Use imperative mood** (e.g., "add" not "added" or "adds")
4. **Do not end subject with a period**
5. **Scope should be lowercase** and concise (e.g., `auth`, `queue`, `firestore`, `security`)
6. **Be specific about WHAT changed** - mention key components, files, or features
7. **Include WHY or IMPACT** when applicable - the business value or technical reason
8. **Mention numbers** - test counts, file counts, rule counts, performance metrics

## Writing Meaningful Descriptions

### ❌ Too Generic
- `feat(auth): add login`
- `fix(queue): fix bug`
- `test(firestore): add tests`

### ✅ Meaningful & Specific
- `feat(auth): implement email/password login with Google Sign-In fallback`
- `fix(queue): prevent ticket overflow when position exceeds 999`
- `test(firestore): add 78 security rule tests covering all collections`

### Key Patterns for Better Messages

**Features**: Mention what capability is added
- `feat(scope): implement X enabling Y`
- `feat(scope): add X with Y validation/support`

**Fixes**: State what was broken and how it's resolved
- `fix(scope): resolve X causing Y`
- `fix(scope): correct X validation to prevent Y`

**Tests**: Specify test count and coverage
- `test(scope): add N tests for X covering Y scenarios`
- `test(scope): cover X with N unit tests achieving Y% coverage`

**Refactors**: Explain the improvement
- `refactor(scope): extract X to Y for better reusability`
- `refactor(scope): replace X with Y helper reducing duplication`

**Docs**: State what documentation is updated
- `docs(scope): document X with examples and usage patterns`
- `docs(readme): add deployment instructions for X environment`

## Examples - Generic vs Meaningful

### Authentication
❌ `feat(auth): add signup`  
✅ `feat(auth): implement role-based signup with admin/customer selection`

❌ `fix(auth): fix login error`  
✅ `fix(auth): handle null email error in Google Sign-In flow`

### Firestore Security
❌ `feat(firestore): add rules`  
✅ `feat(firestore): implement RBAC security rules for 6 collections`

❌ `test(firestore): add tests`  
✅ `test(firestore): add 78 tests covering CRUD operations and validation`

❌ `refactor(firestore): clean up code`  
✅ `refactor(firestore): use createdAtNotModified helper eliminating 6 duplications`

### Deployment
❌ `chore: deploy`  
✅ `chore(deploy): release firestore rules to dev and production environments`

### Documentation
❌ `docs: update readme`  
✅ `docs(firestore): document security rule test patterns and helper functions`

### Bug Fixes
❌ `fix(queue): fix issue`  
✅ `fix(queue): prevent race condition when multiple customers join simultaneously`

### Performance
❌ `perf: optimize`  
✅ `perf(firestore): reduce rule evaluation time from 45ms to 8ms using indexed queries`

## Scope Guidelines by Area

- `auth` - Authentication, login, signup, password reset
- `firestore` - Database rules, collections, queries
- `security` - Security rules, permissions, RBAC
- `queue` - Queue management, ticket system
- `appointment` - Appointment booking, scheduling
- `admin` - Admin dashboard, organization management
- `customer` - Customer features, booking interface
- `ui` - UI components, widgets, styling
- `router` - Navigation, routing, guards
- `api` - API integration, HTTP clients
- `test` - Test files, test utilities
- `deploy` - Deployment, CI/CD, environments
- `config` - Configuration files, environment setup
