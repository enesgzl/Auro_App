import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../core/theme.dart';
import '../../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isSuitable;
  final VoidCallback onTap;
  final VoidCallback onComplete;
  final VoidCallback onFocus;
  final VoidCallback onDefer;

  const TaskCard({
    super.key,
    required this.task,
    required this.isSuitable,
    required this.onTap,
    required this.onComplete,
    required this.onFocus,
    required this.onDefer,
  });

  Color _getDifficultyColor() {
    if (task.difficultyScore >= 4) return Colors.redAccent;
    if (task.difficultyScore >= 3) return Colors.yellowAccent;
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    final difficultyColor = _getDifficultyColor();
    final opacity = isSuitable ? 1.0 : 0.4;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 85,
          borderRadius: 20,
          blur: 15,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Custom Checkbox
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        onComplete();
                      },
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: task.isCompleted
                                ? AppTheme.accentTeal
                                : Colors.white30,
                            width: 2,
                          ),
                          color: task.isCompleted
                              ? AppTheme.accentTeal
                              : Colors.transparent,
                        ),
                        child: task.isCompleted
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Task Info
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: difficultyColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: difficultyColor.withValues(
                                        alpha: 0.5,
                                      ),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                "${task.duration ?? 15} dk",
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                              if (!isSuitable) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '⚡ Enerji!',
                                  style: TextStyle(
                                    color: AppTheme.accentOrange.withValues(
                                      alpha: 0.8,
                                    ),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Play Button
                    if (!task.isCompleted)
                      IconButton(
                        icon: const Icon(
                          Icons.play_circle_outline,
                          color: AppTheme.accentTeal,
                          size: 28,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onFocus();
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
