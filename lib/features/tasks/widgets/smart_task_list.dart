import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:math';

import '../../../core/theme.dart';
import '../../../data/models/task_model.dart';
import '../../../data/providers/task_provider.dart';
import '../../../data/services/smart_planner_service.dart';
import '../../focus/focus_screen.dart';

class SmartTaskList extends ConsumerStatefulWidget {
  final List<Task> tasks;
  final int energyLevel;
  final String? excludeTaskId;
  final bool showPlayButton; // Added to support direct play from calendar

  const SmartTaskList({
    super.key,
    required this.tasks,
    required this.energyLevel,
    this.excludeTaskId,
    this.showPlayButton = false,
  });

  @override
  ConsumerState<SmartTaskList> createState() => _SmartTaskListState();
}

class _SmartTaskListState extends ConsumerState<SmartTaskList> {
  final List<String> _removingTaskIds = [];

  final List<String> _motivations = [
    "Efsane gidiyorsun! 🔥",
    "Bir görev daha bitti, harika! 🚀",
    "Kendine bir kahve ısmarla. ☕",
    "Hız kesmeden devam! ⚡",
    "Bugün çok üretkensin! ✨",
    "Harika bir ivme yakaladın! 🌊",
  ];

  void _completeTask(Task task) async {
    setState(() => _removingTaskIds.add(task.id));
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      ref.read(taskProvider.notifier).completeTask(task.id);
      setState(() => _removingTaskIds.remove(task.id));

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_motivations[Random().nextInt(_motivations.length)]),
          backgroundColor: AppTheme.accentTeal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(12),
        ),
      );
    }
  }

  void _deleteTask(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text("Görevi Sil", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Bu görevi silmek istediğinize emin misiniz?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("İptal", style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Sil",
              style: TextStyle(color: AppTheme.accentOrange),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      ref.read(taskProvider.notifier).deleteTask(task.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // For Calendar, we might want to show COMPLETED tasks too or filter differently
    // But Dashboard filters for non-completed.
    // Let's stick to non-completed as "Task List" usually implies pending work.
    final sortedTasks = SmartPlannerService()
        .getSmartOrder(widget.tasks, widget.energyLevel)
        .where((t) => !t.isCompleted && t.id != widget.excludeTaskId)
        .toList();

    if (sortedTasks.isEmpty) return const SizedBox.shrink();

    final isDark = AppTheme.isDark(context);
    final textPrimary = isDark ? Colors.white : AppTheme.textPrimary(context);
    final textSecondary = isDark
        ? Colors.white38
        : AppTheme.textSecondary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "AKILLI GÖREV LİSTESİ",
          style: TextStyle(
            color: textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedTasks.length,
          itemBuilder: (context, index) {
            final task = sortedTasks[index];
            final isRemoving = _removingTaskIds.contains(task.id);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isRemoving ? 0 : 1,
                child: GlassmorphicContainer(
                  width: double.infinity,
                  height: 70,
                  borderRadius: 16,
                  blur: 15,
                  alignment: Alignment.center,
                  border: 1,
                  linearGradient: LinearGradient(
                    colors: isDark
                        ? [
                            Colors.white.withValues(alpha: 0.08),
                            Colors.white.withValues(alpha: 0.03),
                          ]
                        : [
                            AppTheme.accentPurple.withValues(alpha: 0.05),
                            AppTheme.accentTeal.withValues(alpha: 0.05),
                          ],
                  ),
                  borderGradient: LinearGradient(
                    colors: isDark
                        ? [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.05),
                          ]
                        : [
                            AppTheme.accentPurple.withValues(alpha: 0.2),
                            AppTheme.accentTeal.withValues(alpha: 0.2),
                          ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Custom Checkbox
                        GestureDetector(
                          onTap: () => _completeTask(task),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.accentTeal.withValues(
                                  alpha: 0.8,
                                ),
                                width: 2,
                              ),
                              boxShadow: isRemoving
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.accentTeal.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: isRemoving
                                ? const Center(
                                    child: Icon(
                                      Icons.check,
                                      size: 16,
                                      color: AppTheme.accentTeal,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Task Title + Info
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
                                      color: _getDifficultyColor(
                                        task.difficultyScore,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        decoration: isRemoving
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${task.duration ?? 15} dk",
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Play Icon (if enabled)
                        if (widget.showPlayButton)
                          IconButton(
                            icon: const Icon(
                              Icons.play_circle_outline,
                              color: AppTheme.accentTeal,
                              size: 24,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => FocusScreen(task: task),
                                ),
                              );
                            },
                          ),
                        // Delete Icon
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: isDark ? Colors.white24 : Colors.black26,
                            size: 20,
                          ),
                          onPressed: () => _deleteTask(task),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getDifficultyColor(int score) {
    if (score >= 4) return Colors.redAccent;
    if (score >= 3) return Colors.yellowAccent;
    return Colors.greenAccent;
  }
}
