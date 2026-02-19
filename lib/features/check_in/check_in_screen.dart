import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/models/user_state.dart';
import '../../data/providers/user_state_provider.dart';
import '../../data/providers/message_provider.dart';
import 'widgets/aurora_background.dart';
import 'widgets/vertical_energy_slider.dart';
import 'widgets/mood_selector.dart';

/// Morning ritual check-in screen
/// This is the "Buffer Zone" that greets users before showing tasks
class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0; // 0: Energy, 1: Mood, 2: Message
  double _energyValue = 0.5; // Default: 50%
  int _selectedMood = 2; // Default: Neutral

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  Future<void> _loadUserName() async {
    final name = await ref.read(userStateRepositoryProvider).getUserName();
    if (mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _nextStep() async {
    if (_currentStep < 2) {
      await _fadeController.reverse();
      setState(() {
        _currentStep++;
      });
      _fadeController.forward();
    } else {
      _completeCheckIn();
    }
  }

  void _completeCheckIn() async {
    final energyPercentage = (_energyValue * 100).toInt();

    // Create and save user state
    final userState = UserState(
      id: const Uuid().v4(),
      date: DateTime.now(),
      energyLevel: energyPercentage,
      moodTypeIndex: _selectedMood,
      checkinTime: DateTime.now(),
    );

    await ref.read(userStateProvider.notifier).saveCheckIn(userState);

    // Set checked in for this session
    ref.read(isSessionCheckedInProvider.notifier).state = true;

    // Navigate to home
    if (mounted) {
      context.go('/');
    }
  }

  String _getMotivationalMessage() {
    final energyPercentage = (_energyValue * 100).toInt();
    return ref.read(
      checkInMessageProvider((
        energyLevel: energyPercentage,
        moodTypeIndex: _selectedMood,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allow gradient to cover entire screen
      body: Stack(
        children: [
          // Dynamic Aurora Background
          AuroraBackground(energyLevel: _energyValue),

          // Glass overlay for depth
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // AURO Branding at the top
                  const Text(
                    'AURO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // New Header Structure
                  Column(
                    children: [
                      Text(
                        'Günaydın, ${_userName ?? 'Dostum'} ☀️',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sistemler nasıl çalışıyor?',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),

                  // Progress indicator
                  _buildProgressIndicator(),

                  const SizedBox(height: 40),

                  // Step content
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildCurrentStep(),
                    ),
                  ),

                  // Action button
                  _buildActionButton(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Removed _buildBackgroundOrbs as we use AuroraBackground now

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == _currentStep;
        final isCompleted = index < _currentStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: isActive ? 32 : 12,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: isActive || isCompleted
                ? AppTheme.accentTeal
                : Colors.white.withValues(alpha: 0.2),
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildEnergyStep();
      case 1:
        return _buildMoodStep();
      case 2:
        return _buildMessageStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEnergyStep() {
    String feedback = "";
    if (_energyValue < 0.3) {
      feedback = "Anlaşıldı. Bugün rölantideyiz. Seni yormayacağım. 🌙";
    } else if (_energyValue < 0.7) {
      feedback = "Dengeli. Sadece önemli olanları halledelim. ⚖️";
    } else {
      feedback = "Harika! Bugün dünyaları devirebiliriz. 🚀";
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          VerticalEnergySlider(
            value: _energyValue,
            onChanged: (value) {
              setState(() {
                _energyValue = value;
              });
            },
          ),
          const SizedBox(height: 40),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              feedback,
              key: ValueKey<double>(
                _energyValue < 0.3 ? 0 : (_energyValue < 0.7 ? 1 : 2),
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Nasıl Hissediyorsun?',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 30),
          MoodSelector(
            selectedMood: _selectedMood,
            onChanged: (mood) {
              setState(() {
                _selectedMood = mood;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageStep() {
    final message = _getMotivationalMessage();
    final energyEmoji = _energyValue < 0.3
        ? '😴'
        : (_energyValue < 0.7 ? '🙂' : '🚀');
    final moodEmoji = _selectedMood <= 1
        ? '🌧️'
        : (_selectedMood == 2 ? '🌥️' : '☀️');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Status summary
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(energyEmoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Text(
                '+',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 16),
              Text(moodEmoji, style: const TextStyle(fontSize: 40)),
            ],
          ),
          const SizedBox(height: 40),

          // Motivational message in glass container
          GlassmorphicContainer(
            width: double.infinity,
            height: 260,
            borderRadius: 24,
            blur: 20,
            alignment: Alignment.center,
            border: 1,
            linearGradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderGradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.3),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final isLastStep = _currentStep == 2;
    final buttonText = isLastStep ? 'Senkronize Et & Başla ➔' : 'Devam ➔';

    return GestureDetector(
      onTap: _nextStep,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: GlassmorphicContainer(
          width: 280,
          height: 64,
          borderRadius: 32,
          blur: 20,
          alignment: Alignment.center,
          border: 1.5,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.15),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.4),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          child: Text(
            buttonText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
