import 'dart:ui';
import 'package:flutter/material.dart';

/// A clean iOS-style app bar with optional blur/transparency.
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final leadingWidget = leading;

    return ClipRect(
      child: BackdropFilter(
        filter: transparent
            ? ImageFilter.blur(sigmaX: 24, sigmaY: 24)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          decoration: BoxDecoration(
            color: transparent
                ? (isDark ? Colors.black.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.85))
                : theme.scaffoldBackgroundColor,
            border: transparent
                ? Border(bottom: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                    width: 0.33,
                  ))
                : null,
          ),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  if (showBackButton)
                    _BackButton(onPressed: onBackPressed ?? () => Navigator.pop(context), isDark: isDark)
                  else if (leadingWidget != null)
                    leadingWidget,
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.3)),
                        if (subtitle != null)
                          Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(fontSize: 12)),
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

class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isDark;
  const _BackButton({required this.onPressed, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: primary),
      ),
    );
  }
}

/// Desktop-style floating top nav bar.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (i) => _buildItem(i, primary, isDark)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index, Color primary, bool isDark) {
    final item = items[index];
    final isSelected = currentIndex == index;
    final inactiveColor = isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.35);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? primary.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isSelected ? item.activeIcon : item.icon, color: isSelected ? primary : inactiveColor, size: 20),
              const SizedBox(height: 2),
              Text(item.label, style: TextStyle(color: isSelected ? primary : inactiveColor, fontSize: 10, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
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
  const GlassNavItem({required this.label, required this.icon, required this.activeIcon});
}