# CLAUDE.md Writer Skill — Design Spec

**Date:** 2026-07-19
**Status:** Design Approved, Ready for Implementation
**Author:** yuyu

## Overview

智能 CLAUDE.md 编写 skill，覆盖三种场景：创建新 CLAUDE.md、审计优化已有 CLAUDE.md、全局宪法维护。核心是**用户意图驱动路由**——不以文件是否存在判断模式，而是解析用户的触发词和意图，然后按模式执行不同的扫描/交互策略。

## Core Capabilities

### 1. 两级 / 三级宪法读取（必选）

- 执行前读取 `~/.claude/CLAUDE.md`（全局），然后扫描项目树查找 CLAUDE.md
- Monorepo 场景按**三级继承**检测：`Global > Root CLAUDE.md > Subproject CLAUDE.md`，子项目规则不可推翻根项目规则，根项目规则不可推翻全局规则
- 检测三类问题：**冲突**（项目违反全局约束）、**重复**（全局已有项目又写一遍）、**越权**（项目规则试图覆盖全局偏好）
- 冲突分级处理：
  - **Override（覆盖型）**：项目规则试图否定/架空全局规则 → **默认拦截**，skill 报告并建议删除项目规则、改写为兼容形式、或移入 skill。**例外逃逸**：当项目客观属性导致无法遵守全局规则（如纯英文开源仓库 vs 全局中文偏好），允许用户使用显式特权标记 `> [!NOTE] Overrides Global: <理由>` 声明局部例外。**例外仅限**语言、文档规范、技术栈等项目上下文规则——**不得**用于覆盖安全规则或行为约束（如"先讨论后实施"）。skill 检测到该标记后放行但高亮警告
  - **Duplicate（重复型）**：全局已有相同规则 → 建议从项目级删除
  - **Missing（缺失型）**：全局约束**要求项目级显式声明**（如构建命令、测试命令、技术栈）且项目未体现 → 建议补充。不要求项目重复声明通用行为规则（如"先讨论后实施"、"回答用中文"）
- 禁止静默覆盖。Override 默认拦截，仅在显式特权标记 + 理由充分时放行

### 2. 项目扫描（必选）

使用工具链分析项目，**硬性忽略目录**：`node_modules/`, `dist/`, `build/`, `.git/`, `coverage/`, `target/`, `vendor/`, `.next/`, `__pycache__/`, `.tox/`

| 扫描维度 | 工具 | 产出 | 限制 |
|----------|------|------|------|
| 目录结构 | Glob（限制深度 2） | 判断 monorepo/单体、子项目位置 | 单层文件 > 200 个时抽样 |
| 语言/框架 | Glob 检测 `package.json`/`go.mod`/`Cargo.toml` 等 | 技术栈清单 | 文件 > 15KB 跳过内容读取 |
| 构建工具 | Glob 检测 `Makefile`/`justfile`/CI 配置 | 命令列表 | — |
| 测试框架 | Glob 检测 `*.test.*`/`*_test.*`/`__tests__/` | 测试约定 | 仅检测前 2 层 |
| 现有 CLAUDE.md | Read 两级文件 | 冲突检测 + 用户画像 | 文件 > 20KB 截断 |
| 代码风格 | 抽样读取 ≤5 个关键源文件 | 命名约定、缩进风格 | 优先 `src/`、main entry、package entry；如 metadata 可用则选最近修改的 |

### 3. 用户画像匹配（必选）

从全局 CLAUDE.md 提取四个维度，生成规则时自动对齐：
- **语言**：中文界面 vs 英文
- **风格**：caveman mode、详细 vs 简洁
- **自主权限**：两阶段模式（讨论/实施）、行动授权规则
- **约束**：不讨论法律风险、诚实回答等硬性规则

只提取显式声明的内容，不做推测性画像。

### 4. 权威参考知识库（必选）

10 个来源分三层管理，按模式按需加载：

**Tier 1 — 官方规范（所有模式可用）**
| # | 来源 | 引用场景 |
|---|------|----------|
| 1 | Anthropic "Steering Claude Code" | 分层决策：什么放 CLAUDE.md / skills / hooks |
| 8 | Karpathy Guidelines | 四个核心行为准则（已有，作为 baseline） |

