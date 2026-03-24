import 'animation_asset.dart';

/// 성장 단계별 애니메이션 팩토리
/// Lottie -> Rive 교체 시 이 파일의 switch 블록만 수정
abstract final class GrowthAnimationRegistry {
  static AnimationAsset forStage(String stage) {
    switch (stage) {
      case 'seed':   return const LottieAnimationAsset('assets/lottie/seed.json');
      case 'sprout': return const LottieAnimationAsset('assets/lottie/sprout.json');
      case 'tree':   return const RiveAnimationAsset('assets/rive/tree.riv', artboardName: 'Tree');
      case 'fruit':  return const RiveAnimationAsset('assets/rive/fruit.riv', artboardName: 'Fruit');
      default:       return const LottieAnimationAsset('assets/lottie/seed.json');
    }
  }
}
