---
name: claude-md-writer
description: Use when user wants to create, update, optimize, or audit a CLAUDE.md file — whether for a new project, an existing project, or the global user-level configuration.
---

# CLAUDE.md Writer

## Overview

Smart CLAUDE.md authoring skill with three modes: create from scratch, audit existing config, or maintain the global constitution. **Intent-driven routing** -- parse what the user says, not whether a file exists.

## HARD GATE — Read Before Any Action

**Every pre-generation step is a PREREQUISITE.** Steps are sequential and mandatory — you CANNOT skip ahead.

- **Step N not done → Step N+1 is FORBIDDEN.**
- After every step, self-check: *"Did I actually do this with a real tool call?"* If the answer is NO — go back and do it. Do not simulate, assume, or rely on memory.
- **TOP VIOLATION:** Generating a draft without reading global CLAUDE.md and scanning the project. This is the #1 failure mode. Check yourself before every output.
- **STOP AND WAIT:** Any step labeled `USER-GATE` means you MUST pause and wait for explicit user response before continuing. Do NOT proceed past a USER-GATE until the user replies.

### Gate Types

| Label | Meaning |
|-------|---------|
| `PREREQUISITE` | Must complete with tool call before next step |
| `SELF-CHECK` | Pause and verify before continuing |
| `USER-GATE` | **STOP HERE. Do NOT proceed.** Wait for user response. |

**Violation check:** before writing any file, re-read this block and verify every gate was honored.

## Core Constraints

### Hierarchy (Global > Root > Subproject)

Three-level inheritance for monorepos. Subproject rules cannot override root rules. Root rules cannot override global rules (`~/.claude/CLAUDE.md`).

### Conflict Policy

| Type | Definition | Action |
|------|-----------|--------|
| **Override** | Project rule negates/undermines a global rule | **Block by default.** Report and suggest deletion, rewrite, or move to skill |
| **Duplicate** | Global already states the same rule | Suggest removal from project level |
| **Missing** | Global requires project declaration (build commands, test commands, tech stack) but project is silent | Suggest addition. Does NOT apply to behavioral rules (e.g. "answer in Chinese", "discuss before implementing") |

### Override Exception (narrow escape hatch)

Override-type conflicts are blocked EXCEPT when the project has an objective reason to differ in: language, documentation norms, or tech stack. The project rule MUST carry the explicit marker:

```
> [!NOTE] Overrides Global: <reason>
```

This exception CANNOT be used for safety rules or behavioral constraints (e.g. "discuss then implement", "no legal advice"). When detected, the skill passes the rule through but highlights a warning.

## Mode Routing

Parse the user's trigger words to route -- do NOT use file existence:

```
"create/init/write/generate CLAUDE.md"         → Mode A (Create)
"audit/review/check/improve/optimize CLAUDE.md" → Mode B (Audit)
"optimize constitution/tidy global CLAUDE.md"   → Mode C (Global Audit)
```

Ambiguous input (e.g. "look at the rules") defaults to Mode B, with a hint about Mode C.

---

## Mode A -- Create

**Trigger:** "write CLAUDE.md", "initialize project", "create project config"

### Steps

