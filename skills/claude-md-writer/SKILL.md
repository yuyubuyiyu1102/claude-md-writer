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
3. `PREREQUISITE` **Scan project** — Glob depth=2, ignore: `node_modules/`, `dist/`, `build/`, `.git/`, `coverage/`, `target/`, `vendor/`, `.next/`, `__pycache__/`, `.tox/`. Detect: directory structure, language/framework (package.json, go.mod, Cargo.toml, etc.), build tools (Makefile, justfile, CI configs), test conventions (file patterns, top 2 levels only), code style (sample up to 5 key source files, prefer src/, main entry, package entry), OS: check `uname -s` / `$env:OS` for shell syntax selection. Use real Glob/Read tool calls — do not guess.

   After scan, also detect OS for command syntax: `uname -s` (Unix/Linux/macOS) or `$env:OS` (Windows). Note result for Commands section formatting.

   Classify project type by detection signals:

   | Type | Signals | Template |
   |------|---------|----------|
   | **Standard** | package.json / go.mod / Cargo.toml / pyproject.toml / Makefile present; `src/` or `lib/` or `app/` directory exists | standard template as-is |
   | **Non-standard** | No build system config; no `src/`/`lib/`/`app/` directory; `.claude/skills/` present OR only `.md`/`.yaml`/`.json`/`.toml` files OR `skills/*/SKILL.md` pattern OR no compiled sources | Non-Standard Projects adapter (see template) |
   | **Mixed** | Both build config AND `.claude/skills/` or skill/config directories present | Use standard template for code sections + Non-Standard adapter for skill/config sections. Merge: commands from both, style from both, constraints unified |

   Detection signals — collect ALL signals first, then apply classification table. Order = signal reliability (strongest first), NOT a stop-at-first-match rule:
   1. `.claude/skills/` directory → Claude Code extension / skill collection
   2. Only `.md`, `.yaml`, `.json`, `.toml` files → config or docs project
   3. `skills/*/SKILL.md` pattern → skill collection
   4. No `src/`, `lib/`, `app/`, `cmd/`, `pkg/` directory → non-compiled project
   5. Build config file present + source directory exists → standard project
4. `USER-GATE` **Mature project check** — If project has many existing files, ask user: "Detected a mature project. Create new CLAUDE.md?" **STOP HERE.** Wait for user response.
   `SELF-CHECK` (before proceeding to Step 5): (a) Did I present the question? If NO → present it now and wait. (b) Did user explicitly reply with "yes"/"create"/"proceed"? If YES → gate passed. If user replied with something else → clarify and re-ask. If no reply yet → WAIT, do NOT re-ask (re-asking spams the user).
   Do NOT proceed to step 5 until user replies.
5. `SELF-CHECK` **Generate draft** — PREREQUISITES: steps 1-4 MUST be complete. Before generating, self-check: (a) Did I read global CLAUDE.md with Read tool? (b) Did I write down user profile? (c) Did I scan the project with Glob? (d) Is every rule declarative (not a procedural step)? Check against Constraint 1 if/when boundary table. If any answer is NO — go back, do NOT generate. Use `templates/new-project-prompt.md`.
   - If Standard → use standard template as-is.
   - If Non-standard → use template "Non-Standard Projects" adapter section. Commands section MUST provide verification commands even if no build system exists — see template for formats.
   - If Mixed → apply both: standard template for code sections + Non-Standard adapter for skill/config sections.
   Align language, style, and autonomy rules with user profile from step 2. Target: concise, project-specific, under 300 lines.
