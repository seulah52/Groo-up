import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/garden_provider.dart';

class HealthStatusIndicator extends StatelessWidget {
  final void Function(HealthFilter) onFilterChanged;
  const HealthStatusIndicator({super.key, required this.onFilterChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<HealthFilter>(
      icon: const Icon(Icons.filter_list),
      onSelected: onFilterChanged,
      itemBuilder: (_) => [
        const PopupMenuItem(value: HealthFilter.all, child: Text('전체')),
        PopupMenuItem(value: HealthFilter.green, child: Row(children: [
          CircleAvatar(backgroundColor: AppColors.healthGreen, radius: 6),
          const SizedBox(width: 8), const Text('건강함')])),
        PopupMenuItem(value: HealthFilter.orange, child: Row(children: [
          CircleAvatar(backgroundColor: AppColors.healthOrange, radius: 6),
          const SizedBox(width: 8), const Text('관심 필요')])),
        PopupMenuItem(value: HealthFilter.red, child: Row(children: [
          CircleAvatar(backgroundColor: AppColors.healthRed, radius: 6),
          const SizedBox(width: 8), const Text('위험')])),
      ],
    );
  }
}
