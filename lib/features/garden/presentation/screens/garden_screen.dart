import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../../../shared/widgets/app_bottom_nav.dart';
import '../../domain/entities/groo_entity.dart';
import '../providers/garden_provider.dart';
import '../widgets/garden_canvas.dart';
import '../widgets/health_status_indicator.dart';

class GardenScreen extends ConsumerStatefulWidget {
  const GardenScreen({super.key});

  @override
  ConsumerState<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends ConsumerState<GardenScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;
  late Animation<Color?> _bgColorAnimation;
  int _lastTargetRate = -1;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _bgColorAnimation = AlwaysStoppedAnimation<Color?>(_colorForCompletion(0));
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  void _animateBackgroundTo(int completionRate) {
    final clamped = completionRate.clamp(0, 100);
    if (_lastTargetRate == clamped) return;
    _lastTargetRate = clamped;

    final begin =
        _bgColorAnimation.value ?? Theme.of(context).scaffoldBackgroundColor;
    final end = _colorForCompletion(clamped);
    _bgColorAnimation = ColorTween(begin: begin, end: end).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOutCubic),
    );
    _bgController
      ..stop()
      ..reset()
      ..forward();
  }

  int _averageCompletionRate(List<GrooEntity> groos) {
    if (groos.isEmpty) return 0;
    final sum = groos.fold<int>(0, (acc, g) => acc + g.completionRate);
    return (sum / groos.length).round().clamp(0, 100);
  }

  Color _colorForCompletion(int rate) {
    final r = rate.clamp(0, 100);
    const seedRed = Color(0xFFFFE4E6);
    const sproutAmber = Color(0xFFFFF3D6);
    const treeGreen = Color(0xFFE8F5E9);
    if (r <= 25) return seedRed;
    if (r <= 50) {
      final t = (r - 25) / 25;
      return Color.lerp(seedRed, sproutAmber, t) ?? seedRed;
    }
    final t = (r - 50) / 50;
    return Color.lerp(sproutAmber, treeGreen, t) ?? treeGreen;
  }

  @override
  Widget build(BuildContext context) {
    final groos = ref.watch(filteredGroosProvider);
    final gardenAsync = ref.watch(gardenNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final avgCompletionRate = _averageCompletionRate(groos);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _animateBackgroundTo(avgCompletionRate);
    });

    return AnimatedBuilder(
      animation: _bgColorAnimation,
      builder: (context, _) {
        return Scaffold(
          backgroundColor:
              _bgColorAnimation.value ?? Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('내 과수원'),
                if (authState.user?.username != null)
                  Text(
                    authState.user!.username!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
            actions: [
              HealthStatusIndicator(
                onFilterChanged: (f) =>
                    ref.read(grooFilterProvider.notifier).set(f),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'signout', child: Text('로그아웃')),
                ],
                onSelected: (val) async {
                  if (val == 'signout') {
                    await ref.read(authNotifierProvider.notifier).signOut();
                  }
                },
              ),
            ],
          ),
          body: gardenAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(e.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () =>
                        ref.read(gardenNotifierProvider.notifier).refresh(),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
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
      },
    );
  }
}
