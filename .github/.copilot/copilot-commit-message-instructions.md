# Commit Message Instructions

Use **Conventional Commits** format for all commit messages.

## Format

```
type(scope): description
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

## Rules

1. Include a scope in parentheses when the change targets a specific area
2. Keep the subject line under 72 characters
3. Use imperative mood in the description (e.g., "add" not "added")
4. Do not end the subject line with a period
5. The Scope should be lowercase and concise, typically a single word representing the area of the codebase affected or the feature being changed (e.g., `auth`, `queue`, `ui`, `services`).
6. documentation changes should be prefixed with `docs` and can include the scope if it targets a specific area (e.g., `docs(readme): update installation instructions`).

## Examples

- `feat(auth): add login screen`
- `fix(queue): resolve ticket number overflow`
- `docs(readme): update installation instructions`
- `refactor(services): extract API client to separate class`
- `chore(deps): update flutter dependencies`