**Tier 2 — 最佳实践（模式 A/B 加载）**
| # | 来源 | 引用场景 |
|---|------|----------|
| 4 | Optimus Claude 最佳实践 | WHAT/WHY/HOW 框架、60 行理想 / 300 行上限 |
| 5 | Agent Engineering Handbook | Rules vs Skills 决策、优先级分层 |
| 7 | Morph LLM CLAUDE.md 指南 | 模板、加载顺序 |

**Tier 3 — 社区经验（模式 B/C 加载）**
| # | 来源 | 引用场景 |
|---|------|----------|
| 2 | Boris Cherny 13 条技巧 | 团队协作、出错即加规则、验证闭环 |
| 3 | Arize Prompt Learning 方法论 | 规则优化七步循环 |
| 6 | Addy Osmani Agent Skills | spec-first、原子提交、验证即证据 |
| 9 | Steve Kinney 三层决策 | Skills / Rules / Hooks 分工 |
| 10 | Cursor Rules 社区实践 | `.mdc` 格式、alwaysApply 策略 |

`references/authoritative-sources.md` 中每个来源提取 3-5 条结构化要点，非原文。按模式路由加载对应 Tier，不同来源冲突时高 Tier 优先。

### 5. 三模式路由（必选）

**核心原则：用户意图驱动路由，不依赖文件是否存在。**

```
┌──────────────────────────────────────────────────┐
│                  Skill 入口点                      │
│  解析用户输入 → 提取意图 → 路由模式                │
└──────────────────────┬───────────────────────────┘
                       │
         ┌─────────────┼─────────────┐
         ▼             ▼             ▼
   「创建/初始化/    「优化/改进/    「优化宪法/
    帮我写」         审查/检查」     整理全局」
         │             │             │
         ▼             ▼             ▼
    ┌─────────┐   ┌─────────┐   ┌─────────┐
    │ 模式 A   │   │ 模式 B   │   │ 模式 C   │
    │ Create  │   │ Audit   │   │ Global   │
    └────┬────┘   └────┬────┘   └────┬────┘
         │             │             │
         ▼             ▼             ▼
  1. 读取全局宪法   1. 读取两级宪法  1. 读取全局宪法
  2. 提取用户画像   2. 扫描项目      2. 分层审计
  3. 扫描项目       3. 冲突/重复/    3. 标记冗余规则
  4. 如检测到项目      缺失检测        （注明删除后果）
     已有大量文件    4. 检测可下沉    4. 检测可下沉 hooks
     → 提示并确认     的 hooks       5. 检测可移出 skills
     是否继续       5. 检测可移出    6. 展示审计报告
  5. 生成初版草稿     的 skills      7. 逐条用户确认
     （尽量遵守     6. 生成改进建议     → 执行
     全局约束）       清单
  6. Validate(草稿  7. 逐条用户确认
     vs 全局宪法)     → 执行
     → 自动修正
     Override 冲突
     → 高亮说明
  7. 附带待确认
     参数列表
  8. 用户批量确认
  9. 写入

意图模糊时（如「看看现在的规则」）：
  → 默认走模式 B，分析报告中附加模式 C 触发提示
```

### 6. 全局宪法维护模式（必选）

触发词：「优化宪法」「整理全局 CLAUDE.md」

特殊规则：
- **做减法极度慎重**：标记每条疑似冗余规则，注明「删除后果」，需用户逐条确认
- **新增全局规则需论证必要性**：必须满足至少一项——(a) 用户明确说明多个项目需要 (b) 当前工作区发现多项目证据 (c) 用户确认其为长期跨项目偏好。规则应尽量放在项目级或 skill 中
- **分层优化**：检查哪些全局规则该下沉到 hooks（确定性规则）、哪些该移到 skills（流程性规则）

### 7. Project Bootstrap Hook（可选附加示例）

