import 'dart:math' as math;
import 'package:flutter/material.dart';

class AuroraBackground extends StatefulWidget {
  final double energyLevel; // 0.0 to 1.0

  const AuroraBackground({super.key, required this.energyLevel});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Low Energy: Dark purples, deep blues
    // High Energy: Vibrant turquoises, neon greens
    final Color color1 = Color.lerp(
      const Color(0xFF2D0063), // Deep Purple
      const Color(0xFF00F2FE), // Cyan
      widget.energyLevel,
    )!;

    final Color color2 = Color.lerp(
      const Color(0xFF001242), // Deep Blue
      const Color(0xFF4FACFE), // Blue
      widget.energyLevel,
    )!;

    final Color color3 = Color.lerp(
      const Color(0xFF4A00E0), // Vibrant Purple
      const Color(0xFF00FF87), // Neon Green
      widget.energyLevel,
    )!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Solid base
            Container(color: const Color(0xFF0A0A0E)),

            // Aurora Orb 1
            _AuroraOrb(
              color: color1,
              size: 500,
              offset: Offset(
                math.sin(_controller.value * 2 * math.pi) * 100,
                math.cos(_controller.value * 2 * math.pi) * 50,
              ),
              alignment: Alignment.topLeft,
            ),

            // Aurora Orb 2
            _AuroraOrb(
              color: color2,
              size: 450,
              offset: Offset(
                math.cos(_controller.value * 2 * math.pi) * 80,
                math.sin(_controller.value * 2 * math.pi) * 120,
              ),
              alignment: Alignment.bottomRight,
            ),

            // Aurora Orb 3
            _AuroraOrb(
              color: color3,
              size: 400,
              offset: Offset(
                math.sin(_controller.value * 2 * math.pi + 1) * 150,
                math.cos(_controller.value * 2 * math.pi + 1) * 150,
              ),
              alignment: Alignment.center,
            ),
          ],
        );
      },
    );
  }
}

class _AuroraOrb extends StatelessWidget {
  final Color color;
  final double size;
  final Offset offset;
  final Alignment alignment;

  const _AuroraOrb({
    required this.color,
    required this.size,
    required this.offset,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Align(
        alignment: alignment,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.25),
                color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
