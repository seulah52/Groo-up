# Groo-up (그루업) — Flutter Architecture Document

## 1. 폴더 트리 구조 (lib/)

```
lib/
├── main.dart
├── app.dart                          # MaterialApp + ProviderScope 루트
│
├── core/                             # 앱 전역 핵심 인프라
│   ├── config/
│   │   ├── app_config.dart           # 환경변수 (dev/staging/prod)
│   │   ├── supabase_config.dart
│   │   └── openai_config.dart
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_dimensions.dart
│   │   └── app_strings.dart          # 다국어 준비용 상수
│   ├── errors/
│   │   ├── app_exception.dart        # 커스텀 예외 클래스
│   │   ├── failure.dart              # Either<Failure, T> 패턴
│   │   └── error_handler.dart
│   ├── network/
│   │   ├── supabase_client.dart      # Supabase 싱글턴 Provider
│   │   ├── openai_client.dart        # Dio + OpenAI base
│   │   └── network_info.dart         # 인터넷 연결 상태
│   ├── router/
│   │   ├── app_router.dart           # GoRouter 설정
│   │   ├── app_routes.dart           # 경로 상수
│   │   └── route_guards.dart         # 인증 가드
│   ├── services/
│   │   ├── analytics_service.dart
│   │   ├── notification_service.dart # FCM
│   │   ├── home_widget_service.dart  # Home Widget 브릿지
│   │   └── local_storage_service.dart # SharedPreferences
│   └── utils/
│       ├── date_utils.dart
│       ├── growth_calculator.dart    # 씨앗→열매 성장 로직
│       └── extensions/
│           ├── string_extensions.dart
│           ├── datetime_extensions.dart
│           └── context_extensions.dart
│
├── shared/                           # 재사용 가능한 공유 컴포넌트
│   ├── animations/
│   │   ├── animation_controller.dart
│   │   ├── lottie_wrapper.dart       # Lottie 교체 가능 래퍼
│   │   ├── rive_wrapper.dart         # Rive 캐릭터 교체 가능 래퍼
│   │   └── growth_animation.dart     # 성장 단계 전환 애니메이션
│   ├── providers/
│   │   ├── auth_provider.dart        # 전역 인증 상태
│   │   └── theme_provider.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── light_theme.dart
│   │   └── dark_theme.dart
│   └── widgets/
│       ├── buttons/
│       │   ├── primary_button.dart
│       │   └── icon_action_button.dart
│       ├── cards/
│       │   ├── base_card.dart
│       │   └── insight_card.dart
│       ├── dialogs/
│       │   └── confirm_dialog.dart
│       ├── inputs/
│       │   ├── goo_text_field.dart
│       │   └── chat_input_bar.dart
│       └── loaders/
│           ├── shimmer_loader.dart
│           └── growth_progress_indicator.dart
│
└── features/                         # Feature-first 도메인 분리
    │
    ├── auth/                         # 인증 도메인
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── auth_remote_datasource.dart
    │   │   ├── models/
    │   │   │   └── user_model.dart
    │   │   └── repositories/
    │   │       └── auth_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── user_entity.dart
    │   │   ├── repositories/
    │   │   │   └── auth_repository.dart  # 추상 인터페이스
    │   │   └── usecases/
    │   │       ├── sign_in_usecase.dart
    │   │       ├── sign_up_usecase.dart
    │   │       └── sign_out_usecase.dart
    │   └── presentation/
    │       ├── providers/
    │       │   └── auth_state_provider.dart
    │       ├── screens/
    │       │   ├── login_screen.dart
    │       │   └── onboarding_screen.dart
    │       └── widgets/
    │           └── social_login_button.dart
    │
    ├── garden/                       # 🌳 과수원 메인 화면
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── groo_remote_datasource.dart
    │   │   │   └── groo_local_datasource.dart  # 오프라인 캐시
    │   │   ├── models/
    │   │   │   ├── groo_model.dart
    │   │   │   └── growth_step_model.dart
    │   │   └── repositories/
    │   │       └── garden_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── groo_entity.dart
    │   │   │   ├── growth_step_entity.dart
    │   │   │   └── growth_stage.dart      # enum: seed/sprout/tree/fruit
    │   │   ├── repositories/
    │   │   │   └── garden_repository.dart
    │   │   └── usecases/
    │   │       ├── get_all_groos_usecase.dart
    │   │       ├── update_growth_stage_usecase.dart
    │   │       └── calculate_health_usecase.dart
    │   └── presentation/
    │       ├── providers/
    │       │   ├── garden_provider.dart        # AsyncNotifierProvider
    │       │   ├── groo_animation_provider.dart # 애니메이션 상태
    │       │   └── groo_filter_provider.dart    # 상태 필터 (빨강/주황/초록)
    │       ├── screens/
    │       │   ├── garden_screen.dart
    │       │   └── groo_detail_screen.dart
    │       └── widgets/
    │           ├── garden_canvas.dart         # 나무들 배치 캔버스
    │           ├── groo_tree_widget.dart      # 개별 나무 위젯
    │           ├── growth_stage_badge.dart
    │           └── health_status_indicator.dart  # 빨강/주황/초록
    │
    ├── input/                        # 🌱 씨앗 심기
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   └── input_remote_datasource.dart
    │   │   └── repositories/
    │   │       └── input_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── seed_entity.dart
    │   │   ├── repositories/
    │   │   │   └── input_repository.dart
    │   │   └── usecases/
    │   │       ├── plant_seed_usecase.dart
    │   │       └── get_quick_templates_usecase.dart
    │   └── presentation/
    │       ├── providers/
    │       │   └── input_provider.dart
    │       ├── screens/
    │       │   └── input_screen.dart
    │       └── widgets/
    │           ├── quick_input_bar.dart       # 홈 위젯 연동 입력창
    │           ├── category_selector.dart
    │           └── seed_animation_widget.dart # 심기 완료 애니메이션
    │
    ├── interview/                    # 🤖 AI 그루 대화
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── interview_remote_datasource.dart  # Supabase 저장
    │   │   │   └── openai_datasource.dart             # OpenAI API 호출
    │   │   ├── models/
    │   │   │   ├── message_model.dart
    │   │   │   └── interview_session_model.dart
    │   │   └── repositories/
    │   │       └── interview_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   ├── message_entity.dart
    │   │   │   └── interview_session_entity.dart
    │   │   ├── repositories/
    │   │   │   └── interview_repository.dart
    │   │   └── usecases/
    │   │       ├── send_message_usecase.dart
    │   │       ├── get_interview_history_usecase.dart
    │   │       └── generate_gru_response_usecase.dart
    │   └── presentation/
    │       ├── providers/
    │       │   ├── interview_provider.dart      # StreamProvider 스트리밍
    │       │   └── gru_character_provider.dart  # 캐릭터 감정 상태
    │       ├── screens/
    │       │   └── interview_screen.dart
    │       └── widgets/
    │           ├── gru_character_widget.dart    # Rive 캐릭터 (교체 가능)
    │           ├── chat_bubble.dart
    │           ├── typing_indicator.dart
    │           └── interview_action_buttons.dart
    │
    └── insight/                      # 📊 트렌드 인사이트
        ├── data/
        │   ├── datasources/
        │   │   ├── insight_remote_datasource.dart  # n8n → Supabase
        │   │   └── insight_local_datasource.dart
        │   ├── models/
        │   │   ├── trend_log_model.dart
        │   │   └── insight_card_model.dart
        │   └── repositories/
        │       └── insight_repository_impl.dart
        ├── domain/
        │   ├── entities/
        │   │   ├── trend_log_entity.dart
        │   │   └── insight_category.dart  # enum: news/stock/paper
        │   ├── repositories/
        │   │   └── insight_repository.dart
        │   └── usecases/
        │       ├── get_trending_insights_usecase.dart
        │       └── bookmark_insight_usecase.dart
        └── presentation/
            ├── providers/
            │   ├── insight_provider.dart        # AsyncNotifierProvider
            │   └── insight_filter_provider.dart
            ├── screens/
            │   └── insight_screen.dart
            └── widgets/
                ├── insight_card_widget.dart
                ├── trend_category_tabs.dart
                └── insight_detail_sheet.dart   # BottomSheet
```

