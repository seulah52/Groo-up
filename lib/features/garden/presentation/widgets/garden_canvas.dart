import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/groo_entity.dart';
import 'groo_tree_widget.dart';

class GardenCanvas extends StatelessWidget {
  final List<GrooEntity> groos;
  const GardenCanvas({super.key, required this.groos});

  @override
  Widget build(BuildContext context) {
    if (groos.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('🌱', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text('과수원이 비어있어요',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('첫 번째 아이디어 씨앗을 심어보세요',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/input'),
            icon: const Icon(Icons.add), label: const Text('씨앗 심기')),
        ]),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.9),
      itemCount: groos.length,
      itemBuilder: (_, i) => GrooTreeWidget(groo: groos[i]),
    );
  }
}
