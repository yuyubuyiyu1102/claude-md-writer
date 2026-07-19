# Mode B — Audit Checklist

Use this when reviewing an existing CLAUDE.md against the global constitution.

## Phase 1: Conflict Detection

### Override Conflicts (Highest Priority — Block)

- [ ] Does any project rule negate a global rule?
- [ ] Check: language preferences, security constraints, behavioral rules
- [ ] Mark any found as `[BLOCKED]` — suggest deletion, rewrite, or skill migration
- [ ] If Override Exception applies (language/docs/tech-stack only): verify `> [!NOTE] Overrides Global: <reason>` marker present

### Duplicate Rules

- [ ] Is any rule in project CLAUDE.md already stated in global CLAUDE.md?
- [ ] Tag each: `[DUPLICATE] Suggest deletion from project level`

### Missing Rules

- [ ] Does global CLAUDE.md require project-level declarations (build commands, test commands, tech stack)?
- [ ] Does project CLAUDE.md declare them?
- [ ] Only flag if the global rule explicitly demands project-level declaration
- [ ] Does NOT apply to behavioral rules ("discuss before implement", "answer in Chinese")

## Phase 2: Rule Migration Candidates

### → Hooks (deterministic triggers)

A rule should move to a hook when:
- [ ] It triggers on a specific event (file save, tool use, session start)
- [ ] It's a file existence check or format guard
- [ ] It's fully automatable with no judgment required
- Output format: `[HOOK] "<rule text>" → <suggested hook event + matcher>`

### → Skills (workflow logic)

A rule should move to a skill when:
- [ ] It describes a multi-step process
- [ ] It depends on tool-specific instructions
- [ ] It's reusable across projects
- [ ] It contains conditional logic (if/when/then)
- Output format: `[SKILL] "<rule text>" → <suggested skill name>`

## Phase 3: Priority Ordering

1. **BLOCKED** — Override conflicts (must resolve before anything else)
2. **DUPLICATE** — Waste token budget, easy to remove
3. **MISSING** — Needed for agent to work correctly in this project
4. **HOOK** — Improve reliability, reduce CLAUDE.md bloat
5. **SKILL** — Improve reusability, reduce CLAUDE.md bloat
