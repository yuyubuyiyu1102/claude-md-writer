# 输出质量修复 — 执行计划

**Date:** 2026-07-19
**Spec:** specs/2026-07-19-output-quality-fix.md

## 改动文件

```
skills/claude-md-writer/
├── templates/
│   ├── new-project-prompt.md    ← 主要改动
│   └── analyze-checklist.md     ← 追加一条
└── SKILL.md                     ← 三处补丁
```

## Phase 1: new-project-prompt.md（重写）

实现 Constraint 1 + Constraint 2 + Constraint 3。

删旧写新。旧 ~52 行，新 ~130 行。

### Section 1: Constitution Principle（Constraint 1 + 3）

模板最顶部。

- 一句话定调：CLAUDE.md = constitution, not execution plan
- 声明式 vs 过程式对照表（4 对好例坏例）
- if/when 边界表——允许适用范围条件（"Production code requires X"），禁止流程条件（"When doing X, first do Y"）
- 自检规则：每写一行问 "constraint or script?"
- 引用标注：Steve Kinney #9 + Morph LLM #5 + Optimus #3

### Section 2: Draft Structure（Constraint 1 + 3）

保留 Morph LLM 模板骨架，每节给声明式范例：

- `## Commands` — 表格式，action + invocation
- `## Code Style` — "X must Y / X uses Y / X never Z" 范例
- `## Constraints` — 每条 "must / never / prefer" 范例
- `## References` — 交叉引用不复制

### Section 3: Info Gathering Strategy（Constraint 2）

分两层：

- **Auto-Detect** — agent 自己做的事，表格列 what + how。标注 "do NOT ask user about these"
- **User-Facing Questions** — 只问偏好。spec C2 唯一画像规则：画像含"新手/初学者/beginner" → 禁止技术验证提问。不自行发明额外画像映射

明确列出违规例 + missing-data 例外（可问缺失信息，不可问已有信息确认）

### Section 4: Parameter Checklist（Constraint 2）

拆 Part 1 + Part 2：

- **Part 1: Self-Verify** — agent 自检，不展示。7 项（含 declarative check + if/when 边界检查）
- **Part 2: User-Confirm** — 3-5 个偏好问题。画像=新手时仅偏好问题，0 技术验证

## Phase 2: analyze-checklist.md（追加）

实现 Constraint 4。

Phase 1 Conflict Detection 尾部追加：

```markdown
### Execution-Plan Smell (Procedural rules in wrong place)

参照 Constraint 1 if/when 边界表判断。

- [ ] Does any rule describe a sequence of actions?
- [ ] If you remove the action sequence, is there still a constraint left?
- [ ] Does any rule match the flow-condition pattern ("When X, first A then B")?
- [ ] Tag each: `[PROCEDURAL] → Move to skill or rewrite as declarative`
```

Phase 3 Priority Ordering 追加 P4: PROCEDURAL（P5 SKILL 之前）。

## Phase 3: SKILL.md（三处补丁）

实现 Constraint 1 + Constraint 2。

### 3a. Step 5 SELF-CHECK 追加（Constraint 1）

在现有三问后加第四问：

```
(d) Is every rule declarative (not a procedural step)? Check against Constraint 1 if/when boundary table.
```

### 3b. Step 7 USER-GATE 改描述（Constraint 2）

原：
```
7. `USER-GATE` **Present for batch confirmation** — Show draft with parameter checklist (tech stack, build commands, test commands, code style choices).
```

改：
```
7. `USER-GATE` **Present for batch confirmation** — Show draft with profile-filtered parameter checklist. Technical facts come from workspace discovery (Step 3: Scan project), not from user confirmation. If profile from Step 2 says beginner: ask behavioral preferences ONLY, 0 technical questions. See template Part 2.
```

### 3c. Anti-Patterns 追加（Constraint 1）

在 `#1 FAILURE MODE` 条目之后：

```
- Writing execution plans instead of rules — CLAUDE.md is a constitution. Every rule must be declarative. "When implementing X, first do Y then Z" belongs in a skill.
```

## 不改

| 文件 | 理由 |
|------|------|
| `references/authoritative-sources.md` | 穿透是复制关键点到模板，不改原文 |
| `templates/global-audit-guide.md` | Mode C 本已操作声明式内容，未被 Mode B 引用 |
| `specs/` | 全部不动 |
| `.github/workflows/validate.yml` | 内容质量不适合 CI 自动化 |
| `README.md` | 改动不改变安装/使用方式 |

## 验证

改完后跑 CI 确认 12 个检查通过。
