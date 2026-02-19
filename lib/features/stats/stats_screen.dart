import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';

import '../../data/models/mood_entry.dart';
import '../../data/providers/mood_provider.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with TickerProviderStateMixin {
  late AnimationController _bubbleController;
  final List<BubblePhysics> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodState = ref.watch(moodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'İçgörü Laboratuvarı',
          style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w300),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Colors.black],
          ),
        ),
        child: _buildBody(moodState),
      ),
    );
  }

  Widget _buildBody(MoodState state) {
    if (state is MoodLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is MoodLoaded) {
      if (state.entries.isEmpty) return _buildEmptyState();
      return _buildInsightLab(state.entries);
    }
    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.biotech_outlined, size: 80, color: Colors.white10),
          SizedBox(height: 16),
          Text(
            'Laboratuvar Hazır',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          Text(
            'Analiz için daha fazla veriye ihtiyacımız var.',
            style: TextStyle(color: Colors.white24, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightLab(List<MoodEntry> entries) {
    // Analytics calculations
    final moodCounts = <String, int>{};
    final moodColors = <String, Color>{};
    final weekdayMoods = List.generate(7, (_) => <String>[]);

    for (final entry in entries) {
      moodCounts[entry.moodLabel] = (moodCounts[entry.moodLabel] ?? 0) + 1;
      moodColors[entry.moodLabel] = Color(entry.colorValue);
      weekdayMoods[entry.date.weekday - 1].add(entry.moodLabel);
    }

    // Best Day logic (most positive entries)
    final positiveMoods = ['Mutlu', 'Enerjik', 'Minnettar', 'Huzurlu'];
    int bestDayIndex = 0;
    double maxPositivity = -1;
    final weekdayNames = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];

    for (int i = 0; i < 7; i++) {
      if (weekdayMoods[i].isEmpty) continue;
      final posCount = weekdayMoods[i]
          .where((m) => positiveMoods.contains(m))
          .length;
      final ratio = posCount / weekdayMoods[i].length;
      if (ratio > maxPositivity) {
        maxPositivity = ratio;
        bestDayIndex = i;
      }
    }

    // Initialize bubbles if not already
    if (_bubbles.isEmpty && moodCounts.isNotEmpty) {
      final total = entries.length;
      moodCounts.forEach((label, count) {
        final radius = 30.0 + (count / total) * 100.0;
        _bubbles.add(
          BubblePhysics(
            label: label,
            radius: radius,
            color: moodColors[label] ?? Colors.white,
            pos: Offset(
              Random().nextDouble() * 300,
              Random().nextDouble() * 300,
            ),
            vel: Offset(
              Random().nextDouble() * 2 - 1,
              Random().nextDouble() * 2 - 1,
            ),
          ),
        );
      });
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildSectionHeader(
              "Duygusal Yoğunluk",
              "Baloncuklara dokunarak etkileşime gir",
            ),

            // Physics Bubble Container
            Container(
              height: 350,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: AnimatedBuilder(
                  animation: _bubbleController,
                  builder: (context, child) {
                    _updatePhysics();
                    return CustomPaint(
                      painter: BubblePainter(bubbles: _bubbles),
                      child: GestureDetector(
                        onPanUpdate: (details) =>
                            _handleInteraction(details.localPosition),
                        behavior: HitTestBehavior.opaque,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader(
              "Veri Analiz Kartları",
              "Yaşam kaliteni artıran ipuçları",
            ),

            // Insight Cards Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildDeepInsightCard(
                  "En İyi Günün",
                  weekdayNames[bestDayIndex],
                  Icons.star_rounded,
                  const Color(0xFFFFD93D),
                  "Bu günde seni neyin iyi hissettirdiğini hatırla.",
                ),
                _buildDeepInsightCard(
                  "Duygu Çeşitliliği",
                  "${moodCounts.length} Farklı",
                  Icons.palette_outlined,
                  const Color(0xFF6C5CE7),
                  "Duygusal spektrumun %${(moodCounts.length / 8 * 100).toInt()} oranında geniş.",
                ),
                _buildDeepInsightCard(
                  "Analiz Seviyesi",
                  "Yüksek",
                  Icons.analytics_outlined,
                  const Color(0xFF00CEC9),
                  "Verilerin %${min(100, entries.length * 5)} hassasiyetle işlendi.",
                ),
                _buildDeepInsightCard(
                  "Farkındalık Skoru",
                  "${(max(0, entries.length / 10) * 10).toInt()}",
                  Icons.psychology_outlined,
                  const Color(0xFFFF7675),
                  "Sürekli kayıt yaparak bu skoru artırabilirsin.",
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildInsightsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 180,
      borderRadius: 24,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.05),
          Colors.white.withValues(alpha: 0.01),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.2),
          Colors.white.withValues(alpha: 0.05),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFFFFD93D),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "HAFTALIK FARKINDALIK",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Bu hafta salı günleri en verimli günün oldu.",
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 8),
            Text(
              "Öğleden sonraları enerjin düşüyor, zor işleri sabaha almayı dene.",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updatePhysics() {
    const double bounce = 0.8;
    const double friction = 0.99;
    final Size size = const Size(350, 350); // Approximation

    for (var i = 0; i < _bubbles.length; i++) {
      var b = _bubbles[i];

      // Move
      b.pos += b.vel;
      b.vel *= friction;

      // Random jitter for "floating" effect
      b.vel += Offset(
        Random().nextDouble() * 0.1 - 0.05,
        Random().nextDouble() * 0.1 - 0.05,
      );

      // Boundary collision (hardcoded for 350 height, approximate width)
      if (b.pos.dx < b.radius) {
        b.pos = Offset(b.radius, b.pos.dy);
        b.vel = Offset(-b.vel.dx * bounce, b.vel.dy);
      }
      if (b.pos.dx > 300 - b.radius) {
        b.pos = Offset(300 - b.radius, b.pos.dy);
        b.vel = Offset(-b.vel.dx * bounce, b.vel.dy);
      }
      if (b.pos.dy < b.radius) {
        b.pos = Offset(b.pos.dx, b.radius);
        b.vel = Offset(b.vel.dx, -b.vel.dy * bounce);
      }
      if (b.pos.dy > 350 - b.radius) {
        b.pos = Offset(b.pos.dx, 350 - b.radius);
        b.vel = Offset(b.vel.dx, -b.vel.dy * bounce);
      }

      // Circle-Circle collision
      for (var j = i + 1; j < _bubbles.length; j++) {
        var other = _bubbles[j];
        var dist = (b.pos - other.pos).distance;
        var minDist = b.radius + other.radius;
        if (dist < minDist) {
          // Resolve overlap
          final normal = (b.pos - other.pos) / dist;
          final overlap = minDist - dist;
          b.pos += normal * (overlap / 2);
          other.pos -= normal * (overlap / 2);

          // Elastic bounce
          final relativeVelocity = b.vel - other.vel;
          final speed =
              relativeVelocity.dx * normal.dx + relativeVelocity.dy * normal.dy;
          if (speed < 0) {
            final impulse = normal * speed;
            b.vel -= impulse;
            other.vel += impulse;
          }
        }
      }
    }
  }

  void _handleInteraction(Offset touch) {
    for (var b in _bubbles) {
      if ((b.pos - touch).distance < b.radius * 2) {
        final force = (b.pos - touch).distance == 0
            ? Offset(0.1, 0.1)
            : (b.pos - touch) / (b.pos - touch).distance;
        b.vel += force * 5;
      }
    }
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeepInsightCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String footer,
  ) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: double.infinity,
      borderRadius: 20,
      blur: 15,
      alignment: Alignment.topLeft,
      border: 1,
      linearGradient: LinearGradient(
        colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
      ),
      borderGradient: LinearGradient(
        colors: [color.withValues(alpha: 0.3), Colors.white10],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              footer,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BubblePhysics {
  final String label;
  final double radius;
  final Color color;
  Offset pos;
  Offset vel;

  BubblePhysics({
    required this.label,
    required this.radius,
    required this.color,
    required this.pos,
    required this.vel,
  });
}

class BubblePainter extends CustomPainter {
  final List<BubblePhysics> bubbles;
  BubblePainter({required this.bubbles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var b in bubbles) {
      // Glow
      final paintGlow = Paint()
        ..color = b.color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawCircle(b.pos, b.radius, paintGlow);

      // Circle
      final paintCircle = Paint()
        ..shader = RadialGradient(
          colors: [
            b.color.withValues(alpha: 0.8),
            b.color.withValues(alpha: 0.2),
          ],
        ).createShader(Rect.fromCircle(center: b.pos, radius: b.radius));
      canvas.drawCircle(b.pos, b.radius, paintCircle);

      // Border
      final paintBorder = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(b.pos, b.radius, paintBorder);

      // Label Text
      final textSpan = TextSpan(
        text: b.label.substring(0, min(6, b.label.length)),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: ui.TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        b.pos - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
