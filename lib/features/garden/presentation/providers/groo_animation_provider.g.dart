// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groo_animation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$grooAnimationNotifierHash() =>
    r'61e9140a331c3b93062ab0b515f771b308b4f639';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$GrooAnimationNotifier
    extends BuildlessAutoDisposeNotifier<GrowthAnimationState> {
  late final String grooId;

  GrowthAnimationState build(
    String grooId,
  );
}

/// See also [GrooAnimationNotifier].
@ProviderFor(GrooAnimationNotifier)
const grooAnimationNotifierProvider = GrooAnimationNotifierFamily();

/// See also [GrooAnimationNotifier].
class GrooAnimationNotifierFamily extends Family<GrowthAnimationState> {
  /// See also [GrooAnimationNotifier].
  const GrooAnimationNotifierFamily();

  /// See also [GrooAnimationNotifier].
  GrooAnimationNotifierProvider call(
    String grooId,
  ) {
    return GrooAnimationNotifierProvider(
      grooId,
    );
  }

  @override
  GrooAnimationNotifierProvider getProviderOverride(
    covariant GrooAnimationNotifierProvider provider,
  ) {
    return call(
      provider.grooId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'grooAnimationNotifierProvider';
}

/// See also [GrooAnimationNotifier].
class GrooAnimationNotifierProvider extends AutoDisposeNotifierProviderImpl<
    GrooAnimationNotifier, GrowthAnimationState> {
  /// See also [GrooAnimationNotifier].
  GrooAnimationNotifierProvider(
    String grooId,
  ) : this._internal(
          () => GrooAnimationNotifier()..grooId = grooId,
          from: grooAnimationNotifierProvider,
          name: r'grooAnimationNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$grooAnimationNotifierHash,
          dependencies: GrooAnimationNotifierFamily._dependencies,
          allTransitiveDependencies:
              GrooAnimationNotifierFamily._allTransitiveDependencies,
          grooId: grooId,
        );

  GrooAnimationNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.grooId,
  }) : super.internal();

  final String grooId;

  @override
  GrowthAnimationState runNotifierBuild(
    covariant GrooAnimationNotifier notifier,
  ) {
    return notifier.build(
      grooId,
    );
  }

  @override
  Override overrideWith(GrooAnimationNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: GrooAnimationNotifierProvider._internal(
        () => create()..grooId = grooId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        grooId: grooId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<GrooAnimationNotifier,
      GrowthAnimationState> createElement() {
    return _GrooAnimationNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GrooAnimationNotifierProvider && other.grooId == grooId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, grooId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GrooAnimationNotifierRef
    on AutoDisposeNotifierProviderRef<GrowthAnimationState> {
  /// The parameter `grooId` of this provider.
  String get grooId;
}

class _GrooAnimationNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<GrooAnimationNotifier,
        GrowthAnimationState> with GrooAnimationNotifierRef {
  _GrooAnimationNotifierProviderElement(super.provider);

  @override
  String get grooId => (origin as GrooAnimationNotifierProvider).grooId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
