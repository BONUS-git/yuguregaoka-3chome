# Communication Standard

## Purpose

Keep agent output scannable and conversations on track.
A Summary section at the end of every response ensures decisions, questions, and next steps are never buried in prose.

---

## Summary Section

Append a `## Summary` section at the end of every response, without exception.

### Format

Use category blocks. Omit a block entirely when it has no content.

```
---
## Summary

**決定事項**
- {one line per item}

**あなたへの質問**
- {one line per item}

**次に詰めたいポイント**
- {one line per item}
```

### Category Definitions

| Category | What to include |
|----------|-----------------|
| **決定事項** | Agreements reached in this exchange |
| **あなたへの質問** | Anything that blocks progress; always includes `[assumed]` items from grounding.md |
| **次に詰めたいポイント** | Unresolved design questions, upcoming agenda, next phase inputs |

### Rules

- Show the `## Summary` section in every response.
- Omit a category block entirely when it has no items — never show an empty heading.
- Keep each item to one line. No sub-bullets, no explanation.
- `[assumed]` items from grounding.md must appear in **あなたへの質問** automatically — never omit them silently.
- The summary is a navigation aid, not a repetition of the response body. State only the action-relevant fact, not the reasoning.
