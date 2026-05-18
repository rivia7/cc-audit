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
git-recency signals for the config, plus a `USER LOCALE` section (detected
system language — used only as a report-language fallback, see step 5). Read its
output, then open the specific files
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
Bands (render in the chosen language — English canonical / 简体中文 default):
**Excellent/优秀 ≥85 · Good/良好 70–84 · Needs work/需改进 50–69 ·
Early/起步 <50**. Organizational
governance is *not* in the numeric score (a repo can't prove it) — it's a
separate human-confirmation checklist.

### 5. Write the report

Write the report to `<project-root>/claude-code-audit-<YYYY-MM-DD>.md` (tell the
user the exact path). Use the template below.

**Choose the report language by this precedence:**

1. An explicit instruction in the user's request ("report in English",
   "用中文出报告", "日本語で") — always wins.
2. Otherwise, the language the user is writing in this conversation.
3. Otherwise, the `Detected system language:` line from the discovery script's
   `USER LOCALE` section.
4. Otherwise, English.

The discovery script only *suggests* the system language; the conversation
language outranks it. Render the title, every label, status, band, and the
org-level section in the chosen language using the **Report-label glossary**
below — the Chinese template is the default rendering, not literal text, so
translate the whole structure. Add one line at the very top of the report,
`Report language: <lang> (chosen by <precedence reason>)`, for transparency.
Keep evidence concrete and quotes short. End by telling
the user the top 3 things to fix and offering to go deeper or help implement
(implementation is out of scope for the audit itself).

### 6. When the audit finds a gap an official Anthropic tool targets, point to it

Still read-only: this skill never edits files and never installs anything. But
Anthropic ships official, first-party tools built for some of the exact
categories audited here. When the audit finds a real gap one of them targets,
surface it as an opt-in next step the *user* chooses to run — the same opt-in
framing as step 5's "help implement" offer, and like that offer it stays a
conversational reply, never written into the report file.

**Shared rules — apply to every pointer below.**

- **Conversational reply only**, after the report is saved. Never write any of
  these into the report file.
- **Optional and user-run.** State explicitly that it's optional, that the
  *user* installs/runs it themselves, and that the audit itself stays read-only.
- **Official only.** Each is a plugin from the `claude-plugins-official`
  marketplace (Anthropic-maintained, available by default in Claude Code) —
  never third-party.
- **Commands verbatim.** Keep every `/plugin install …` and `/skill-creator`
  string exactly as written — never translate or paraphrase a command, even
  when the surrounding offer is in another language. Plugin and binary names
  are identifiers.
- **Calibrate, never oversell.** Offer a tool *only* when the audit found the
  specific gap it targets. A category that resolved to `✓` or `N/A` never
  triggers its tool. Pitching a tool the audit didn't motivate trains the user
  to ignore the report — the one failure mode this skill exists to avoid.
- **One consolidated block, severity-ordered.** If more than one pointer fires,
  present them together under a single short "Optional next steps you can run
  yourself" close (mirroring the existing "want me to go deeper?" offer), in
  the report/conversation language, ordered by the weight of the gap each
  addresses (heaviest-weighted failing category first). When Pointer 1 fires
  only on the overall-score condition (CLAUDE.md itself is `✓`/`N/A`), rank it
  by the real failing categories, not CLAUDE.md's nominal weight — consistent
  with its calibration note. Include only the pointers that actually fired —
  never the full menu.

**Pointer 1 — CLAUDE.md → `claude-md-management`.** Audits and improves
CLAUDE.md files; targets the highest-weighted category here.

- *Fires when:* the CLAUDE.md category resolved to `⚠ Partial` or `✗ Missing`,
  **or** the overall score is below 70. If CLAUDE.md is `✓ Compliant` or `N/A`
  *and* the score is ≥70, it does not fire.
- *Say it* via the **CLAUDE.md plugin offer** glossary row. Calibrate:
  - CLAUDE.md is the weak spot (`⚠`/`✗`): lead with it — it targets the exact,
    heaviest-weighted gap found.
  - CLAUDE.md is `✓`/`N/A` and only the overall score is <70: lead with the
    real weak categories from the priority list; mention this only as optional
    ongoing CLAUDE.md upkeep (and for `N/A`, only if a CLAUDE.md would help at
    this scale). Don't oversell a CLAUDE.md tool when CLAUDE.md isn't the
    problem.

**Pointer 2 — LSP / code intelligence → per-language LSP plugin.** Adds
symbol-precise navigation (go-to-definition / find-references) at scale.

