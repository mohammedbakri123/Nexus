import 'dart:ui';
import 'package:flutter/material.dart';

class NeonBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NeonBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 68,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    index: 0,
                    currentIndex: currentIndex,
                    onTap: onTap,
                  ),
                  _NavItem(
                    icon: Icons.favorite_rounded,
                    index: 1,
                    currentIndex: currentIndex,
                    onTap: onTap,
                  ),
                  _NavItem(
                    icon: Icons.settings_rounded,
                    index: 2,
                    currentIndex: currentIndex,
                    onTap: onTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        height: 64,
        child: Center(
          child: AnimatedScale(
            scale: isActive ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isActive ? 1 : 0.6,
              child: Icon(
                icon,
                size: 26,
                color: isActive ? const Color(0xFF9B5CFF) : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
