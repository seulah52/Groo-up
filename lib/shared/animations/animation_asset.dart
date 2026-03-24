import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rive/rive.dart';

/// 추상 인터페이스 — Lottie <-> Rive 교체 시 구현체만 수정
abstract interface class AnimationAsset {
  Widget buildWidget({double? width, double? height, bool? repeat});
}

class LottieAnimationAsset implements AnimationAsset {
  final String assetPath;
  const LottieAnimationAsset(this.assetPath);
  @override
  Widget buildWidget({double? width, double? height, bool? repeat}) =>
      Lottie.asset(assetPath, width: width, height: height, repeat: repeat ?? true);
}

class RiveAnimationAsset implements AnimationAsset {
  final String assetPath;
  final String artboardName;
  const RiveAnimationAsset(this.assetPath, {required this.artboardName});
  @override
  Widget buildWidget({double? width, double? height, bool? repeat}) =>
      RiveAnimation.asset(assetPath, artboard: artboardName);
}