- *Fires when:* the LSP / code intelligence category resolved to `⚠ Partial`
  or `✗ Missing`. If it's `✓ Compliant` or `N/A`, it does not fire — `N/A`
  here means text search is genuinely adequate at this scale, so an LSP pitch
  would be exactly the noise this skill avoids.
- *Say it* via the **LSP plugin offer** glossary row. Name the specific
  plugin(s) for the repo's actual primary language(s) from the **Official LSP
  plugin map** below, and state the user must also put the matching
  language-server binary on `PATH` (the audit points; it installs neither). If
  the main language isn't in the map, say the official marketplace carries the
  rest as `*-lsp@claude-plugins-official` rather than guessing a name.

**Pointer 3 — Skills → `skill-creator`.** An official plugin that scaffolds,
edits, and evals skills; installs as
`/plugin install skill-creator@claude-plugins-official`, then provides the
`/skill-creator` command.

- *Fires when:* the Skills category resolved to `⚠ Partial` or `✗ Missing`.
  This covers both sub-cases: an obvious repeatable workflow with no skill, and
  reusable domain knowledge crammed into CLAUDE.md that should be a skill — for
  the latter, tie it to the CLAUDE.md finding (note the misplaced knowledge,
  point at `skill-creator` to extract it). If Skills is `✓` or `N/A`, it does
  not fire.
- *Say it* via the **skill-creator offer** glossary row. Keep the
  `/plugin install …` command verbatim, exactly as for Pointer 1.

**Official LSP plugin map.** Language → plugin → required language-server
binary; every plugin installs as
`/plugin install <plugin>@claude-plugins-official`. Name only the row(s)
matching the repo's primary language(s):

| Language | Plugin | Required binary |
|---|---|---|
| C / C++ | `clangd-lsp` | `clangd` |
| C# | `csharp-lsp` | `csharp-ls` |
| Go | `gopls-lsp` | `gopls` |
| Java | `jdtls-lsp` | `jdtls` |
| Kotlin | `kotlin-lsp` | `kotlin-language-server` |
| Lua | `lua-lsp` | `lua-language-server` |
| PHP | `php-lsp` | `intelephense` |
| Python | `pyright-lsp` | `pyright-langserver` |
| Rust | `rust-analyzer-lsp` | `rust-analyzer` |
| Swift | `swift-lsp` | `sourcekit-lsp` |
| TypeScript / JavaScript | `typescript-lsp` | `typescript-language-server` |

Languages not listed: the official marketplace carries additional `*-lsp`
plugins — point the user there; do not invent a plugin name.

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

## Report-label glossary (render in the chosen language)

The template above shows the 简体中文 default. Render every fixed label in the
chosen language using this table. Traditional Chinese → 繁體中文 equivalents of
the 简体中文 column; any language not listed → translate naturally from the
English column.

