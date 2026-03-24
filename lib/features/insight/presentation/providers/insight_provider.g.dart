// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$insightRemoteDatasourceHash() =>
    r'1e665daf6a989da29fead4827285662b0b1d4e22';

/// See also [insightRemoteDatasource].
@ProviderFor(insightRemoteDatasource)
final insightRemoteDatasourceProvider =
    AutoDisposeProvider<InsightRemoteDatasource>.internal(
  insightRemoteDatasource,
  name: r'insightRemoteDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$insightRemoteDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef InsightRemoteDatasourceRef
    = AutoDisposeProviderRef<InsightRemoteDatasource>;
String _$insightRepositoryHash() => r'f173f365cc41aac4274463ecb7d927c06571c9b8';

/// See also [insightRepository].
@ProviderFor(insightRepository)
final insightRepositoryProvider =
    AutoDisposeProvider<InsightRepository>.internal(
  insightRepository,
  name: r'insightRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$insightRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef InsightRepositoryRef = AutoDisposeProviderRef<InsightRepository>;
String _$getTrendingInsightsUsecaseHash() =>
    r'b3dff2addba2e37c940fbc245ec157812af680ad';

/// See also [getTrendingInsightsUsecase].
@ProviderFor(getTrendingInsightsUsecase)
final getTrendingInsightsUsecaseProvider =
    AutoDisposeProvider<GetTrendingInsightsUsecase>.internal(
  getTrendingInsightsUsecase,
  name: r'getTrendingInsightsUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getTrendingInsightsUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetTrendingInsightsUsecaseRef
    = AutoDisposeProviderRef<GetTrendingInsightsUsecase>;
String _$toggleTrendBookmarkUsecaseHash() =>
    r'27ba9612e59c52876455d6fe2b39d36faf127c5a';

/// See also [toggleTrendBookmarkUsecase].
@ProviderFor(toggleTrendBookmarkUsecase)
final toggleTrendBookmarkUsecaseProvider =
    AutoDisposeProvider<ToggleTrendBookmarkUsecase>.internal(
  toggleTrendBookmarkUsecase,
  name: r'toggleTrendBookmarkUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$toggleTrendBookmarkUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ToggleTrendBookmarkUsecaseRef
    = AutoDisposeProviderRef<ToggleTrendBookmarkUsecase>;
String _$trendLogsForCategoryHash() =>
    r'b85705d085dca9299e6e4d05cf5a4634dfb08777';

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

/// 탭별 트렌드 목록
///
/// Copied from [trendLogsForCategory].
@ProviderFor(trendLogsForCategory)
const trendLogsForCategoryProvider = TrendLogsForCategoryFamily();

/// 탭별 트렌드 목록
///
/// Copied from [trendLogsForCategory].
class TrendLogsForCategoryFamily
    extends Family<AsyncValue<List<TrendLogEntity>>> {
  /// 탭별 트렌드 목록
  ///
  /// Copied from [trendLogsForCategory].
  const TrendLogsForCategoryFamily();

  /// 탭별 트렌드 목록
  ///
  /// Copied from [trendLogsForCategory].
  TrendLogsForCategoryProvider call(
    InsightCategory category,
  ) {
    return TrendLogsForCategoryProvider(
      category,
    );
  }

  @override
  TrendLogsForCategoryProvider getProviderOverride(
    covariant TrendLogsForCategoryProvider provider,
  ) {
    return call(
      provider.category,
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
  String? get name => r'trendLogsForCategoryProvider';
}

/// 탭별 트렌드 목록
///
/// Copied from [trendLogsForCategory].
class TrendLogsForCategoryProvider
    extends AutoDisposeFutureProvider<List<TrendLogEntity>> {
  /// 탭별 트렌드 목록
  ///
  /// Copied from [trendLogsForCategory].
  TrendLogsForCategoryProvider(
    InsightCategory category,
  ) : this._internal(
          (ref) => trendLogsForCategory(
            ref as TrendLogsForCategoryRef,
            category,
          ),
          from: trendLogsForCategoryProvider,
          name: r'trendLogsForCategoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$trendLogsForCategoryHash,
          dependencies: TrendLogsForCategoryFamily._dependencies,
          allTransitiveDependencies:
              TrendLogsForCategoryFamily._allTransitiveDependencies,
          category: category,
        );

  TrendLogsForCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.category,
  }) : super.internal();

  final InsightCategory category;

  @override
  Override overrideWith(
    FutureOr<List<TrendLogEntity>> Function(TrendLogsForCategoryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TrendLogsForCategoryProvider._internal(
        (ref) => create(ref as TrendLogsForCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TrendLogEntity>> createElement() {
    return _TrendLogsForCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TrendLogsForCategoryProvider && other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TrendLogsForCategoryRef
    on AutoDisposeFutureProviderRef<List<TrendLogEntity>> {
  /// The parameter `category` of this provider.
  InsightCategory get category;
}

class _TrendLogsForCategoryProviderElement
    extends AutoDisposeFutureProviderElement<List<TrendLogEntity>>
    with TrendLogsForCategoryRef {
  _TrendLogsForCategoryProviderElement(super.provider);

  @override
  InsightCategory get category =>
      (origin as TrendLogsForCategoryProvider).category;
}

String _$bookmarkedTrendIdsHash() =>
    r'c342cbf10938717c0922672d9463f537c018f366';

/// 로그인 사용자의 북마크 id (없으면 빈 집합)
///
/// Copied from [bookmarkedTrendIds].
@ProviderFor(bookmarkedTrendIds)
final bookmarkedTrendIdsProvider =
    AutoDisposeFutureProvider<Set<String>>.internal(
  bookmarkedTrendIds,
  name: r'bookmarkedTrendIdsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bookmarkedTrendIdsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef BookmarkedTrendIdsRef = AutoDisposeFutureProviderRef<Set<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