---

## 2. Supabase DB 스키마

```sql
-- =============================================
-- USERS (인증은 Supabase Auth 사용, profiles 확장)
-- =============================================
CREATE TABLE public.profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username      TEXT UNIQUE NOT NULL,
  avatar_url    TEXT,
  gru_name      TEXT DEFAULT 'Gru',         -- 사용자가 지정한 AI 캐릭터 이름
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- GROOS (아이디어 나무, 핵심 엔티티)
-- =============================================
CREATE TABLE public.groos (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title           TEXT NOT NULL,             -- 한 줄 아이디어 메모
  description     TEXT,
  category        TEXT,                      -- 자유 태그
  growth_stage    TEXT NOT NULL DEFAULT 'seed'
                  CHECK (growth_stage IN ('seed', 'sprout', 'tree', 'fruit')),
  health_status   TEXT NOT NULL DEFAULT 'green'
                  CHECK (health_status IN ('red', 'orange', 'green')),
  health_score    INTEGER DEFAULT 100        -- 0~100, 비활성 시 감소
                  CHECK (health_score BETWEEN 0 AND 100),
  last_activity_at TIMESTAMPTZ DEFAULT NOW(), -- 마지막 인터뷰/업데이트 시각
  is_archived     BOOLEAN DEFAULT FALSE,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_groos_user_id ON public.groos(user_id);
CREATE INDEX idx_groos_health_status ON public.groos(health_status);

-- =============================================
-- STEPS (성장 단계 기록 로그)
-- =============================================
CREATE TABLE public.steps (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  groo_id       UUID NOT NULL REFERENCES public.groos(id) ON DELETE CASCADE,
  user_id       UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  from_stage    TEXT NOT NULL,
  to_stage      TEXT NOT NULL,
  trigger_type  TEXT NOT NULL               -- 'interview' | 'manual' | 'time_based'
                CHECK (trigger_type IN ('interview', 'manual', 'time_based')),
  notes         TEXT,                       -- 성장 계기 메모
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_steps_groo_id ON public.steps(groo_id);

-- =============================================
-- INTERVIEW_SESSIONS (AI 대화 세션)
-- =============================================
CREATE TABLE public.interview_sessions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  groo_id       UUID NOT NULL REFERENCES public.groos(id) ON DELETE CASCADE,
  user_id       UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status        TEXT DEFAULT 'active'
                CHECK (status IN ('active', 'completed', 'paused')),
  summary       TEXT,                       -- AI가 생성한 세션 요약
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  ended_at      TIMESTAMPTZ
);

-- =============================================
-- MESSAGES (채팅 메시지)
-- =============================================
CREATE TABLE public.messages (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id    UUID NOT NULL REFERENCES public.interview_sessions(id) ON DELETE CASCADE,
  role          TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content       TEXT NOT NULL,
  metadata      JSONB,                      -- 감정, 성장 힌트 등 AI 메타데이터
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_messages_session_id ON public.messages(session_id);

-- =============================================
-- TREND_LOGS (n8n에서 수집된 트렌드 데이터)
-- =============================================
CREATE TABLE public.trend_logs (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category      TEXT NOT NULL
                CHECK (category IN ('news', 'stock', 'paper')),
  title         TEXT NOT NULL,
  summary       TEXT,
  source_url    TEXT,
  source_name   TEXT,
  relevance_tags TEXT[],                    -- 연관 키워드 배열
  raw_data      JSONB,                      -- n8n 원본 데이터
  published_at  TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_trend_logs_category ON public.trend_logs(category);
CREATE INDEX idx_trend_logs_published_at ON public.trend_logs(published_at DESC);

-- =============================================
-- BOOKMARKS (인사이트 북마크)
-- =============================================
CREATE TABLE public.bookmarks (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  trend_log_id  UUID NOT NULL REFERENCES public.trend_logs(id) ON DELETE CASCADE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, trend_log_id)
);

-- =============================================
-- RLS (Row Level Security) 정책
-- =============================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.groos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.interview_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookmarks ENABLE ROW LEVEL SECURITY;

-- profiles: 본인만 읽기/수정
CREATE POLICY "Users can view own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- groos: 본인 데이터만 CRUD
CREATE POLICY "Users manage own groos" ON public.groos
  USING (auth.uid() = user_id);

-- trend_logs: 모든 인증 사용자 읽기 가능 (n8n 서비스 롤로 쓰기)
ALTER TABLE public.trend_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Authenticated users can read trends" ON public.trend_logs
  FOR SELECT TO authenticated USING (true);
```

