import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';

class HUDNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<HUDNavItem> items;

  const HUDNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                items.length,
                (index) => _buildHUDItem(context, index),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildHUDItem(BuildContext context, int index) {
    final item = items[index];
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: 300.ms,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryTeal.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected ? AppColors.primaryTeal : AppColors.textSecondaryLight,
              size: 22,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 4,
              width: 4,
              decoration: const BoxDecoration(
                color: AppColors.primaryTeal,
                shape: BoxShape.circle,
              ),
            ).animate().scale(),
        ],
      ),
    );
  }
}

class HUDNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const HUDNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

class FloatingHUD extends StatelessWidget {
  final Widget child;
  final bool showNav;
  final int currentIndex;
  final ValueChanged<int>? onNavTap;
  final List<HUDNavItem>? navItems;

  const FloatingHUD({
    super.key,
    required this.child,
    this.showNav = true,
    this.currentIndex = 0,
    this.onNavTap,
    this.navItems,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Stack(
      children: [
        child,
        if (showNav && isDesktop && navItems != null && onNavTap != null)
          Positioned(
            left: 0,
            right: 0,
            top: 16,
            child: Center(
              child: HUDNavigation(
                currentIndex: currentIndex,
                onTap: onNavTap!,
                items: navItems!,
              ),
            ),
          ),
      ],
    );
  }
}