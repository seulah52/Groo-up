import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/growth_stage.dart';
import '../providers/garden_provider.dart';

class GrooDetailScreen extends ConsumerWidget {
  final String grooId;
  const GrooDetailScreen({super.key, required this.grooId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groos = ref.watch(gardenNotifierProvider).valueOrNull ?? [];
    final groo  = groos.where((g) => g.id == grooId).firstOrNull;

    if (groo == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final statusColor = switch (groo.healthStatus) {
      'red'    => AppColors.healthRed,
      'orange' => AppColors.healthOrange,
      'gold'   => const Color(0xFFFFB300),
      _        => AppColors.healthGreen,
    };

    return Scaffold(
      appBar: AppBar(title: Text(groo.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 성장 단계
            Card(child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('성장 단계', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(children: GrowthStage.values.map((stage) {
                  final isCurrent = groo.growthStage == stage;
                  return Expanded(child: GestureDetector(
                    onTap: () async {
                      if (!isCurrent) {
                        await ref.read(gardenNotifierProvider.notifier).growStage(grooId, stage);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(stage.label, textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                          color: isCurrent ? Colors.white : Colors.grey)),
                    ),
                  ));
                }).toList()),
              ]),
            )),
            const SizedBox(height: 12),
            // 아이디어 완성도
            Card(child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('아이디어 완성도', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('${groo.completionRate}%', style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700, color: statusColor)),
                ]),
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: groo.completionRate / 100, minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(statusColor))),
                const SizedBox(height: 6),
                Text(_completionLabel(groo.completionRate),
                    style: TextStyle(fontSize: 12, color: statusColor)),
              ]),
            )),
            if (groo.category != null) ...[
              const SizedBox(height: 12),
              Card(child: ListTile(
                leading: const Icon(Icons.label_outline),
                title: Text(groo.category!), subtitle: const Text('카테고리'))),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/interview/${groo.id}'),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('그루와 대화하기'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _confirmDelete(context, ref),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('삭제', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ),
      ),
    );
  }

  String _completionLabel(int rate) {
    if (rate >= 81) return '열매 단계입니다 — 최종 결과물 생성이 가능합니다';
    if (rate >= 51) return '나무 단계입니다 — 구조화가 진행 중입니다';
    if (rate >= 26) return '새싹 단계입니다 — 구체화를 이어가세요';
    return '씨앗 단계입니다 — 맥락 정보를 더 채워주세요';
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('삭제하시겠어요?'),
        content: const Text('삭제하면 복구할 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(gardenNotifierProvider.notifier).deleteGroo(grooId);
      if (context.mounted) context.pop();
    }
  }
}
