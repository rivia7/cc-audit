# Audit checklist — detailed criteria

One section per practice area. Each has: the **principle** (from the blog,
quoted), **where to look** in the repo, **strong vs. weak** signals, and **when
N/A** applies. Work top to bottom. Gather evidence before assigning status.

> Reference standard: *How Claude Code works in large codebases: best practices
> and where to start* (claude.com/blog). Quotes below are from that article.

---

## 1. CLAUDE.md hierarchy & leanness  (weight 25)

**Principle.** Layered structure: a root file for the big picture, subdirectory
files for local conventions; files load additively as Claude moves through the
codebase. *"Root file should be pointers and critical gotchas only; everything
else drifts into noise."* Initialize CLAUDE.md in subdirectories so Claude is
*"scoped to the part of the codebase that's actually relevant to the task."* Do
**not** put reusable domain expertise here — that belongs in a skill.

**Where to look.** Root `CLAUDE.md` (and `CLAUDE.local.md`); any nested
`CLAUDE.md`; line counts from the discovery script; for non-trivial repos, the
mapping between top-level service/package dirs and whether each has its own
CLAUDE.md. Also note `AGENTS.md` if present (related convention).

**Strong.** Root file is short and mostly pointers + non-obvious gotchas;
multi-service/large repos have scoped subdirectory CLAUDE.md files near the code
they describe; no large blocks of generic advice or reusable domain tutorials.

**Weak / Missing.** No CLAUDE.md at all; a single sprawling root file carrying
everything for a large multi-service repo; root file full of generic guidance the
model already knows, or reusable domain knowledge that should be a skill; stub
file with one boilerplate line.

**N/A nuance.** Subdirectory hierarchy is `N/A` for a single small package — say
so. A short root file for a small project is *good*, not "incomplete."

---

## 2. File organization & navigation  (weight 15)

**Principle.** Scope test/lint commands per subdirectory — *"Running the full
suite when Claude changed one service causes timeouts and wastes context."*
Exclude generated files, build artifacts, and third-party code (ignore
configuration / version-controlled `.claude/settings.json` permissions). For
non-conventional structures, build a codebase map: a markdown file listing
top-level folders with descriptions. Massive codebases: root file describes the
highest level, subdirectory CLAUDE.md provides the next level.

**Where to look.** `.claudeignore`; `permissions` / deny patterns in
`.claude/settings.json`; per-package test/lint scripts (e.g. `package.json`
scripts, `Makefile`, per-service tooling) and whether CLAUDE.md points to scoped
commands rather than one global "run everything"; any codebase-map markdown
(e.g. `ARCHITECTURE.md`, a "repo layout" section, a folder index) — especially
important if the directory layout is non-obvious.

**Strong.** Generated/vendored/build dirs excluded; commands are scoped so a
one-service change doesn't trigger the whole suite; non-conventional layouts have
a map.

**Weak / Missing.** Huge generated/vendored trees with no exclusion (Claude will
waste context reading them); only a single global test/lint command for a
multi-service repo; opaque layout with no map.

**N/A nuance.** Codebase map is `N/A` for small/conventional layouts. Scoped
commands matter only when there's more than one independently testable unit.

---

## 3. Hooks  (weight 12)

**Principle.** Prefer automation over prompts for consistent behavior.
*"A stop hook can reflect on the session and propose CLAUDE.md updates"* — the
most valuable use is continuous self-improvement, not just prevention. Start
hooks load team-specific context dynamically so developers get the right setup
without manual configuration. Enforce deterministic checks (lint/format) via
hooks rather than relying on Claude to remember instructions.

**Where to look.** `hooks` in `.claude/settings.json`; any `.claude/hooks/`
scripts; what events they bind (PreToolUse/PostToolUse/Stop/SessionStart);
whether deterministic checks (lint/format/tests) are hook-enforced; presence of a
stop/session-end reflection hook; start/session-start context-loading hook.

**Strong.** Deterministic format/lint enforced by hooks; a session-start hook
loads dynamic team context; bonus for a stop hook that reflects/proposes config
improvements.

**Weak / Missing.** No hooks where deterministic enforcement clearly applies
(project has linters/formatters but relies on prose in CLAUDE.md to remember
them); hooks present but broken/trivial.

**N/A nuance.** A tiny project with no lint/format/test tooling has less to
enforce — note it, but a self-improvement stop hook is still cheap value.

---

## 4. Skills  (weight 12)

**Principle.** Progressive disclosure — load specialized workflows on demand
rather than in every session. *"Skills can also be scoped to specific paths so
they only activate in the relevant part of the codebase."* Keep reusable
expertise in skills so it doesn't bloat every session; this is also where domain
knowledge that does *not* belong in CLAUDE.md should live.

**Where to look.** `.claude/skills/*/SKILL.md`; skill frontmatter for path
scoping / clear trigger descriptions; whether reusable workflows or domain
expertise that's currently crammed into CLAUDE.md should instead be skills.

**Strong.** Reusable, specialized workflows captured as skills with crisp trigger
descriptions; path-scoped where they're only relevant to part of the repo.

