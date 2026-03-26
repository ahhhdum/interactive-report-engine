#!/usr/bin/env bash
# sync-skill.sh - Copy engine template to /action-report skill references
set -e

SKILL_DIR="$HOME/.claude/skills/action-report/references"

if [ ! -d "$SKILL_DIR" ]; then
  echo "Skill directory not found: $SKILL_DIR"
  exit 1
fi

cp interactive-report-engine.html "$SKILL_DIR/interactive-report-engine.html"
echo "Synced template to $SKILL_DIR/interactive-report-engine.html"
