# Documentation Standard

## Source of Truth

Git diff is the authoritative source.

Never rely on conversation history.

---

## Update Targets

| File | When to Update |
|------|----------------|
| README.md | Public interface or setup changes |
| CHANGELOG.md | Every feature or fix |
| spec.md | Requirement or behavior changes |
| .ai/ | Architecture, domain, or decision changes |

---

## Branch Documentation

For each feature branch, create a directory under `docs/` mirroring the branch name.

Example:

```
docs/
  feature/admin/shipping-info/
    README.md
    spec.md
    plan.md
    test.md
    review.md
```

| File | Purpose |
|------|---------|
| README.md | What this branch is and why it exists |
| spec.md | Requirements and acceptance criteria |
| plan.md | Execution plan and current progress |
| test.md | Test design including intentional coverage gaps |
| review.md | Review findings and outstanding issues |

These files allow an AI to reconstruct the exact work state at any point in time.

---

## Rules

- Update only what changed.
- Documentation must reflect actual code, not intent.
