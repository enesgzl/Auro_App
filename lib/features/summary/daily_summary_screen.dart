import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

import '../../core/theme.dart';
import '../check_in/widgets/aurora_background.dart';

class DailySummaryScreen extends ConsumerStatefulWidget {
  final int completedCount;
  final int totalMinutes;
  final int streak;

  const DailySummaryScreen({
    super.key,
    required this.completedCount,
    this.totalMinutes = 0,
    this.streak = 1,
  });

  @override
  ConsumerState<DailySummaryScreen> createState() => _DailySummaryScreenState();
}

class _DailySummaryScreenState extends ConsumerState<DailySummaryScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Generate confetti particles
    final rng = Random();
    for (int i = 0; i < 40; i++) {
      _particles.add(
        _ConfettiParticle(
          x: rng.nextDouble(),
          speed: 0.5 + rng.nextDouble() * 1.5,
          size: 4 + rng.nextDouble() * 8,
          color: [
            AppTheme.accentTeal,
            AppTheme.accentPurple,
            AppTheme.accentOrange,
            AppTheme.accentPink,
            AppTheme.accentBlue,
            Colors.amber,
          ][i % 6],
          rotation: rng.nextDouble() * pi * 2,
          wobble: rng.nextDouble() * 2 - 1,
        ),
      );
    }

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _scaleController.forward();
    });

    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  static const List<String> _motivationalQuotes = [
    "Bugün harika iş çıkardın! Her adım seni hedefe yaklaştırıyor. 🚀",
    "Başarı, küçük adımların toplamıdır. Bugün o adımları attın! 💪",
    "Kendine yatırım yaptığın her gün, yarının kazancıdır. ✨",
    "Disiplin, motivasyonun sona erdiği yerde başlar. Sen bunu başardın! 🌟",
    "Bugünkü çaban, yarının gülümsemesi olacak. 😊",
    "Her tamamlanan görev, güçlenen bir alışkanlık demek. 🔥",
    "Sen düşündüğünden çok daha güçlüsün! 💎",
    "Küçük zaferler, büyük başarıların kapısını açar. 🏆",
  ];

  String get _randomQuote {
    final rng = Random();
    return _motivationalQuotes[rng.nextInt(_motivationalQuotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          const Positioned.fill(child: AuroraBackground(energyLevel: 0.8)),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.4)),
          ),

          // Confetti animation
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, _) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _confettiController.value,
                ),
              );
            },
          ),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Trophy / celebration icon
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.amber.shade400,
                              Colors.orange.shade600,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.5),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🏆', style: TextStyle(fontSize: 52)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Harika Gün! 🎉',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Tüm günlük görevlerini tamamladın!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),

                    const SizedBox(height: 36),

                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard(
                          '${widget.completedCount}',
                          'Görev',
                          Icons.check_circle_outline,
                          AppTheme.accentTeal,
                        ),
                        _buildStatCard(
                          '${widget.totalMinutes}',
                          'Dakika',
                          Icons.timer_outlined,
                          AppTheme.accentPurple,
                        ),
                        _buildStatCard(
                          '${widget.streak}',
                          'Seri',
                          Icons.local_fire_department_outlined,
                          AppTheme.accentOrange,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Motivational quote
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withValues(alpha: 0.1),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _randomQuote,
                              style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Continue button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.accentTeal,
                              AppTheme.accentPurple,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentTeal.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Devam Et →',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 95,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(label, style: TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }
}

/// Confetti particle data
class _ConfettiParticle {
  final double x;
  final double speed;
  final double size;
  final Color color;
  final double rotation;
  final double wobble;

  _ConfettiParticle({
    required this.x,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotation,
    required this.wobble,
  });
}

/// Confetti painter
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = (progress * p.speed * size.height) % size.height;
      final x = p.x * size.width + sin(progress * pi * 2 + p.wobble) * 30;
      final paint = Paint()
        ..color = p.color.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * p.rotation);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.6,
          ),
          const Radius.circular(1),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
