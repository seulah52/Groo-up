import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  /// 빌드 시 --dart-define-from-file=.env 로 주입 (기본값 비우면 미설정 분기 가능)
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
  static const openAiApiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');

  /// 빌드에 키가 없으면 인터뷰는 템플릿 응답만 사용
  static String get resolvedOpenAiApiKey => openAiApiKey.trim();
  static bool get hasOpenAiConfig => resolvedOpenAiApiKey.isNotEmpty;

  static const n8nWebhookUrl = String.fromEnvironment('N8N_WEBHOOK_URL');

  /// .env 한 줄에 따옴표/공백이 섞여도 동작하도록 trim 한 값 (초기화·검사에 공통 사용)
  static String get resolvedSupabaseUrl => supabaseUrl.trim();
  static String get resolvedSupabaseAnonKey => supabaseAnonKey.trim();

  /// Supabase 초기화 전에 호출해 에뮬레이터/IDE에서 .env 미적용 여부를 구분
  static bool get hasSupabaseConfig {
    final url = resolvedSupabaseUrl;
    final key = resolvedSupabaseAnonKey;
    return url.isNotEmpty &&
        key.isNotEmpty &&
        (Uri.tryParse(url)?.hasScheme ?? false) &&
        key.length > 20;
  }

  /// 디버그에서만: URL 호스트·키 길이·JWT 접두만 출력 (전체 키는 로그에 남기지 않음)
  static void debugLogSupabaseDefineSummary() {
    if (!kDebugMode) return;
    final url = resolvedSupabaseUrl;
    final key = resolvedSupabaseAnonKey;
    final uri = Uri.tryParse(url);
    final prefixLen = key.length >= 16 ? 16 : key.length;
    final keyPrefix = prefixLen > 0 ? '${key.substring(0, prefixLen)}…' : '(비어 있음)';
    debugPrint(
      '[AppConfig] SUPABASE_URL host=${uri?.host ?? "파싱 실패"} '
      'scheme=${uri?.scheme ?? "-"} | '
      'SUPABASE_ANON_KEY length=${key.length} prefix=$keyPrefix',
    );
  }
}