仅在 `git init` 时触发（工作区上下文准确），不做每次 Bash 都检查：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{
          "type": "command",
          "command": "case \"$CLAUDE_TOOL_INPUT\" in *\"git init\"*) if [ ! -f CLAUDE.md ]; then echo '⚠️  No CLAUDE.md found. Run /init or say 「帮我写 CLAUDE.md」'; fi ;; esac"
        }]
      }
    ]
  }
}
```

- 用户手动复制到 `settings.json`，skill **绝不**静默修改配置文件
- 可选启用，不强制安装
- **注意**：这是一个示例，不保证覆盖所有项目初始化方式（`pnpm create`、`cargo new`、`npm create` 等不触发 `git init` 的场景不会命中）

### 8. 领域隔离：与已有 Skill 的边界（必选）

| Skill | 职责 | 与本 skill 关系 |
|-------|------|----------------|
| `claude-md-writer`（本 skill） | 输出规则约束与系统提示（CLAUDE.md 内容） | — |
| `/init`（内置命令） | 自动扫描生成初始 CLAUDE.md | **增强而非替代**。推荐工作流：`/init` → 本 skill 审计优化。`/init` 由 Anthropic 维护升级，本 skill 不依赖其内部逻辑 |
| `writing-skills` | 创建/编辑 skill 文件（可执行工具集/脚本） | 互补。用户写好 CLAUDE.md 后如需配套 skill，可触发 writing-skills |
| `neat-freak` | 同步代码与文档，清理腐烂引用 | 互补。neat-freak 负责文档→代码一致性，本 skill 负责规则本身的编写 |

## Skill Structure

```
skills/
  claude-md-writer/
    SKILL.md                    # 主文件 (~800-1200 words)，入口路由 + 核心逻辑 + 安全规则
    references/
      authoritative-sources.md  # 10 个来源的结构化摘要（每个 3-5 条要点，非原文，按 Tier 组织）
    templates/
      new-project-prompt.md     # 模式 A：一键 Draft 模板
      analyze-checklist.md      # 模式 B：已有项目分析清单
      global-audit-guide.md     # 模式 C：全局宪法审视指南
```

## Token Budget

| 文件 | 预估 Token（approximate upper bound） | 加载时机 |
|------|-----------|----------|
| SKILL.md | ~1500-2000 | 始终（触发时） |
| authoritative-sources.md (Tier 1) | ~400-500 | 所有模式 |
| authoritative-sources.md (Tier 2) | ~600-800 | 模式 A/B |
| authoritative-sources.md (Tier 3) | ~800-1000 | 模式 B/C |
| 单个 template | ~500-700 | 按模式加载 1 个 |
| **单次 skill 文件加载上限** | **~2500-3500** | — |

- Skill 文件 token 不含项目扫描消耗（源码读取、Glob 结果等另行计算）
- Tier 分层是**逻辑分层**。若 skill framework 不支持文件内部分段加载，允许整体加载 `authoritative-sources.md`，但不改变 Tier 的引用优先级逻辑（高 Tier 规则优先）

## Error Handling

| 场景 | 处理策略 |
|------|----------|
| 全局 CLAUDE.md 不存在 | 提醒用户未找到全局配置，降级为纯项目扫描模式，不阻断 |
| 全局配置为软链接/只读 | 解析真实目标路径并在终端提示，**仅输出 DIFF 不执行物理写入** |
| 项目不在 git repo 中 | 正常执行，跳过 git 相关扫描（branch、commit hook 等） |
| 用户中途取消 | 不写入任何文件；已生成的临时内容丢弃 |
| 项目根无可识别技术栈文件 | 提示用户手动确认，改为完全交互式提问 |
| 目标文件已存在且被外部修改 | 先 diff 再覆盖，保留用户手动添加的内容 |
| 无法写入目标目录（权限不足） | 输出完整内容到标准输出流，提示用户手动创建 |
| Monorepo（多个子项目） | 询问用户：root / subproject / both？分别生成或合并 |
| 巨型项目（>5000 文件） | 限制扫描深度为 2，每层文件 > 200 时抽样，显式告知用户采样策略 |
| 部分扫描失败 | warning + 继续，不阻断整体流程 |
| 文件系统权限拒绝 (EACCES/ELOOP) | 静默跳过该节点，记录 warning，流程继续。包括：Docker/Root 生成的无读权限目录、损坏软链接、软链接循环等 |
| `settings.json` 不存在 | Hook 配置仅输出到标准输出流，不尝试创建或修改配置文件 |

## Trigger Conditions

- 直接触发：「帮我写 CLAUDE.md」「初始化项目」「优化宪法」「整理 CLAUDE.md」「创建项目配置」「审查 CLAUDE.md」「改进项目规则」
- 上下文触发：新项目无 CLAUDE.md 时（如果装了 hook）
- `description`: "Use when user wants to create, update, optimize, or audit a CLAUDE.md file — whether for a new project, an existing project, or the global user-level configuration"

## Key Design Decisions

1. **用户意图驱动路由**——不以文件是否存在判断模式，而是解析触发词和用户意图。意图模糊时默认走分析模式并附加提示
2. **一级目录放 skill 根目录（`~/.claude/skills/claude-md-writer/`）**——用户个人 skill，不放项目里
3. **参考来源放 `references/`，按 Tier + 按模式加载**——token 重，不全量塞入；每个来源提取 3-5 条结构化要点而非原文
4. **模板放独立 `templates/` 目录**——不同模式加载不同模板；templates 是 affordance（被 skill 逻辑调用），references 是参考资料，目录同级分开
5. **做减法 = 二次确认机制**——任何删除操作都需要用户明确同意，skill 只做建议
6. **全局写入 = 高信噪比单次确认（附证据）**——skill 识别出需要写入全局 CLAUDE.md 时，一次性展示：(a) 必要性论证 (b) 多项目适用证据 (c) 具体改动内容；用户做一次确认，而非三轮 y/n 对话框
7. **全局规则不可被项目覆盖**——冲突分为 Override / Duplicate / Missing 三级，Override 型默认拦截。例外逃逸仅限语言、文档规范、技术栈等上下文规则（通过 `> [!NOTE] Overrides Global:` 标记），不得用于覆盖安全规则或行为约束

## Interaction Flow

```
用户: "帮我写 CLAUDE.md"（意图 = Create）
  → Skill 读全局宪法 → 提取用户画像
  → Skill 扫描项目
  → 如项目已有大量文件 → 提示「检测到成熟项目，确认创建新的 CLAUDE.md？」
  → 生成初版草稿（尽量遵守全局约束）
  → Validate(草稿 vs 全局宪法) → 自动修正 Override 冲突并高亮说明
  → 附带待确认参数列表
  → 用户批量确认 → 写入

