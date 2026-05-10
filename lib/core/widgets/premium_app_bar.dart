import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final bool transparent;

  const PremiumAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.leading,
    this.transparent = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    final leadingWidget = leading;
    return ClipRect(
      child: BackdropFilter(
        filter: transparent
            ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          decoration: BoxDecoration(
            color: transparent
                ? AppColors.glassBackground
                : AppColors.backgroundSlate,
            border: transparent
                ? const Border(
                    bottom: BorderSide(
                      color: AppColors.glassBorder,
                      width: 0.5,
                    ),
                  )
                : null,
          ),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  if (showBackButton)
                    _GlassIconButton(
                      icon: Icons.arrow_back_ios_new,
                      onPressed: onBackPressed ?? () => Navigator.pop(context),
                    )
                  else if (leadingWidget != null)
                    leadingWidget,
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                     child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (actions != null) ...actions!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;


  const _GlassIconButton({
    required this.icon,
    this.onPressed,
  });

  @override
  State<_GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<_GlassIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: AppSpacing.animationFast,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _isPressed
              ? AppColors.glassHighlight.withValues(alpha: 0.3)
              : AppColors.glassBackground,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 1,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: AppColors.primaryIndigo.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Icon(
          widget.icon,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }
}

class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;

  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusFull),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              color: AppColors.glassBackground,
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusFull),
              border: Border.all(
                color: AppColors.glassBorder,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                items.length,
                (index) => _buildItem(index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    final item = items[index];
    final isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppSpacing.animationNormal,
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryIndigo.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryIndigo.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? item.activeIcon : item.icon,
                color: isSelected ? AppColors.primaryTeal : AppColors.textMuted,
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryTeal : AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlassNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const GlassNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}