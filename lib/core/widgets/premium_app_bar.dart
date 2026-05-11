import 'package:flutter/material.dart';

/// Premium frosted-glass app bar with blur backdrop.
/// Sits above content with a translucent material effect.
class PremiumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBackPressed;
  final double height;
  final Widget? titleWidget;

  const PremiumAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.showBack = false,
    this.onBackPressed,
    this.height = kToolbarHeight,
    this.titleWidget,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: showBack
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : leading,
      title: titleWidget ??
          (title != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style:
                            theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                      ),
                  ],
                )
              : null),
      actions: actions,
    );
  }
}
