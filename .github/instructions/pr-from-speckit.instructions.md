---
description: "Use when creating pull requests, PR descriptions, merge requests, or preparing feature branches for review. Automatically generates comprehensive PR titles and descriptions from speckit documentation."
---

# Pull Request Creation from Speckit

When the user asks to create a PR, prepare a PR, or needs a PR description, follow this workflow to generate a comprehensive pull request based on the feature's speckit documentation.

**IMPORTANT**: Always use GitHub MCP tools (`mcp_github_github_create_pull_request`) to create PRs directly. Load the tool first using `tool_search_tool_regex` if not already available.

## Discovery Process

1. **Identify the feature branch and spec folder**:
   - Current branch name (e.g., `feature/admin-core`) maps to spec folder (e.g., `specs/001-admin-core/`)
   - If branch name doesn't match a spec folder, ask the user which spec to use
   - List available spec folders in `specs/` if unclear

2. **Load essential spec files**:
   - `spec.md` - Feature specification with user stories and requirements
   - `tasks.md` - Implementation tasks and completion status
   - `plan.md` - Technical implementation plan and architecture decisions

## PR Title Format

```
feat(<scope>): <concise feature summary from spec>
```

**Examples**:
- `feat(admin): organization setup and service management`
- `feat(customer): queue joining and status tracking`
- `feat(security): firestore security rules implementation`

**Scope extraction**:
- Derive from the feature's primary domain (admin, customer, shared, core)
- Use the first major area mentioned in spec.md if unclear

## PR Description Template

```markdown
## 🎯 Feature Overview

[2-3 sentence summary from spec.md overview/summary section]

**Branch**: `<branch-name>`  
**Spec**: `specs/<spec-folder>/`  
**Sprint**: [Extract from spec.md or plan.md]  
**Status**: [✅ Complete / 🚧 In Progress / ⏸️ Blocked]

## 📋 User Stories Delivered

[List each user story from spec.md with priority level]

- **[P1]** [User Story 1 title]
  - [Brief description of what was delivered]
- **[P2]** [User Story 2 title]
  - [Brief description]

## 🏗️ Technical Implementation

### Architecture Changes
[Summarize major architectural decisions from plan.md]

- **New Repositories**: [List domain repositories created]
- **Data Layer**: [Firestore datasources and collections]
- **State Management**: [Cubits/Blocs added]
- **UI Components**: [Key screens and widgets]

### Key Deliverables

**Domain Layer**:
- [List new entities, repositories]

**Data Layer**:
- [List datasources, models, repository implementations]

**Presentation Layer**:
- [List screens, cubits, widgets]

**Infrastructure**:
- [Router changes, DI updates, configuration]

## 🎨 Feature Flow

[Extract the user flow from spec.md acceptance scenarios, written as a step-by-step narrative]

1. **[Action 1]**: User performs X → System does Y
2. **[Action 2]**: User navigates to Z → Screen displays A
3. **[Action 3]**: User submits form → Data persists to Firestore

## ✅ Acceptance Criteria Met

[Extract the key acceptance scenarios from spec.md that were implemented]

- ✅ [Scenario 1 from spec]
- ✅ [Scenario 2 from spec]
- ✅ [Scenario 3 from spec]

## 📊 Implementation Status

**Completed Tasks**: X / Y  
[Extract from tasks.md - count completed vs total]

**Key Milestones**:
- [List Phase X checkpoints from tasks.md that are complete]

## 🧪 Testing

[Extract testing approach from plan.md Constitution Check or tasks.md]

- **Unit Tests**: [Coverage or deferred status]
- **Widget Tests**: [Status]
- **Integration Tests**: [Status]

## 📦 Dependencies

[List new packages added from pubspec.yaml diff, if any]

## 🔗 Related Documentation

- Feature Spec: [`specs/<folder>/spec.md`](../specs/<folder>/spec.md)
- Implementation Plan: [`specs/<folder>/plan.md`](../specs/<folder>/plan.md)
- Tasks Breakdown: [`specs/<folder>/tasks.md`](../specs/<folder>/tasks.md)

## 🎬 Demo / Screenshots

[If available, reference demo files in docs/demos/ or UI screens in docs/ui-screens/]

## 🔍 Review Focus Areas

[Highlight specific areas that need careful review based on complexity or risk from spec.md]

1. **[Area 1]**: [Why this needs attention]
2. **[Area 2]**: [Specific concern]

## ⚠️ Breaking Changes

[List any breaking changes or migration steps required]

- None / [List changes]

## 📝 Notes for Reviewers

[Any additional context from plan.md or implementation decisions that reviewers should know]

---

**Reviewers**: @copilot  
**Related Issues**: Closes #[issue-number]
```

