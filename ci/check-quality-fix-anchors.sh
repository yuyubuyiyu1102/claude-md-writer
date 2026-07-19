#!/usr/bin/env bash
set -euo pipefail

FAILS=0
CHECKS=0

# ── helpers ────────────────────────────────────────────────────────────────

fail() {
  echo "FAIL: $1"
  FAILS=$((FAILS + 1))
}

pass() {
  echo "PASS: $1"
}

tick() {
  CHECKS=$((CHECKS + 1))
}

# ── A-1: C1 declaration table ──────────────────────────────────────────────

check_a1() {
  local f="skills/claude-md-writer/templates/new-project-prompt.md"
  local hits=0

  grep -q "Declarative" "$f"      && hits=$((hits + 1)) || true
  grep -q "constitution" "$f"     && hits=$((hits + 1)) || true
  if grep -q "Constraint or script" "$f" || grep -q "constraint someone follows" "$f"; then
    hits=$((hits + 1))
  fi

  if [[ $hits -eq 3 ]]; then
    pass "A-1: C1 declaration table"
  else
    fail "A-1: C1 declaration table ($hits/3 anchors hit)"
  fi
  tick
}

# ── A-2: C1 SKILL.md step (d) ──────────────────────────────────────────────

check_a2() {
  local f="skills/claude-md-writer/SKILL.md"
  local hits=0

  grep -q "Is every rule declarative" "$f" && hits=$((hits + 1)) || true
  grep -q "procedural" "$f"              && hits=$((hits + 1)) || true

  if [[ $hits -eq 2 ]]; then
    pass "A-2: C1 SKILL.md step (d)"
  else
    fail "A-2: C1 SKILL.md step (d) ($hits/2 anchors hit)"
  fi
  tick
}

# ── A-3: C1 if/when boundary ───────────────────────────────────────────────

check_a3() {
  local f="skills/claude-md-writer/templates/new-project-prompt.md"

  if grep -qi "scope condition" "$f" || grep -q "Production code requires" "$f"; then
    pass "A-3: C1 if/when boundary"
  else
    fail "A-3: C1 if/when boundary (no anchor hit)"
  fi
  tick
}

# ── A-4: C2 persona -- NEVER ask technical-verification questions ──────────

check_a4() {
  local f="skills/claude-md-writer/templates/new-project-prompt.md"
  local hits=0

  grep -qi "never ask" "$f"      && hits=$((hits + 1)) || true
  grep -q "技术栈正确吗" "$f"   && hits=$((hits + 1)) || true

  if [[ $hits -eq 2 ]]; then
    pass "A-4: C2 persona -- no technical verification questions"
  else
    fail "A-4: C2 persona -- no technical verification questions ($hits/2 anchors hit)"
  fi
  tick
}

# ── A-5: C2 persona -- Missing-data exception ──────────────────────────────

check_a5() {
  local f="skills/claude-md-writer/templates/new-project-prompt.md"

  if grep -q "无法从代码中确认" "$f" || grep -q "补充缺失" "$f"; then
    pass "A-5: C2 persona -- missing-data exception"
  else
    fail "A-5: C2 persona -- missing-data exception (no anchor hit)"
  fi
  tick
}

# ── A-6: C2 persona -- Self-Verify partition ───────────────────────────────

check_a6() {
  local f="skills/claude-md-writer/templates/new-project-prompt.md"
  local hits=0

  grep -q "Self-Verify"    "$f" && hits=$((hits + 1)) || true
  grep -qi "do NOT ask user" "$f" && hits=$((hits + 1)) || true
  grep -q "User-Confirm"   "$f" && hits=$((hits + 1)) || true

  if [[ $hits -eq 3 ]]; then
    pass "A-6: C2 persona -- Self-Verify partition"
  else
    fail "A-6: C2 persona -- Self-Verify partition ($hits/3 anchors hit)"
  fi
  tick
}

# ── A-7: C3 source provenance ──────────────────────────────────────────────

