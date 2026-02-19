import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../data/models/mood_entry.dart';
import '../../home/widgets/mood_canvas.dart';

class MoodDetailScreen extends StatelessWidget {
  final MoodEntry entry;

  const MoodDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = Color(entry.colorValue);
    final dateStr = DateFormat('MMMM d, yyyy').format(entry.date);
    final timeStr = DateFormat('h:mm a').format(entry.date);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background reused canvas logic or simple gradient
          Positioned.fill(
            child: Container(
              color: AppTheme.backgroundBlack,
              child: Opacity(
                opacity: 0.3,
                child: MoodCanvas(activeColor: color),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hero Transition for the "Orb"
                Hero(
                  tag: 'mood_orb_${entry.id}',
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.6),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  entry.moodLabel,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: color.withValues(alpha: 0.8),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "$dateStr • $timeStr",
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Text(
                  "Intensity: ${(entry.intensity * 100).toInt()}%",
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
