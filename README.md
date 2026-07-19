# CLAUDE.md Writer Skill

智能 CLAUDE.md 编写 skill，覆盖三种场景：创建、审计、全局宪法维护。HARD GATE 门禁系统确保 agent 不会跳过核心工作流。

[![Skill Validation](https://github.com/yuyubuyiyu1102/claude-md-writer/actions/workflows/validate.yml/badge.svg)](https://github.com/yuyubuyiyu1102/claude-md-writer/actions/workflows/validate.yml)

## 结构

```
skills/claude-md-writer/
├── SKILL.md                         # 主文件，入口路由 + 三模式逻辑 + 门禁
├── references/
│   └── authoritative-sources.md     # 10 个权威来源（Tier 1/2/3）
└── templates/
    ├── new-project-prompt.md        # Mode A：一键 Draft 模板
    ├── analyze-checklist.md         # Mode B：分析清单
    └── global-audit-guide.md        # Mode C：全局审计指南
```

## 安装

```bash
# macOS / Linux
cp -r skills/claude-md-writer ~/.claude/skills/claude-md-writer

# Windows (PowerShell)
Copy-Item -Recurse skills/claude-md-writer $env:USERPROFILE\.claude\skills\claude-md-writer
```

## 使用

| 我想做什么 | 这样说 |
|-----------|--------|
| 创建项目 CLAUDE.md | "帮我写 CLAUDE.md" |
| 审查优化已有 CLAUDE.md | "审查 CLAUDE.md" |
| 优化全局配置 | "优化宪法" |

## 设计

见 [specs/2026-07-19-claude-md-writer-skill-design.md](specs/2026-07-19-claude-md-writer-skill-design.md)

## 仓库

https://github.com/yuyubuyiyu1102/claude-md-writer
