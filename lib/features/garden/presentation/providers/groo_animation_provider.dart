import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'groo_animation_provider.g.dart';

enum GrowthAnimationState { idle, growing, completed }

@riverpod
class GrooAnimationNotifier extends _$GrooAnimationNotifier {
  @override
  GrowthAnimationState build(String grooId) => GrowthAnimationState.idle;

  void triggerGrowth() {
    state = GrowthAnimationState.growing;
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (state == GrowthAnimationState.growing) state = GrowthAnimationState.completed;
    });
  }

  void reset() => state = GrowthAnimationState.idle;
}