1. `PREREQUISITE` **Read global config** — Use Read tool to load `~/.claude/CLAUDE.md`. MANDATORY. If missing, warn user and downgrade to project-only mode (do not block). GATE: Do not proceed to step 2 until this read completes with a real tool call.
2. `PREREQUISITE` **Extract user profile** — From global CLAUDE.md output: language preference, verbosity style (caveman/full), autonomy mode (discuss/implement phases), hard constraints. Only extract explicitly stated content — do not infer. Write these down so you can reference them in step 5.
3. `PREREQUISITE` **Scan project** — Glob depth=2, ignore: `node_modules/`, `dist/`, `build/`, `.git/`, `coverage/`, `target/`, `vendor/`, `.next/`, `__pycache__/`, `.tox/`. Detect: directory structure, language/framework (package.json, go.mod, Cargo.toml, etc.), build tools (Makefile, justfile, CI configs), test conventions (file patterns, top 2 levels only), code style (sample up to 5 key source files, prefer src/, main entry, package entry). Use real Glob/Read tool calls — do not guess.
4. `USER-GATE` **Mature project check** — If project has many existing files, ask user: "Detected a mature project. Create new CLAUDE.md?" **STOP HERE.** Wait for user response. Do NOT proceed to step 5 until user replies.
5. `SELF-CHECK` **Generate draft** — PREREQUISITES: steps 1-4 MUST be complete. Before generating, self-check: (a) Did I read global CLAUDE.md with Read tool? (b) Did I write down user profile? (c) Did I scan the project with Glob? If any answer is NO — go back, do NOT generate. Use `templates/new-project-prompt.md`. Align language, style, and autonomy rules with user profile from step 2. Target: concise, project-specific, under 300 lines.
6. `PREREQUISITE` **Validate vs global** — Compare draft against global CLAUDE.md. Auto-correct Override conflicts BEFORE presenting to user. If Override Exception applies (language/docs/tech-stack only), include `> [!NOTE] Overrides Global: <reason>` marker and highlight for user attention. GATE: Do NOT present a draft that you know violates the global constitution.
7. `USER-GATE` **Present for batch confirmation** — Show draft with parameter checklist (tech stack, build commands, test commands, code style choices). **STOP HERE. Wait for explicit user confirmation.** Do NOT proceed to step 8 until user confirms. If user asks questions about the draft — answer, but do NOT write.
8. **Write** — Write `CLAUDE.md` to project root. Only after step 7 USER-GATE passes. If target exists, diff first then overwrite.

---

## Mode B -- Audit

**Trigger:** "review CLAUDE.md", "check project rules", "improve CLAUDE.md"

### Steps

1. `PREREQUISITE` **Read two levels** — Use Read tool to load `~/.claude/CLAUDE.md` and the project's CLAUDE.md.
2. `PREREQUISITE` **Scan project** — Same scan protocol as Mode A step 3. Use real Glob/Read tools.
3. `USER-GATE` **Missing CLAUDE.md?** — If no project-level CLAUDE.md exists, output scan findings and ask: "No project CLAUDE.md found. Switch to Create mode to generate one?" **STOP HERE. Wait for user response.**
4. **Conflict detection** — Use `templates/analyze-checklist.md`. Check Override / Duplicate / Missing across all levels.
5. **Hooks candidates** — Identify deterministic rules (format checks, file existence guards) that could move to hooks.
6. **Skills candidates** — Identify procedural rules that could move into dedicated skills.
7. **Generate improvement list** — Prioritize: Override conflicts (highest), then Duplicates, then Missing, then Hooks/Skills candidates.
8. `USER-GATE` **Confirm item by item** — Present findings. User confirms each change individually. **STOP HERE. Wait for explicit confirmation before executing.**
9. **Execute** — Apply approved changes. Do NOT modify `settings.json` silently — only output hook config to stdout.

---

## Mode C -- Global Audit

**Trigger:** "optimize global CLAUDE.md", "tidy up constitution"

### Steps

1. `PREREQUISITE` **Read global config** — Use Read tool to load `~/.claude/CLAUDE.md`.
2. **Layered audit** — Use `templates/global-audit-guide.md`. Categorize every rule: stay, delete, move to hooks, move to skill.
3. **Redundancy marking** — For each candidate deletion, state the consequence explicitly.
4. **Hooks candidate check** — Which rules are deterministic and belong in `settings.json` hooks?
5. **Skills candidate check** — Which rules are procedural workflows better suited as skills?
6. **New rule justification** — Any new global addition must meet at least one: (a) user explicitly states multiple projects need it, (b) multi-project evidence found in workspace, (c) user confirms it's a long-term cross-project preference. Default: prefer project-level or skill-level placement.
7. `USER-GATE` **Present audit report** — Single summary with all recommendations + consequences. **STOP HERE. Wait for user response.**
8. `USER-GATE` **Confirm item by item** — Deletions require individual explicit confirmation. **STOP HERE. Wait for explicit confirmation before executing.**
9. **Execute** — If global config is a symlink, output DIFF only (no physical write). Otherwise, apply confirmed changes.

