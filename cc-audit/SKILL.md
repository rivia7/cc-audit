---
name: cc-audit
description: >-
  Audits a project/codebase against Anthropic's published Claude Code
  engineering best practices for large codebases — CLAUDE.md hierarchy,
  .claude configuration, hooks, skills, plugins, MCP servers, LSP/code
  intelligence, subagent workflows, configuration maintenance cadence, and
  organizational governance — then produces a structured Markdown compliance
  report with per-item status, concrete evidence from the repo, and
  prioritized, actionable recommendations. The skill only reports; it never
  modifies project files. Use this whenever the user wants to check, audit,
  review, score, or assess whether a repository follows Claude Code
  engineering standards / 工程规范 / best practices; asks things like "is my
  CLAUDE.md any good?", "audit my .claude setup", "are we set up right for
  Claude Code?", "Claude Code 配置健康检查"; is onboarding an existing
  codebase to Claude Code and wants a readiness check; or mentions reviewing
  their Claude Code configuration — even when they do not name this skill or
  the blog post explicitly.
---

# Claude Code Compliance Audit

This skill checks how well a repository is set up to work with Claude Code, using
the practices Anthropic published in *"How Claude Code works in large codebases:
best practices and where to start"* as the reference standard. It produces a
read-only Markdown report. It does **not** scaffold or fix anything — if the user
wants fixes, surface that as a follow-up, but the deliverable here is the audit.

## Why this skill exists

A team's Claude Code experience is shaped almost entirely by how the codebase is
configured: layered CLAUDE.md files, scoped commands, hooks, skills, MCP, and so
on. These artifacts accrete unevenly and drift. A periodic, evidence-based audit
tells a team exactly where they stand and what to fix first, instead of vague
"we should improve our setup" hand-waving.

## Core principle: calibrate to the project, don't just tick boxes

The single biggest failure mode here is mechanically penalizing a project for
not having org-scale machinery it doesn't need. A 300-line single-package CLI
does not need a subdirectory CLAUDE.md hierarchy, a plugin marketplace, or a
dedicated agent-manager role — and a report that dings it for their absence is
noise that trains the user to ignore the report.

So before scoring, form a view of the project's **scale and type** (rough size,
mono-repo vs. single package, number of services/languages, team vs. solo,
internal vs. OSS). Then judge each item as: *is this practice load-bearing for a
project like this?* An item that genuinely doesn't apply is marked `N/A` with a
one-line reason, not `✗`. Reserve `✗` for things this project really should have
and doesn't. The report is only useful if every ✗ is something worth acting on.

## Workflow

### 1. Locate the project root

Audit the user's current project unless they point elsewhere. The root is where
the top-level `CLAUDE.md` would live — typically the repo root / git toplevel, or
the working directory if it's not a git repo. State which path you audited.

### 2. Inventory the Claude Code artifacts

Run the discovery script — it does the repetitive scanning once so you don't have
to hand-roll `find`/`grep` every time:

```bash
bash <skill-path>/scripts/discover.sh <project-root>
```

