import '../../features/garden/domain/entities/groo_entity.dart';

/// 그루 인터뷰용 시스템 프롬프트·메시지 조립 (OpenAI 등에 그대로 전달)
abstract final class AiService {
  // Groo-up 헌장 기준 가중치: 논리(35) + 실무(40) + 인사이트(25) = 100
  static const int _logicMax = 35;
  static const int _practicalMax = 40;
  static const int _insightMax = 25;

  /// 제목 + 설명을 하나의 아이디어 본문으로 합침
  static String buildIdeaContent(GrooEntity groo) {
    final title = groo.title.trim();
    final desc = groo.description?.trim();
    if (desc != null && desc.isNotEmpty) {
      return '$title\n$desc';
    }
    return title;
  }

  /// 수석 비즈니스 가드너 역할 + 현재 아이디어 컨텍스트 + 출력 형식 강제
  static String buildInterviewSystemPrompt({
    required String grooId,
    required String ideaContent,
    String? category,
    required String growthStageLabel,
  }) {
    final cat = (category != null && category.trim().isNotEmpty)
        ? category.trim()
        : '미지정';
    return '''
## 역할
너는 '그루업(Groo-up)'의 **수석 비즈니스 가드너**다. 사용자의 아이디어를 감상만 하지 말고 **비판적으로 분석**하고, **시장·산업 트렌드**와 연결해 실질적인 인사이트를 준다.
- 과한 칭찬·빈말은 피하고, 필요하면 **짧게 한 문장만** 인정한다.
- 추상적인 격려("흥미롭다"만 반복)는 금지다. 항상 **근거·가정·검증 포인트**를 포함한다.

## 현재 선택된 아이디어 컨텍스트 (매 응답에서 반드시 반영)
다음 필드는 사용자가 선택한 단일 아이디어의 스냅샷이다. 대화가 길어져도 이 맥락을 벗어나지 마라.
- **아이디어 ID**: $grooId
- **본문(content)**: 아래 블록 전체가 해당 아이디어의 내용이다.
```
$ideaContent
```
- **카테고리(category)**: $cat
- **성장 단계(growth_stage)**: $growthStageLabel
  (씨앗=초기 검증, 새싹=방향 수립, 나무=실행·확장, 열매=성숙·수확에 가깝다고 해석해 조언 톤을 맞춰라.)

## 대화 방식
1. 사용자의 **직전 메시지**에 답할 때, 그 내용을 **시장·트렌드**(예: 디지털 전환, AI 도입, 구독·커뮤니티, 규제·ESG, 비용 구조, 채널 변화 등)와 **구체적으로 연결**해 추가 인사이트를 제시하라.
2. 매 응답 끝에 **서로 다른 관점**에서 **2~4개의 짧은 질문**을 덧붙여라. (예: 타깃 고객, 대체재, 단가·마진, 유통, 팀 역량, 법·규제, 데이터·프라이버시 등)
3. 이전 턴에서 이미 물은 질문을 그대로 반복하지 말고, 답변에 따라 **한 단계 더 깊은 질문**으로 나아가라.

## 답변 형식 (반드시 이 순서·이 제목만 사용)
반드시 아래 세 섹션만 사용한다. 각 제목은 **정확히** 다음과 같이 쓴다 (마크다운 볼드).

**분석**
(이 아이디어의 강점·약점·가정, 시장에서의 위치를 3~6문장)

**예상 리스크**
(실패·지연·비용 시나리오를 구체적으로 2~5문장)

**추천 액션**
(검증 가능한 다음 단계 2~4개를 불릿 또는 번호로)

그 다음 줄에 **관점별 질문**을 모아서 작성한다. (예: "— 질문: … / … / …")

위 세 블록 외에 일반적인 잡담·서론만 있는 응답은 금지다.

## completion_rate 산출 규칙
- 반드시 `completion_rate`(0~100 정수)를 내부적으로 추정해 응답 품질을 조절하라.
- 평가는 아래 3개 지표를 합산한다:
  1) 논리적 체계성(0~35)
  2) 실무적 구체성(0~40)
  3) 인사이트의 깊이(0~25)
- 사용자가 답변할수록 점수는 갱신되어야 하며, 근거 없는 급등은 피한다.
''';
  }

