# cc-audit

**English** · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

A [Claude Code](https://claude.com/claude-code) skill that audits a repository
against Anthropic's published best practices for working in large codebases and
produces a **scored, read-only Markdown compliance report** — with per-item
status, concrete evidence from the repo, and a prioritized fix list.

Reference standard: *["How Claude Code works in large codebases: best practices
and where to start"](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start)*.

## What it does

Given a project, the skill inventories every Claude Code artifact and grades
nine categories against the blog's guidance:

| # | Category |
|---|---|
| 1 | CLAUDE.md hierarchy & leanness |
| 2 | File organization & navigation (`.claudeignore`, scoped commands, codebase map) |
| 3 | Hooks (deterministic checks, start/stop context) |
| 4 | Skills (progressive disclosure, path scoping) |
| 5 | MCP servers |
| 6 | LSP / code intelligence |
| 7 | Subagent workflow conventions |
| 8 | Plugins / distribution |
| 9 | Configuration maintenance cadence |

Each item is marked `✓ Compliant` / `⚠ Partial` / `✗ Missing` / `N/A`, backed
by concrete evidence, and rolled up into a 0–100 score with bands
(优秀 ≥85 · 良好 70–84 · 需改进 50–69 · 起步 <50).

Key design choices:

- **Calibrated to project scale.** A tiny single-file tool is not penalized for
  lacking a CLAUDE.md hierarchy or a plugin marketplace — genuinely
  inapplicable practices are marked `N/A` (with a reason) and excluded from the
  score, not scored as failures.
- **Read-only.** It never modifies your project. Its only output is the report
  file `claude-code-audit-<YYYY-MM-DD>.md` written at the project root.
- **Organizational governance is separated.** Items a single repo cannot prove
  (DRI ownership, managed marketplace, review cadence, etc.) are surfaced as a
  human-confirmation checklist, not scored.
- **Evidence first, verdict second.** Every finding cites a file path, line
  count, or quoted snippet.

## Repository layout

```
cc-audit/                 # the installable skill (this subdirectory)
├── SKILL.md              # workflow + report template + scoring rubric
├── references/
│   └── checklist.md      # per-category audit criteria + verbatim blog points
├── scripts/
│   └── discover.sh       # one-shot inventory of all Claude Code config
└── evals/
    └── evals.json        # test scenarios + assertions used to validate the skill
README.md                 # this file (+ zh-CN / ja / ko translations)
```

## Install

**Global (all your projects):**

```bash
git clone https://github.com/rivia7/cc-audit.git
cp -R cc-audit/cc-audit ~/.claude/skills/cc-audit
chmod +x ~/.claude/skills/cc-audit/scripts/discover.sh
```

**Per-project:**

```bash
cp -R cc-audit ./your-repo/.claude/skills/cc-audit
```

Start a new Claude Code session so the skill is discovered.

## Usage

Invoke it **explicitly** for reliable activation:

> Use the cc-audit skill to audit this repository.
>
> Audit the current project against Claude Code engineering best practices and
> give me a report.

The report is written to `<project-root>/claude-code-audit-<YYYY-MM-DD>.md` and
the top fixes are summarized in the reply.

### A note on triggering

Auto-triggering for "audit my setup" requests is structurally limited — a
capable model often just does an ad-hoc review inline instead of consulting a
skill. This is a known Claude behavior, not a defect of this skill. In testing,
the description never false-triggered (100% precision on near-miss queries), so
the reliable path is **explicit invocation** (a slash mention or "use the
cc-audit skill"). When invoked, the skill's audit quality is consistent.

## What it does not do

- It does not fix or scaffold anything — it reports. Ask separately if you want
  the fixes applied.
- Organizational/governance items are advisory and need human confirmation; a
  repo cannot prove them.

## Development

`cc-audit/scripts/discover.sh <path>` prints the raw artifact inventory.
`cc-audit/evals/evals.json` holds the scenarios (no-config, bloated monorepo,
lean single-file, well-configured) used to validate calibration, quality
judgment, the read-only guarantee, and the "don't manufacture problems"
behavior.

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=rivia7/cc-audit&type=Date)](https://star-history.com/#rivia7/cc-audit&Date)
