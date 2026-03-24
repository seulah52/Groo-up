import 'package:supabase_flutter/supabase_flutter.dart';

import 'failure.dart';

/// PostgREST 예외를 [ServerFailure] 로 변환 (리포지토리 계층 공통)
ServerFailure mapPostgrestToFailure(PostgrestException e) => ServerFailure(
      message: SupabaseErrorMapper.toUserMessage(e),
      code: e.code?.toString(),
    );

/// Postgrest/Supabase 예외를 사용자에게 보여줄 한국어 메시지로 변환
abstract final class SupabaseErrorMapper {
  /// RLS·RPC·함수 누락 등 흔한 케이스를 안내 문구로 매핑
  static String toUserMessage(PostgrestException e) {
    final raw = e.message;
    final lower = raw.toLowerCase();
    final code = e.code?.toString() ?? '';

    if (code == '42501' ||
        lower.contains('row-level security') ||
        lower.contains('violates row-level security')) {
      if (lower.contains('ideas') || lower.contains('groos')) {
        return '아이디어를 저장할 권한이 없습니다.\n'
            'Supabase 에서 public.ideas 테이블 RLS·GRANT 를 확인하세요.\n'
            '(참고: supabase/fix_ideas_rls.sql)\n'
            'INSERT 시 user_id 는 로그인한 사용자(auth.uid())와 같아야 합니다.';
      }
      if (lower.contains('profiles')) {
        return '프로필을 저장할 권한이 없습니다.\n'
            'Supabase SQL Editor에서 다음을 적용했는지 확인하세요:\n'
            '• COPY_PASTE_SUPABASE.sql 의 [2] 블록(트리거·RLS)\n'
            '• 20240318200000_ensure_my_profile_rpc.sql (ensure_my_profile 함수)\n'
            '그리고 이메일 확인을 켠 경우 가입 직후에는 DB 트리거로만 프로필이 생깁니다.';
      }
      return '데이터 접근이 보안 정책(RLS)에 의해 거절되었습니다. Supabase 정책을 확인해주세요.';
    }

    if (lower.contains('could not find the function') ||
        lower.contains('function public.ensure_my_profile') ||
        (lower.contains('schema cache') && lower.contains('ensure_my_profile'))) {
      return 'DB에 ensure_my_profile 함수가 없습니다.\n'
          'supabase/migrations/20240318200000_ensure_my_profile_rpc.sql 을 '
          'Supabase SQL Editor에서 실행해주세요.';
    }

    if (lower.contains('jwt') && lower.contains('invalid')) {
      return '인증 정보가 올바르지 않습니다. 로그아웃 후 다시 시도해주세요.';
    }

    final hint = e.hint;
    if (hint != null && hint.isNotEmpty) {
      return '$raw\n($hint)';
    }
    return raw;
  }

  /// Auth API 예외 메시지 정리
  static String authMessage(AuthException e) => e.message;
}