6. `PREREQUISITE` **Validate vs global** — Compare draft against global CLAUDE.md. MUST produce explicit mapping before presenting to user:
   1. List every global rule as a row in status table:
      | Global Rule | Status | Action |
      |------------|--------|--------|
      | `<rule text>` | Inherited / Overridden / Duplicated / Missing / N/A | Keep / Add Override marker / Remove / Flag-or-Fill / — |
   2. Status definitions:
      - Inherited: project follows global rule without modification → Keep
      - Overridden: project needs different behavior → MUST have `> [!NOTE] Overrides Global: <reason>` marker. Verify present.
      - Duplicated: project repeats global verbatim → suggest removal
      - Missing: global requires project-level declaration (commands, tech stack) and project is silent → Flag in report, or Fill from scan data
      - N/A: rule does not apply to this project type → skip
   3. If Override marker missing → add BEFORE presenting draft.
   4. GATE: Do NOT present a draft with unmapped global rules or unmarked overrides.
7. `USER-GATE` **Present for batch confirmation** — Show draft. MUST output ALL below in the message body:
   - **Part 1 — Self-verify results** (completed checklist from template, all 7 items ticked or flagged). Do NOT skip this section.
   - **Part 2 — User questions** (filtered by profile from Step 2)
   - **Draft** (the generated CLAUDE.md content)
   If Part 1 or Part 2 is missing → GATE NOT PASSED, re-output with all required sections.
   `SELF-CHECK` (before presenting): Count sections — are Part 1, Part 2, and Draft all present? If any missing → GATE NOT PASSED.
   Technical facts come from workspace discovery (Step 3), not user confirmation. Beginner profile → behavioral questions ONLY, 0 technical. **STOP HERE. Wait for explicit user confirmation.** Do NOT proceed to step 8 until user confirms. If user asks questions about the draft — answer, but do NOT write.
8. **Write** — Write `CLAUDE.md` to project root. Only after step 7 USER-GATE passes. If target exists, diff first then overwrite.

---

## Mode B -- Audit

**Trigger:** "review CLAUDE.md", "check project rules", "improve CLAUDE.md"

### Steps

1. `PREREQUISITE` **Read two levels** — Use Read tool to load `~/.claude/CLAUDE.md` and the project's CLAUDE.md.
2. `PREREQUISITE` **Scan project** — Same scan protocol as Mode A step 3. Use real Glob/Read tools.
3. `USER-GATE` **Missing CLAUDE.md?** — If no project-level CLAUDE.md exists, output scan findings and ask: "No project CLAUDE.md found. Switch to Create mode to generate one?" **STOP HERE. Wait for user response.**
4. **Conflict detection** — Use `templates/analyze-checklist.md`. Check Override / Duplicate / Missing across all levels.
5. `PREREQUISITE` **Hooks candidates** — from `templates/analyze-checklist.md` Phase 2 → Hooks checklist. Identify deterministic rules (format checks, file existence guards, event-triggered checks). MUST output EACH candidate in format: `[HOOK] "<rule text>" → <hook event> | <matcher>`. If zero candidates found, MUST output: "No hooks candidates identified — no deterministic/event-triggered rules found in project CLAUDE.md."
   Silent skip (proceeding to Step 6 without either candidates or explicit "none found" statement) = Mode B violation.
   GATE: Do NOT proceed to Step 6 without this output.
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
| Detect non-CLAUDE.md doc requirements referenced in project baselines (README, CONTRIBUTING.md, 开发流程.txt, SDLC docs that name files like CONSTITUTION.md, GOVERNANCE.md, etc.) | Generate those docs — report detection, warn user, suggest manual creation or relevant skill |

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

- Writing execution plans instead of rules -- CLAUDE.md is a constitution. Every rule must be declarative. "When implementing X, first do Y then Z" belongs in a skill.

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
- USER-GATE without checklist output — presenting a draft without Part 1 + Part 2 checklist in the message = gate not honored, add both sections and re-present
- Skipping project type classification — Step 3 must classify as Standard, Non-standard, or Mixed before template selection
- Silent hooks candidates in Mode B — Step 5 must output hook config or explicit "none found" statement
- Mixed project treated as Standard-only — when both build config and skill/config dirs present, must merge templates; do not drop Non-Standard adapter