---

## 3. Riverpod 상태 관리 전략

### 3-1. Provider 계층 구조

```
Supabase Client (Provider)
       │
       ▼
RemoteDataSource (Provider)  ←── LocalDataSource (Provider)
       │
       ▼
Repository (Provider)         ← 추상 인터페이스 주입
       │
       ▼
UseCase (Provider)
       │
       ▼
AsyncNotifierProvider  ──→  UI (watch/listen)
```

### 3-2. Garden 상태 관리 핵심 패턴

```dart
// features/garden/presentation/providers/garden_provider.dart

// 1. 전체 그루 목록 (AsyncNotifier)
@riverpod
class GardenNotifier extends _$GardenNotifier {
  @override
  Future<List<GrooEntity>> build() async {
    return ref.watch(getAllGroosUsecaseProvider).execute();
  }

  Future<void> refresh() async => ref.invalidateSelf();

  Future<void> updateHealthStatus() async {
    // health_score 기반으로 status 재계산 후 Supabase 업데이트
  }
}

// 2. 헬스 상태 필터 (StateProvider - 단순 상태)
@riverpod
HealthFilter grooFilter(GrooFilterRef ref) => HealthFilter.all;

// 3. 필터링된 그루 목록 (derived state)
@riverpod
List<GrooEntity> filteredGroos(FilteredGroosRef ref) {
  final groos = ref.watch(gardenNotifierProvider).valueOrNull ?? [];
  final filter = ref.watch(grooFilterProvider);
  return switch (filter) {
    HealthFilter.all    => groos,
    HealthFilter.red    => groos.where((g) => g.healthStatus == 'red').toList(),
    HealthFilter.orange => groos.where((g) => g.healthStatus == 'orange').toList(),
    HealthFilter.green  => groos.where((g) => g.healthStatus == 'green').toList(),
  };
}

// 4. 애니메이션 상태 (개별 그루별 AnimationController 관리)
@riverpod
class GrooAnimationNotifier extends _$GrooAnimationNotifier {
  @override
  GrowthAnimationState build(String grooId) {
    return GrowthAnimationState.idle;
  }

  void triggerGrowth(GrowthStage from, GrowthStage to) {
    state = GrowthAnimationState.growing(from: from, to: to);
  }
}
```

