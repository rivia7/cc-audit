# cc-audit

[English](README.md) · [简体中文](README.zh-CN.md) · **日本語** · [한국어](README.ko.md)

リポジトリが Claude Code 向けにどれだけ整っているかを点検し、スコア付きの
読み取り専用レポートを出力する [Claude Code](https://claude.com/claude-code)
スキルです。

Anthropic のガイド
[《How Claude Code works in large codebases》](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start)
に照らして構成を採点し、すべての指摘にリポジトリ内の実証拠を添え、まず何を
直すべきかを示します。コードには一切手を加えません。書き出すのはレポートだけ
です。

## 得られるもの

プロジェクトに向けて実行すると、Claude Code の構成要素をすべて棚卸しし、
9 つの領域を採点します。

| 領域 | 見るところ |
|---|---|
| CLAUDE.md | 階層化されているか、簡潔か(指針と落とし穴だけで、雑音を入れない) |
| ファイル構成 | `.claudeignore`、スコープ化したコマンド、コードベースマップ |
| Hooks | 決定論的チェック、開始/終了時のコンテキスト読み込み |
| Skills | 段階的開示、パススコープ |
| MCP サーバー | 社内ツールや構造化検索が接続されているか |
| LSP / コードインテリジェンス | 大規模でのシンボル単位のナビゲーション |
| サブエージェント | 「調査してから編集」の規約 |
| Plugins | 個人の暗黙知で終わらず、パッケージ化・配布されているか |
| メンテナンス | レビュー周期があるか、古い規則が除去されているか |

各項目は `✓ 準拠`・`⚠ 部分的`・`✗ 欠落`・`N/A` で評価し、判断根拠を添えます。
全体は 0〜100 点のスコアと評価帯にまとめます:**優秀**(≥85)、**良好**
(70–84)、**要改善**(50–69)、**初期**(<50)。

このレポートが読むに値する理由:

- **基準はプロジェクト規模に合わせて動く。** 単一ファイルのスクリプトが
  CLAUDE.md 階層やプラグインマーケットプレイスを持たないことで減点される
  ことはありません。本当に該当しない項目は理由付きで `N/A` とし、スコアから
  外します。失敗としては数えません。
- **読み取り専用。** プロジェクトを変更しません。出力はリポジトリ直下の
  `claude-code-audit-<YYYY-MM-DD>.md` 一つだけです。
- **組織レベルの項目は分離。** リポジトリ単体では証明できないこと——構成の
  責任者、マネージドマーケットプレイス、レビュー周期——は人が確認する
  チェックリストにまとめ、スコアには影響させません。
- **結論より先に根拠。** すべての指摘がパス・行数・抜粋のいずれかを示します。

## 構成

```
cc-audit/                 # スキル本体(このサブディレクトリ)
├── SKILL.md              # ワークフロー、レポートテンプレート、採点基準
├── references/
│   └── checklist.md      # 領域別の判定基準と出典ガイド
├── scripts/
│   └── discover.sh       # Claude Code 構成の一括棚卸し
└── evals/
    └── evals.json        # スキル検証に使うシナリオ
README.md                 # いまここ(翻訳:zh-CN、ja、ko)
```

## インストール

すべてのプロジェクトで使えるように、グローバルに:

```bash
git clone https://github.com/rivia7/cc-audit.git
cp -R cc-audit/cc-audit ~/.claude/skills/cc-audit
chmod +x ~/.claude/skills/cc-audit/scripts/discover.sh
```

特定のリポジトリだけに入れる場合:

```bash
cp -R cc-audit your-repo/.claude/skills/cc-audit
```

その後、スキルが認識されるように Claude Code を新しいセッションで開き直して
ください。

## 使い方

名前を指定して呼ぶ——これが確実な実行方法です。

> cc-audit スキルでこのリポジトリを監査して。

レポートは `<リポジトリ>/claude-code-audit-<YYYY-MM-DD>.md` に出力され、
優先度の高い修正点が返信に要約されます。

**なぜ名前を指定するのか。** 「自分の構成を監査して」という依頼では、能力の
高いモデルはスキルを呼ばず自分で見てしまいがちです。これは Claude の既知の
性質であって、ここでの欠陥ではありません。利点は、不要なときに発動しないこと
です(テストでは類似プロンプトでの誤発動はゼロ)。ですから明示的に呼んで
ください。動き出せば監査の品質は安定しています。

## 対象外

- レポートはしますが修正はしません。適用が必要なら別途依頼してください。
- 組織・ガバナンス項目は人が確認するための助言です。リポジトリには証明
  できません。

## 開発

`cc-audit/scripts/discover.sh <パス>` で生の棚卸し結果を表示します。
`cc-audit/evals/evals.json` には検証用の 4 シナリオ——構成なし、肥大化した
モノレポ、簡潔な単一ファイル、構成良好——が入っており、規模較正・品質判断・
読み取り専用の保証・「問題をでっち上げない」ことを検証します。

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=rivia7/cc-audit&type=Date)](https://star-history.com/#rivia7/cc-audit&Date)
