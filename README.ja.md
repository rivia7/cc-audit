# cc-audit

[English](README.md) · [简体中文](README.zh-CN.md) · **日本語** · [한국어](README.ko.md)

リポジトリを Anthropic 公開のラージコードベース向けベストプラクティスに照らして
監査し、**スコア付きの読み取り専用 Markdown コンプライアンスレポート**を生成する
[Claude Code](https://claude.com/claude-code) スキルです。各項目のステータス、
リポジトリから得た具体的な根拠、優先順位付きの修正リストを出力します。

参照基準:ブログ《[How Claude Code works in large codebases: best practices and
where to start](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start)》。

## 何をするか

プロジェクトに対し、すべての Claude Code 構成要素を棚卸しし、ブログの指針に沿って
9 つのカテゴリを採点します:

| # | カテゴリ |
|---|---|
| 1 | CLAUDE.md の階層と簡潔さ |
| 2 | ファイル構成とナビゲーション(`.claudeignore`、スコープ化コマンド、コードベースマップ) |
| 3 | Hooks(決定論的チェック、開始/終了コンテキスト) |
| 4 | Skills(段階的開示、パススコープ) |
| 5 | MCP サーバー |
| 6 | LSP / コードインテリジェンス |
| 7 | サブエージェントのワークフロー規約 |
| 8 | Plugins / 配布 |
| 9 | 構成メンテナンスの周期 |

各項目は `✓ 準拠` / `⚠ 部分的` / `✗ 欠落` / `N/A` で示され、具体的な根拠を伴い、
0〜100 点のスコアと評価帯(優秀 ≥85 · 良好 70–84 · 要改善 50–69 · 初期 <50)に
集約されます。

主要な設計上の判断:

- **プロジェクト規模に合わせて較正。** 単一ファイルの小さなツールが CLAUDE.md
  階層やプラグインマーケットプレイスを持たないことで減点されることはありません。
  本当に該当しないプラクティスは(理由付きで)`N/A` とされ、スコアから除外され、
  失敗として採点されません。
- **読み取り専用。** プロジェクトを一切変更しません。唯一の出力は、プロジェクト
  ルートに書き出されるレポート `claude-code-audit-<YYYY-MM-DD>.md` です。
- **組織ガバナンスは分離。** 単一リポジトリでは証明できない項目(構成 DRI、
  マネージドマーケットプレイス、レビュー周期など)は採点せず、人による確認用
  チェックリストとして提示します。
- **根拠が先、判定は後。** すべての指摘はファイルパス、行数、または引用箇所を
  明示します。

## リポジトリ構成

```
cc-audit/                 # インストール可能なスキル(このサブディレクトリ)
├── SKILL.md              # ワークフロー + レポートテンプレート + 採点ルール
├── references/
│   └── checklist.md      # カテゴリ別の監査基準 + ブログ原文の要点
├── scripts/
│   └── discover.sh       # Claude Code 構成の一括棚卸し
└── evals/
    └── evals.json        # スキル検証に使用したテストシナリオと表明
README.md                 # 本ファイル(および zh-CN / ja / ko 翻訳)
```

## インストール

**グローバル(すべてのプロジェクトで有効):**

```bash
git clone https://github.com/rivia7/cc-audit.git
cp -R cc-audit/cc-audit ~/.claude/skills/cc-audit
chmod +x ~/.claude/skills/cc-audit/scripts/discover.sh
```

**プロジェクト単位:**

```bash
cp -R cc-audit ./your-repo/.claude/skills/cc-audit
```

スキルが認識されるよう、新しい Claude Code セッションを開始してください。

## 使い方

確実に起動させるため、**明示的に呼び出して**ください:

> cc-audit スキルでこのリポジトリを監査して。
>
> 現在のプロジェクトを Claude Code のエンジニアリング規範に照らして監査し、
> レポートをください。

レポートは `<プロジェクトルート>/claude-code-audit-<YYYY-MM-DD>.md` に書き出され、
最優先の修正点が返信で要約されます。

### トリガーについて

「自分のセットアップを監査して」という類の依頼の自動トリガーには構造的な上限が
あります。能力の高いモデルは、スキルを参照せずにその場でアドホックなレビューを
行いがちです。これは Claude の既知の挙動であり、本スキルの欠陥ではありません。
テストでは説明文が誤トリガーすることは一度もなく(近似のひっかけクエリで
precision 100%)、確実な経路は**明示的な呼び出し**(スラッシュでの言及、または
「cc-audit スキルを使って」)です。呼び出されれば、監査品質は一貫しています。

## やらないこと

- 修正やスキャフォールドは行いません。レポートのみです。修正の適用が必要な場合は
  別途依頼してください。
- 組織/ガバナンス項目は助言であり、人による確認が必要です。リポジトリでは
  証明できません。

## 開発

`cc-audit/scripts/discover.sh <パス>` は生の構成要素一覧を出力します。
`cc-audit/evals/evals.json` には、規模較正・品質判断・読み取り専用保証・
「問題をでっち上げない」挙動を検証するためのシナリオ(構成なし / 肥大化した
モノレポ / 簡潔な単一ファイル / 構成良好)が含まれます。

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=rivia7/cc-audit&type=Date)](https://star-history.com/#rivia7/cc-audit&Date)
