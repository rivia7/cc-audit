#!/usr/bin/env bash
# Inventory a project's Claude Code configuration artifacts.
# Usage: bash discover.sh [project-root]   (defaults to current directory)
# Read-only: this script never modifies the project. Output is a plain-text
# inventory the auditor reads, then opens specific files to judge quality.

set -uo pipefail

ROOT="${1:-$PWD}"
if [ ! -d "$ROOT" ]; then
  echo "ERROR: not a directory: $ROOT" >&2
  exit 1
fi
ROOT="$(cd "$ROOT" && pwd)"

# Directories that are noise for this audit (deps / vcs / build output).
PRUNE=( -name .git -o -name node_modules -o -name vendor -o -name .venv \
        -o -name venv -o -name dist -o -name build -o -name target \
        -o -name .next -o -name .turbo -o -name __pycache__ )

section() { printf '\n=== %s ===\n' "$1"; }
note()    { printf -- '- %s\n' "$1"; }

echo "Claude Code artifact inventory"
echo "Project root: $ROOT"
echo "Generated:    $(date +%Y-%m-%d)"

# --- git context ----------------------------------------------------------
section "GIT CONTEXT"
if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  TOPLEVEL="$(git -C "$ROOT" rev-parse --show-toplevel 2>/dev/null)"
  note "git repo: yes (toplevel: $TOPLEVEL)"
  note "current branch: $(git -C "$ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null)"
else
  note "git repo: no (auditing directory as-is)"
fi

# --- CLAUDE.md family -----------------------------------------------------
section "CLAUDE.md FILES (path : line count)"
found_any=0
while IFS= read -r f; do
  found_any=1
  lines="$(wc -l <"$f" | tr -d ' ')"
  rel="${f#"$ROOT"/}"
  printf -- '- %s : %s lines\n' "$rel" "$lines"
done < <(find "$ROOT" \( "${PRUNE[@]}" \) -prune -o \
           -type f \( -name 'CLAUDE.md' -o -name 'CLAUDE.local.md' \) -print 2>/dev/null | sort)
[ "$found_any" -eq 0 ] && note "none found"

section "RELATED CONVENTION FILES"
for n in AGENTS.md ARCHITECTURE.md CONTRIBUTING.md; do
  while IFS= read -r f; do
    note "${f#"$ROOT"/}"
  done < <(find "$ROOT" \( "${PRUNE[@]}" \) -prune -o -type f -name "$n" -print 2>/dev/null | sort)
done

# --- .claude directory ----------------------------------------------------
section ".claude/ DIRECTORY TREE"
if [ -d "$ROOT/.claude" ]; then
  find "$ROOT/.claude" -maxdepth 4 -print 2>/dev/null | sed "s|$ROOT/||" | sort
else
  note ".claude/ not present"
fi

section "SETTINGS FILES"
for s in .claude/settings.json .claude/settings.local.json; do
  if [ -f "$ROOT/$s" ]; then
    note "$s present ($(wc -l <"$ROOT/$s" | tr -d ' ') lines)"
    # surface which capability keys are configured (presence only, no values)
    for key in permissions hooks mcpServers env model; do
      grep -q "\"$key\"" "$ROOT/$s" 2>/dev/null && note "  -> declares: $key"
    done
  else
    note "$s absent"
  fi
done

# --- ignore / exclusion ---------------------------------------------------
section "IGNORE / EXCLUSION CONFIG"
[ -f "$ROOT/.claudeignore" ] && note ".claudeignore present ($(wc -l <"$ROOT/.claudeignore" | tr -d ' ') lines)" || note ".claudeignore absent"
if [ -f "$ROOT/.claude/settings.json" ] && grep -q '"deny"' "$ROOT/.claude/settings.json" 2>/dev/null; then
  note "settings.json declares deny/permission rules"
fi
[ -f "$ROOT/.gitignore" ] && note ".gitignore present (proxy for what could be excluded from Claude too)"

# --- MCP ------------------------------------------------------------------
section "MCP CONFIG"
[ -f "$ROOT/.mcp.json" ] && note ".mcp.json present ($(wc -l <"$ROOT/.mcp.json" | tr -d ' ') lines)" || note ".mcp.json absent"

# --- skills ---------------------------------------------------------------
section "SKILLS"
if [ -d "$ROOT/.claude/skills" ]; then
  found_any=0
  while IFS= read -r f; do
    found_any=1
    note "${f#"$ROOT"/}"
  done < <(find "$ROOT/.claude/skills" -maxdepth 3 -name 'SKILL.md' -print 2>/dev/null | sort)
  [ "$found_any" -eq 0 ] && note ".claude/skills/ exists but has no SKILL.md"
else
  note ".claude/skills/ absent"
fi

# --- slash commands -------------------------------------------------------
section "SLASH COMMANDS"
if [ -d "$ROOT/.claude/commands" ]; then
  find "$ROOT/.claude/commands" -maxdepth 2 -type f -name '*.md' 2>/dev/null | sed "s|$ROOT/||" | sort || true
else
  note ".claude/commands/ absent"
fi

# --- hooks ----------------------------------------------------------------
section "HOOKS"
[ -d "$ROOT/.claude/hooks" ] && find "$ROOT/.claude/hooks" -maxdepth 2 -type f 2>/dev/null | sed "s|$ROOT/||" | sort
for s in .claude/settings.json .claude/settings.local.json; do
  [ -f "$ROOT/$s" ] && grep -q '"hooks"' "$ROOT/$s" 2>/dev/null && note "hooks declared inside $s"
done
[ ! -d "$ROOT/.claude/hooks" ] && ! grep -lq '"hooks"' "$ROOT"/.claude/settings*.json 2>/dev/null && note "no hooks found"

# --- plugins / marketplace ------------------------------------------------
section "PLUGINS / MARKETPLACE"
for p in .claude-plugin/marketplace.json .claude-plugin/plugin.json plugin.json; do
  [ -f "$ROOT/$p" ] && note "$p present"
done
[ -d "$ROOT/.claude-plugin" ] || note ".claude-plugin/ absent"

# --- config maintenance recency ------------------------------------------
section "CONFIG MAINTENANCE RECENCY (git)"
if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  for target in CLAUDE.md .claude; do
    if [ -e "$ROOT/$target" ]; then
      last="$(git -C "$ROOT" log -1 --format='%ci (%cr) %h %an' -- "$target" 2>/dev/null)"
      [ -n "$last" ] && note "$target last commit: $last" || note "$target: no git history"
    fi
  done
  note "CLAUDE.md total commits: $(git -C "$ROOT" rev-list --count HEAD -- CLAUDE.md 2>/dev/null || echo 0)"
else
  note "no git history available — cannot assess maintenance recency"
fi

# --- LSP / code-intelligence hints ---------------------------------------
section "LSP / CODE-INTELLIGENCE HINTS"
hint=0
grep -RIl --include='*.json' -e 'language-server' -e 'code-intelligence' -e 'lsp' \
  "$ROOT/.claude" 2>/dev/null | sed "s|$ROOT/||" | while read -r h; do note "mentions LSP: $h"; done
grep -qi 'lsp\|language server' "$ROOT/CLAUDE.md" 2>/dev/null && { note "CLAUDE.md mentions LSP/language server"; hint=1; }
[ "$hint" -eq 0 ] && note "no explicit LSP/code-intelligence config detected (verify manually)"

echo
echo "=== END OF INVENTORY ==="
echo "Next: open the files above (root CLAUDE.md, settings.json, skills, hooks)"
echo "to judge QUALITY — presence alone is not compliance."