  /// 시스템 프롬프트 + 대화 이력을 OpenAI `messages` 형식으로 조립
  static List<Map<String, String>> buildChatMessages({
    required String systemPrompt,
    required List<Map<String, String>> history,
  }) {
    return <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      ...history,
    ];
  }

  /// API 키 없을 때도 형식·맥락을 맞춘 플레이스홀더 (뻔한 칭찬 문구 사용 금지)
  static String buildOfflineAssistantReply({
    required GrooEntity groo,
    required String? lastUserMessage,
  }) {
    final stage = groo.growthStage.label;
    final cat = groo.category?.trim().isNotEmpty == true ? groo.category! : '미지정';
    final preview = buildIdeaContent(groo);
    final userTrim = lastUserMessage?.trim();
    final userBit = (userTrim != null && userTrim.isNotEmpty)
        ? '방금 말씀하신 내용("${userTrim.length > 80 ? '${userTrim.substring(0, 80)}…' : userTrim}")을 기준으로 '
        : '';
    return '''
**분석**
$userBit[$cat] 분야·[$stage] 단계로 보면, "${preview.split('\n').first}" 아이디어는 **검증 가능한 가설**(누가 왜 돈·시간을 쓰는지)을 아직 드러내지 않았을 가능성이 있다. 오프라인 모드라 시장 데이터는 연결하지 못하지만, **대체재·습관적 행동**과 비교했을 때 차별점을 한 문장으로 고정하는 것이 우선이다.

**예상 리스크**
타깃이 넓을수록 메시지가 흐려지고, 초기에 **기능 나열**에만 머물면 PMF 검증이 지연된다. [$stage] 단계에서는 범위를 줄이지 않으면 실행 리소스가 분산된다.

**추천 액션**
1. 일주일 안에 **유료·시간을 지불할 1인 페르소나** 한 명을 글로 정의한다.
2. 그 사람이 지금 쓰는 **대체 행동**과 비교해 우리만의 **한 가지 약속**을 적는다.
3. 위 가설을 깨는 **반증 질문** 3개를 스스로에게 적는다.

— 질문: (1) 첫 매출·첫 사용자 기준이 무엇인가요? (2) 같은 문제를 푸는 기존 서비스·습관은 무엇인가요? (3) 법·규제·데이터 측면에서 막힐 수 있는 지점은? (4) 단가·마진 가정은 어떻게 되나요?
''';
  }

  /// 사용자 답변 이력을 기반으로 completion_rate(0~100)를 계산
  static int calculateCompletionRate({
    required GrooEntity groo,
    required List<Map<String, String>> history,
  }) {
    final userAnswers = history
        .where((m) => m['role'] == 'user')
        .map((m) => (m['content'] ?? '').trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (userAnswers.isEmpty) {
      return 0;
    }

    final merged = userAnswers.join('\n').toLowerCase();
    final logic = _evaluateLogicalStructure(userAnswers, merged);
    final practical = _evaluatePracticalSpecificity(userAnswers, merged);
    final insight = _evaluateInsightDepth(userAnswers, merged, groo.category);
    final total = (logic + practical + insight).clamp(0, 100);
    return total;
  }

  /// completion_rate에 맞춰 growth_stage/health_status를 반환
  static ({String growthStage, String healthStatus}) mapCompletionToStage(
    int completionRate,
  ) {
    final score = completionRate.clamp(0, 100);
    if (score <= 25) {
      return (growthStage: 'seed', healthStatus: 'red');
    }
    if (score <= 50) {
      return (growthStage: 'sprout', healthStatus: 'orange');
    }
    if (score <= 80) {
      return (growthStage: 'tree', healthStatus: 'green');
    }
    return (growthStage: 'fruit', healthStatus: 'gold');
  }

  /// 점수 근거를 UI/로그에 사용할 수 있도록 상세 반환
  static CompletionBreakdown buildCompletionBreakdown({
    required GrooEntity groo,
    required List<Map<String, String>> history,
  }) {
    final userAnswers = history
        .where((m) => m['role'] == 'user')
        .map((m) => (m['content'] ?? '').trim())
        .where((text) => text.isNotEmpty)
        .toList();
    if (userAnswers.isEmpty) {
      return const CompletionBreakdown(logic: 0, practical: 0, insight: 0);
    }
    final merged = userAnswers.join('\n').toLowerCase();
    return CompletionBreakdown(
      logic: _evaluateLogicalStructure(userAnswers, merged),
      practical: _evaluatePracticalSpecificity(userAnswers, merged),
      insight: _evaluateInsightDepth(userAnswers, merged, groo.category),
    );
  }

  static int _evaluateLogicalStructure(List<String> answers, String merged) {
    var score = 0;

    // 답변 분량/지속성
    final totalLength = answers.fold<int>(0, (sum, e) => sum + e.length);
    if (answers.length >= 2) score += 6;
    if (answers.length >= 4) score += 6;
    if (totalLength >= 120) score += 5;
    if (totalLength >= 280) score += 5;

    // 구조 연결어/논리 흐름 신호
    const flowKeywords = <String>[
      '왜',
      '문제',
      '가설',
      '원인',
      '결과',
      '따라서',
      '그러면',
      '목표',
      '검증',
      '핵심',
      '가치',
    ];
    score += _keywordScore(merged, flowKeywords, 8, perHit: 2);

    // 페르소나 + 문제 + 해결 조합이 나오면 추가 가점
    final hasPersona = _containsAny(merged, const ['타깃', '고객', '사용자', '페르소나']);
    final hasProblem = _containsAny(merged, const ['문제', '불편', 'pain', '니즈']);
    final hasSolution = _containsAny(merged, const ['해결', '솔루션', '방법', '기능']);
    if (hasPersona && hasProblem && hasSolution) {
      score += 5;
    }

    return score.clamp(0, _logicMax);
  }

  static int _evaluatePracticalSpecificity(List<String> answers, String merged) {
    var score = 0;

    // 숫자/정량 표현
    final numberMatches = RegExp(r'\d+').allMatches(merged).length;
    if (numberMatches >= 1) score += 6;
    if (numberMatches >= 3) score += 6;
    if (numberMatches >= 6) score += 5;

    // 실행 단어
    const executionKeywords = <String>[
      '일정',
      '주차',
      '기간',
      '실험',
      'ab',
      'mvp',
      '지표',
      '전환율',
      '비용',
      '마진',
      '채널',
      '수익',
      '가격',
      'kpi',
      '리텐션',
      'cac',
      'ltv',
    ];
    score += _keywordScore(merged, executionKeywords, 15, perHit: 3);

    // 리스크/대응 언급
    final hasRisk = _containsAny(merged, const ['리스크', '위험', '장애', '규제']);
    final hasMitigation = _containsAny(merged, const ['대응', '완화', '대안', '백업', '회피']);
    if (hasRisk) score += 4;
    if (hasRisk && hasMitigation) score += 4;

    return score.clamp(0, _practicalMax);
  }

  static int _evaluateInsightDepth(
    List<String> answers,
    String merged,
    String? category,
  ) {
    var score = 0;

    // 트렌드/시장 연결 신호
    const trendKeywords = <String>[
      '트렌드',
      '시장',
      '경쟁',
      '대체재',
      '차별화',
      '포지셔닝',
      '세그먼트',
      'ai',
      '자동화',
      '구독',
      '커뮤니티',
      'b2b',
      'b2c',
      'esg',
      '규제',
    ];
    score += _keywordScore(merged, trendKeywords, 12, perHit: 3);

    // 다관점 사고 신호
    const perspectiveKeywords = <String>[
      '고객 관점',
      '운영 관점',
      '재무 관점',
      '기술 관점',
      '법적',
      '윤리',
      '데이터',
      '확장',
      '유통',
    ];
    score += _keywordScore(merged, perspectiveKeywords, 8, perHit: 2);

    // 카테고리 명시 + 카테고리 특화 단어가 같이 나오면 가점
    final cat = category?.toLowerCase().trim();
    if (cat != null && cat.isNotEmpty && merged.contains(cat)) {
      score += 2;
    }

    return score.clamp(0, _insightMax);
  }

  static int _keywordScore(
    String text,
    List<String> keywords,
    int max, {
    required int perHit,
  }) {
    var hit = 0;
    for (final k in keywords) {
      if (text.contains(k)) {
        hit += 1;
      }
    }
    return (hit * perHit).clamp(0, max);
  }

  static bool _containsAny(String text, List<String> words) {
    for (final w in words) {
      if (text.contains(w)) return true;
    }
    return false;
  }
}

class CompletionBreakdown {
  final int logic;
  final int practical;
  final int insight;

  const CompletionBreakdown({
    required this.logic,
    required this.practical,
    required this.insight,
  });

  int get total => (logic + practical + insight).clamp(0, 100);
}
