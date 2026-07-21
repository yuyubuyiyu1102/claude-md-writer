# 门禁加固 + 非标准项目适配 — 执行计划

**Date:** 2026-07-20
**Ref:** 8 个问题分析（用户反馈）+ 15 条审核反馈
**Scope:** SKILL.md + 2 个 template，不改 spec、不改 references、不改架构

## ⚠️ 实施前必读

**行号基于当前文件快照。** 改动的执行顺序会影响行号（前序改动插入行会令后续目标偏移）。实施时必须以**内容锚点**（步骤标题、关键文本）定位目标行，禁止盲按行号。

## 改动文件

```
skills/claude-md-writer/
├── SKILL.md                          ← 8 处增补
├── templates/
│   ├── new-project-prompt.md         ← 1 处新增（非标准项目段）
│   └── analyze-checklist.md          ← 2 处增补（hooks 输出 + Skill 清单提醒）
```

## 改动清单

### A. SKILL.md Step 3 — 加项目类型检测（修 #7）

**位置:** Step 3 末尾（当前第 77 行），扫描描述段落之后

**改动:** 在现有扫描维度后追加 OS 检测 + 项目类型分类：

```markdown
   After scan, also detect OS for command syntax: `uname -s` (Unix/Linux/macOS) or `$env:OS` (Windows). Note result for Commands section formatting.

   Classify project type by detection signals:
```

**同时更新 Step 3 原文**——在现有扫描描述末尾追加一行：`- OS: check uname -s / $env:OS for shell syntax selection`

```markdown
   After scan, classify project type by detection signals:

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
```

**验证:** agent 在三类项目中都能正确路由到模板

**审核响应 #3 #8 #14:** 补了 `.toml`、加了 Mixed 分类、补了 IaC/CI/Docker 项目的 fallback（Non-standard 兜底）

---

### B. SKILL.md Step 4 — USER-GATE 后加自检（修 #1）

**位置:** Step 4 段落（当前第 78 行）

**改动:** USER-GATE 后追加 SELF-CHECK：

```markdown
4. `USER-GATE` **Mature project check** — If project has many existing files, ask user: "Detected a mature project. Create new CLAUDE.md?" **STOP HERE.** Wait for user response.
   `SELF-CHECK` (before proceeding to Step 5): (a) Did I present the question? If NO → present it now and wait. (b) Did user explicitly reply with "yes"/"create"/"proceed"? If YES → gate passed. If user replied with something else → clarify and re-ask. If no reply yet → WAIT, do NOT re-ask (re-asking spams the user).
   Do NOT proceed to step 5 until user replies.
```

**验证:** agent 不会再自说自话跳过 USER-GATE

**审核响应 #5:** SELF-CHECK 时机从 `(after user replies)` 改为 `(before proceeding to Step 5)`，检查逻辑改为「看到回复=通过，看不到=重问」

---

### C. SKILL.md Step 5 — 引用非标准/混合项目分支（修 #4, #7）

**位置:** Step 5 段落（当前第 79 行），`Use templates/new-project-prompt.md` 之后

**改动:** 追加：

```markdown
   - If Standard → use standard template as-is.
   - If Non-standard → use template "Non-Standard Projects" adapter section. Commands section MUST provide verification commands even if no build system exists — see template for formats.
   - If Mixed → apply both: standard template for code sections + Non-Standard adapter for skill/config sections.
```

**验证:** 非标准/混合项目 Commands 段不再空置

---

### D. SKILL.md Step 6 — 显式规则映射清单（修 #2）

**位置:** Step 6 段落（当前第 80 行），**替换**现有文本

**改动:**

```markdown
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
```

**验证:** agent 逐条比对全局规则，不会漏 Override 标记

**审核响应 #4 #10:** Action 列补了 `Flag-or-Fill`（对应 Missing 状态）；影响面评估升级——这是行为模式变更，输出从自动修正变为逐条审计报告

---

### E. SKILL.md Step 7 — 参数清单强制输出（修 #3）

**位置:** Step 7 段落（当前第 81 行）

**改动:** 插入强制输出约束：

