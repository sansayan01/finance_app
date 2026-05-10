import 'dart:ui';
import 'package:flutter/material.dart';

/// iOS-style floating bottom navigation bar for mobile devices.
class LumaBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<LumaBarItem> items;

  const LumaBar({
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: isDark
                  ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.92)
                  : Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (i) => _buildItem(context, i, primary, isDark)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index, Color primary, bool isDark) {
    final item = items[index];
    final isSelected = currentIndex == index;
    final inactiveColor = isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.35);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected ? primary : inactiveColor,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected ? primary : inactiveColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LumaBarItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const LumaBarItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

/// Alternative bottom nav for non-floating usage.
class PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const PremiumBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final inactiveColor = isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.35);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          decoration: BoxDecoration(
            color: isDark 
                ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.92) 
                : Colors.white.withValues(alpha: 0.92),
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                width: 0.33,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view_rounded, label: 'Home', isSelected: currentIndex == 0, primary: primary, inactive: inactiveColor, onTap: () => onTap(0)),
                  _NavItem(icon: Icons.account_balance_outlined, activeIcon: Icons.account_balance_rounded, label: 'Loans', isSelected: currentIndex == 1, primary: primary, inactive: inactiveColor, onTap: () => onTap(1)),
                  _NavItem(icon: Icons.savings_outlined, activeIcon: Icons.savings_rounded, label: 'Savings', isSelected: currentIndex == 2, primary: primary, inactive: inactiveColor, onTap: () => onTap(2)),
                  _NavItem(icon: Icons.people_outlined, activeIcon: Icons.people_rounded, label: 'Members', isSelected: currentIndex == 3, primary: primary, inactive: inactiveColor, onTap: () => onTap(3)),
                  _NavItem(icon: Icons.analytics_outlined, activeIcon: Icons.analytics_rounded, label: 'Analytics', isSelected: currentIndex == 4, primary: primary, inactive: inactiveColor, onTap: () => onTap(4)),
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
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final Color primary;
  final Color inactive;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.isSelected, required this.primary, required this.inactive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon, color: isSelected ? primary : inactive, size: 22),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: isSelected ? primary : inactive, fontSize: 10, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}