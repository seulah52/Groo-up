// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'garden_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$grooRemoteDatasourceHash() =>
    r'caf541d0cafa00880ea33da491ce9aa9292799e6';

/// See also [grooRemoteDatasource].
@ProviderFor(grooRemoteDatasource)
final grooRemoteDatasourceProvider =
    AutoDisposeProvider<GrooRemoteDatasource>.internal(
  grooRemoteDatasource,
  name: r'grooRemoteDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$grooRemoteDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GrooRemoteDatasourceRef = AutoDisposeProviderRef<GrooRemoteDatasource>;
String _$gardenRepositoryHash() => r'9e8acea22fbc6949b1052193d631e7c22f5e089b';

/// DIP 핵심: 반환 타입이 추상 GardenRepository
///
/// Copied from [gardenRepository].
@ProviderFor(gardenRepository)
final gardenRepositoryProvider = AutoDisposeProvider<GardenRepository>.internal(
  gardenRepository,
  name: r'gardenRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gardenRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GardenRepositoryRef = AutoDisposeProviderRef<GardenRepository>;
String _$getAllGroosUsecaseHash() =>
    r'928713c02b8302bc5ced2b6950fc8f68f6502f56';

/// See also [getAllGroosUsecase].
@ProviderFor(getAllGroosUsecase)
final getAllGroosUsecaseProvider =
    AutoDisposeProvider<GetAllGroosUsecase>.internal(
  getAllGroosUsecase,
  name: r'getAllGroosUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getAllGroosUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetAllGroosUsecaseRef = AutoDisposeProviderRef<GetAllGroosUsecase>;
String _$updateGrowthStageUsecaseHash() =>
    r'831c41fa3a3729e7de791622be92594766c92bf1';

/// See also [updateGrowthStageUsecase].
@ProviderFor(updateGrowthStageUsecase)
final updateGrowthStageUsecaseProvider =
    AutoDisposeProvider<UpdateGrowthStageUsecase>.internal(
  updateGrowthStageUsecase,
  name: r'updateGrowthStageUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$updateGrowthStageUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UpdateGrowthStageUsecaseRef
    = AutoDisposeProviderRef<UpdateGrowthStageUsecase>;
String _$updateHealthScoreUsecaseHash() =>
    r'859a5c5de3cc8f97d4f2b4b930bf8aa0991ba4c2';

/// See also [updateHealthScoreUsecase].
@ProviderFor(updateHealthScoreUsecase)
final updateHealthScoreUsecaseProvider =
    AutoDisposeProvider<UpdateHealthScoreUsecase>.internal(
  updateHealthScoreUsecase,
  name: r'updateHealthScoreUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$updateHealthScoreUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UpdateHealthScoreUsecaseRef
    = AutoDisposeProviderRef<UpdateHealthScoreUsecase>;
String _$filteredGroosHash() => r'3537ec00641d9e707421310d56f77329964de825';

/// See also [filteredGroos].
@ProviderFor(filteredGroos)
final filteredGroosProvider = AutoDisposeProvider<List<GrooEntity>>.internal(
  filteredGroos,
  name: r'filteredGroosProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredGroosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FilteredGroosRef = AutoDisposeProviderRef<List<GrooEntity>>;
String _$grooFilterHash() => r'14f6d9466f0961a3aed60ddbeee9d5dd45d2c072';

/// See also [GrooFilter].
@ProviderFor(GrooFilter)
final grooFilterProvider =
    AutoDisposeNotifierProvider<GrooFilter, HealthFilter>.internal(
  GrooFilter.new,
  name: r'grooFilterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$grooFilterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GrooFilter = AutoDisposeNotifier<HealthFilter>;
String _$gardenNotifierHash() => r'e6d63a93b5c516523c39d605080e1f3b93628bf9';

/// See also [GardenNotifier].
@ProviderFor(GardenNotifier)
final gardenNotifierProvider =
    AutoDisposeAsyncNotifierProvider<GardenNotifier, List<GrooEntity>>.internal(
  GardenNotifier.new,
  name: r'gardenNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gardenNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GardenNotifier = AutoDisposeAsyncNotifier<List<GrooEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
