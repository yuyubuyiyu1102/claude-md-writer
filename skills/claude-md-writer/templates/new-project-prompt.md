# Mode A — New Project Draft Template

Use this when generating an initial CLAUDE.md draft for a project that has none.

## Info to Gather (batch, not one-by-one)

| Dimension | Question | Default/Derived |
|-----------|----------|-----------------|
| Project type | Library? CLI? Web app? Service? Monorepo? | Detect from scan |
| Tech stack | Language, framework, package manager | Detect from scan |
| Team size | Solo? Small team (<5)? Large team? | Ask if unclear |
| Build | Build command, run command, test command | Detect from `package.json` scripts, Makefile, etc. |
| Constraints | Any project-specific rules or gotchas? | Leave blank if none |

## Draft Structure

```markdown
# Project: <name>

## Overview
<1-2 sentences about what this project is>

## Commands
- Build: `<cmd>`
- Test: `<cmd>`
- Run/Dev: `<cmd>`
- Lint: `<cmd>`

## Code Style
- <language-specific conventions detected from scan>
- <indentation, naming, imports>

## Constraints
- <project-specific rules, if any>
- <align with user profile from global CLAUDE.md>
```

## Parameter Checklist (present with draft)

- [ ] Tech stack correct?
- [ ] Build/Test/Run commands correct?
- [ ] Code style detected right?
- [ ] Any project constraints to add?
- [ ] Global CLAUDE.md preferences respected?

## Notes

- Keep under 300 lines total
- Do NOT repeat rules already in `~/.claude/CLAUDE.md`
- Align language and style with user profile extracted from global config
- If Override Exception applies, include `> [!NOTE] Overrides Global: <reason>` marker