check_a7() {
  local f="skills/claude-md-writer/templates/new-project-prompt.md"
  local hits=0

  grep -q "Steve Kinney" "$f" && hits=$((hits + 1)) || true
  grep -q "Morph LLM"    "$f" && hits=$((hits + 1)) || true
  grep -q "Optimus"      "$f" && hits=$((hits + 1)) || true

  if [[ $hits -eq 3 ]]; then
    pass "A-7: C3 source provenance"
  else
    fail "A-7: C3 source provenance ($hits/3 sources found)"
  fi
  tick
}

# ── A-8: C4 procedural detect -- Phase 1 addon ─────────────────────────────

check_a8() {
  local f="skills/claude-md-writer/templates/analyze-checklist.md"
  local hits=0

  grep -q "Procedural"          "$f" && hits=$((hits + 1)) || true
  grep -q "sequence of actions" "$f" && hits=$((hits + 1)) || true
  if grep -q "flow.condition" "$f" || grep -q "flow-condition" "$f" || grep -q "flow condition" "$f"; then
    hits=$((hits + 1))
  fi

  if [[ $hits -eq 3 ]]; then
    pass "A-8: C4 procedural detect -- Phase 1 addon"
  else
    fail "A-8: C4 procedural detect -- Phase 1 addon ($hits/3 anchors hit)"
  fi
  tick
}

# ── A-9: C4 procedural detect -- Phase 3 P4 before P5(SKILL) ──────────────

check_a9() {
  local f="skills/claude-md-writer/templates/analyze-checklist.md"

  local proc_line
  local skill_line

  proc_line=$(grep -n "PROCEDURAL" "$f" | tail -1 | cut -d: -f1)
  skill_line=$(grep -n "SKILL" "$f" | tail -1 | cut -d: -f1)

  if [[ -z "$proc_line" ]]; then
    fail "A-9: Phase 3 P4 order -- 'PROCEDURAL' not found"
    tick
    return
  fi
  if [[ -z "$skill_line" ]]; then
    fail "A-9: Phase 3 P4 order -- 'SKILL' not found"
    tick
    return
  fi

  if [[ "$proc_line" -lt "$skill_line" ]]; then
    pass "A-9: Phase 3 P4 order -- PROCEDURAL ($proc_line) before SKILL ($skill_line)"
  else
    fail "A-9: Phase 3 P4 order -- PROCEDURAL ($proc_line) NOT before SKILL ($skill_line)"
  fi
  tick
}

# ── A-10: SKILL.md Anti-Patterns addon ─────────────────────────────────────

check_a10() {
  local f="skills/claude-md-writer/SKILL.md"
  local hits=0

  grep -q "#1 FAILURE MODE"              "$f" && hits=$((hits + 1)) || true
  grep -q "execution plans instead of rules" "$f" && hits=$((hits + 1)) || true

  if [[ $hits -eq 2 ]]; then
    pass "A-10: SKILL.md Anti-Patterns addon"
  else
    fail "A-10: SKILL.md Anti-Patterns addon ($hits/2 anchors hit)"
  fi
  tick
}

# ── A-11: template line-count range ────────────────────────────────────────

check_a11() {
  local f="skills/claude-md-writer/templates/new-project-prompt.md"
  local lines

  lines=$(wc -l < "$f")

  if [[ "$lines" -lt 100 ]]; then
    echo "WARNING: A-11: template is $lines lines (< 100, too short)"
    tick
  elif [[ "$lines" -gt 175 ]]; then
    echo "WARNING: A-11: template is $lines lines (> 175, too long)"
    tick
  else
    pass "A-11: template line count ($lines lines, in [100,175])"
    tick
  fi
}

# ── run ─────────────────────────────────────────────────────────────────────

echo "=== Quality Fix Anchor Checks ==="
echo

check_a1
check_a2
check_a3
check_a4
check_a5
check_a6
check_a7
check_a8
check_a9
check_a10
check_a11

echo
echo "=== Summary: $CHECKS checks, $FAILS failed ==="

exit "$FAILS"
