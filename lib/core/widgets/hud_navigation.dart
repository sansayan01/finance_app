import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

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
      margin: const EdgeInsets.all(AppSpacing.md),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusFull),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            height: 80,
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: AppColors.glassBackground.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusFull),
              border: Border.all(
                color: AppColors.glassBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.primaryIndigo.withValues(alpha: 0.1),
                  blurRadius: 60,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  items.length,
                  (index) => _buildHUDItem(index),
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildHUDItem(int index) {
    final item = items[index];
    final isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppSpacing.animationNormal,
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryIndigo.withValues(alpha: 0.25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
            border: isSelected
                ? Border.all(
                    color: AppColors.primaryIndigo.withValues(alpha: 0.4),
                    width: 1,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryIndigo.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppSpacing.animationNormal,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.primaryTeal.withValues(alpha: 0.2)
                      : Colors.transparent,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryTeal.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  color: isSelected ? AppColors.primaryTeal : AppColors.textMuted,
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryTeal : AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ],
          ),
        ),
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
            bottom: AppSpacing.lg,
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