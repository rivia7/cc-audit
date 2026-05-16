# cc-audit

[English](README.md) · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · **한국어**

저장소를 Anthropic이 공개한 대규모 코드베이스 모범 사례에 비추어 감사하고,
**점수가 매겨진 읽기 전용 Markdown 컴플라이언스 보고서**를 생성하는
[Claude Code](https://claude.com/claude-code) 스킬입니다. 항목별 상태,
저장소에서 얻은 구체적 근거, 우선순위가 매겨진 수정 목록을 출력합니다.

기준 문서: 블로그 《[How Claude Code works in large codebases: best practices and
where to start](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start)》.

## 무엇을 하나요

프로젝트에 대해 모든 Claude Code 구성 요소를 점검하고, 블로그 지침에 따라
9개 범주를 채점합니다:

| # | 범주 |
|---|---|
| 1 | CLAUDE.md 계층 구조와 간결성 |
| 2 | 파일 구성 및 탐색(`.claudeignore`, 범위 지정 명령, 코드베이스 맵) |
| 3 | Hooks(결정론적 검사, 시작/종료 컨텍스트) |
| 4 | Skills(점진적 공개, 경로 범위 지정) |
| 5 | MCP 서버 |
| 6 | LSP / 코드 인텔리전스 |
| 7 | 서브에이전트 워크플로 규약 |
| 8 | Plugins / 배포 |
| 9 | 구성 유지 관리 주기 |

각 항목은 `✓ 준수` / `⚠ 부분` / `✗ 누락` / `N/A` 로 표시되며 구체적 근거가
뒷받침되고, 0–100점 점수와 등급(우수 ≥85 · 양호 70–84 · 개선 필요 50–69 ·
초기 <50)으로 집계됩니다.

핵심 설계 결정:

- **프로젝트 규모에 맞춰 보정.** 단일 파일 소형 도구가 CLAUDE.md 계층이나
  플러그인 마켓플레이스가 없다는 이유로 감점되지 않습니다. 실제로 해당되지 않는
  사례는 (이유와 함께) `N/A` 로 표시되어 점수에서 제외되며, 실패로 채점되지
  않습니다.
- **읽기 전용.** 프로젝트를 절대 수정하지 않습니다. 유일한 산출물은 프로젝트
  루트에 작성되는 보고서 `claude-code-audit-<YYYY-MM-DD>.md` 입니다.
- **조직 거버넌스는 분리.** 단일 저장소가 증명할 수 없는 항목(구성 DRI,
  관리형 마켓플레이스, 검토 주기 등)은 채점하지 않고 사람이 확인하는
  체크리스트로 제시합니다.
- **근거 먼저, 판정은 나중.** 모든 발견은 파일 경로, 줄 수, 또는 인용 구절을
  명시합니다.

## 저장소 구조

```
cc-audit/                 # 설치 가능한 스킬(이 하위 디렉터리)
├── SKILL.md              # 워크플로 + 보고서 템플릿 + 채점 기준
├── references/
│   └── checklist.md      # 범주별 감사 기준 + 블로그 원문 요점
├── scripts/
│   └── discover.sh       # 모든 Claude Code 구성 일괄 점검
└── evals/
    └── evals.json        # 스킬 검증에 사용한 테스트 시나리오와 어서션
README.md                 # 이 파일(및 zh-CN / ja / ko 번역)
```

## 설치

**전역(모든 프로젝트에 적용):**

```bash
git clone https://github.com/rivia7/cc-audit.git
cp -R cc-audit/cc-audit ~/.claude/skills/cc-audit
chmod +x ~/.claude/skills/cc-audit/scripts/discover.sh
```

**프로젝트 단위:**

```bash
cp -R cc-audit ./your-repo/.claude/skills/cc-audit
```

스킬이 인식되도록 새 Claude Code 세션을 시작하세요.

## 사용법

안정적으로 활성화하려면 **명시적으로 호출**하세요:

> cc-audit 스킬로 이 저장소를 감사해줘.
>
> 현재 프로젝트를 Claude Code 엔지니어링 모범 사례에 비추어 감사하고 보고서를
> 줘.

보고서는 `<프로젝트 루트>/claude-code-audit-<YYYY-MM-DD>.md` 에 작성되며, 최우선
수정 항목이 답변에 요약됩니다.

### 트리거에 관하여

"내 설정을 감사해줘" 류 요청의 자동 트리거에는 구조적 한계가 있습니다. 능력 있는
모델은 스킬을 참조하지 않고 그 자리에서 즉석 검토를 해버리는 경향이 있습니다.
이는 Claude의 알려진 동작이며 이 스킬의 결함이 아닙니다. 테스트에서 설명문이
오트리거된 적은 한 번도 없었으므로(유사·함정 쿼리에서 precision 100%), 안정적인
경로는 **명시적 호출**(슬래시 언급 또는 "cc-audit 스킬 사용")입니다. 호출되면
감사 품질은 일관됩니다.

## 하지 않는 것

- 수정이나 스캐폴딩을 하지 않습니다 — 보고만 합니다. 수정 적용이 필요하면 별도로
  요청하세요.
- 조직/거버넌스 항목은 권고이며 사람의 확인이 필요합니다. 저장소가 이를 증명할
  수 없습니다.

## 개발

`cc-audit/scripts/discover.sh <경로>` 는 원시 구성 요소 목록을 출력합니다.
`cc-audit/evals/evals.json` 에는 규모 보정, 품질 판단, 읽기 전용 보장,
"문제를 지어내지 않음" 동작을 검증하는 시나리오(구성 없음 / 비대한 모노레포 /
간결한 단일 파일 / 구성 양호)가 들어 있습니다.

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=rivia7/cc-audit&type=Date)](https://star-history.com/#rivia7/cc-audit&Date)
