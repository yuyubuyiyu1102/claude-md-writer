# Authoritative Sources — CLAUDE.md Design Reference

10 sources organized in 3 tiers. Higher tier wins on conflict.
Structured as 3-5 key points per source (not verbatim text).

---

## Tier 1 — Official Guidance (All Modes)

### 1. Anthropic "Steering Claude Code"

Official Anthropic guidance on controlling Claude behavior through configuration files.

- CLAUDE.md sits between system prompt and runtime context -- it shapes Claude's defaults, not hard gates
- Three control layers: CLAUDE.md (behavioral defaults) > Skills (workflow scripts) > Hooks (deterministic triggers)
- Keep CLAUDE.md concise: 60 lines ideal, 300 lines hard cap. Beyond that, rules get ignored due to context dilution
- What goes in CLAUDE.md: project conventions, build/test commands, security constraints, style preferences. What goes in skills: reusable workflows, tool-specific instructions
- Rules at the top get more attention than rules at the bottom -- order matters

### 2. Karpathy Guidelines

Behavioral guidelines to reduce common LLM coding mistakes. Already referenced in many CLAUDE.md configs.

- Think before coding: state assumptions, surface unknowns, present tradeoffs before implementation
- Simplicity first: minimum code, no speculative features, no abstractions for single-use, rewrite if 200 lines could be 50
- Surgical changes: touch only what's needed, match existing style, don't "improve" adjacent code
- Goal-driven execution: define verifiable success criteria, loop until verified, weak criteria = constant clarification
- These four principles work as a baseline behavioral contract between user and agent

---

## Tier 2 — Best Practices (Modes A + B)

### 3. Optimus Claude Best Practices

Community-distilled best practices from heavy Claude Code users.

- WHAT / WHY / HOW framework: every rule answers what to do, why it matters, how to verify
- 60 lines is the sweet spot for CLAUDE.md; 300 lines is the absolute upper bound before rules lose effectiveness
- Project-specific over generic: "use Jest with --coverage" beats "write tests"
- Avoid negative-only rules: pair each "don't do X" with "do Y instead"
- Review and prune regularly: stale rules confuse more than absent rules

### 4. Agent Engineering Handbook

Systematic approach to configuring coding agents for teams.

- Rules vs Skills decision matrix: deterministic/repeatable = rule; contextual/multi-step = skill
- Priority layering: Global (personal defaults) > Team (shared standards) > Project (repo-specific) > Task (one-off)
- Each layer should only contain what isn't already covered by a higher layer
- Team-level CLAUDE.md should be checked into git; personal CLAUDE.md should not
- Version your CLAUDE.md: when conventions change, update the file immediately

### 5. Morph LLM CLAUDE.md Guide

Template and loading-order reference for CLAUDE.md configuration.

- Loading order: Global (`~/.claude/CLAUDE.md`) loads first, then root project, then subproject. Last loaded does NOT override first -- global wins
- Template structure: Overview → Commands → Code Style → Constraints → References
- Explicit is better than implicit: "use 2-space tabs" not "use standard formatting"
- Cross-reference external docs rather than duplicating them inline
- Test your CLAUDE.md by spawning a fresh agent and checking if it follows conventions

---

## Tier 3 — Community Experience (Modes B + C)

### 6. Boris Cherny 13 Tips

Practical tips from a developer who heavily uses AI coding assistants.

- If the agent makes the same mistake twice, add a rule -- don't fix manually a third time
- Verification beats trust: every generated change should have a test or manual check step
- Team collaboration: when multiple people use the same repo, CLAUDE.md is the shared contract
- "Don't be clever" beats "be clever" -- predictable output over elegant output
- Onboarding value: a good CLAUDE.md means a new team member's first agent session is productive

### 7. Arize Prompt Learning

Methodology for systematically improving prompts (applied to CLAUDE.md optimization).

- Seven-step loop: Deploy → Observe failures → Hypothesize gaps → Write rule → Test → Measure → Repeat
- Don't add rules for problems that haven't happened yet -- observed failures only
- A/B test rule changes: run the same task with old and new CLAUDE.md, compare results
- Measure quantitatively: count overrides, ignored rules, clarification questions before/after
- Remove rules that never trigger -- dead rules erode trust in the entire document

### 8. Addy Osmani Agent Skills

Guidance on building effective agent skills and conventions.

- Spec-first development: write the spec/requirements, then let the agent generate from spec
- Atomic commits: each commit is one logical change, verifiable independently
- Verification as evidence: screenshot, test output, or log -- not "I checked and it works"
- Skills should compose: a deploy skill calls a test skill calls a build skill
- Documentation is a byproduct, not a separate task -- generated from working code

### 9. Steve Kinney 3-Layer Decision

Framework for deciding where to put agent instructions.

- Skills = "how to do X" (workflows, multi-step processes, tool-specific guides)
- Rules = "always/never do Y" (constraints, conventions, behavioral defaults) -- this is CLAUDE.md
- Hooks = "when Z happens, do W" (triggers, automated checks, deterministic actions) -- this is settings.json
- If a CLAUDE.md rule starts with "when..." or "if...", it's probably a hook or skill
- CLAUDE.md should be mostly declarative statements, not conditional logic

### 10. Cursor Rules Community

Community practices from Cursor's `.mdc` rule format, applicable to CLAUDE.md.

- `.mdc` / `.cursorrules` format with `alwaysApply` flag maps to CLAUDE.md's "always loaded" behavior
- Workspace-level rules for shared conventions, user-level rules for personal preferences
- Globs for rule scoping: apply certain rules only to specific file types or directories
- Community maintains shared rule repositories by framework (Next.js, Django, etc.) -- use as reference but adapt
- Rule granularity tradeoff: too many small rules = context overhead; too few large rules = ignored specifics
