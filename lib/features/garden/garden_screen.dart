import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../data/models/mood_entry.dart';
import '../../data/providers/mood_provider.dart';
import '../../core/theme.dart';

class GardenScreen extends ConsumerStatefulWidget {
  const GardenScreen({super.key});

  @override
  ConsumerState<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends ConsumerState<GardenScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fireflyController;
  final List<Point> _fireflies = List.generate(
    15,
    (i) => Point(Random().nextDouble(), Random().nextDouble()),
  );

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fireflyController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fireflyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodState = ref.watch(moodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ruh Bahçesi"),
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
        child: moodState is MoodLoaded
            ? _buildContent(moodState.entries)
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildContent(List<MoodEntry> entries) {
    // Logic to determine crystal state based on last 7 days
    final lastWeek = entries
        .where(
          (e) =>
              e.date.isAfter(DateTime.now().subtract(const Duration(days: 7))),
        )
        .toList();

    // Average intensity/valence (mock logic: positive keywords = healthy)
    final positiveMoods = ['Mutlu', 'Enerjik', 'Minnettar', 'Huzurlu'];
    final positiveCount = lastWeek
        .where((e) => positiveMoods.contains(e.moodLabel))
        .length;
    final healthRatio = lastWeek.isEmpty
        ? 0.5
        : positiveCount / lastWeek.length;

    // Determine crystal color - average of last week or default purple
    Color crystalColor = lastWeek.isEmpty
        ? AppTheme.accentPurple
        : Color(lastWeek.last.colorValue);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildTotemSection(healthRatio, crystalColor),
            const SizedBox(height: 40),
            _buildBadgesSection(entries),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTotemSection(double health, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Ambient glow
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(
                          alpha: 0.2 * _pulseController.value * health,
                        ),
                        blurRadius: 100 * _pulseController.value,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                );
              },
            ),

            // Fireflies (only if healthy)
            if (health > 0.4) ..._fireflies.map((p) => _buildFirefly(p, color)),

            // The Crystal Totem
            GestureDetector(
              onTap: () => _showTotemInsight(health),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.05 * health),
                    child: Column(
                      children: [
                        Icon(
                          health > 0.4
                              ? Icons.diamond
                              : Icons.heart_broken_outlined,
                          size: 150,
                          color: color.withValues(
                            alpha: health > 0.3 ? 0.9 : 0.4,
                          ),
                        ),
                        if (health < 0.3)
                          const Icon(
                            Icons.flash_off,
                            color: Colors.white24,
                            size: 40,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          health > 0.7
              ? "Ruhun Parlıyor ✨"
              : health > 0.4
              ? "Dengedesin ⚖️"
              : "Biraz Bakıma İhtiyacın Var 🕯️",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Son 7 günlük duygusal enerjin",
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildFirefly(Point p, Color color) {
    return AnimatedBuilder(
      animation: _fireflyController,
      builder: (context, child) {
        final offset = sin(_fireflyController.value * 2 * pi + p.x * 10) * 10;
        return Positioned(
          left: 150 + (p.x - 0.5) * 250,
          top: 150 + (p.y - 0.5) * 250 + offset,
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color, blurRadius: 10)],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadgesSection(List<MoodEntry> entries) {
    final badges = [
      _BadgeData(
        "Kaşif",
        "İlk 5 aura kaydını yaptın",
        Icons.explore,
        entries.length >= 5,
      ),
      _BadgeData(
        "Sakin Ruh",
        "3 gün üst üste huzurlu hissettin",
        Icons.self_improvement,
        false,
      ),
      _BadgeData(
        "Farkındalık",
        "Uygulamayı 7 gün boyunca kullandın",
        Icons.auto_awesome,
        entries.length >= 7,
      ),
      _BadgeData(
        "Gece Kuşu",
        "Gece 00:00'dan sonra kayıt yaptın",
        Icons.dark_mode,
        false,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ruh Rozetleri",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              return GlassmorphicContainer(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 20,
                blur: 10,
                alignment: Alignment.center,
                border: 1,
                linearGradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
                borderGradient: LinearGradient(
                  colors: [Colors.white24, Colors.white10],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      badge.icon,
                      color: badge.isUnlocked ? Colors.amber : Colors.white10,
                      size: 30,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      badge.name,
                      style: TextStyle(
                        color: badge.isUnlocked ? Colors.white : Colors.white24,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      badge.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showTotemInsight(double health) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          "Ruh Totemi Analizi",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          health > 0.7
              ? "Kristalin çok güçlü parlıyor. Son zamanlarda pozitif enerjin yüksek. Bu ışığı etrafındakilerle paylaşmaya devam et!"
              : health > 0.4
              ? "Dengen yerinde. Hayatın gel-gitlerine uyum sağlıyorsun. Kristalin sakin bir mavisel tonda parlıyor."
              : "Kristalin biraz yorgun görünüyor. Kendine daha fazla zaman ayırmalı ve nefes egzersizlerini denemelisin.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Kapat"),
          ),
        ],
      ),
    );
  }
}

class _BadgeData {
  final String name;
  final String description;
  final IconData icon;
  final bool isUnlocked;

  _BadgeData(this.name, this.description, this.icon, this.isUnlocked);
}

class Point {
  final double x;
  final double y;
  Point(this.x, this.y);
}
