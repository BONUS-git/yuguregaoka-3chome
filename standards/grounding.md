# Grounding Standard

## Purpose

Prevent agents from silently completing requirements or generating hallucinations.
Ensure context continuity across compact operations.

---

## Related Standards

| Standard | Purpose | Used During |
|----------|---------|-------------|
| workflow.md | Development lifecycle | All phases |

---

# Part 1: Requirement Grounding

## Assumption Tagging

Every requirement or design decision in `plan.md` must carry a source tag:

| Tag | Meaning |
|-----|---------|
| `[explicit]` | User stated this directly |
| `[inferred]` | Derived from existing code or context |
| `[assumed]` | Agent's own interpretation — requires confirmation |

## Rule: Stop on `[assumed]`

Any item tagged `[assumed]` must be surfaced to the user before proceeding.
Do not continue implementation with unconfirmed assumptions.

## Required Output Before Entering Planning Phase

Before transitioning from brainstorming to planning, always output:

1. **Confirmed Requirements** — items tagged `[explicit]` or `[inferred]`
2. **Open Ambiguities** — questions that affect scope or implementation
3. **Assumed Items** — interpretations the agent made without user confirmation

Do not enter the planning phase while Open Ambiguities remain unresolved.

## Assumptions Section in plan.md

Every `plan.md` must include an `## Assumptions` section:

```markdown
## Assumptions
- [assumed] API returns paginated results → requires confirmation
- [inferred] Auth uses JWT based on existing middleware
- [explicit] Target is mobile-first (user stated)
```

Items marked `[assumed]` remain open until the user explicitly confirms them.
Upon confirmation, update the tag to `[explicit]`.

---

# Part 2: Context Hygiene

## Token Threshold

Monitor remaining tokens via the `<total_tokens>` value in the system prompt.

**Threshold: 3,000,000 tokens remaining**

When remaining tokens fall below this threshold:

1. Update `plan.md` with current progress and next steps.
2. Write a handoff document to `.ai/handoffs/` (see format below).
3. Notify the user: "コンテキストが少なくなっています。/compact を実行してください。引き継ぎ書を書きました: `.ai/handoffs/{branch}-{timestamp}.md`"

The agent cannot invoke `/compact` directly. User action is required for the compact itself.

## Handoff Trigger Points

Check the token threshold at every phase transition in the workflow.
Never start a heavy phase (Implementation, Test Execution, Review) without first verifying the threshold.

## Handoff Document

### Location

```
.ai/handoffs/{branch-name}-{YYYYMMDD-HHMM}.md
```

Branch-based naming isolates concurrent agents working on different branches.

### Format

```markdown
# Agent Handoff
generated_at: {ISO 8601 timestamp}
phase: {current workflow phase}
branch: {git branch name}
tokens_at_generation: {remaining token count}

## Active Plan
{Copy of current plan.md checkbox state}

## Confirmed Requirements
- {requirement} ({source: explicit/inferred})

## Open Assumptions
- {assumption} → requires user confirmation after resumption

## Work in Progress
{What was being worked on and immediate next step}

## Resumption Instructions
1. Read this file.
2. Read plan.md.
3. Confirm any Open Assumptions with the user before proceeding.
4. Resume from the Work in Progress section above.
```

## Session Start: Handoff Detection

At the start of every session, check `.ai/handoffs/` for files matching the current branch.
If a file exists that was generated within the last 24 hours, read it before beginning any work.

This rule belongs in `CLAUDE.md`:

```markdown
## Session Start
Check `.ai/handoffs/` for a recent handoff matching the current branch.
If found (within 24 hours), read it and follow its Resumption Instructions.
```

## Handoff File Lifecycle

- Handoff files are not deleted automatically.
- After confirming resumption is complete, the agent may note completion in the file but does not delete it.
- Files older than 24 hours are ignored on session start.

---

# Part 3: Planning Gate

## Rule: Confirm Before Planning

Before transitioning from Phase 1 (Requirement Analysis) to Phase 2 (Planning), always present the current understanding to the user and wait for explicit confirmation.

**Exception**: If the user has issued an explicit trigger such as "実装に入って" or equivalent, skip this gate and enter the Implementation Loop directly.

## Confirmation Prompt Format

```
以下の理解でプランニングに進みます。確認してください。

**要件理解**
- [explicit] {requirement}
- [inferred] {requirement}

**未確認の前提**（[assumed]）
- {assumption} → 進む前に確認が必要

よければ「進めて」、修正があれば教えてください。
```

- List every `[assumed]` item under **未確認の前提**.
- Do not enter Phase 2 until the user responds.
- On receiving confirmation, update `[assumed]` items to `[explicit]` and proceed.
