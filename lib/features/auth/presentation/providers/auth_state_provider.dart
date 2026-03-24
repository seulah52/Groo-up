import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/config/supabase_config.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';

part 'auth_state_provider.g.dart';

@riverpod
AuthRemoteDatasource authRemoteDatasource(AuthRemoteDatasourceRef ref) =>
    AuthRemoteDatasourceImpl(supabase: ref.watch(supabaseClientProvider));

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) =>
    AuthRepositoryImpl(remote: ref.watch(authRemoteDatasourceProvider));

@riverpod
SignInUsecase signInUsecase(SignInUsecaseRef ref) =>
    SignInUsecase(repository: ref.watch(authRepositoryProvider));

@riverpod
SignUpUsecase signUpUsecase(SignUpUsecaseRef ref) =>
    SignUpUsecase(repository: ref.watch(authRepositoryProvider));

@riverpod
SignOutUsecase signOutUsecase(SignOutUsecaseRef ref) =>
    SignOutUsecase(repository: ref.watch(authRepositoryProvider));

/// loading: 가입/로그인 처리 중(회원가입 시 이 단계에서 profiles 생성·검증까지 포함)
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  const AuthState({this.status = AuthStatus.initial, this.user, this.errorMessage});
  AuthState copyWith({AuthStatus? status, UserEntity? user, String? errorMessage}) =>
      AuthState(status: status ?? this.status, user: user ?? this.user, errorMessage: errorMessage);
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) return AuthState(status: AuthStatus.authenticated, user: user);
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await ref.read(signInUsecaseProvider)
        .execute(email: email, password: password);
    result.fold(
      (f) => state = state.copyWith(status: AuthStatus.error, errorMessage: f.message),
      (u) => state = state.copyWith(status: AuthStatus.authenticated, user: u),
    );
  }

  /// 회원가입: 성공 시에만 authenticated — 데이터소스에서
  /// signUp → 세션 대기 → profiles 수동 반영 → DB에서 행 확인 후 User 반환(그 전에는 메인으로 가지 않음)
  Future<void> signUp({
    required String email, required String password, required String username}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await ref.read(signUpUsecaseProvider)
        .execute(email: email, password: password, username: username);
    result.fold(
      (f) => state = state.copyWith(status: AuthStatus.error, errorMessage: f.message),
      (u) => state = state.copyWith(status: AuthStatus.authenticated, user: u),
    );
  }

  Future<void> signOut() async {
    await ref.read(signOutUsecaseProvider).execute();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// 재시도 전 이전 오류 메시지 제거 (로그인 화면 UX)
  void clearError() {
    if (state.status == AuthStatus.error) {
      state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: null);
    }
  }
}

