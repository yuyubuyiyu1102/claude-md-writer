# Mode A -- New Project Draft Template

Use this when generating an initial CLAUDE.md draft for a project that has none.

## Constitution Principle -- Read Before Writing

CLAUDE.md is a **constitution**, not an execution plan. Every rule must be declarative: read it and immediately know whether you are following it.

**Reference:** Steve Kinney 3-Layer Decision (Tier 3 #9): "CLAUDE.md should be mostly declarative statements, not conditional logic." Morph LLM Guide (Tier 2 #5): template pattern Overview -> Commands -> Code Style -> Constraints -> References. Optimus (Tier 2 #3): "Project-specific over generic: 'use Jest with --coverage' beats 'write tests'."

### Declarative vs Procedural

| Declarative (constitutional) | Procedural (plan/script) |
|------------------------------|--------------------------|
| "Commit messages follow Conventional Commits" | "When committing, first check the diff, then write a Conventional Commits message" |
| "2-space indentation, no tabs" | "Open your editor, go to settings, set tab size to 2" |
| "New features require tests in the same PR" | "Before merging, run `npm test`, check coverage, fix failures, then push" |
| "Binary assets never committed to git" | "Download the binaries, put them in assets/, add assets/ to .gitignore" |

### if/when Boundary

| Allowed (scope condition) | Forbidden (flow condition) |
|---------------------------|---------------------------|
| "Database migrations must have a rollback plan" | "When writing a migration, first write the up, then the down" |
| "Production code requires test coverage" | "If merging to production, run tests, check coverage, then deploy" |
| "New API endpoints must include OpenAPI docs" | "When adding an API endpoint, create the handler, add the route, generate docs" |

**Distinction test:** Delete "if"/"when" prefix. Is the remainder still a complete constraint?

- Yes -> scope condition (allowed)
- No (empty operation remains) -> flow condition (forbidden)

**Self-check before writing each line:** "Constraint or script?"

- Constraint -> CLAUDE.md
- Script/workflow -> Skill
- Trigger -> Hook

**Optimus rule (Tier 2 #3):** "Avoid negative-only rules: pair each 'don't do X' with 'do Y instead'."

## Draft Structure

Use **Morph LLM template pattern**: Overview -> Commands -> Code Style -> Constraints -> References.

Each section is filled with **declarative rules**, not steps. Examples below are reference -- adapt to detected project type.

```markdown
# <Project Name>

<One-line: what this is, who it's for. Plain language, no jargon.>

## Commands

Commands name the action + invocation. No "how to" instructions.

| Action | Command |
|--------|---------|
| Build | `<cmd>` |
| Test | `<cmd>` |
| Run | `<cmd>` |
| Lint | `<cmd>` |

## Code Style

Declarative constraints. "X must Y" / "X uses Y" / "X never Z."

- 2-space indentation, no tabs (example -- replace with detected)
- Imports grouped: stdlib -> third-party -> local
- Function names: camelCase, file names: kebab-case

## Constraints

Project-specific behavioral rules. Each one is a "must" / "never" / "prefer."

- Commit messages follow Conventional Commits
- New features require tests
- Binary files excluded from git
- Breaking API changes update the changelog

## References

Cross-reference external docs rather than duplicating them (Morph LLM Guide principle).

- Design: `specs/design.md`
- API: `docs/api.md`
```

## Non-Standard Projects

When Step 3 detects Non-standard or Mixed type — use this adapter for the non-code sections.

### Commands Section

Even without build/compile step, provide verification commands agent can execute. **Adapt to OS shell detected in scan.**

| Action | Command |
|--------|---------|
| Verify structure | `<cmd to check required files exist>` — OS-aware |
| Validate config | `<cmd to lint/check config files>` — OS-aware |
| Check format | `<cmd to verify file formatting>` — OS-aware |

If absolutely no automated command applies, state: "No automated verification available. Manual checks: <list specific checks>."

**Examples — Unix (bash/sh):**

```
| Action | Command |
|--------|---------|
| Verify skill files | `for f in skills/*/SKILL.md; do echo "$f: $(wc -l < "$f") lines"; done` |
| Validate YAML | `python -c "import yaml; yaml.safe_load(open('config.yaml'))"` |
| Check structure | `ls README.md CLAUDE.md skills/ > /dev/null && echo "OK"` |
```

**Examples — Windows (PowerShell):**

```
| Action | Command |
|--------|---------|
| Verify skill files | `Get-ChildItem skills/*/SKILL.md | ForEach-Object { "$($_.Name): $((Get-Content $_.FullName | Measure-Object -Line).Lines) lines" }` |
| Validate YAML | `python -c "import yaml; yaml.safe_load(open('config.yaml'))"` |
| Check structure | `if (Test-Path README.md -and Test-Path CLAUDE.md -and Test-Path skills) { Write-Host "OK" }` |
```

**Rule:** write examples matching the OS from `uname -s` / `$env:OS` detected during Step 3 scan. If OS unclear, provide both variants or default to project's primary platform.

### Structure Adaptation by Project Type

| Project Type | Commands → | Code Style → | Constraints → |
|-------------|-----------|-------------|--------------|
| Claude Code extension / skill repo | Validation scripts for skill structure | File naming, SKILL.md frontmatter conventions | Skill boundaries, cross-skill rules, HARD GATE compliance |
| Config-only repo | Lint/validate config files | Key naming, hierarchy, format rules | Config change policies, no silent modifications |
| Docs-only repo | Link check, spell check | Heading conventions, link formats | No stale docs, review requirements |
| IaC / infra repo (Terraform, Pulumi, etc.) | `terraform validate`, `pulumi preview` | Module naming, variable conventions | Plan-before-apply, state file safety |
| CI / workflow repo | `act` dry-run, YAML schema validation | Workflow naming, trigger conventions | No secrets in logs, workflow testing before merge |
| Docker / container repo | `docker build --check`, `hadolint` | Dockerfile best practices, layer conventions | Image size limits, no secrets in layers |

Last row is catch-all: if project type doesn't fit any above, derive closest match from detection signals.

### Detection Signals (must match Change A in SKILL.md)

| Signal | Likely Type |
|--------|-------------|
| `.claude/skills/` directory present, no build config files | Claude Code extension project |
| Only `.md`, `.yaml`, `.json`, `.toml` files | Config or docs project |
| `skills/*/SKILL.md` file pattern | Skill collection |
| No `src/`, `lib/`, `app/`, `cmd/`, `pkg/` directory | Non-compiled project |
| `*.tf` / `*.tfvars` / `Pulumi.yaml` files, no `src/` | IaC project |
| `.github/workflows/*.yml` as primary content | CI / workflow project |
| `Dockerfile` + no package manager config | Docker / container project |

## Info Gathering Strategy

### Auto-Detect (skill verifies -- do NOT ask user about these)

| What | How |
|------|-----|
| Tech stack | Scan config files: `package.json`, `go.mod`, `Cargo.toml`, etc. |
| Build/Test/Run commands | Extract from scripts field, CI configs, Makefile, justfile |
| Language/Framework | Detect from file extensions + config |
| Code style | Sample <=5 source files, prioritize `src/`, main entry |
| Project type | Library? CLI? App? Service? -- detect from entry points |

### User-Facing Questions (preferences only -- filtered by profile)

**CRITICAL:** Questions MUST match user profile from Step 2. The skill's job is to verify technical facts. The user's job is to state preferences.

**Only profile rule:** If profile from Step 2 says "编程新手"/"beginner"/"new to coding" -> ask behavioral preferences ONLY, 0 technical questions. Do NOT invent additional profile mappings.

| Profile signal | Ask |
|----------------|-----|
| "编程新手"/"beginner"/"new to coding" | Behavioral preferences ONLY. Skip ALL technical verification. |
| "简洁"/"caveman" | Confirm style alignment. Keep questions minimal. |
| Expert/experienced | Confirm auto-detected values + ask preferences. |
| No signal | Default: behavioral preferences + brief tech confirm. |

**Violation examples (never ask):**

- "技术栈正确吗？" -- YOUR job to verify from scan
- "构建命令对吗？" -- YOUR job to extract
- "这个设计决策对吗？" -- YOUR job to reason about

**Missing-data exception -- allowed vs forbidden:**

| Allowed (filling missing info) | Forbidden (offloading verification) |
|-------------------------------|-------------------------------------|
| "当前目录没有检测到项目文件，你希望使用什么技术栈？" | "技术栈正确吗？" |
| "我没有找到构建配置，你的构建命令是什么？" | "构建命令对吗？" |
| "你的测试框架是 Jest 还是 Vitest？" | "设计决策对吗？" |

**Beginner-appropriate questions instead:**

- "这个项目有什么你特别在意/想避免的行为？"
- "你对代码风格有偏好吗？"
- "有什么额外约束想加？"

If you genuinely couldn't verify something from the scan, say so explicitly: "我无法从代码中确认 X，你能帮我补充吗？" -- but only as last resort.

## Parameter Checklist (present with draft)

### Part 1: Self-Verify (do NOT ask user -- check internally)

Before presenting draft to user:

- [ ] Tech stack from scan matches draft?
- [ ] Commands extracted from project files are correct?
- [ ] Every rule is declarative ("X must Y") -- no procedural steps?
- [ ] Every if/when clause is a scope condition, not a flow condition? (See if/when boundary table above)
- [ ] No duplicate of global CLAUDE.md rules?
- [ ] Global CLAUDE.md preferences respected in draft?
- [ ] Under 300 lines?

### Part 2: User-Confirm (ask user -- filter by profile)

Pick 3-5 questions max. Each question targets a **preference**, not technical verification.

If the answer is obvious from the scan or user profile -> don't ask. Confirm and move on.

If profile from Step 2 says beginner: ask behavioral preferences ONLY, 0 technical questions.

**Questions (pick relevant ones based on profile):**

- 风格偏好？简洁还是详细？
- 有什么你最在意/想强调的行为规范？
- 有什么你想禁止的？（比如"不要格式化我的代码"）
- 还想加什么额外约束？

## Notes

- Keep under 300 lines total
- Do NOT repeat rules already in `~/.claude/CLAUDE.md`
- Align language and style with user profile from Step 2
- If Override Exception applies, include `> [!NOTE] Overrides Global: <reason>` marker
- **Every rule must be declarative.** If you wrote "first... then...", rewrite it
- **Karpathy Guidelines (Tier 1 #2)** are the baseline behavioral contract -- do NOT duplicate them in every project unless the project needs specific Karpathy scope adjustments
