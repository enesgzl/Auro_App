import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A particle representing a single "drop" of mood in the canvas.
class MoodParticle {
  Offset position;
  double radius;
  double opacity;
  double age;
  final double maxAge; // How long the particle lives (seconds)
  final double expansionRate; // How fast it grows
  final Color color;

  MoodParticle({required this.position, required this.color})
    : radius = 10.0 + Random().nextDouble() * 15.0, // Initial random size
      opacity = 1.0,
      age = 0.0,
      // Particle lives between 2.0 and 3.0 seconds
      maxAge = 2.0 + Random().nextDouble() * 1.0,
      // Expands continuously to create diffusion effect
      expansionRate = 15.0 + Random().nextDouble() * 20.0;

  /// Updates the particle state. Returns false if the particle is dead.
  bool update(double dt) {
    age += dt;
    if (age >= maxAge) return false;

    // Linear fade out based on age
    opacity = 1.0 - (age / maxAge);

    // Grow the particle
    radius += expansionRate * dt;

    return true;
  }
}

/// The canvas that renders the generative fluid art.
class MoodCanvas extends StatefulWidget {
  final Color activeColor;

  const MoodCanvas({super.key, required this.activeColor});

  @override
  State<MoodCanvas> createState() => _MoodCanvasState();
}

class _MoodCanvasState extends State<MoodCanvas>
    with SingleTickerProviderStateMixin {
  final List<MoodParticle> _particles = [];
  late Ticker _ticker;
  Duration? _lastElapsed;

  @override
  void initState() {
    super.initState();
    // Ticker ensures we render at the device's refresh rate (e.g., 60fps or 120fps)
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;

    // Calculate delta time in seconds
    final double dt = _lastElapsed == null
        ? 0.0
        : (elapsed - _lastElapsed!).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    if (dt > 0) {
      setState(() {
        // Update all particles and remove dead ones
        _particles.removeWhere((p) => !p.update(dt));
      });
    }
  }

  void _addMoodAt(Offset position) {
    setState(() {
      // Spawn a main particle
      _particles.add(
        MoodParticle(position: position, color: widget.activeColor),
      );

      // Spawn a few smaller auxiliary particles for organic feel
      final random = Random();
      for (int i = 0; i < 2; i++) {
        final offset = Offset(
          (random.nextDouble() - 0.5) * 30,
          (random.nextDouble() - 0.5) * 30,
        );
        _particles.add(
          MoodParticle(position: position + offset, color: widget.activeColor),
        );
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // Correct placement
      // Allow user to draw by dragging
      onPanUpdate: (details) {
        _addMoodAt(details.localPosition);
      },
      // Allow user to tap to create a splash
      onPanDown: (details) {
        _addMoodAt(details.localPosition);
      },
      child: CustomPaint(
        painter: _FluidPainter(particles: List.of(_particles)),
        size: Size.infinite,
      ),
    );
  }
}

class _FluidPainter extends CustomPainter {
  final List<MoodParticle> particles;

  _FluidPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    // We don't clear the canvas because we want to layer on top of background
    // implicitly handled by the parent widget commonly.

    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        // High sigma blur creates the "smoke" or "liquid" look
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30.0)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(particle.position, particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FluidPainter oldDelegate) {
    // Always repaint since particles are animating constantly
    return true;
  }
}
