import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/auth_exceptions.dart';

/// 원격 인증·프로필 동기화 (UI는 [AuthNotifier] → 유스케이스 → 리포지토리 → 본 클래스 순)
abstract interface class AuthRemoteDatasource {
  Future<User> signInWithEmail({
    required String email,
    required String password,
  });
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  });
  Future<void> signOut();
  User? get currentUser;
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final SupabaseClient _supabase;
  const AuthRemoteDatasourceImpl({required SupabaseClient supabase}) : _supabase = supabase;

  static const _rpcEnsureProfile = 'ensure_my_profile';
  static const _sessionWaitTimeout = Duration(seconds: 8);
  static const _sessionPollInterval = Duration(milliseconds: 80);

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final res = await _supabase.auth.signInWithPassword(email: email, password: password);
    if (res.user == null) throw Exception('로그인에 실패했습니다.');
    // 1) 세션·JWT가 PostgREST에 붙을 때까지 대기 2) RPC로 프로필 보장(RLS 우회)
    await _waitForSessionMatchingUser(res.user!.id);
    _debugLogSessionContext(label: 'signIn 세션 준비 후');
    await _ensureProfileViaRpc(expectedUserId: res.user!.id, username: null);
    return res.user!;
  }

  @override
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    // ① Supabase Auth 가입
    final res = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: <String, dynamic>{'username': username},
    );
    if (res.user == null) throw Exception('회원가입에 실패했습니다.');

    final userId = res.user!.id;

    // ② Confirm email OFF면 보통 즉시 session 이 오지만, 클라이언트 반영이 한 틱 늦을 수 있어 폴링
    try {
      await _waitForSessionMatchingUser(userId);
    } catch (_) {
      if (res.session == null) {
        throw EmailConfirmationPendingException(
          '가입 확인 메일을 연 뒤 로그인해 주세요.\n'
          '(즉시 세션이 필요하면 Supabase에서 Confirm email 을 끄세요.)',
        );
      }
      rethrow;
    }

    _debugLogSessionContext(label: 'signUp 세션 준비 후');

    // ③ DB 트리거 없음: 앱에서 profiles 수동 반영 후 ④ 조회로 생성 확인될 때까지 완료하지 않음
    await _createProfileRowAfterSignUp(userId: userId, username: username);
    await _verifyProfileRowExists(userId);

    return res.user!;
  }

  /// accessToken·userId가 일치할 때까지 짧은 간격으로 재시도 (세션 선행 보장)
  Future<void> _waitForSessionMatchingUser(String expectedUserId) async {
    final deadline = DateTime.now().add(_sessionWaitTimeout);
    while (DateTime.now().isBefore(deadline)) {
      final session = _supabase.auth.currentSession;
      final token = session?.accessToken;
      final uid = _supabase.auth.currentUser?.id;
      if (session != null &&
          token != null &&
          token.isNotEmpty &&
          uid == expectedUserId) {
        return;
      }
      await Future<void>.delayed(_sessionPollInterval);
    }
    if (kDebugMode) {
      debugPrint(
        '[Auth] 세션 대기 타임아웃: expectedUserId=$expectedUserId '
        'currentUid=${_supabase.auth.currentUser?.id}',
      );
    }
    throw AuthSessionUserMismatchException(
      '로그인 세션이 준비되지 않았습니다. 잠시 후 다시 시도해 주세요.',
    );
  }

  void _debugLogSessionContext({required String label}) {
    if (!kDebugMode) return;
    final s = _supabase.auth.currentSession;
    final u = _supabase.auth.currentUser;
    final tokenLen = s?.accessToken.length ?? 0;
    debugPrint(
      '[Auth] $label | session=${s != null} userId=${u?.id} accessTokenLen=$tokenLen',
    );
  }

  /// 회원가입 직후: profiles 에 user.id 로 행 삽입(동일 PK 있으면 upsert 로 정합)
  Future<void> _createProfileRowAfterSignUp({
    required String userId,
    required String username,
  }) async {
    final currentId = _supabase.auth.currentUser?.id;
    if (currentId != userId) {
      throw AuthSessionUserMismatchException(
        '인증 세션이 올바르지 않습니다. 다시 로그인해 주세요.',
      );
    }
    final name = username.trim();
    try {
      await _supabase.from('profiles').insert(<String, dynamic>{
        'id': userId,
        'username': name,
      });
    } on PostgrestException catch (e) {
      final code = e.code?.toString() ?? '';
      final msg = e.message.toLowerCase();
      final isDuplicate = code == '23505' ||
          msg.contains('duplicate') ||
          msg.contains('unique');
      if (isDuplicate) {
        await _supabase.from('profiles').upsert(<String, dynamic>{
          'id': userId,
          'username': name,
        });
        return;
      }
      if (kDebugMode) {
        debugPrint(
          '[Auth] profiles insert 실패 code=$code message=${e.message} userId=$userId',
        );
      }
      rethrow;
    }
  }

  /// PostgREST 로 본인 행이 읽히는지 확인(메인 이동 전 단계)
  Future<void> _verifyProfileRowExists(String userId) async {
    try {
      final row = await _supabase
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      if (row == null || (row['id'] as String?) != userId) {
        throw Exception('프로필 생성을 확인할 수 없습니다. 잠시 후 다시 시도해 주세요.');
      }
    } on PostgrestException catch (e, st) {
      if (kDebugMode) {
        debugPrint(
          '[Auth] profiles 검증(select) 실패 code=${e.code} message=${e.message}',
        );
        debugPrint('$st');
      }
      rethrow;
    }
  }

  /// 로그인 시: 닉네임 없이도 DB에서 프로필 보장 (RPC)
  Future<void> _ensureProfileViaRpc({
    required String expectedUserId,
    required String? username,
  }) async {
    final currentId = _supabase.auth.currentUser?.id;
    if (currentId != expectedUserId) {
      throw AuthSessionUserMismatchException(
        '인증 세션이 올바르지 않습니다. 다시 로그인해 주세요.',
      );
    }
    try {
      if (username != null && username.isNotEmpty) {
        await _supabase.rpc<void>(
          _rpcEnsureProfile,
          params: <String, dynamic>{'p_username': username},
        );
      } else {
        await _supabase.rpc<void>(_rpcEnsureProfile);
      }
    } on PostgrestException catch (e, st) {
      if (kDebugMode) {
        debugPrint(
          '[Auth] $_rpcEnsureProfile 실패 code=${e.code} message=${e.message} '
          '(JWT user는 $expectedUserId)',
        );
        debugPrint('$st');
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() => _supabase.auth.signOut();

  @override
  User? get currentUser => _supabase.auth.currentUser;
}
