import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  bool _isBreathing = false;
  String _phase = 'Başlamak için dokun';
  int _breathCount = 0;

  // Breathing pattern: 4-7-8 technique
  final int _inhale = 4;
  final int _hold = 7;
  final int _exhale = 8;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _inhale + _hold + _exhale),
    );

    _breathAnimation = TweenSequence<double>([
      // Inhale - expand
      TweenSequenceItem(
        tween: Tween(
          begin: 0.5,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: _inhale.toDouble(),
      ),
      // Hold - stay expanded
      TweenSequenceItem(tween: ConstantTween(1.0), weight: _hold.toDouble()),
      // Exhale - contract
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.5,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: _exhale.toDouble(),
      ),
    ]).animate(_breathController);

    _breathController.addListener(_updatePhase);
    _breathController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isBreathing) {
        setState(() => _breathCount++);
        _breathController.forward(from: 0);
      }
    });
  }

  void _updatePhase() {
    if (!_isBreathing) return;

    final progress = _breathController.value;
    final totalDuration = _inhale + _hold + _exhale;
    final inhaleEnd = _inhale / totalDuration;
    final holdEnd = (_inhale + _hold) / totalDuration;

    String newPhase;
    if (progress < inhaleEnd) {
      newPhase = 'Nefes Al...';
    } else if (progress < holdEnd) {
      newPhase = 'Tut...';
    } else {
      newPhase = 'Yavaşça Ver...';
    }

    if (newPhase != _phase) {
      setState(() => _phase = newPhase);
      HapticFeedback.lightImpact();
    }
  }

  void _toggleBreathing() {
    setState(() {
      _isBreathing = !_isBreathing;
      if (_isBreathing) {
        _breathController.forward(from: 0);
        _phase = 'Nefes Al...';
      } else {
        _breathController.stop();
        _phase = 'Devam etmek için dokun';
      }
    });
    HapticFeedback.mediumImpact();
  }

  void _reset() {
    setState(() {
      _isBreathing = false;
      _breathCount = 0;
      _phase = 'Başlamak için dokun';
      _breathController.reset();
    });
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nefes Egzersizi'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_breathCount > 0)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: _reset,
            ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF0a0a15)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Info Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  '4-7-8 Nefes Tekniği',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '4 saniye nefes al • 7 saniye tut • 8 saniye ver',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),

              const Spacer(),

              // Breathing Circle
              GestureDetector(
                onTap: _toggleBreathing,
                child: AnimatedBuilder(
                  animation: _breathAnimation,
                  builder: (context, child) {
                    final scale = _breathAnimation.value;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow rings
                        ...List.generate(3, (index) {
                          return Container(
                            width: 200 + (index * 40) * scale,
                            height: 200 + (index * 40) * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(
                                  0xFF6C5CE7,
                                ).withValues(alpha: 0.3 - (index * 0.1)),
                                width: 2,
                              ),
                            ),
                          );
                        }),

                        // Main breathing circle
                        Container(
                          width: 200 * scale,
                          height: 200 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF6C5CE7),
                                const Color(0xFF6C5CE7).withValues(alpha: 0.3),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF6C5CE7,
                                ).withValues(alpha: 0.5 * scale),
                                blurRadius: 50 * scale,
                                spreadRadius: 10 * scale,
                              ),
                            ],
                          ),
                        ),

                        // Center icon/text
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isBreathing ? Icons.spa : Icons.touch_app,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _phase,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),

              const Spacer(),

              // Breath Counter
              if (_breathCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.loop, color: Colors.white54, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '$_breathCount nefes döngüsü',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Tips
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.amber,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'İpucu',
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Rahat bir pozisyon al. Gözlerini kapatabilirsin. '
                      'Nefesini burnundan al, ağzından ver. '
                      'Daire büyürken nefes al, küçülürken ver.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
