# cc-audit

[English](README.md) · **简体中文** · [日本語](README.ja.md) · [한국어](README.ko.md)

一个 [Claude Code](https://claude.com/claude-code) 技能:对照 Anthropic 公开的
大型代码库最佳实践审计你的仓库,产出一份**带评分的只读 Markdown 合规报告**——
逐项给出状态、来自仓库的具体证据,以及按优先级排序的改进清单。

对照标准:博客《[How Claude Code works in large codebases: best practices and
where to start](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start)》。

## 它做什么

对一个项目,技能会盘点全部 Claude Code 配置物料,并按博客指引对九大类打分:

| # | 类别 |
|---|---|
| 1 | CLAUDE.md 层级与精简度 |
| 2 | 文件组织与导航(`.claudeignore`、作用域命令、代码库地图) |
| 3 | Hooks(确定性检查、启动/结束上下文) |
| 4 | Skills(渐进式披露、路径作用域) |
| 5 | MCP 服务 |
| 6 | LSP / 代码智能 |
| 7 | Subagent 工作流约定 |
| 8 | Plugins / 分发 |
| 9 | 配置维护节奏 |

每项标记 `✓ 符合` / `⚠ 部分` / `✗ 缺失` / `N/A`,均附具体证据,并汇总为
0–100 分及等级(优秀 ≥85 · 良好 70–84 · 需改进 50–69 · 起步 <50)。

核心设计取舍:

- **按项目规模校准。** 单文件小工具不会因为没有 CLAUDE.md 层级或插件市场被扣分
  ——真正不适用的实践会标为 `N/A`(并给出理由)、不计入评分,而非按失败处理。
- **只读。** 绝不修改你的项目。唯一产出是写在项目根目录的报告文件
  `claude-code-audit-<YYYY-MM-DD>.md`。
- **组织治理单列。** 单个仓库无法证明的条目(配置 DRI、托管 marketplace、
  评审节奏等)以"需人工确认"清单呈现,不计分。
- **先证据,后结论。** 每条发现都引用文件路径、行数或原文片段。

## 仓库结构

```
cc-audit/                 # 可安装的技能(即本子目录)
├── SKILL.md              # 工作流 + 报告模板 + 评分规则
├── references/
│   └── checklist.md      # 逐类别审计标准 + 博客原文要点
├── scripts/
│   └── discover.sh       # 一键盘点全部 Claude Code 配置
└── evals/
    └── evals.json        # 用于验证技能的测试场景与断言
README.md                 # 本文件(及 zh-CN / ja / ko 译本)
```

## 安装

**全局(对你所有项目生效):**

```bash
git clone https://github.com/rivia7/cc-audit.git
cp -R cc-audit/cc-audit ~/.claude/skills/cc-audit
chmod +x ~/.claude/skills/cc-audit/scripts/discover.sh
```

**单项目:**

```bash
cp -R cc-audit ./你的仓库/.claude/skills/cc-audit
```

安装后请新开一个 Claude Code 会话以便发现该技能。

## 使用

为确保可靠激活,请**显式调用**:

> 用 cc-audit 技能审计这个仓库。
>
> 对照 Claude Code 工程规范审计当前项目并给我一份报告。

报告会写入 `<项目根>/claude-code-audit-<YYYY-MM-DD>.md`,并在回复中总结最高优先级
的改进项。

### 关于触发

"审计我的配置"这类请求的自动触发存在结构性上限——能力强的模型往往直接内联做一次
即兴检查,而不去调用技能。这是 Claude 的已知行为,并非本技能的缺陷。测试中该描述
从未误触发(近义陷阱用例上 precision 100%),因此可靠路径是**显式调用**(斜杠提及
或"用 cc-audit 技能")。一旦被调用,技能的审计质量是稳定的。

## 它不做什么

- 不修复、不脚手架——只出报告。需要落地修复请另行提出。
- 组织/治理条目仅为建议、需人工确认;仓库无法证明这些。

## 开发

`cc-audit/scripts/discover.sh <路径>` 打印原始物料清单。
`cc-audit/evals/evals.json` 收录了用于验证规模校准、质量判断、只读保证以及
"不无中生有"行为的场景(无配置 / 臃肿 monorepo / 精简单文件 / 配置完善)。

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=rivia7/cc-audit&type=Date)](https://star-history.com/#rivia7/cc-audit&Date)
