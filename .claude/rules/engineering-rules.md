# Engineering Rules
> These are the engineering principles I expect you to follow on this project.
> Read and internalize them before making any suggestion or change.

---

## 🧱 Code Quality

### 1. Clean Code Priority
- I want you to always prioritize **clarity over cleverness**
- Write code that any teammate can read without ever having seen it before
- Make sure everything you write is searchable by keyword and maintainable without me
- If you need a comment to explain what a line does, rewrite the line instead

### 2. Small Files and Functions
- I expect you to follow the **Single Responsibility** principle strictly
- Every function you write should do one thing; every file should own one concept
- If a function goes over **30 lines**, split it
- If a file goes over **200–300 lines**, split it
- Treat these as warning signs, not hard rules — use judgment

### 3. Minimalist Commenting
- Only add a comment when the **"why" is not obvious** from the code itself
- Never comment *what* the code is doing — only *why* it does it that way
- Delete any stale, redundant, or obvious comments you come across

### 4. Avoid Over-Engineering
- Do not introduce patterns, abstractions, or layers unless the problem **concretely requires** them
- Apply YAGNI — You Aren't Gonna Need It
- Before adding an abstraction, ask yourself: *does this solve a real problem I have today?*
- If the answer is "maybe later," don't add it

### 5. DRY — Avoid Duplication
- Never duplicate logic, UI fragments, or validation rules
- Before writing something new, search the codebase first
- If you find yourself copying more than 2–3 lines, extract it into a shared function or widget
- Remember: DRY applies to strings, constants, and config values too — not just functions

### 6. Naming Conventions
- I expect you to follow official **Dart naming conventions** without exception:
  - `snake_case` → files and directories
  - `PascalCase` → classes, enums, typedefs
  - `camelCase` → variables, parameters, functions
  - `SCREAMING_SNAKE_CASE` → top-level constants
- Every name you choose must be self-documenting — write `fetchUserOrders()`, not `getData()`

---

## 🏛️ Architecture

### 7. Strict Clean Architecture
- I want you to maintain a strict **three-layer architecture** at all times:
  - **Data Layer** — repositories, data sources, DTOs, API/DB calls
  - **Domain Layer** — entities, use cases, abstract repository interfaces, pure business logic
  - **Presentation Layer** — UI widgets, state management, view models
- The Domain Layer you write must have **zero dependencies** on Flutter or any external packages

### 8. Separation of Concerns
- Put business logic, validation, and decision-making in the **Domain Layer only**
- The UI layer you write should only receive state and dispatch events — it must make no decisions
- Data sources should only transform raw responses into DTOs — apply no business rules there
- Never put logic inside widgets

### 9. Layer Communication Rules
- Only let layers communicate through **defined contracts (abstract classes / interfaces)**:
  - Presentation → Domain via use cases
  - Domain → Data via repository abstractions (defined in Domain, implemented in Data)
- Never access a layer directly across boundaries — calling a datasource from a widget is **strictly forbidden**

### 10. Core Folder Management
- Always maintain a `core/` folder for everything shared across features:
  ```
  core/
    constants/
    extensions/
    theme/
    widgets/       # truly shared, reusable widgets only
    utils/
    errors/
  ```
- Never let features reach into each other's folders
- Promote any shared logic to `core/` immediately

### 11. Consistent State Management
- Use **Bloc/Cubit** for every feature — no exceptions
- Never mix approaches (no `setState` inside a Bloc-managed screen, no ad-hoc `ValueNotifier` for stateful logic)
- I value consistency across the codebase over any personal preference you might have

---

## 🐛 Problem Solving

### 12. Root Cause Problem Solving
- Always identify and fix the **root cause** of a bug, not its symptoms
- Before you apply any fix, tell me clearly: *what is the root cause?*
- If you can't answer that, keep investigating — don't guess
- Band-aid fixes that suppress errors or hide bad state are **forbidden**

### 13. Minimal Surface Changes
- When fixing a bug or adding a feature, make the **smallest reasonable change** to the existing system
- Do not refactor unrelated code in the same step
- Do not rename variables or restructure files "while you're in there"
- Every unrelated change you make introduces unrelated risk

