// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authRemoteDatasourceHash() =>
    r'ce1e241685e3d3a1e3b2a62fabb2fd144705be41';

/// See also [authRemoteDatasource].
@ProviderFor(authRemoteDatasource)
final authRemoteDatasourceProvider =
    AutoDisposeProvider<AuthRemoteDatasource>.internal(
  authRemoteDatasource,
  name: r'authRemoteDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRemoteDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthRemoteDatasourceRef = AutoDisposeProviderRef<AuthRemoteDatasource>;
String _$authRepositoryHash() => r'347e19d16c504379272f3a68f6fd9849a9bfbb32';

/// See also [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$signInUsecaseHash() => r'189dfb83524e2a896416b85290f7b1f15f1ad9f3';

/// See also [signInUsecase].
@ProviderFor(signInUsecase)
final signInUsecaseProvider = AutoDisposeProvider<SignInUsecase>.internal(
  signInUsecase,
  name: r'signInUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$signInUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SignInUsecaseRef = AutoDisposeProviderRef<SignInUsecase>;
String _$signUpUsecaseHash() => r'e53c0958328e412ef2de7d3e68eba23163db892c';

/// See also [signUpUsecase].
@ProviderFor(signUpUsecase)
final signUpUsecaseProvider = AutoDisposeProvider<SignUpUsecase>.internal(
  signUpUsecase,
  name: r'signUpUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$signUpUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SignUpUsecaseRef = AutoDisposeProviderRef<SignUpUsecase>;
String _$signOutUsecaseHash() => r'7bf78597b65d8943a28f6f35f2dde4a62d4da55b';

/// See also [signOutUsecase].
@ProviderFor(signOutUsecase)
final signOutUsecaseProvider = AutoDisposeProvider<SignOutUsecase>.internal(
  signOutUsecase,
  name: r'signOutUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$signOutUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SignOutUsecaseRef = AutoDisposeProviderRef<SignOutUsecase>;
String _$authNotifierHash() => r'2e3d3c393506ec5a7f00c2c5c8d27f13ce484889';

/// See also [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AutoDisposeNotifierProvider<AuthNotifier, AuthState>.internal(
  AuthNotifier.new,
  name: r'authNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthNotifier = AutoDisposeNotifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
