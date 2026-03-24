import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 메인 탭(과수원·심기·트렌드) 공통 하단 내비게이션
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) {
        if (i == 0) context.go('/garden');
        if (i == 1) context.go('/input');
        if (i == 2) context.go('/insight');
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.park_outlined),
          selectedIcon: Icon(Icons.park),
          label: '과수원',
        ),
        NavigationDestination(
          icon: Icon(Icons.eco_outlined),
          selectedIcon: Icon(Icons.eco),
          label: '심기',
        ),
        NavigationDestination(
          icon: Icon(Icons.insights_outlined),
          selectedIcon: Icon(Icons.insights),
          label: '트렌드',
        ),
      ],
    );
  }
}
