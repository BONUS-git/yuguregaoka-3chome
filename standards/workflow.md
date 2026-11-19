# AI Development Workflow

## Purpose

This document orchestrates the complete AI development lifecycle.

It defines when each development standard should be applied.

Detailed guidance is intentionally separated into dedicated standards to keep this workflow concise and maintainable.

---

## Related Standards

| Standard | Purpose | Used During |
|----------|----------|-------------|
| testing.md | Test strategy | Test Design / Test Implementation |
| review.md | Code Review | Self Review |
| documentation.md | Documentation Policy | Documentation |
| coding-style.md | Implementation Guidelines | Implementation |
| grounding.md | Assumption control / Context hygiene | Brainstorming / Planning / All phases |
| communication.md | Response format / Summary section | All phases |

---

# Core Principles

- Use Git as the source of truth.
- Use `plan.md` as the persistent execution state.
- Update project knowledge continuously.
- Prefer automated verification over manual verification.
- Ask for clarification only when required.
- Minimize unnecessary user interaction.
- Never assume ambiguous requirements.

---

# Implementation Loop

When the user says "実装に入って" or equivalent, execute the following loop autonomously without interruption.

```
Plan → Implementation → Test Implementation → Test Execution
                                                    ↓
                                             Fail → Fix (max 3 attempts)
                                                    ↓ still failing → surface to user
                                             Pass → /code-review
                                                         ↓
                                                   Findings → Fix (max 2 attempts)
                                                         ↓ still failing → surface to user
                                                   Clear → Return to user
```

Rules:

- Do not pause between Plan and Implementation. Proceed directly.
- Do not ask for confirmation during the loop unless a Decision Rule requires it (see below).
- Surface to user only when retry limits are exceeded or a Decision Rule is triggered.
- At every phase transition, check remaining tokens. If below 3,000,000, write a handoff document and notify the user to run `/compact` before continuing. See standards/grounding.md.

---

# Feature Development Workflow

## Phase 1 - Requirement Analysis

Reference:

- standards/grounding.md

Objective:

Understand the requested feature before implementation.

Tasks:

- Read the user request.
- Retrieve only the project context relevant to the current task.
- Identify missing information.
- Tag each requirement as `[explicit]`, `[inferred]`, or `[assumed]`.
- Ask clarifying questions only if implementation cannot safely continue.

Deliverable:

- Shared understanding of the requested feature.
- List of Confirmed Requirements, Open Ambiguities, and Assumed Items.

Completion Criteria:

- Requirements are sufficiently understood.
- No `[assumed]` items remain unconfirmed.
- No Open Ambiguities that affect scope or implementation remain unresolved.
- User has explicitly confirmed understanding before Phase 2 begins (except when the Implementation Loop was triggered explicitly by the user).

---

## Phase 2 - Planning

Reference:

- standards/grounding.md

Objective:

Create an execution plan.

Tasks:

- Generate or update `plan.md`.
- Break work into small executable tasks.
- Use Markdown checkboxes.
- Include an `## Assumptions` section listing all `[explicit]`, `[inferred]`, and `[assumed]` items.

Example:

```markdown
# Feature Plan

- [ ] Update API
- [ ] Implement Service
- [ ] Write Feature Test
- [ ] Update Documentation
```

Rules:

- Update checkboxes immediately after completing work.
- Record blockers.
- Preserve unfinished work.

`plan.md` is the recovery point after context loss.

Completion Criteria:

- All implementation tasks are defined.
- Proceed immediately to Phase 3 without waiting for user confirmation.

---

## Phase 3 - Architecture Validation

Objective:

Ensure the planned implementation matches the project's architecture.

Tasks:

- Verify layer responsibilities.
- Verify dependency direction.
- Verify naming consistency.
- Verify existing implementation patterns.
- Reuse existing abstractions whenever possible.

If architectural changes are required:

Pause and request user confirmation.

Completion Criteria:

- Implementation strategy follows project architecture.

---

## Phase 4 - Implementation

Objective:

Implement the feature.

Tasks:

- Modify the minimum required files.
- Keep changes cohesive.
- Prefer consistency over cleverness.
- Update `plan.md` continuously.

Completion Criteria:

- Feature implementation completed.

---

## Phase 5 - Test Design

Reference:

- standards/testing.md

Objective:

Identify the required verification.

Tasks:

Design test cases covering:

- Happy path
- Boundary conditions
- Error handling
- Regression risks

Prefer automated tests.

Completion Criteria:

- Required test cases identified.

---

## Phase 6 - Test Implementation

Objective:

Verify implementation correctness.

Tasks:

- Add or update tests.
- Execute lint.
- Execute automated tests. Use the test command defined in the project's `.ai/` context.

If failures occur:

- Record status in `plan.md`.
- Preserve debugging notes.
- Fix and re-run. Repeat up to 3 attempts.
- If failures remain after 3 attempts, surface to user with findings.

Completion Criteria:

- All required tests pass.

---

## Phase 7 - Self Review

Reference:

- standards/review.md

Objective:

Review the implementation before presenting it.

Steps:

1. Run `/code-review` before any commit.
2. Address all findings.
3. If findings remain after 2 fix attempts, surface to user with remaining findings.

Review areas:

- Correctness
- Readability
- Maintainability
- Security
- Performance
- Duplicate logic
- Dead code
- Responsibility boundaries

Use Git diff as the review source.

Completion Criteria:

- `/code-review` has been executed and all findings addressed.
- No obvious improvements remain.

---

## Phase 8 - Documentation

Reference:

- standards/documentation.md

Objective:

Synchronize documentation with implementation.

Possible updates:

- spec.md
- review.md
- CHANGELOG.md
- README.md

Rules:

Documentation must reflect actual code.

Never rely solely on conversation history.

Git diff is the authoritative source.

Completion Criteria:

- Documentation matches implementation.

---

## Phase 9 - Knowledge Update

Objective:

Improve the project's long-term knowledge.

Update project knowledge when necessary.

Possible targets:

- architecture.md
- domain.md
- glossary.md
- project-memory.md
- decisions/

Record:

- Lessons learned
- Architectural decisions
- Newly discovered constraints
- Operational knowledge

Completion Criteria:

- Project knowledge reflects newly acquired information.

---

## Phase 10 - Completion

Before considering work complete:

- All planned tasks finished
- Tests pass
- Documentation updated
- Knowledge updated
- Implementation reviewed

Provide:

- Summary
- Remaining risks
- Suggested next steps

---

# Decision Rules

Proceed automatically for:

- Bug fixes
- Small refactoring
- Documentation
- Tests
- UI adjustments

Pause and ask for confirmation before:

- Database schema changes
- Public API changes
- Authentication changes
- Authorization changes
- Infrastructure changes
- Third-party dependency changes

---

# Context Retrieval Strategy

Do not load all project documents.

Instead:

1. Search for relevant documents.
2. Read only what is necessary.
3. Expand context gradually.

Large repositories should be explored incrementally.

---

# Persistent State

The following files preserve execution state:

- plan.md
- project-memory.md

These files allow work to continue after:

- Context window limits
- Session interruptions
- Agent replacement

---

# Definition of Done

A feature MUST NOT be considered complete until:

- Test cases have been designed.
- Automated tests have been implemented whenever practical.
- All tests pass.
- If automated testing is not feasible, the reason must be explicitly documented.