**Weak / Missing.** Reusable expertise/domain knowledge living in CLAUDE.md
instead of a skill (cross-reference finding #1); skills with vague descriptions
that won't trigger; no skills despite obvious repeatable specialized workflows.

**N/A nuance.** Small project with no specialized recurring workflow legitimately
has no skills — `N/A`, don't manufacture a finding.

---

## 5. MCP servers  (weight 8)

**Principle.** Extend connectivity to internal tools, data sources, and APIs
otherwise unreachable. Sophisticated teams expose structured search as a tool
Claude can call directly (vs. blind grep across a billion-line codebase).
Examples: internal docs, ticketing, analytics.

**Where to look.** `.mcp.json`; `mcpServers` in `.claude/settings.json`; whether
servers are version-controlled/shared vs. only in personal `settings.local.json`;
whether any structured-search/internal-data server exists where it'd clearly help.

**Strong.** Relevant internal systems wired via MCP and shared in-repo so the
team gets them, not just one person.

**Weak / Missing.** Obvious internal dependency (issue tracker, internal docs,
data warehouse) that Claude can't reach and no MCP for it; MCP only in personal
local settings, not shared.

**N/A nuance.** Self-contained OSS/solo project with no internal systems to
connect → `N/A`.

---

## 6. LSP / code intelligence  (weight 8)

**Principle.** *"LSP returns only references pointing to the same symbol, so
filtering happens before Claude reads anything"* — essential at scale for
symbol-precise "go to definition" / "find all references"; particularly critical
for C/C++ navigation reliability. Setup = a code-intelligence plugin for the
language plus the matching language-server binary.

**Where to look.** Code-intelligence/LSP plugin configuration; documented setup
of language servers; for large or C/C++/multi-language repos, whether navigation
relies on plain text search alone.

**Strong.** LSP/code-intelligence configured for the repo's main language(s),
setup documented so the whole team gets it.

**Weak / Missing.** Large or C/C++/strongly-typed multi-language codebase with no
LSP — symbol navigation will be unreliable and context-wasting.

**N/A nuance.** Small repo where text search is perfectly adequate → `N/A` or low
weight. Scale the expectation to size and language.

---

## 7. Subagent workflow conventions  (weight 5)

**Principle.** Split exploration from editing: use a read-only subagent to map a
subsystem and write findings to a file; each subagent has its own context window
and returns only its final result to the parent.

**Where to look.** CLAUDE.md / skills / commands that codify an
explore-then-edit or "subagent writes findings to a file" convention; custom
subagent definitions.

**Strong.** The explore/edit split (or similar context-isolation discipline) is
written down as a convention so it's applied consistently.

**Weak / Missing.** Large codebase with no guidance on using subagents for
exploration (acceptable but a missed efficiency).

**N/A nuance.** Small project where everything fits in one context comfortably →
`N/A`.

---

## 8. Plugins / distribution  (weight 5)

**Principle.** Bundle skills, hooks, and MCP configurations into a single
installable package so new engineers immediately get the same context and
capabilities; updates distributed via an organizational managed marketplace.
Prevents good setups from staying tribal.

**Where to look.** `.claude-plugin/` / `marketplace.json` / plugin manifests;
whether the repo's skills+hooks+MCP are packaged for distribution vs. only living
ad hoc in this one repo.

**Strong.** Setup is packaged/distributable so the team and new hires get it
uniformly.

**Weak / Missing.** Valuable setup that exists only here and would be lost to new
projects/engineers — note the tribal-knowledge risk.

**N/A nuance.** Solo or single-repo context with no distribution need → `N/A`.

---

## 9. Configuration maintenance cadence  (weight 10)

**Principle.** *"Teams should expect meaningful configuration review every three
to six months,"* and whenever performance plateaus after major model releases.
Remove compensatory rules: skills/hooks built for old model limitations become
overhead once those limitations are gone (e.g. CLAUDE.md rules forcing
single-file refactors that now constrain models capable of coordinated
cross-file edits).

**Where to look.** Git recency of `CLAUDE.md` / `.claude/` from the discovery
script (last-modified, churn); any documented review cadence; smell-test the
CLAUDE.md/hooks/skills for rules that read like workarounds for obsolete model
limits.

**Strong.** Config touched/reviewed within the last ~6 months; a stated review
cadence; no obviously stale compensatory rules.

**Weak / Missing.** Config untouched for a long time; rules that look like
old-model workarounds; no review rhythm.

**N/A nuance.** Brand-new repo with no history yet → note it, low confidence,
don't penalize as if stale.

---

## 10. Organizational governance  (NOT in numeric score — human-confirm list)

These come straight from the blog but a single repo cannot prove them. List them
in the report's "组织级事项" section as an unchecked checklist for the team to
self-assess; never score or guess them from the filesystem:

- **DRI / ownership.** A directly responsible individual with authority over
  configuration, settings, permissions policy, and the plugin marketplace —
  the minimum viable governance.
- **Infrastructure / DevEx function.** *"A small team, sometimes just one
  person, wired up tooling so Claude fit developer workflows"* — typically under
  developer experience / developer productivity.
- **Agent manager.** Emerging hybrid PM/engineer role dedicated to managing the
  Claude Code ecosystem.
- **Managed marketplace.** Org-level distribution and updates of plugins so
  thousands of engineers don't independently rebuild the same solutions.
- **Access control posture.** Start restrictive (approved skills, code review
  required, limited initial access); expand gradually as confidence builds.
- **Cross-functional working group.** Engineering + infosec + governance brought
  in early to prevent fragmentation.
- **Review cadence ownership.** Someone owns the 3–6 month / post-model-release
  configuration review.
