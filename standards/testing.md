# Testing Standard

## Principle

Every feature should have a verification strategy.

Prefer automated tests.

Manual testing is the exception.

---

## Required Test Design

Every implementation should identify:

- Happy path
- Validation
- Error handling
- Boundary conditions
- Regression risks

---

## Automated Tests

When possible:

- Add new tests.
- Update existing tests.
- Keep tests readable.

---

## When Tests Cannot Be Added

Document:

- Why automated testing is difficult.
- Manual verification procedure.
- Remaining risks.

---

## Intentional Coverage Gaps

When requirements are ambiguous, do not skip silently.

Record the gap explicitly:

- What is not covered.
- What assumption was made instead.
- What needs to be confirmed when requirements are clarified.

Example:

```markdown
## Coverage Gaps

- [ ] Behavior when X is null: requirement unclear. Assumed Y. Verify when spec is finalized.
```

These records serve as a future verification checklist, not as failures.