import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/animations/growth_animation_registry.dart';
import '../../domain/entities/groo_entity.dart';

class GrooTreeWidget extends ConsumerWidget {
  final GrooEntity groo;
  const GrooTreeWidget({super.key, required this.groo});

  Color get _statusColor => switch (groo.healthStatus) {
    'red'    => AppColors.healthRed,
    'orange' => AppColors.healthOrange,
    'gold'   => const Color(0xFFFFB300),
    _        => AppColors.healthGreen,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asset = GrowthAnimationRegistry.forStage(groo.growthStage.name);
    return GestureDetector(
      onTap: () => context.push('/garden/${groo.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _statusColor, width: 2),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(height: 80, child: asset.buildWidget(height: 80)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(groo.title, maxLines: 2, overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
          const SizedBox(height: 4),
          Text(groo.growthStage.label,
              style: TextStyle(fontSize: 11, color: _statusColor)),
          const SizedBox(height: 2),
          Text('${groo.completionRate}%',
              style: TextStyle(fontSize: 10, color: _statusColor)),
        ]),
      ),
    );
  }
}