```markdown
7. `USER-GATE` **Present for batch confirmation** — Show draft. MUST output ALL below in the message body:
   - **Part 1 — Self-verify results** (completed checklist from template, all 7 items ticked or flagged). Do NOT skip this section.
   - **Part 2 — User questions** (filtered by profile from Step 2)
   - **Draft** (the generated CLAUDE.md content)
   If Part 1 or Part 2 is missing → GATE NOT PASSED, re-output with all required sections.
   `SELF-CHECK` (before presenting): Count sections — are Part 1, Part 2, and Draft all present? If any missing → GATE NOT PASSED.
   Technical facts come from workspace discovery (Step 3), not user confirmation. Beginner profile → behavioral questions ONLY, 0 technical. **STOP HERE. Wait for explicit user confirmation.** Do NOT proceed to step 8 until user confirms. If user asks questions about the draft — answer, but do NOT write.
```

**验证:** 用户收到的确认消息必定包含 Part 1 + Part 2 + Draft

---

### F. SKILL.md Mode B Step 5 — hooks 输出强制执行（修 #8）

**位置:** Mode B Step 5（当前第 96 行），替换现有文本

**改动:** 从无 gate 标记升级为 PREREQUISITE + 格式 + 零结果也必须输出：

```markdown
5. `PREREQUISITE` **Hooks candidates** — from `templates/analyze-checklist.md` Phase 2 → Hooks checklist. Identify deterministic rules (format checks, file existence guards, event-triggered checks). MUST output EACH candidate in format: `[HOOK] "<rule text>" → <hook event> | <matcher>`. If zero candidates found, MUST output: "No hooks candidates identified — no deterministic/event-triggered rules found in project CLAUDE.md."
   Silent skip (proceeding to Step 6 without either candidates or explicit "none found" statement) = Mode B violation.
   GATE: Do NOT proceed to Step 6 without this output.
```

**验证:** agent 必须在输出中体现 hooks 分析结果

---

### G. SKILL.md Anti-Patterns — 追加四条（防复发）

**位置:** Anti-Patterns 列表末尾（当前第 181 行后）

**改动:**

```markdown
- USER-GATE without checklist output — presenting a draft without Part 1 + Part 2 checklist in the message = gate not honored, add both sections and re-present
- Skipping project type classification — Step 3 must classify as Standard, Non-standard, or Mixed before template selection
- Silent hooks candidates in Mode B — Step 5 must output hook config or explicit "none found" statement
- Mixed project treated as Standard-only — when both build config and skill/config dirs present, must merge templates; do not drop Non-Standard adapter
```

**验证:** 新增反模式与补丁一一对应

---

### H. SKILL.md Domain Boundaries — CONSTITUTION.md 边界提示（修 #5）

**位置:** Domain Boundaries 表格末尾（当前第 144 行后）

**改动:** 加一行：

```markdown
| Detect non-CLAUDE.md doc requirements referenced in project baselines (README, CONTRIBUTING.md, 开发流程.txt, SDLC docs that name files like CONSTITUTION.md, GOVERNANCE.md, etc.) | Generate those docs — report detection, warn user, suggest manual creation or relevant skill |
```

**验证:** 碰到项目基线引用额外文档时，agent 有明确检测信号（README/CONTRIBUTING/开发流程 中出现的文件名引用）

**审核响应 #6:** 补充了检测触发条件：README、CONTRIBUTING.md、开发流程.txt、SDLC 文档中引用其他文件名时触发

---

### I. new-project-prompt.md — 新增「非标准项目」适配段（修 #7, #4）

**位置:** 第 86 行后（`## Info Gathering Strategy` 之前）

**改动:** 新增整段 ~50 行：

```markdown
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
```

**验证:** 非标准项目 CLAUDE.md 的 Commands 段有 OS 对应的可执行命令

**审核响应 #7:** 加了 Windows/PowerShell 完整示例，加了「根据 scan 检测到的 OS 选择示例」规则
**审核响应 #14:** 补了 IaC、CI/Workflow、Docker 三种遗漏类型

