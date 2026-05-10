import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';


class ProgressGauge extends StatefulWidget {
  final double value;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? center;
  final bool animate;
  final Duration animationDuration;

  const ProgressGauge({
    super.key,
    required this.value,
    this.size = 120,
    this.strokeWidth = 8,
    this.progressColor,
    this.backgroundColor,
    this.center,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  State<ProgressGauge> createState() => _ProgressGaugeState();
}

class _ProgressGaugeState extends State<ProgressGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ProgressGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = _animation.value;
      _animation = Tween<double>(begin: _oldValue, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _GaugePainter(
                  value: _animation.value.clamp(0.0, 1.0),
                  strokeWidth: widget.strokeWidth,
                  progressColor: widget.progressColor ?? AppColors.primaryTeal,
                  backgroundColor:
                      widget.backgroundColor ?? AppColors.surfaceSlate.withValues(alpha: 0.5),
                ),
              ),
              if (widget.center != null) widget.center!,
            ],
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  _GaugePainter({
    required this.value,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * value;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [
          progressColor.withValues(alpha: 0.8),
          progressColor,
        ],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    final glowPaint = Paint()
      ..color = progressColor.withValues(alpha: 0.3)
      ..strokeWidth = strokeWidth + 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      value != oldDelegate.value ||
      progressColor != oldDelegate.progressColor;
}

class LinearProgressBar extends StatefulWidget {
  final double value;
  final double height;
  final Color? progressColor;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool animate;

  const LinearProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.progressColor,
    this.backgroundColor,
    this.borderRadius,
    this.animate = true,
  });

  @override
  State<LinearProgressBar> createState() => _LinearProgressBarState();
}

class _LinearProgressBarState extends State<LinearProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(LinearProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: _animation.value, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(widget.height / 2);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.surfaceSlate.withValues(alpha: 0.5),
            borderRadius: radius,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _animation.value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (widget.progressColor ?? AppColors.primaryTeal).withValues(alpha: 0.8),
                      widget.progressColor ?? AppColors.primaryTeal,
                    ],
                  ),
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(
                      color: (widget.progressColor ?? AppColors.primaryTeal)
                          .withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}