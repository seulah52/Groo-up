/// 이메일 확인 등으로 가입 직후 세션이 없을 때 (RLS 호출 시 anon 이 되어 42501 유발)
class EmailConfirmationPendingException implements Exception {
  final String message;
  EmailConfirmationPendingException(this.message);

  @override
  String toString() => message;
}

/// GoTrue 세션의 user id와 API 응답 user id가 어긋날 때 (드묾)
class AuthSessionUserMismatchException implements Exception {
  final String message;
  AuthSessionUserMismatchException(this.message);

  @override
  String toString() => message;
}
