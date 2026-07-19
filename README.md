# CLAUDE.md Writer Skill

智能 CLAUDE.md 编写 skill，覆盖三种场景：创建、审计、全局宪法维护。

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
cp -r skills/claude-md-writer ~/.claude/skills/claude-md-writer
```

## 使用

- "帮我写 CLAUDE.md" → 创建模式
- "审查 CLAUDE.md" → 审计模式
- "优化宪法" → 全局宪法维护

## 设计

见 `specs/2026-07-19-claude-md-writer-skill-design.md`
