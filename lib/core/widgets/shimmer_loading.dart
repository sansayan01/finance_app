import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_spacing.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppSpacing.borderRadiusMd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
      highlightColor:
          isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF2F2F7),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final double? width;
  final double height;

  const ShimmerCard({
    super.key,
    this.width,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
      highlightColor:
          isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF2F2F7),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.spacing = AppSpacing.md,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index < itemCount - 1 ? spacing : 0),
          child: ShimmerCard(height: itemHeight),
        ),
      ),
    );
  }
}

class ShimmerStatsRow extends StatelessWidget {
  final int itemCount;

  const ShimmerStatsRow({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        itemCount,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index > 0 ? AppSpacing.sm : 0,
              right: index < itemCount - 1 ? AppSpacing.sm : 0,
            ),
            child: const ShimmerCard(height: 100),
          ),
        ),
      ),
    );
  }
}

class SkeletonLoader extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final ShimmerLoading? placeholder;

  const SkeletonLoader({
    super.key,
    required this.child,
    this.isLoading = false,
    this.placeholder,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [
                      Color(0xFF2C2C2E),
                      Color(0xFF3A3A3C),
                      Color(0xFF2C2C2E)
                    ]
                  : const [
                      Color(0xFFE5E5EA),
                      Color(0xFFF2F2F7),
                      Color(0xFFE5E5EA)
                    ],
              stops: [
                0.0,
                0.5 + _animation.value * 0.25,
                1.0,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.placeholder ?? widget.child,
        );
      },
    );
  }
}
