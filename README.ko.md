# cc-audit

[English](README.md) · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · **한국어**

저장소가 Claude Code에 얼마나 잘 맞춰져 있는지 점검하고, 점수가 매겨진 읽기
전용 보고서를 작성하는 [Claude Code](https://claude.com/claude-code) 스킬입니다.

Anthropic 가이드
[《How Claude Code works in large codebases》](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start)
에 비추어 구성을 채점하고, 모든 지적에 저장소의 실제 근거를 붙이며, 무엇부터
고쳐야 하는지 알려줍니다. 코드는 전혀 건드리지 않습니다. 작성하는 것은 보고서
하나뿐입니다.

## 무엇을 얻나요

프로젝트를 대상으로 실행하면 Claude Code 구성 요소를 모두 점검한 뒤 9개 영역을
채점합니다.

| 영역 | 보는 것 |
|---|---|
| CLAUDE.md | 계층 구조인지, 간결한지(지침과 함정만, 잡음은 배제) |
| 파일 구성 | `.claudeignore`, 범위 지정 명령, 코드베이스 맵 |
| Hooks | 결정론적 검사, 시작/종료 시 컨텍스트 로딩 |
| Skills | 점진적 공개, 경로 범위 지정 |
| MCP 서버 | 내부 도구와 구조화 검색이 연결되어 있는지 |
| LSP / 코드 인텔리전스 | 대규모에서의 심벌 단위 탐색 |
| 서브에이전트 | "탐색 후 편집" 규약 |
| Plugins | 개인 노하우에 그치지 않고 패키지화·배포되었는지 |
| 유지 관리 | 검토 주기가 있는지, 오래된 규칙이 제거되었는지 |

각 항목은 `✓ 준수`, `⚠ 부분`, `✗ 누락`, `N/A` 로 평가하고 판단 근거를 함께
제시합니다. 전체는 0–100점 점수와 등급으로 집계됩니다: **우수**(≥85),
**양호**(70–84), **개선 필요**(50–69), **초기**(<50).

이 보고서가 읽을 가치가 있는 이유:

- **기준이 프로젝트 규모에 맞춰 움직입니다.** 단일 파일 스크립트가 CLAUDE.md
  계층이나 플러그인 마켓플레이스가 없다고 감점되지 않습니다. 실제로 해당되지
  않는 항목은 이유와 함께 `N/A` 로 두고 점수에서 제외하며, 실패로 세지
  않습니다.
- **읽기 전용입니다.** 프로젝트를 수정하지 않습니다. 출력은 저장소 루트의
  `claude-code-audit-<YYYY-MM-DD>.md` 하나뿐입니다.
- **조직 차원 항목은 분리합니다.** 저장소 혼자서는 증명할 수 없는 것들——구성
  담당자, 관리형 마켓플레이스, 검토 주기——은 사람이 확인하는 체크리스트로
  모으고 점수에는 반영하지 않습니다.
- **결론보다 근거가 먼저입니다.** 모든 지적이 경로, 줄 수, 또는 인용을
  제시합니다.

## 구조

```
cc-audit/                 # 스킬 본체(이 하위 디렉터리)
├── SKILL.md              # 워크플로, 보고서 템플릿, 채점 기준
├── references/
│   └── checklist.md      # 영역별 판정 기준과 출처 가이드
├── scripts/
│   └── discover.sh       # Claude Code 구성 일괄 점검
└── evals/
    └── evals.json        # 스킬 검증에 쓰는 시나리오
README.md                 # 현재 위치(번역: zh-CN, ja, ko)
```

## 설치

작업하는 모든 프로젝트에서 쓰도록 전역 설치:

```bash
git clone https://github.com/rivia7/cc-audit.git
cp -R cc-audit/cc-audit ~/.claude/skills/cc-audit
chmod +x ~/.claude/skills/cc-audit/scripts/discover.sh
```

특정 저장소에만 넣으려면:

```bash
cp -R cc-audit your-repo/.claude/skills/cc-audit
```

그런 다음 스킬이 인식되도록 새 Claude Code 세션을 시작하세요.

## 사용법

이름을 지정해 호출하세요——이것이 확실한 실행 방법입니다.

> cc-audit 스킬로 이 저장소를 감사해줘.

보고서는 `<저장소>/claude-code-audit-<YYYY-MM-DD>.md` 에 작성되며, 우선순위가
높은 수정 항목이 답변에 요약됩니다.

**왜 이름을 지정하나요?** "내 구성을 감사해줘" 같은 요청에서는 능력 있는
모델이 스킬을 부르지 않고 직접 살펴보는 경향이 있습니다. 이는 Claude의 알려진
성향이며 여기서의 결함이 아닙니다. 장점은 필요 없을 때 발동하지 않는다는
점입니다(테스트에서 유사 프롬프트에 대한 오발동 0건). 그러므로 명시적으로
호출하세요. 일단 실행되면 감사 품질은 일관됩니다.

## 범위 밖

- 보고는 하지만 수정은 하지 않습니다. 적용이 필요하면 별도로 요청하세요.
- CLAUDE.md가 취약 지점인 경우(또는 전체 점수가 70 미만인 경우), 답변에서
  Anthropic 공식 `claude-md-management` 플러그인을 선택적 다음 단계로
  안내합니다. 실행은 직접 하시면 됩니다——감사 자체는 읽기 전용을 유지합니다.
- 조직·거버넌스 항목은 사람이 확인할 권고입니다. 저장소가 증명할 수 없습니다.

## 개발

`cc-audit/scripts/discover.sh <경로>` 로 원시 점검 결과를 출력합니다.
`cc-audit/evals/evals.json` 에는 검증용 시나리오 4개——구성 없음, 비대한
모노레포, 간결한 단일 파일, 구성 양호——가 들어 있어 규모 보정, 품질 판단,
읽기 전용 보장, "문제를 지어내지 않음"을 검증합니다.

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=rivia7/cc-audit&type=Date)](https://star-history.com/#rivia7/cc-audit&Date)
