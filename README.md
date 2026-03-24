# Groo-up 🌳

아이디어를 나무처럼 키우는 Flutter 앱

## 기술 스택
- Flutter 3.x + Dart 3.x
- Riverpod 2.x (상태관리)
- GoRouter (네비게이션)
- Supabase (DB + Auth)
- OpenAI API (AI 인터뷰)
- n8n (트렌드 데이터 수집)
- Lottie / Rive (애니메이션)

## 폴더 구조
```
lib/
├── core/          # 전역 인프라 (config, router, errors, utils)
├── shared/        # 재사용 위젯, 테마, 애니메이션 래퍼
└── features/      # Feature-first 도메인 분리
    ├── auth/      # 인증 (로그인/회원가입)
    ├── garden/    # 🌳 과수원 메인 화면
    ├── input/     # 🌱 씨앗 심기
    ├── interview/ # 🤖 AI 그루 대화
    └── insight/   # 📊 트렌드 인사이트
```

## 시작하기
1. `.env.example`을 `.env`로 복사 후 키 입력
2. 의존성 설치 및 코드 생성
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```
3. 실행
```bash
flutter run --dart-define-from-file=.env
```
- **Cursor / VS Code**: 저장소에 포함된 `.vscode/settings.json`으로 `Run` 시에도 `.env`가 넘어갑니다. 안 되면 `F5` → 구성 **Groo-up (에뮬레이터)** 선택.

## Supabase 마이그레이션
**SQL Editor에 한 번에 붙여넣기:** `supabase/COPY_PASTE_SUPABASE.sql` (주석에 [1][2] 순서 안내)  
**profiles 자동 생성 트리거만:** `supabase/trigger_profiles_on_signup.sql` (`groos_user_id_fkey` 오류 시 필수)  
**ideas RLS(씨앗 심기 42501, RLS 재사용 시):** `supabase/fix_ideas_rls.sql` — 앱 테이블명은 `SupabaseTables.ideas` (`public.ideas`)

원격/로컬 DB에 스키마·RLS·`profiles` 트리거·`ensure_my_profile` RPC를 적용합니다. (**회원가입/로그인 시 `profiles` RLS 42501 오류 방지**)
```bash
supabase db push
```
또는 Supabase 대시보드 **SQL Editor**에서 `supabase/migrations` 폴더의 SQL을 **파일 이름 순서대로** 실행합니다.  
이미 DB가 있는 경우에도 `20240318120000_*.sql` 다음 `20240318200000_*.sql` 을 반드시 적용하세요.

| 대시보드에 쓴 이름 | 레포 파일 |
|-------------------|-----------|
| initial Schema Migration | `20240101000000_init.sql` |
| Row-level policies for profiles/groos | `20240318120000_profiles_trigger_and_rls.sql` (동일 정책명 + 트리거 포함) |
| (앱용 RPC) | `20240318200000_ensure_my_profile_rpc.sql` |

## Android 배포(AAB)
```bash
flutter build appbundle --release --dart-define-from-file=.env
```
출력: `build/app/outputs/bundle/release/app-release.aab`