## Content Extraction Guidelines

### From spec.md
- Extract feature title/summary from the # heading
- Pull user stories from "User Scenarios & Testing" section
- Get priority levels (P1, P2, P3, P4) from each story
- Extract acceptance scenarios for "Acceptance Criteria Met"
- Note any edge cases or special considerations

### From tasks.md
- Count total tasks vs completed (marked with [X] or [✓])
- List Phase names and their checkpoints
- Identify implementation milestones
- Note any blocked or skipped tasks

### From plan.md
- Extract Sprint number and date
- Get technical context (dependencies, versions)
- Summarize architecture decisions
- Pull testing strategy from Constitution Check
- List key technical constraints

## Rules

1. **Always read all three files** (spec.md, tasks.md, plan.md) before generating the PR description
2. **Use actual content** from the spec files - don't invent or assume details
3. **Keep priorities visible** - P1/P2/P3/P4 labels help reviewers understand the scope
4. **Link to spec files** - always include relative links to the spec folder
5. **Be specific** - list concrete deliverables, not vague statements
6. **Extract, don't infer** - when a section isn't covered in the spec, mark it as "N/A" or omit it
7. **Show progress** - X/Y tasks completed gives reviewers confidence
8. **Highlight testing** - make testing status (or deferral) explicit
9. **Always include @copilot as a reviewer** - Copilot review is required for all PRs
10. **Use GitHub MCP tools** - Search for and use `mcp_github_github_create_pull_request` tool to create PRs directly when available
11. **Target develop branch** - PRs ALWAYS target the `develop` branch, never `main` (develop is the integration branch)

## Common Adjustments

- If testing is deferred, clearly state this in the Testing section with the Sprint it's scheduled for
- If the feature is incomplete, mark status as 🚧 In Progress and note remaining work
- If there are no breaking changes, explicitly state "None" to give reviewers confidence
- For infrastructure features (CI/CD, tooling), adjust sections to fit the technical nature

## Output Format

After reading the spec files, present the PR information in two parts:

1. **PR Title** (one line, in conventional commits format)
2. **PR Description** (full markdown formatted according to the template)

## PR Creation Workflow

**Always use GitHub MCP tools when available:**

0. Before opening any pull request, run the relevant CI checks locally first, including formatting, linter/analyzer, and tests. If any local check fails, fix the issue and rerun the checks until they pass.

1. **Search for GitHub MCP tools**: Use `tool_search_tool_regex` with pattern `create_pull_request` to load the GitHub MCP tool
2. **Create PR directly**: Use `mcp_github_github_create_pull_request` with:
   - `owner`: Repository owner (Clark605)
   - `repo`: Repository name (queue_ease)
   - `title`: Generated PR title
   - `body`: Generated PR description (must include `**Reviewers**: @copilot`)
   - `head`: Current feature branch name
   - `base`: **develop** (integration branch - ALWAYS use develop, never main)
   - `draft`: false (unless user specifies draft)
3. **Request Copilot review**: After PR creation, search for and use `mcp_github_github_request_copilot_review` or `mcp_github_github_assign_copilot_to_issue` to assign Copilot as reviewer

**If GitHub MCP tools are not available**, offer these alternatives:
- Copy the title and description to clipboard for manual PR creation
- Save the description to a file
- Display the formatted PR for the user to copy manually
