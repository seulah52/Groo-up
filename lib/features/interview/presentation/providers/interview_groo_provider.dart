import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../garden/domain/entities/groo_entity.dart';
import '../../../garden/presentation/providers/garden_provider.dart';

/// 인터뷰에서 선택된 아이디어(그루) 단건 — AI 컨텍스트 주입용
final interviewGrooProvider =
    FutureProvider.family<GrooEntity, String>((ref, grooId) async {
  final repo = ref.watch(gardenRepositoryProvider);
  final result = await repo.getGrooById(grooId);
  return result.fold(
    (f) => throw Exception(f.message),
    (g) => g,
  );
});
