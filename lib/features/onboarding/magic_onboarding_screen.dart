import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../data/providers/task_provider.dart';
import '../../data/providers/user_state_provider.dart';

class MagicOnboardingScreen extends ConsumerStatefulWidget {
  const MagicOnboardingScreen({super.key});

  @override
  ConsumerState<MagicOnboardingScreen> createState() =>
      _MagicOnboardingScreenState();
}

class _MagicOnboardingScreenState extends ConsumerState<MagicOnboardingScreen>
    with TickerProviderStateMixin {
  late AnimationController _scannerController;
  late AnimationController _pulseController;
  late Animation<double> _scannerAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _scannerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(incompleteTasksProvider).take(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF020617), // bg-slate-950
      body: Stack(
        children: [
          // 1. Background (The Aurora Effect)
          const Positioned.fill(child: _AuroraBackground()),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // 2. Typography & Header
                  Text(
                    "Ben AURO. Kaosu düzene çevirmek benim işim.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                      shadows: [
                        const Shadow(
                          color: Colors.black45,
                          offset: Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "Sen sadece hedefini söyle, ben gününü senin enerjine göre planlayayım.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueGrey[300],
                        height: 1.5,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // 3. Magic Explanation Card
                  Center(
                    child: GlassmorphicContainer(
                      width: double.infinity,
                      height: 380,
                      borderRadius: 32,
                      blur: 20,
                      alignment: Alignment.center,
                      border: 1,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.05),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                      borderGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF0BD3D3,
                              ).withValues(alpha: 0.15),
                              blurRadius: 50,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  // Hero Task
                                  _HeroTaskCard(),
                                  const SizedBox(height: 20),
                                  // Task List
                                  ...tasks.map(
                                    (task) => _TaskListItem(
                                      title: task.title,
                                      energyIcon: _getEnergyIcon(
                                        task.difficultyScore,
                                      ),
                                    ),
                                  ),
                                  // Fallback tasks if fewer than 3
                                  if (tasks.length < 1) ...[
                                    const _TaskListItem(
                                      title: "Reply to Emails",
                                      energyIcon: Icons.bolt,
                                    ),
                                    const _TaskListItem(
                                      title: "Do Reading",
                                      energyIcon: Icons.coffee,
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Scanner Effect
                            AnimatedBuilder(
                              animation: _scannerAnimation,
                              builder: (context, child) {
                                return Positioned(
                                  top: 100 + (_scannerAnimation.value * 100),
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 2,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF0BD3D3,
                                          ).withValues(alpha: 0.8),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Color(0xFF0BD3D3),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // 4. Action Button
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: double.infinity,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF2DD4BF),
                            Color(0xFFA855F7),
                          ], // Teal-400 to Purple-400
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF2DD4BF,
                            ).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => context.go('/'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: Text(
                          "Ba\u015flayalım \u2728",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEnergyIcon(int difficulty) {
    if (difficulty >= 4) return Icons.bolt;
    if (difficulty >= 2) return Icons.coffee;
    return Icons.lightbulb_outline;
  }
}

class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Radial Blobs
        _Blob(
          alignment: Alignment.topLeft,
          color: const Color(0xFF0BD3D3), // dark teal
          size: 300,
        ),
        _Blob(
          alignment: Alignment.bottomRight,
          color: const Color(0xFFB854FF), // deep purple
          size: 400,
        ),
        _Blob(
          alignment: Alignment.centerRight,
          color: const Color(0xFF1E40AF), // dark blue
          size: 250,
        ),
        // Glassmorphism Blur
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final double size;

  const _Blob({
    required this.alignment,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _HeroTaskCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0BD3D3).withValues(alpha: 0.8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0BD3D3).withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.access_time, color: Color(0xFF0BD3D3), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "SIRADAKİ ODAK: 30 Dakika Yürüyüş Yap",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Icon(Icons.auto_awesome, color: Color(0xFF0BD3D3), size: 18),
        ],
      ),
    );
  }
}

class _TaskListItem extends StatelessWidget {
  final String title;
  final IconData energyIcon;

  const _TaskListItem({required this.title, required this.energyIcon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(energyIcon, color: Colors.white60, size: 18),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