### 14. Repository Pattern Consistency
- Follow the **existing patterns** in the repository, even if you disagree with them
- I care more about uniformity across the codebase than your individual preference
- If you think a pattern should change, flag it to me separately — never mix it into feature work

---

## ⚡ Performance

### 15. Flutter Performance Awareness
- Always use `const` constructors wherever possible
- Mark every non-reassigned variable as `final`
- Never build large widget trees inside `setState` callbacks
- Always use `ListView.builder` (not `ListView`) for dynamic lists
- Profile with DevTools before suggesting optimizations — never guess at bottlenecks

### 16. Performance-First Refactoring
- When you refactor, prioritize decisions that improve speed and reduce memory usage
- Measure performance before and after — show me the difference
- If a refactor improves readability but hurts performance, justify it explicitly
- Never optimize prematurely — only what profiling confirms is a real problem

---

## 🔒 Reliability & Security

### 17. No Silent Failures
- **Never swallow exceptions silently** — I won't accept it
- Every `catch` block you write must do one of: re-throw, log with full context, or map to a user-facing error state
- Never show a generic "Something went wrong" alert with no context
- Every error must be specific, actionable, and traceable in logs

### 18. Security Standards
- Never commit API keys, secrets, or credentials to version control
- Use `.env` files with `flutter_dotenv` or equivalent, and always add them to `.gitignore`
- Always use a dedicated **logger class** in production that strips or masks sensitive fields (tokens, passwords, card numbers)
- Never log raw API responses in production builds

### 19. Dependency Management
- Do not add a package unless you have a **clear, justified reason** that can't be met by existing dependencies or the SDK
- Before adding any package, verify it is:
  - Actively maintained (recent commits, open issues addressed)
  - On the latest stable version
  - Compatible with the current Flutter/Dart SDK version
- Always prefer Dart/Flutter SDK-native solutions over third-party packages when they're equivalent

---

## 🤖 AI Collaboration

### 20. You Are My Senior Engineering Partner
- I expect you to behave as a **senior engineering partner**, not a code generator
- Actively flag it when my proposed approach has architectural issues
- Suggest a better alternative when a simpler or more idiomatic solution exists
- Push back on requirements that seem unclear or contradictory
- If something I ask for violates these rules, flag it explicitly before proceeding

### 21. You Must Verify Before You Change
- Before suggesting or making any change, **read the relevant files first**
- Never assume how existing code behaves — verify it
- If you need to review a file to give a safe answer, review it before answering
- Never suggest a change that could silently break unread parts of the codebase

### 22. Generate Metadata When Done
- Once I mark a task as **"done"**, I expect you to automatically output:
  - A **branch name** following: `type/short-description`
    - e.g., `feat/gas-station-filter`, `fix/auth-token-refresh`
  - A **commit message** following Conventional Commits: `type(scope): description`
  - A **PR description** covering: summary of changes, affected layers, and testing notes

---

## 🛠️ Tooling & Standards

### 23. Latest Dart & Flutter Practices
- Always use the most current stable Dart/Flutter APIs and idioms
- Prefer **Sealed classes** (Dart 3+) over `Freezed` for union types where the use case is simple
- Prefer **Records and patterns** (Dart 3+) for destructuring and local data grouping
- Prefer **named constructors** over factory methods for simple cases
- When you encounter deprecated APIs, flag them to me and migrate — never leave them in place

### 24. Optimized Import Ordering
- Always follow **Effective Dart** import ordering (enforced via `dart fix`):
  ```dart
  // 1. Dart SDK imports
  import 'dart:async';

  // 2. Flutter imports
  import 'package:flutter/material.dart';

  // 3. External package imports
  import 'package:bloc/bloc.dart';

  // 4. Internal/local imports
  import '../core/theme/app_colors.dart';
  ```

### 25. Testing Discipline
- Write tests in this priority order:
  1. **Unit tests** for all use cases and domain logic — this is mandatory
  2. **Integration tests** for critical user flows (e.g., auth, checkout)
  3. **Widget tests** only for complex, stateful widget behavior
- Any use case or repository method with non-trivial logic that you ship without a unit test is **incomplete**
- Place all tests in `test/` mirroring the `lib/` folder structure exactly

---