用户: "优化/审查 CLAUDE.md"（意图 = Audit）
  → Skill 读两级宪法
  → Skill 扫描项目
  → 如项目级 CLAUDE.md 不存在：
     输出扫描结果，提示「未发现项目 CLAUDE.md。是否切换到 Create 模式生成初版？」→ 用户确认后切换
  → 如存在：冲突/重复/缺失检测
  → 检测可下沉 hooks / 可移出 skills
  → 生成改进建议清单
  → 逐条用户确认 → 执行

用户: "优化全局 CLAUDE.md"（意图 = Global Audit）
  → Skill 读全局宪法
  → 分层审计（哪些下沉 hooks？哪些移 skills？哪些冗余？）
  → 展示审计报告
  → 冗余项标记「建议删除 + 理由」
  → 逐条用户确认（删除需单独确认）
  → 如全局配置为软链接：仅输出 DIFF，不物理写入
  → 执行

用户: "看看现在的规则"（意图模糊）
  → 默认走模式 B（Audit）
  → 分析报告中附加：「如需优化全局配置，可以说「优化宪法」」
```

## Anti-Patterns (For Implementation)

- ❌ 不经扫描直接生成 —— 先读再写
- ❌ 用文件是否存在决定模式 —— 用户意图驱动，非文件状态驱动
- ❌ 生成超过 300 行的项目 CLAUDE.md
- ❌ 在项目级 CLAUDE.md 重复全局已有内容
- ❌ 未经用户确认就修改全局 CLAUDE.md
- ❌ 做减法时不解释后果
- ❌ 所有功能塞进 SKILL.md —— token 浪费
- ❌ Glob `**/*` 不加 ignore 和深度限制 —— 巨型项目直接 OOM
- ❌ 静默修改 `settings.json` —— Hook 配置只输出到 stdout
- ❌ 逐个问题串行提问 —— 模式 A 改为一键 Draft + 批量确认
- ❌ 覆盖型冲突让用户自选 —— 全局宪法优先，默认拦截，例外仅限上下文规则且需显式标记

## Self-Review Checklist

- [x] No TBD/TODO placeholders
- [x] Internal consistency: 三种模式有明确入口和边界，意图模糊有 fallback
- [x] Scope: 聚焦 CLAUDE.md 编写/优化，不扩展到 skill 创建
- [x] No ambiguity: 用户意图驱动路由，冲突分三级处理
- [x] References real sources (all 10 verified, tiered by mode)
- [x] 领域隔离：与 /init、writing-skills、neat-freak 边界明确
- [x] 安全边界：全局不可被项目覆盖、不静默写配置、软链接保护
- [x] Token budget 明确，扫描有硬性限制