It prints an inventory: every `CLAUDE.md` (with line counts), `.claude/` tree,
`settings.json` / `settings.local.json`, ignore configuration, `.mcp.json`,
skills, slash commands, hooks, plugin/marketplace files, related `AGENTS.md`, and
git-recency signals for the config. Read its output, then open the specific files
you need to actually judge quality (e.g. read the root `CLAUDE.md` to assess
whether it's lean, skim subdirectory ones, look at `settings.json` permissions).
The script gathers facts; *you* make the judgments — don't grade from filenames
alone.

### 3. Evaluate against the checklist

Read `references/checklist.md`. It has one section per practice area with: the
verbatim principle from the blog, what to look for in the repo, what good vs.
weak looks like, and how `N/A` applies. Work through every section. For each
item, gather concrete evidence (file path, line count, a short quoted snippet, or
"absent") before you assign a status — evidence first, verdict second.

### 4. Score

Per item, assign one of:

- `✓ 符合 / Compliant` — practice is present and reasonably well done
- `⚠ 部分 / Partial` — present but weak, incomplete, or drifting
- `✗ 缺失 / Missing` — should have it for a project like this, doesn't
- `N/A 不适用` — genuinely doesn't apply at this scale/type (give the reason)

Then a per-category status (worst-reasonable roll-up of its items) and an overall
score out of 100. The score is a **heuristic to prioritize attention, not a
grade** — say so in the report. Suggested weighting (only count categories that
aren't entirely N/A, and renormalize to 100 over the ones that apply):

| Category | Weight |
|---|---|
| CLAUDE.md hierarchy & leanness | 25 |
| File organization & navigation (ignore, scoped commands, codebase map) | 15 |
| Hooks (deterministic checks, start/stop context) | 12 |
| Skills (progressive disclosure, path scoping) | 12 |
| MCP servers | 8 |
| LSP / code intelligence | 8 |
| Subagent workflow conventions | 5 |
| Plugins / distribution | 5 |
| Configuration maintenance cadence | 10 |

Map status to fraction of the category's weight: `✓`=1.0, `⚠`=0.5, `✗`=0.0.
Bands: **优秀 ≥85 · 良好 70–84 · 需改进 50–69 · 起步 <50**. Organizational
governance is *not* in the numeric score (a repo can't prove it) — it's a
separate human-confirmation checklist.

### 5. Write the report

Write the report to `<project-root>/claude-code-audit-<YYYY-MM-DD>.md` (tell the
user the exact path). Use the template below. Write the report in the **same
language the user is using in the conversation** — the template labels below are
the Chinese defaults; keep them Chinese if the user writes Chinese, otherwise
translate the structure. Keep evidence concrete and quotes short. End by telling
the user the top 3 things to fix and offering to go deeper or help implement
(implementation is out of scope for the audit itself).

## Report template

```markdown
# Claude Code 工程规范合规审计报告

- **审计项目**: <绝对路径>
- **项目画像**: <规模/类型一句话,如 "单包 Python CLI,~4k 行,个人项目">
- **审计日期**: <YYYY-MM-DD>
- **对照标准**: How Claude Code works in large codebases — best practices
  (claude.com/blog)
- **总体评分**: <N>/100 — **<等级>**
- **评分说明**: 该分数仅用于排序改进优先级,已按项目规模剔除不适用项,非绝对评级。

## 摘要

<2–4 句:最值得肯定的 1 点 + 最紧迫的 1–2 个问题。给出整体判断。>

## 评分概览

| 类别 | 状态 | 关键发现 |
|---|---|---|
| CLAUDE.md 层级与精简 | ✓/⚠/✗/N/A | <一句话> |
| 文件组织与导航 | ✓/⚠/✗/N/A | <一句话> |
| Hooks | ✓/⚠/✗/N/A | <一句话> |
| Skills | ✓/⚠/✗/N/A | <一句话> |
| MCP 服务 | ✓/⚠/✗/N/A | <一句话> |
| LSP / 代码智能 | ✓/⚠/✗/N/A | <一句话> |
| Subagent 工作流约定 | ✓/⚠/✗/N/A | <一句话> |
| Plugins / 分发 | ✓/⚠/✗/N/A | <一句话> |
| 配置维护节奏 | ✓/⚠/✗/N/A | <一句话> |

## 详细发现

### 1. CLAUDE.md 层级结构与精简度
- **状态**: <✓/⚠/✗/N/A>
- **证据**: <文件路径、行数、片段;或 "未发现 CLAUDE.md">
- **对照实践**: <博客原则,简短引用>
- **建议**: <可执行,具体到文件/动作;N/A 则说明为何不适用>

### 2. 文件组织与导航
<同上结构:.claudeignore / .claude/settings.json 权限、按子目录划分的
test/lint 命令、非常规结构下的代码库地图>

### 3. Hooks
<同上:确定性检查 hook、start hook 动态上下文、stop hook 自我改进>

### 4. Skills
<同上:渐进式披露、路径作用域、可复用专业知识下沉到 skill 而非 CLAUDE.md>

### 5. MCP 服务
<同上:内部工具/数据源连接、结构化搜索>

### 6. LSP / 代码智能
<同上:代码智能插件 + 对应语言服务器>

### 7. Subagent 工作流约定
<同上:探索与编辑分离、只读 subagent 产出 findings 文件>

### 8. Plugins / 分发
<同上:打包 skills+hooks+MCP、避免设置停留在个人/部落知识层面>

### 9. 配置维护节奏
<同上:3–6 个月评审、模型升级后复审、移除为旧模型限制而写的补偿规则>

## 组织级事项(仓库无法自动检测,需人工确认)

> 以下来自博客的组织/治理建议,单个仓库证明不了,不计入上方评分。
> 请团队自查:

- [ ] 是否有明确的配置 **DRI**(对设置、权限策略、插件市场有决定权的负责人)?
- [ ] 是否有(哪怕一个人的)负责把工具接入开发流程的基础设施/开发体验职能?
- [ ] 是否考虑设立 **Agent manager**(PM/工程混合)角色统管 Claude Code 生态?
- [ ] 是否通过组织 **托管 marketplace** 分发与更新插件,而非各团队各自重建?
- [ ] 访问策略是否"先收紧、建立信心后再放开"?
- [ ] 是否有工程 / 信息安全 / 治理的跨职能工作组尽早介入?
- [ ] 是否设定了每 **3–6 个月** 或重大模型发布后的配置评审节奏?

## 优先改进清单

1. <影响最大的一项:做什么、改哪个文件、为什么重要>
2. <第二项>
3. <第三项>
```

## Notes on judgment

- **Lean ≠ short.** A long root `CLAUDE.md` isn't automatically `⚠`. Judge
  whether content is "pointers and critical gotchas" vs. drifted-in noise,
  reusable domain knowledge that belongs in a skill, or generic advice the model
  already knows. Cite the *kind* of bloat you see.
- **Absence of subdirectory CLAUDE.md** is only a finding for multi-service /
  multi-team / large repos where scoping matters. For a single small package
  it's expected — mark `N/A`.
- **Scoped test/lint commands**: the signal is whether commands are scoped to the
  part of the codebase Claude touched (per-package scripts, per-subdir CLAUDE.md
  noting the local command) so a one-service change doesn't run the whole suite.
- **Don't reward presence alone.** An empty `.claude/` or a stub `CLAUDE.md` with
  one boilerplate line is `⚠`/`✗`, not `✓`.
- If the project has **no Claude Code configuration at all**, that's a valid and
  important result: low score, but the report should be a constructive
  starting-point roadmap, not a scolding. Lead the summary with where to begin.
