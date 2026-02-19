import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Energy level selector widget with 3 options: Low, Medium, High
class EnergySlider extends StatelessWidget {
  final int selectedLevel; // 0: Low (🪫), 1: Medium (🔋), 2: High (⚡)
  final ValueChanged<int> onChanged;

  const EnergySlider({
    super.key,
    required this.selectedLevel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Pil durumun nasıl?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _EnergyOption(
              emoji: '🪫',
              label: 'Bitik',
              sublabel: 'Düşük enerji',
              isSelected: selectedLevel == 0,
              color: const Color(0xFFFF6B6B),
              onTap: () {
                HapticFeedback.mediumImpact();
                onChanged(0);
              },
            ),
            _EnergyOption(
              emoji: '🔋',
              label: 'Orta',
              sublabel: 'Normal enerji',
              isSelected: selectedLevel == 1,
              color: const Color(0xFFFFD93D),
              onTap: () {
                HapticFeedback.mediumImpact();
                onChanged(1);
              },
            ),
            _EnergyOption(
              emoji: '⚡',
              label: 'Full',
              sublabel: 'Yüksek enerji',
              isSelected: selectedLevel == 2,
              color: const Color(0xFF4ECDC4),
              onTap: () {
                HapticFeedback.mediumImpact();
                onChanged(2);
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Convert UI level (0-2) to percentage (1-100)
  static int levelToPercentage(int level) {
    switch (level) {
      case 0:
        return 25; // Low
      case 1:
        return 50; // Medium
      case 2:
        return 85; // High
      default:
        return 50;
    }
  }

  /// Convert percentage (1-100) to UI level (0-2)
  static int percentageToLevel(int percentage) {
    if (percentage <= 33) return 0;
    if (percentage <= 66) return 1;
    return 2;
  }
}

class _EnergyOption extends StatelessWidget {
  final String emoji;
  final String label;
  final String sublabel;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _EnergyOption({
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
        width: isSelected ? 110 : 95,
        height: isSelected ? 140 : 120,
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
