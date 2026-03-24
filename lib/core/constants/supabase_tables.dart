/// Supabase public 스키마 — 아이디어(씨앗) **단일 테이블** 이름 (앱 전체가 여기만 참조)
abstract final class SupabaseTables {
  /// DB 에 `public.ideas` 가 있어야 함. 예전 `groos` 만 쓰는 프로젝트면 값을 `'groos'` 로 바꿔 주세요.
  static const ideas = 'ideas';
  static const trendLogs = 'trend_logs';
  static const bookmarks = 'bookmarks';
}