### 3-3. 성장 상태(Health) 자동 계산 로직

```dart
// core/utils/growth_calculator.dart

class GrowthCalculator {
  static const int redThreshold    = 30;  // 30 이하 → 빨강
  static const int orangeThreshold = 60;  // 60 이하 → 주황
  static const int decayPerDay     = 5;   // 하루 미활동 시 -5점

  static String calculateHealthStatus(int score) => switch (score) {
    <= redThreshold    => 'red',
    <= orangeThreshold => 'orange',
    _                  => 'green',
  };

  static int calculateDecay(DateTime lastActivity) {
    final days = DateTime.now().difference(lastActivity).inDays;
    return (days * decayPerDay).clamp(0, 100);
  }

  static GrowthStage determineStage({
    required int interviewCount,
    required int healthScore,
    required Duration age,
  }) {
    if (interviewCount == 0) return GrowthStage.seed;
    if (interviewCount < 3)  return GrowthStage.sprout;
    if (healthScore >= 70)   return GrowthStage.fruit;
    return GrowthStage.tree;
  }
}
```

---

## 4. 애니메이션 교체 가능 구조 (Lottie / Rive)

```dart
// shared/animations/lottie_wrapper.dart
// → Lottie를 Rive로 교체 시 이 파일만 수정

abstract class AnimationAsset {
  Widget buildWidget({double? width, double? height, bool? repeat});
}

class LottieAnimationAsset implements AnimationAsset {
  final String assetPath;
  const LottieAnimationAsset(this.assetPath);

  @override
  Widget buildWidget({double? width, double? height, bool? repeat}) {
    return Lottie.asset(assetPath, width: width, height: height, repeat: repeat ?? true);
  }
}

class RiveAnimationAsset implements AnimationAsset {
  final String assetPath;
  final String artboardName;
  const RiveAnimationAsset(this.assetPath, {required this.artboardName});

  @override
  Widget buildWidget({double? width, double? height, bool? repeat}) {
    return RiveAnimation.asset(assetPath, artboard: artboardName);
  }
}

// 사용: 스테이지별 애니메이션 팩토리
class GrowthAnimationRegistry {
  static AnimationAsset forStage(GrowthStage stage) => switch (stage) {
    GrowthStage.seed   => const LottieAnimationAsset('assets/lottie/seed.json'),
    GrowthStage.sprout => const LottieAnimationAsset('assets/lottie/sprout.json'),
    GrowthStage.tree   => const RiveAnimationAsset('assets/rive/tree.riv', artboardName: 'Tree'),
    GrowthStage.fruit  => const RiveAnimationAsset('assets/rive/fruit.riv', artboardName: 'Fruit'),
  };
}
```

