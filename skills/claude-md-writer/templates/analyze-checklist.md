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

### Skill Reference Quality (advisory)

Not a blocking check. If project CLAUDE.md lists skill files without describing what each does or when to trigger:

- [ ] (advisory) Skill list entries have purpose description? Compare: `skills/foo/SKILL.md` (insufficient) vs `skills/foo/SKILL.md — 生成 7 维 spec，用户提需求时触发` (usable)
- Suggested format: `| Skill | 用途 | 触发场景 |`
- If missing → report as `[ADVISORY] Skill list lacks descriptions — agent may not know when to invoke`

### Execution-Plan Smell (Procedural rules in wrong place)

参照 Constraint 1 if/when 边界表判断。

- [ ] Does any rule describe a sequence of actions?
- [ ] If you remove the action sequence, is there still a constraint left?
- [ ] Does any rule match the flow-condition pattern ("When X, first A then B")?
- [ ] Tag each: `[PROCEDURAL] -> Move to skill or rewrite as declarative`

## Phase 2: Rule Migration Candidates

### → Hooks (deterministic triggers)

A rule should move to a hook when:
- [ ] It triggers on a specific event (file save, tool use, session start)
- [ ] It's a file existence check or format guard
- [ ] It's fully automatable with no judgment required
- Output format: `[HOOK] "<rule text>" → <suggested hook event + matcher>`
- [ ] OUTPUT MANDATORY: every Phase 2 → Hooks run must produce text. Even if zero candidates: "No hooks candidates identified — no deterministic/event-triggered rules found." Silent skip (checklist ticked but no text output) = Mode B violation, step incomplete.

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
4. **PROCEDURAL** — Execution-plan rules in wrong place, rewrite as declarative or move to skill
5. **HOOK** — Improve reliability, reduce CLAUDE.md bloat
6. **SKILL** — Improve reusability, reduce CLAUDE.md bloat
