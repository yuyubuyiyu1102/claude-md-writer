# CLAUDE.md Writer — 输出质量修复 Spec

**Date:** 2026-07-19
**Status:** Design Approved
**Author:** yuyu

## Problem Statement

两轮测试发现两个输出质量问题：

### P1: 产出像执行方案，不像宪法

Mode A 生成的 CLAUDE.md 包含过程式步骤（"先做 A → 再检查 B"），而非声明式规则（"X 禁止 / Y 必须 / Z 偏好"）。根因不是 agent 笨，是模板只给了空壳标题，没有教它声明式写作的格式约束。

### P2: 参数清单向新手提问技术细节

用户画像标记"编程新手"时，确认环节仍然问"技术栈正确吗？""构建命令对吗？"——这是 agent 把自己的验证责任推给了一个无法回答的用户。

## Amendment: 新增约束

以下约束在原 spec 基础上增量追加。除非显式覆盖，原 spec 所有规则继续有效。

## Constraint 1: 声明式输出（constitution-style output）

CLAUDE.md 是规则集，不是执行计划。

**判断标准**：每条规则读完后，人可以立即判断"我在遵守它吗？"

```
✅ 声明式（constitutional）     ❌ 过程式（procedural）
"Commit messages follow CC"     "When committing, first check diff, then write CC message"
"2-space indent, no tabs"       "Open editor → settings → set tab size to 2"
"New features require tests"    "Before merge: npm test, check coverage, fix, push"
```

**格式约束**：

- 每条规则是陈述句：主语 + modal（必须/禁止/偏好）+ 谓语
- 不允许步骤链（"first A, then B, finally C"）
- 不允许**流程条件句**——描述"在 X 情况下，先做 A 再做 B"的条件分支（引用 Steve Kinney #9: "If a CLAUDE.md rule starts with 'when...' or 'if...', it's probably a hook or skill"）

**if/when 边界**：

| ✅ 允许（适用范围条件） | ❌ 禁止（流程条件） |
|------------------------|---------------------|
| "Database migrations must have a rollback plan" | "When writing a migration, first write the up, then the down" |
| "Production code requires test coverage" | "If merging to production, run tests, check coverage, then deploy" |
| "New API endpoints must include OpenAPI docs" | "When adding an API endpoint, create the handler, add the route, generate docs" |

区分标准：规则删掉"if/when"前缀后是否仍然是完整约束？
- 是 → 适用范围条件 ✅
- 否（删掉后变成空操作）→ 流程条件 ❌

**适用范围**：Mode A 生成 + Mode B 审计。Mode C 本已操作声明式，不受影响。

## Constraint 2: 画像感知的参数确认（profile-filtered confirmation）

生成后的用户确认环节，提问必须符合用户画像。

**分层原则**：

- **技术事实**（栈、命令、结构、设计决策）→ skill 自行扫描验证，不问用户
- **偏好**（风格、约束、行为倾向）→ 可以问用户
- **画像 = 新手/初学者/beginner** → 完全禁止技术验证提问

**判断标准**：是否可通过扫描代码库/系统环境得出客观事实结论？

- 是 → 技术事实，不该问
- 否 → 偏好，可以问

**Missing-data exception**：当信息无法从当前工作区自动检测时（空目录、无配置文件、扫描失败），可向用户**补充缺失上下文**，而非验证已知信息。

| ✅ 允许（补充缺失信息） | ❌ 禁止（推卸验证责任） |
|------------------------|------------------------|
| "当前目录没有检测到项目文件，你希望使用什么技术栈？" | "技术栈正确吗？" |
| "我没有找到构建配置，你的构建命令是什么？" | "构建命令对吗？" |
| "你的测试框架是 Jest 还是 Vitest？" | "设计决策对吗？" |

**违规例**（永远不该问）：

- "技术栈正确吗？"
- "构建命令对吗？"
- "设计决策对吗？"

## Constraint 3: 权威来源穿透（source penetration）

权威来源中的关键指导原则必须直接嵌入模板，而非仅在 references/ 文件中引用。

**背景**：SKILL.md 和 templates/ 之间通过一句话 "Use `templates/new-project-prompt.md`" 连接。agent 打开模板后，只能看到模板本身的内容，不会去翻 references/ 查指导。因此模板内必须自包含关键的写作原则。

**穿透规则**：

- 模板顶部可见声明式 vs 过程式的对照表（来源：Steve Kinney #9, Morph LLM #5, Optimus #3）
- 模板的 Draft Structure 每节给出声明式范例，而非空壳占位符
- 引用出处标注在范例旁边（agent 知道这不是凭空编的）

**不影响**：references/ 文件内容保持不变。穿透 = 复制关键 3-5 条到模板，不是移动。

## Constraint 4: 审计覆盖过程式规则（procedural rule detection）

Mode B 审计必须能检测出过程式规则。

**在原 Conflict Policy 三种类型（Override / Duplicate / Missing）之外追加第四类**：

| Type | Definition | Action |
| ---- | ---------- | ------ |
| **Procedural** | Rule is a flow condition (Constraint 1 ❌ column) or describes a sequence of actions instead of stating a constraint | Suggest rewriting as declarative rule OR moving to skill |

Procedural 检测参照 Constraint 1 的 if/when 边界表。适用范围条件（"Production code requires X"）≠ Procedural。流程条件（"When deploying, first do A then B"）= Procedural。额外检测信号：规则是否描述了动作序列？删除该序列后是否还有约束剩余？

## Interaction Flow Changes

仅 Mode A 和 Mode B 受影响：

```
Mode A (Create):
  Step 5 GENERATE:
    + 生成前自检：每条规则是声明式？（Constraint 1）
    + 使用模板时：模板已内置宪法写作原则和范例（Constraint 3）
  
  Step 7 CONFIRM:
    + 技术事实已自行验证，不展示给用户（Constraint 2）
    + 向用户展示的确认清单按画像过滤（Constraint 2）
    + 画像=新手 → 清单只有偏好问题，0 个技术验证（Constraint 2）

Mode B (Audit):
  Phase 1 CONFLICT DETECTION:
    + 在原三种类型外，检测 Procedural 型规则（Constraint 4）
```

## Design Decisions

1. **模板自包含原则**——模板必须独立可读，不依赖 agent 主动查 references。这不是对 agent 的不信任，是对 LLM 注意力机制的现实考虑：读模板时不会自动关联 references/ 里的 Steve Kinney 第 5 条。
2. **新手保护 0 容忍**——画像含"新手"标记时，技术验证提问不是"减少"而是"禁止"。因为一次技术提问 = 暴露 agent 对扫描结果没信心 = 把责任推给无法负责的人。
3. **不改原 spec**——原 spec 是项目设计 baseline，保持不动。本 spec 是 amendment，若与原 spec 冲突，以本 spec 为准（仅在 Constraint 1-4 范围内）。
4. **Spec 与执行计划分离**——本 spec 只定义约束和能力。具体改动文件、行数、顺序见执行计划文档。

## Self-Review Checklist

- [x] No TBD/TODO placeholders
- [x] 与原 spec 无冲突（增量追加，不覆盖）
- [x] 每条约束有明确的判断标准
- [x] 约束可验证（生成后可以逐条检查是否满足）
- [x] Scope 不溢出（不改 CI、不改 settings.json、不碰原 spec）
- [x] 不含执行细节（文件路径、改动行数不在此文档）
