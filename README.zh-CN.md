# cc-audit

[English](README.md) · **简体中文** · [日本語](README.ja.md) · [한국어](README.ko.md)

一个 [Claude Code](https://claude.com/claude-code) 技能:检查你的仓库为 Claude
Code 配置得好不好,产出一份带评分的只读报告。

它对照 Anthropic 的指南
[《How Claude Code works in large codebases》](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start)
给你的配置打分,每条结论都附上仓库里的实际证据,并告诉你该先修哪儿。它不动你的
代码——唯一写出的东西就是那份报告。

## 你会得到什么

把它指向一个项目,它会盘点全部 Claude Code 配置物料,然后给九个方面评级:

| 方面 | 看什么 |
|---|---|
| CLAUDE.md | 分层结构,是否精简(只放指针和坑,不堆噪音) |
| 文件组织 | `.claudeignore`、作用域命令、代码库地图 |
| Hooks | 确定性检查,启动/结束时加载上下文 |
| Skills | 渐进式披露,路径作用域 |
| MCP 服务 | 是否接入内部工具与结构化搜索 |
| LSP / 代码智能 | 规模化下的符号级导航 |
| Subagent | 探索与编辑分离的约定 |
| Plugins | 是否打包分发,而非停留在个人经验 |
| 维护 | 是否有评审节奏;过时规则是否清理 |

每项评为 `✓ 符合`、`⚠ 部分`、`✗ 缺失` 或 `N/A`,并附上判定依据。各项汇总为
0–100 分及等级:**优秀**(≥85)、**良好**(70–84)、**需改进**(50–69)、
**起步**(<50)。

这份报告凭什么值得一看:

- **标准随项目规模浮动。** 单文件脚本不会因为没有 CLAUDE.md 层级或插件市场被扣
  分。真正不适用的实践会标为 `N/A` 并给出理由、不计入评分,而不是当成失败。
- **只读。** 绝不修改你的项目。唯一产出是仓库根目录下的
  `claude-code-audit-<YYYY-MM-DD>.md`。
- **组织级条目单独列。** 仓库自身证明不了的东西——配置负责人、托管市场、评审
  节奏——放进一份交给人确认的清单,不影响评分。
- **先给证据,再下结论。** 每条结论都引用路径、行数或原文片段。

## 目录结构

```
cc-audit/                 # 技能本体(即本子目录)
├── SKILL.md              # 工作流、报告模板、评分规则
├── references/
│   └── checklist.md      # 各方面判定标准与来源指南
├── scripts/
│   └── discover.sh       # 一次性盘点 Claude Code 配置
└── evals/
    └── evals.json        # 用于验证技能的测试场景
README.md                 # 你在这里(译本:zh-CN、ja、ko)
```

## 安装

全局安装,对你所有项目生效:

```bash
git clone https://github.com/rivia7/cc-audit.git
cp -R cc-audit/cc-audit ~/.claude/skills/cc-audit
chmod +x ~/.claude/skills/cc-audit/scripts/discover.sh
```

或者只装到某个仓库:

```bash
cp -R cc-audit your-repo/.claude/skills/cc-audit
```

然后新开一个 Claude Code 会话,让它识别到这个技能。

## 用法

点名调用——这是最稳的运行方式:

> 用 cc-audit 技能审计这个仓库。

报告会写到 `<仓库>/claude-code-audit-<YYYY-MM-DD>.md`,最高优先级的改进项会在
回复里给你总结。

**为什么要点名?** 遇到「审计我的配置」这类请求,能力强的模型往往自己直接看了,
而不去调用技能——这是 Claude 的已知习性,不是这里的缺陷。好处是它绝不会在不该
触发时触发(测试中对相似干扰提示零误触发)。所以请显式调用;一旦跑起来,审计
质量是稳定的。

## 不在范围内

- 它只报告,不修复。需要落地修改请另外说。
- 当审计发现某个官方工具针对的缺口时,回复会把它作为可选的下一步、由你自行
  运行向你指出:CLAUDE.md 薄弱时是 `claude-md-management` 插件,代码智能薄弱时
  是按语言的 LSP 插件,缺 skill 时是 `skill-creator` 插件。审计本身不安装
  任何东西,保持只读。
- 组织与治理类条目是交给人确认的建议——仓库证明不了这些。

## 开发

运行 `cc-audit/scripts/discover.sh <路径>` 可打印原始物料清单。
`cc-audit/evals/evals.json` 收录了用于验证的四个场景——无配置、臃肿 monorepo、
精简单文件、配置完善——覆盖规模校准、质量判断、只读保证,以及「不无中生有」。

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=rivia7/cc-audit&type=Date)](https://star-history.com/#rivia7/cc-audit&Date)
