# cc-audit

**English** · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · [한국어](README.ko.md)

A [Claude Code](https://claude.com/claude-code) skill that checks how well a
repository is set up for Claude Code and writes a scored, read-only report.

It grades your setup against Anthropic's guide
[*How Claude Code works in large codebases*](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start),
backs every finding with concrete evidence, and tells you what to fix first. It
never touches your code — the only thing it writes is the report.

## What you get

Point it at a project. It inventories every Claude Code artifact, then grades
nine areas:

| Area | What it looks at |
|---|---|
| CLAUDE.md | Layered hierarchy, kept lean (pointers and gotchas, not noise) |
| File organization | `.claudeignore`, scoped commands, a codebase map |
| Hooks | Deterministic checks, start/stop context loading |
| Skills | Progressive disclosure, path scoping |
| MCP servers | Internal tools and structured search wired in |
| LSP / code intelligence | Symbol-level navigation at scale |
| Subagents | Explore-then-edit conventions |
| Plugins | Packaged and distributed, not tribal |
| Maintenance | A review cadence; stale rules removed |

Each item is rated `✓ Compliant`, `⚠ Partial`, `✗ Missing`, or `N/A`, with the
evidence behind it. Items roll up into a 0–100 score and a band: **Excellent**
(≥85), **Good** (70–84), **Needs work** (50–69), or **Early** (<50).

What makes the report worth reading:

- **The bar scales to your project.** A single-file script isn't marked down
  for having no CLAUDE.md hierarchy or plugin marketplace. Practices that
  genuinely don't apply are `N/A` with a reason and left out of the score,
  not counted as failures.
- **It's read-only.** Your project is never modified. The one output is
  `claude-code-audit-<YYYY-MM-DD>.md` at the repo root.
- **Org-level items stay separate.** Things a repo can't prove on its own — a
  config owner, a managed marketplace, a review cadence — go in a checklist
  for a human to confirm, and don't affect the score.
- **Evidence comes before the verdict.** Every finding quotes a path, a line
  count, or a snippet.

## Layout

```
cc-audit/                 # the skill itself (this subdirectory)
├── SKILL.md              # workflow, report template, scoring rubric
├── references/
│   └── checklist.md      # per-area criteria and the source guidance
├── scripts/
│   └── discover.sh       # one-shot inventory of Claude Code config
└── evals/
    └── evals.json        # scenarios used to validate the skill
README.md                 # you are here (translations: zh-CN, ja, ko)
```

## Install

Globally, for every project you work on:

```bash
git clone https://github.com/rivia7/cc-audit.git
cp -R cc-audit/cc-audit ~/.claude/skills/cc-audit
chmod +x ~/.claude/skills/cc-audit/scripts/discover.sh
```

Or just for one repo:

```bash
cp -R cc-audit your-repo/.claude/skills/cc-audit
```

Then start a fresh Claude Code session so it picks up the skill.

## Usage

Ask for it by name — that's the reliable way to run it:

> Use the cc-audit skill to audit this repository.

You'll get the report at `<repo>/claude-code-audit-<YYYY-MM-DD>.md`, with the
highest-priority fixes summarized in the reply.

**Why ask by name?** For "audit my setup" requests, a capable model tends to
just review things itself instead of reaching for a skill — a known Claude
trait, not a flaw here. The upside: it never fires when it shouldn't (zero
false triggers on look-alike prompts in testing). So invoke it explicitly;
once it runs, the audit is consistent.

## Not in scope

- It reports; it doesn't fix. Ask separately if you want the changes made.
- When the audit finds a gap an official Anthropic tool targets, the reply
  points you to it as an optional next step you run yourself: the
  `claude-md-management` plugin for a weak CLAUDE.md, a per-language LSP
  plugin for weak code intelligence, or the `skill-creator` plugin for
  missing skills. The audit itself installs nothing and stays read-only.
- Org and governance items are advice for a human to confirm — a repo can't
  prove them.

## Development

Run `cc-audit/scripts/discover.sh <path>` to print the raw inventory.
`cc-audit/evals/evals.json` holds the four scenarios used to validate the
skill — no config, a bloated monorepo, a lean single file, and a
well-configured repo — covering scale calibration, quality judgment, the
read-only guarantee, and not inventing problems.

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=rivia7/cc-audit&type=Date)](https://star-history.com/#rivia7/cc-audit&Date)
