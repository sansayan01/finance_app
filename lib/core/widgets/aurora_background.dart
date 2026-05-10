import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AuroraBackground extends StatefulWidget {
  final Widget child;
  final bool animate;

  const AuroraBackground({
    super.key,
    required this.child,
    this.animate = true,
  });

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with TickerProviderStateMixin {
  late AnimationController _primaryController;
  late AnimationController _secondaryController;
  late Animation<double> _primaryAnimation;
  late Animation<double> _secondaryAnimation;

  @override
  void initState() {
    super.initState();

    _primaryController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _secondaryController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);

    _primaryAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _primaryController, curve: Curves.linear),
    );

    _secondaryAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _secondaryController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.backgroundDark,
                AppColors.backgroundSlate,
                Color(0xFF0F1729),
              ],
            ),
          ),
        ),
        if (widget.animate) ...[
          AnimatedBuilder(
            animation: Listenable.merge([_primaryAnimation, _secondaryAnimation]),
            builder: (context, child) {
              return CustomPaint(
                painter: AuroraPainter(
                  primaryAngle: _primaryAnimation.value,
                  secondaryAngle: _secondaryAnimation.value,
                ),
                size: Size.infinite,
              );
            },
          ),
        ] else ...[
          CustomPaint(
            painter: AuroraPainter(
              primaryAngle: 0,
              secondaryAngle: math.pi,
            ),
            size: Size.infinite,
          ),
        ],
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.backgroundDark.withValues(alpha: 0.3),
                AppColors.backgroundDark.withValues(alpha: 0.8),
                AppColors.backgroundDark,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class AuroraPainter extends CustomPainter {
  final double primaryAngle;
  final double secondaryAngle;

  AuroraPainter({
    required this.primaryAngle,
    required this.secondaryAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 3);

    final paint1 = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          math.cos(primaryAngle) * 0.5,
          math.sin(primaryAngle) * 0.5,
        ),
        radius: 1.2,
        colors: [
          AppColors.primaryTeal.withValues(alpha: 0.4),
          AppColors.primaryIndigo.withValues(alpha: 0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.8));

    canvas.drawCircle(
      center + Offset(math.cos(primaryAngle) * 100, math.sin(primaryAngle) * 50),
      size.width * 0.6,
      paint1,
    );

    final paint2 = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          math.cos(secondaryAngle) * 0.3,
          math.sin(secondaryAngle) * 0.3,
        ),
        radius: 1.0,
        colors: [
          AppColors.primaryPurple.withValues(alpha: 0.3),
          AppColors.primaryIndigo.withValues(alpha: 0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.7, size.height * 0.4),
        radius: size.width * 0.5,
      ));

    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.4) +
          Offset(math.cos(secondaryAngle) * 80, math.sin(secondaryAngle) * 40),
      size.width * 0.45,
      paint2,
    );

    final paint3 = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.accentCyan.withValues(alpha: 0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.2, size.height * 0.6),
        radius: size.width * 0.4,
      ));

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.6),
      size.width * 0.35,
      paint3,
    );
  }

  @override
  bool shouldRepaint(AuroraPainter oldDelegate) =>
      primaryAngle != oldDelegate.primaryAngle ||
      secondaryAngle != oldDelegate.secondaryAngle;
}

class MeshGradientBackground extends StatelessWidget {
  final Widget child;

  const MeshGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0F1A),
            Color(0xFF0F172A),
            Color(0xFF111827),
            Color(0xFF0F172A),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryIndigo.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryTeal.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.3,
            left: size.width * 0.6,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryPurple.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Size get size => Size.zero;
}