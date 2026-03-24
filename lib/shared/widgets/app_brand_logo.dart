import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// 앱 브랜드 마크(숲·성장 톤, Material 아이콘 조합 — 외부 핀 이미지 미사용)
class GrooUpBrandMark extends StatelessWidget {
  const GrooUpBrandMark({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    final ring = size * 0.92;
    return Semantics(
      label: 'Groo-up 로고',
      child: Container(
        width: ring,
        height: ring,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.moss, AppColors.treeGreen],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.treeGreen.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          Icons.forest_rounded,
          size: size * 0.48,
          color: Colors.white.withValues(alpha: 0.95),
        ),
      ),
    );
  }
}
