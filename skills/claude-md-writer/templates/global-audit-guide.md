# Mode C — Global Audit Guide

Use this when optimizing `~/.claude/CLAUDE.md`.

## Phase 1: Rule Categorization

For each rule in the global config, classify:

| Category | Criteria | Action |
|----------|----------|--------|
| **Keep** | Still relevant, used in ≥1 active project | Leave as-is |
| **Delete** | Never triggered, obsolete, or better placed elsewhere | Mark with consequence |
| **→ Hook** | Deterministic, event-triggered, no judgment needed | Suggest hook config |
| **→ Skill** | Procedural workflow, multi-step, reusable | Suggest skill name |

## Phase 2: Redundancy Check

For each candidate deletion:
- [ ] When was this rule last relevant?
- [ ] What breaks if removed?
- [ ] Is it covered by a hook, skill, or project-level rule?

Output format:
```
[DELETE] "<rule text>"
Consequence: <what changes if removed>
Why: <reason for deletion>
```

## Phase 3: Hook → Skill Migration

### Hook Suitability Test

- [ ] Does this rule fire on a specific event?
- [ ] Is the action deterministic (same input → same output)?
- [ ] Can it be expressed as a shell command or script?
- If all three YES → candidate for `settings.json` hook

### Skill Suitability Test

- [ ] Is this a multi-step workflow?
- [ ] Does it require context-dependent decisions?
- [ ] Is it reusable across projects?
- If all three YES → candidate for standalone skill

## Phase 4: New Rule Justification

For any NEW global rule being proposed:

**Required — at least one of:**
- [ ] User explicitly states multiple projects need this
- [ ] Multi-project evidence found in workspace
- [ ] User confirms it is a long-term cross-project preference

**Default:** prefer project-level or skill-level placement over global.

## Phase 5: Symlink Safety

Before writing `~/.claude/CLAUDE.md`:
- [ ] Is the file a symlink? → Resolve real path, output DIFF only, do NOT write
- [ ] Is the file read-only? → Output DIFF to stdout, instruct user
- [ ] Is the target directory writable? → Proceed with write
