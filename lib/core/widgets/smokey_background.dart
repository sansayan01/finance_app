import 'dart:math';
import 'package:flutter/material.dart';

/// A Flutter port of the WebGL Smokey Background shader.
/// It uses a CustomPainter to simulate wavy, glowing smoke patterns.
class SmokeyBackground extends StatefulWidget {
  final Widget child;
  final Color color;
  
  const SmokeyBackground({
    super.key, 
    required this.child,
    this.color = const Color(0xFF1E40AF),
  });

  @override
  State<SmokeyBackground> createState() => _SmokeyBackgroundState();
}

class _SmokeyBackgroundState extends State<SmokeyBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The Smokey Shader Layer
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _SmokeyPainter(
                progress: _controller.value,
                color: widget.color,
              ),
              size: Size.infinite,
            );
          },
        ),
        // Backdrop Blur Layer (iOS-style)
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _SmokeyPainter extends CustomPainter {
  final double progress;
  final Color color;

  _SmokeyPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80)
      ..style = PaintingStyle.fill;

    final time = progress * 2 * pi;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // We draw several "smoke blobs" that move according to the distortion logic
    for (int i = 1; i <= 5; i++) {
      final dx = 50 * cos(i * 0.8 * time + i);
      final dy = 50 * sin(i * 1.2 * time + i * 2);
      
      final opacity = 0.05 + (0.05 * sin(time + i));
      paint.color = color.withValues(alpha: opacity);

      canvas.drawCircle(
        Offset(centerX + dx, centerY + dy),
        150 + (50 * sin(time * 0.5 + i)),
        paint,
      );
    }

    // Add a central glow
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);
    paint.color = color.withValues(alpha: 0.03);
    canvas.drawCircle(Offset(centerX, centerY), size.width * 0.6, paint);
  }

  @override
  bool shouldRepaint(covariant _SmokeyPainter oldDelegate) => oldDelegate.progress != progress;
}