---

## 5. pubspec.yaml

```yaml
name: groo_up
description: Groo-up — Grow your ideas like a tree 🌳
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # ── State Management ──────────────────────────────────
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # ── Routing ───────────────────────────────────────────
  go_router: ^14.2.0

  # ── Backend / Auth ────────────────────────────────────
  supabase_flutter: ^2.5.0

  # ── Network ───────────────────────────────────────────
  dio: ^5.4.3
  retrofit: ^4.1.0           # OpenAI API 타입세이프 클라이언트

  # ── Local Storage ─────────────────────────────────────
  shared_preferences: ^2.2.3
  flutter_secure_storage: ^9.0.0  # API 키 보안 저장
  hive_flutter: ^1.1.0        # 오프라인 캐시

  # ── Animation ─────────────────────────────────────────
  lottie: ^3.1.2
  rive: ^0.13.5

  # ── UI / Design ───────────────────────────────────────
  flutter_animate: ^4.5.0     # 선언형 애니메이션
  shimmer: ^3.0.0
  gap: ^3.0.1                 # SizedBox 대체 spacing
  cached_network_image: ^3.3.1

  # ── Home Widget ───────────────────────────────────────
  home_widget: ^0.5.0         # iOS/Android 홈 위젯

  # ── Notifications ─────────────────────────────────────
  firebase_core: ^3.3.0
  firebase_messaging: ^15.1.0

  # ── Utils ─────────────────────────────────────────────
  freezed_annotation: ^2.4.1  # 불변 모델
  json_annotation: ^4.9.0
  equatable: ^2.0.5
  dartz: ^0.10.1              # Either / Option (함수형)
  intl: ^0.19.0
  logger: ^2.3.0
  url_launcher: ^6.3.0
  connectivity_plus: ^6.0.3

dev_dependencies:
  flutter_test:
    sdk: flutter

  # ── Code Generation ───────────────────────────────────
  build_runner: ^2.4.11
  riverpod_generator: ^2.4.0
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  retrofit_generator: ^8.1.0

  # ── Testing ───────────────────────────────────────────
  mocktail: ^1.0.3
  fake_async: ^1.3.1

  # ── Linting ───────────────────────────────────────────
  flutter_lints: ^4.0.0
  custom_lint: ^0.6.4
  riverpod_lint: ^2.3.10

flutter:
  uses-material-design: true

  assets:
    - assets/lottie/          # Lottie JSON 파일
    - assets/rive/            # Rive 애니메이션 파일
    - assets/images/
    - assets/fonts/

  fonts:
    - family: PretendardVariable
      fonts:
        - asset: assets/fonts/PretendardVariable.ttf
```

---

## 6. 아키텍처 핵심 원칙 요약

| 계층 | 역할 | 의존 방향 |
|------|------|-----------|
| **Presentation** | UI, Provider, Screen, Widget | → Domain |
| **Domain** | Entity, UseCase, Repository 인터페이스 | 없음 (순수 Dart) |
| **Data** | Model, DataSource, Repository 구현체 | → Domain |
| **Core** | 설정, 라우터, 에러, 유틸 | 모든 계층에서 사용 |
| **Shared** | 재사용 위젯, 테마, 애니메이션 래퍼 | Presentation에서 사용 |

### 의존성 역전 원칙 적용
- `GardenRepository` (추상) → `GardenRepositoryImpl` (구현체)
- UseCase는 항상 추상 Repository를 주입받음
- Riverpod Provider로 의존성 교체 가능 → 테스트 시 `override` 활용