---

### J. analyze-checklist.md — hooks 输出强制（修 #8）

**位置:** Phase 2 → Hooks checklist，Output format 行之后（当前第 43 行后）

**改动:** 追加一条强制输出项：

```markdown
- [ ] OUTPUT MANDATORY: every Phase 2 → Hooks run must produce text. Even if zero candidates: "No hooks candidates identified — no deterministic/event-triggered rules found." Silent skip (checklist ticked but no text output) = Mode B violation, step incomplete.
```

**验证:** agent 执行 hooks 检查时必须输出文字结果

---

### K. analyze-checklist.md — Skill 清单功能描述提醒（修 #6）

**位置:** Phase 1 末尾（Duplicate Rules 段落后，Execution-Plan Smell 段落前）

**改动:** 追加一条软提醒（不强制，仅提示）：

```markdown
### Skill Reference Quality (advisory)

Not a blocking check. If project CLAUDE.md lists skill files without describing what each does or when to trigger:

- [ ] (advisory) Skill list entries have purpose description? Compare: `skills/foo/SKILL.md` (insufficient) vs `skills/foo/SKILL.md — 生成 7 维 spec，用户提需求时触发` (usable)
- Suggested format: `| Skill | 用途 | 触发场景 |`
- If missing → report as `[ADVISORY] Skill list lacks descriptions — agent may not know when to invoke`
```

**验证:** Mode B 审计时 agent 会检查 skill 清单质量并给出建议

**审核响应 #9:** 之前"可在 checklist 加提醒但不强制"未落地，现在通过改动 K 闭环

---

## 影响面

| 文件 | 改动行数 | 风险 | 备注 |
|------|---------|------|------|
| SKILL.md | +55 行（8 处增补） | 中 | Step 6 行为模式变更：从自动修正→逐条审计报告 |
| new-project-prompt.md | +55 行（1 段新增） | 低 | 纯追加，不影响现有标准模板逻辑 |
| analyze-checklist.md | +10 行（2 项追加） | 极低 | K 为 advisory，不阻塞 |

- 不改 Mode C
- 不改 references
- 不改 specs
- 不改 CI
- **Token 影响:** Change D（Step 6 规则映射表）+ Change E（强制 Part 1+2+3）会使 Mode A 确认消息膨胀。全局 CLAUDE.md 有 N 条规则 → D 输出 N 行映射表。用户全局配置通常 <20 条规则，可接受。若 >30 条，agent 已有 `>20KB 截断` 保护（Scanning Limits）。

## 逻辑流（非实现依赖——各改动可并行实施）

```
A (项目类型) ──→ C (分支引用) ──→ I (非标模板)
B (Step 4 自检)     平行      E (Step 7 清单强制)
F (hooks 强制)     平行      J (hooks checklist)
D (规则映射)    独立
G (反模式)     独立     H (边界)    独立     K (skill 提醒)    独立
```

A→C→I 是唯一逻辑链（类型检测驱动模板选择），其余改动独立、无顺序依赖。B/E 和 F/J 是两对平行加固，彼此不依赖。

## 不上车的

| # | 问题 | 原因 |
|---|------|------|
| #5 | CONSTITUTION.md 生成 | 已通过改动 H 处理（Domain Boundaries 声明 + 检测信号），不强制生成——越 skill 边界 |
| #6 | Skill 清单无功能描述 | 已通过改动 K 处理（analyze-checklist advisory 提醒），不升级为强制检查——属内容质量，非结构缺陷 |

## 变更追溯

| 问题 | 修于改动 | 严重度 |
|------|---------|--------|
| #1 USER-GATE 可能被跳过 | B + G | 中 |
| #2 无 Override 标记 | D | 高 |
| #3 未展示参数清单 | E | 中 |
| #4 命令部分不满足模板 | C + I | 中 |
| #5 CONSTITUTION.md 缺失 | H | 高 |
| #6 Skill 清单无描述 | K | 低 |
| #7 模板与项目类型不匹配 | A + C + I | 高 |
| #8 未输出 hooks candidates | F + J + G | 低 |
