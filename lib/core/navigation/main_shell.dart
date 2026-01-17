import 'package:flutter/material.dart';
import '../../features/home/home_page.dart';
import '../../features/favorites/favorites_page.dart';
import '../../features/settings/settings_page.dart';
import '../../shared/widgets/neon_bottom_nav.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [HomePage(), FavoritesPage(), SettingsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: IndexedStack(
              key: ValueKey(_index),
              index: _index,
              children: _pages,
            ),
          ),
          NeonBottomNav(
            currentIndex: _index,
            onTap: (i) {
              if (i != _index) {
                setState(() => _index = i);
              }
            },
          ),
        ],
      ),
    );
  }
}