---

## Scanning Limits (All Modes)

- **Hard ignore:** `node_modules/`, `dist/`, `build/`, `.git/`, `coverage/`, `target/`, `vendor/`, `.next/`, `__pycache__/`, `.tox/`
- **Max depth:** 2 levels for directory listing
- **File size cap:** >15KB files skip content read for language detection; >20KB CLAUDE.md files get truncated
- **Sampling:** >200 files per directory level triggers sampling; inform user
- **Source sampling:** max 5 key source files for code style detection
- **Large projects (>5000 files):** explicit sampling strategy notice to user
- **Partial scan failure:** warning + continue, does not block
- **Permission denied (EACCES/ELOOP):** silently skip, log warning, continue

## Safety Rules

- **Never silently modify `settings.json`** -- Hook configurations are output to stdout only. User copies them manually.
- **Never write through symlinks** -- If global config is a symlink, resolve target, output DIFF only.
- **Subtraction requires explanation** -- Any suggested deletion includes a "consequences of removal" statement.
- **Global writes: single confirm with evidence** -- Present (a) necessity justification, (b) multi-project evidence, (c) specific changes. One confirmation, not three rounds.
- **Stop on cancel** -- If user cancels mid-flow, write nothing. Discard generated content.
- **No write permission?** -- Output full content to stdout, instruct user to create manually.

## Domain Boundaries

| This Skill | Not This Skill |
|------------|---------------|
| Write/audit CLAUDE.md rules | `/init` (built-in) -- use as bootstrap, then audit with this skill |
| Output hook config to stdout | Modify `settings.json` directly |
| Suggest rules → skills migration | Create skills (use `writing-skills` skill) |
| Rule quality and correctness | Code↔docs sync (use `neat-freak` skill) |

Recommended workflow: `/init` → this skill (Mode B, audit) → refine.

## References (loaded by Tier + Mode)

| File | Contents | When |
|------|----------|------|
| `references/authoritative-sources.md` (Tier 1) | Anthropic Steering + Karpathy Guidelines | All modes — **MUST read before generating any draft** |
| `references/authoritative-sources.md` (Tier 2) | Optimus, Agent Eng Handbook, Morph LLM guide | Mode A/B — **MUST consult when generating or auditing project rules** |
| `references/authoritative-sources.md` (Tier 3) | Boris Cherny, Arize, Addy Osmani, Steve Kinney, Cursor Rules | Mode B/C — **MUST consult when auditing or optimizing** |
| `templates/new-project-prompt.md` | Mode A draft questionnaire + structure | Mode A |
| `templates/analyze-checklist.md` | Mode B conflict detection checklist | Mode B |
| `templates/global-audit-guide.md` | Mode C audit framework | Mode C |

## Anti-Patterns

**#1 FAILURE MODE: Generating without reading or scanning.** You did not run Read/Glob tools → you have no business generating a draft.

Other violations:

- Using file existence to route modes (use user intent)
- Project CLAUDE.md over 300 lines
- Repeating global rules in project CLAUDE.md
- Modifying global CLAUDE.md without user confirmation
- Deleting rules without explaining consequences
- Putting everything in SKILL.md -- use templates and references
- Glob `**/*` without ignore list and depth limit
- Serial one-by-one questioning in Mode A -- use batch confirmation
- Letting user choose on Override conflicts -- global wins by default
- Skipping a USER-GATE — always STOP and WAIT
