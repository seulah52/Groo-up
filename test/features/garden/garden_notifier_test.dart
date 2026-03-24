import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:groo_up/features/garden/domain/entities/groo_entity.dart';
import 'package:groo_up/features/garden/domain/entities/growth_stage.dart';
import 'package:groo_up/features/garden/domain/repositories/garden_repository.dart';
import 'package:groo_up/features/garden/presentation/providers/garden_provider.dart';

class MockGardenRepository extends Mock implements GardenRepository {}

void main() {
  late MockGardenRepository mockRepo;

  setUp(() => mockRepo = MockGardenRepository());

  test('getAllGroos 성공 시 목록 반환', () async {
    final fakeGroos = [
      GrooEntity(
        id: 'test-id', userId: 'user-1', title: '테스트 아이디어',
        growthStage: GrowthStage.seed, healthStatus: 'green', healthScore: 100,
        lastActivityAt: DateTime.now(), createdAt: DateTime.now(),
      ),
    ];

    when(() => mockRepo.getAllGroos(any())).thenAnswer((_) async => Right(fakeGroos));
    when(() => mockRepo.updateHealthScore(any(), any()))
        .thenAnswer((_) async => Right(fakeGroos.first));

    final container = ProviderContainer(
      overrides: [gardenRepositoryProvider.overrideWithValue(mockRepo)],
    );
    addTearDown(container.dispose);

    final state = await container.read(gardenNotifierProvider.future);
    expect(state.length, equals(1));
    expect(state.first.title, equals('테스트 아이디어'));
  });
}
