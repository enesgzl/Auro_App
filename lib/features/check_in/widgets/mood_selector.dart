import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mood type selector with weather metaphors
class MoodSelector extends StatelessWidget {
  final int selectedMood; // 0: Cloudy, 1: Sunny, 2: Stormy
  final ValueChanged<int> onChanged;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onChanged,
  });

  void _handleTap(int index) {
    HapticFeedback.mediumImpact();
    onChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Zihin durumun nasıl?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _MoodOption(
                emoji: '😫',
                label: 'Çok Kötü',
                sublabel: 'Tükenmiş',
                isSelected: selectedMood == 0,
                color: const Color(0xFFEF5350),
                onTap: () => _handleTap(0),
              ),
              _MoodOption(
                emoji: '😶‍🌫️',
                label: 'Kötü',
                sublabel: 'Kaygılı',
                isSelected: selectedMood == 1,
                color: const Color(0xFFAB47BC),
                onTap: () => _handleTap(1),
              ),
              _MoodOption(
                emoji: '😐',
                label: 'Nötr',
                sublabel: 'Durgun',
                isSelected: selectedMood == 2,
                color: const Color(0xFF7E57C2),
                onTap: () => _handleTap(2),
              ),
              _MoodOption(
                emoji: '🙂',
                label: 'İyi',
                sublabel: 'Dengeli',
                isSelected: selectedMood == 3,
                color: const Color(0xFF26A69A),
                onTap: () => _handleTap(3),
              ),
              _MoodOption(
                emoji: '🤩',
                label: 'Harika',
                sublabel: 'Enerjik',
                isSelected: selectedMood == 4,
                color: const Color(0xFFFFCA28),
                onTap: () => _handleTap(4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MoodOption extends StatelessWidget {
  final String emoji;
  final String label;
  final String sublabel;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _MoodOption({
    required this.emoji,
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: isSelected ? 90 : 80, // Slightly smaller
        height: isSelected ? 120 : 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isSelected
              ? color.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(fontSize: isSelected ? 42 : 32),
              child: Text(emoji),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: isSelected ? 16 : 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
