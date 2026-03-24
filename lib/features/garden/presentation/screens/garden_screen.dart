import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../providers/garden_provider.dart';
import '../widgets/garden_canvas.dart';
import '../widgets/health_status_indicator.dart';

class GardenScreen extends ConsumerWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groos       = ref.watch(filteredGroosProvider);
    final gardenAsync = ref.watch(gardenNotifierProvider);
    final authState   = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('내 과수원'),
            if (authState.user?.username != null)
              Text(authState.user!.username!,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
          ],
        ),
        actions: [
          HealthStatusIndicator(
            onFilterChanged: (f) => ref.read(grooFilterProvider.notifier).set(f)),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [const PopupMenuItem(value: 'signout', child: Text('로그아웃'))],
            onSelected: (val) async {
              if (val == 'signout') await ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: gardenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(e.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.read(gardenNotifierProvider.notifier).refresh(),
              child: const Text('다시 시도')),
          ]),
        ),
        data: (_) => RefreshIndicator(
          onRefresh: () => ref.read(gardenNotifierProvider.notifier).refresh(),
          child: GardenCanvas(groos: groos),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/input'),
        icon: const Icon(Icons.eco_outlined),
        label: const Text('씨앗 심기'),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}
