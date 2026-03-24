import '../errors/failure.dart';

/// ideas 테이블 INSERT 시 user_id 는 반드시 profiles.id (= auth.uid()) 와 같은 UUID
abstract final class UserIdGuard {
  static final RegExp _uuidV4ish = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  /// null·빈 문자열·UUID 형식 아님 → 한국어 메시지, 통과 시 null
  static String? validationMessage(String? userId) {
    if (userId == null) return '로그인이 필요합니다.';
    final t = userId.trim();
    if (t.isEmpty) return '유저 ID가 비어 있습니다. 다시 로그인해 주세요.';
    if (!_uuidV4ish.hasMatch(t)) {
      return '유저 ID 형식이 올바르지 않습니다. 다시 로그인해 주세요.';
    }
    return null;
  }

  /// 유스케이스/리포지토리용
  static Failure? validationFailure(String? userId) {
    final msg = validationMessage(userId);
    return msg == null ? null : ValidationFailure(message: msg);
  }
}