| Element | English | 简体中文 | 日本語 | 한국어 |
|---|---|---|---|---|
| Report title | Claude Code Engineering Compliance Audit | Claude Code 工程规范合规审计报告 | Claude Code エンジニアリング規範 監査レポート | Claude Code 엔지니어링 규범 감사 보고서 |
| Audit target | Audit target | 审计项目 | 監査対象 | 감사 대상 |
| Project profile | Project profile | 项目画像 | プロジェクト概要 | 프로젝트 개요 |
| Audit date | Audit date | 审计日期 | 監査日 | 감사일 |
| Reference standard | Reference standard | 对照标准 | 参照基準 | 기준 |
| Overall score | Overall score | 总体评分 | 総合スコア | 총점 |
| Score note | Score note | 评分说明 | スコアに関する注記 | 점수 설명 |
| Summary | Summary | 摘要 | 概要 | 요약 |
| Score overview | Score overview | 评分概览 | スコア一覧 | 점수 개요 |
| Detailed findings | Detailed findings | 详细发现 | 詳細な指摘 | 상세 발견 |
| Table headers | Category / Status / Key finding | 类别 / 状态 / 关键发现 | カテゴリ / 状態 / 主な指摘 | 범주 / 상태 / 핵심 발견 |
| Status values | Compliant / Partial / Missing / N/A | 符合 / 部分 / 缺失 / 不适用 | 準拠 / 部分的 / 欠落 / 該当なし | 준수 / 부분 / 누락 / 해당 없음 |
| Bands | Excellent / Good / Needs work / Early | 优秀 / 良好 / 需改进 / 起步 | 優秀 / 良好 / 要改善 / 初期 | 우수 / 양호 / 개선 필요 / 초기 |
| Org-level section | Organizational items (a repo can't auto-verify; needs human confirmation) | 组织级事项(仓库无法自动检测,需人工确认) | 組織レベルの項目(リポジトリでは自動検証不可、要人手確認) | 조직 차원 항목(저장소 자동 검증 불가, 사람 확인 필요) |
| Priority fixes | Priority fixes | 优先改进清单 | 優先改善リスト | 우선 개선 목록 |
| CLAUDE.md plugin offer (conversational reply, not in the report file) | Anthropic's official **claude-md-management** plugin audits and improves CLAUDE.md files. Optional, and you run it yourself — this audit stays read-only. Install: `/plugin install claude-md-management@claude-plugins-official` | Anthropic 官方 **claude-md-management** 插件可审计并改进 CLAUDE.md。可选,由你自行运行——本次审计保持只读。安装:`/plugin install claude-md-management@claude-plugins-official` | Anthropic 公式 **claude-md-management** プラグインは CLAUDE.md の監査と改善を行います。任意で、実行はご自身で——本監査は読み取り専用のままです。インストール:`/plugin install claude-md-management@claude-plugins-official` | Anthropic 공식 **claude-md-management** 플러그인은 CLAUDE.md 감사·개선을 수행합니다. 선택 사항이며 직접 실행합니다 — 이 감사는 읽기 전용을 유지합니다. 설치: `/plugin install claude-md-management@claude-plugins-official` |
| LSP plugin offer (conversational reply, not in the report file) | Anthropic's official per-language **LSP plugins** add symbol-precise navigation. Optional, and you run it yourself — this audit stays read-only. Install the one for your main language and put its language-server binary on PATH, e.g. `/plugin install pyright-lsp@claude-plugins-official` (Python; needs `pyright-langserver`) — see the Official LSP plugin map. | Anthropic 官方按语言提供的 **LSP 插件** 可带来符号级精确导航。可选,由你自行运行——本次审计保持只读。安装与主语言匹配的那个,并把对应语言服务器二进制加入 PATH,例如 `/plugin install pyright-lsp@claude-plugins-official`(Python,需 `pyright-langserver`)——见 Official LSP plugin map。 | Anthropic 公式の言語別 **LSP プラグイン** はシンボル単位の正確なナビゲーションを追加します。任意で、実行はご自身で——本監査は読み取り専用のままです。主要言語に合うものをインストールし、対応する言語サーバーのバイナリを PATH に追加してください。例:`/plugin install pyright-lsp@claude-plugins-official`(Python、`pyright-langserver` が必要)——Official LSP plugin map を参照。 | Anthropic 공식 언어별 **LSP 플러그인** 은 심볼 단위의 정확한 탐색을 추가합니다. 선택 사항이며 직접 실행합니다 — 이 감사는 읽기 전용을 유지합니다. 주 언어에 맞는 것을 설치하고 해당 언어 서버 바이너리를 PATH에 추가하세요. 예: `/plugin install pyright-lsp@claude-plugins-official` (Python, `pyright-langserver` 필요) — Official LSP plugin map 참조. |
| skill-creator offer (conversational reply, not in the report file) | Anthropic's official **skill-creator** plugin scaffolds, edits, and evals skills — good for extracting reusable expertise that shouldn't live in CLAUDE.md. Optional, and you run it yourself — this audit stays read-only. Install: `/plugin install skill-creator@claude-plugins-official`, then use `/skill-creator`. | Anthropic 官方 **skill-creator** 插件可创建、修改并评测 skill——适合把不该留在 CLAUDE.md 的可复用专业知识抽出来。可选,由你自行运行——本次审计保持只读。安装:`/plugin install skill-creator@claude-plugins-official`,随后使用 `/skill-creator`。 | Anthropic 公式 **skill-creator** プラグインはスキルの作成・編集・評価を行います——CLAUDE.md に置くべきでない再利用可能な専門知識の切り出しに有用です。任意で、実行はご自身で——本監査は読み取り専用のままです。インストール:`/plugin install skill-creator@claude-plugins-official`、その後 `/skill-creator` を使用。 | Anthropic 공식 **skill-creator** 플러그인은 스킬을 생성·편집·평가합니다 — CLAUDE.md에 두면 안 되는 재사용 가능한 전문 지식을 분리하는 데 좋습니다. 선택 사항이며 직접 실행합니다 — 이 감사는 읽기 전용을 유지합니다. 설치: `/plugin install skill-creator@claude-plugins-official`, 이후 `/skill-creator` 사용. |

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
