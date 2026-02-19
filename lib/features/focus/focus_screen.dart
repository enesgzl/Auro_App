import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/models/task_model.dart';
import '../../data/providers/task_provider.dart';
import '../../data/providers/message_provider.dart';
import 'widgets/focus_timer.dart';

/// Focus mode screen with minimal UI and countdown timer
/// This is the "distraction-free" work environment
class FocusScreen extends ConsumerStatefulWidget {
  final Task task;
  final int durationMinutes;
  final bool isMiniMode; // New parameter

  const FocusScreen({
    super.key,
    required this.task,
    this.durationMinutes = 5,
    this.isMiniMode = false,
  });

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  late int _totalSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _isCompleted = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // If Mini Mode, default to 5 minutes (300 seconds)
    if (widget.isMiniMode) {
      _totalSeconds = 300;
      _remainingSeconds = 300;
    } else {
      _totalSeconds = widget.durationMinutes * 60;
      _remainingSeconds = _totalSeconds;
    }

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Auto-start the timer
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
          _isCompleted = true;
        });
        _onTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resumeTimer() {
    _startTimer();
  }

  void _onTimerComplete() {
    // Subtle haptic feedback (not overwhelming)
    HapticFeedback.mediumImpact();

    // Show completion dialog
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    final endMessage = ref.read(focusEndMessageProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        title: const Row(
          children: [
            Text('✓', style: TextStyle(fontSize: 24)),
            SizedBox(width: 12),
            Text('Süre Doldu', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              endMessage,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.task.title,
              style: TextStyle(
                color: AppTheme.accentTeal.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close focus screen
            },
            child: Text(
              'Mola',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _resetAndContinue();
            },
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.accentTeal.withValues(alpha: 0.2),
            ),
            child: const Text(
              'Devam',
              style: TextStyle(
                color: AppTheme.accentTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(taskProvider.notifier)
                  .completeTask(widget.task.id);
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close focus screen
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.accentPurple.withValues(alpha: 0.2),
            ),
            child: const Text(
              'Görevi Bitir',
              style: TextStyle(
                color: AppTheme.accentPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetAndContinue() {
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isCompleted = false;
    });
    _startTimer();
  }

  void _exitFocus() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        title: Text(widget.isMiniMode ? 'Mini Görev Modu' : 'Odaklan'),
        content: Text(
          'Henüz ${_formatTime(_totalSeconds - _remainingSeconds)} geçti.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Devam et',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Çık',
              style: TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (_remainingSeconds / _totalSeconds);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      // No app bar - minimal UI
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            if (_isRunning) {
              _pauseTimer();
            } else if (!_isCompleted) {
              _resumeTimer();
            }
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: Stack(
              children: [
                // Background pulse effect
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isRunning ? _pulseAnimation.value : 1.0,
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppTheme.accentTeal.withValues(alpha: 0.1),
                                AppTheme.accentTeal.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Task title
                      Text(
                        widget.task.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 60),

                      // Timer display
                      FocusTimer(
                        remainingSeconds: _remainingSeconds,
                        totalSeconds: _totalSeconds,
                        isRunning: _isRunning,
                      ),

                      const SizedBox(height: 40),

                      // Status text
                      Text(
                        _isRunning
                            ? 'Dokunarak duraklat'
                            : (_isCompleted
                                  ? 'Tamamlandı!'
                                  : 'Dokunarak devam et'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Exit button (minimal, top-right)
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    onPressed: _exitFocus,
                  ),
                ),

                // Progress indicator at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.accentTeal.withValues(alpha: 0.5),
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
