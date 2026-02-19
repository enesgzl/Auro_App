import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../data/providers/task_provider.dart';
import '../../data/models/task_model.dart';
import 'widgets/add_task_sheet.dart';
import '../focus/focus_screen.dart';
import '../check_in/widgets/aurora_background.dart';
import '../summary/daily_summary_screen.dart';

enum TaskFilter { all, today, thisWeek }

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  TaskFilter _filter = TaskFilter.today;
  bool _summaryShown = false;

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final stats = ref.watch(taskStatsProvider);
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background
          if (isDark)
            const Positioned.fill(child: AuroraBackground(energyLevel: 0.35)),
          if (isDark)
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
            ),
          if (!isDark)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.backgroundLight,
                      AppTheme.accentTeal.withValues(alpha: 0.03),
                    ],
                  ),
                ),
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context, isDark),
                // Progress
                if (taskState is TaskLoaded)
                  _buildProgressHeader(context, stats, taskState, isDark),
                // Filter chips
                _buildFilterChips(context, isDark),
                // Task list
                Expanded(
                  child: taskState is TaskLoaded
                      ? _buildTaskList(context, taskState, isDark)
                      : Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.accentTeal,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentPurple.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: 'tasks_fab',
          onPressed: () => _showAddTaskSheet(context),
          backgroundColor: AppTheme.accentPurple,
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 26),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Görev Merkezi',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              Text(
                'Hedeflerine odaklan 🎯',
                style: TextStyle(
                  color: AppTheme.textSecondary(context),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(
    BuildContext context,
    Map<String, int> stats,
    TaskLoaded taskState,
    bool isDark,
  ) {
    // Use today's specific stats
    final total = stats['todayTotal'] ?? 0;
    final completed = stats['todayCompleted'] ?? 0;
    // Calculate progress: if total is 0, progress is 0.
    final progress = total > 0 ? completed / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppTheme.accentPurple.withValues(alpha: 0.15),
                    AppTheme.accentTeal.withValues(alpha: 0.1),
                  ]
                : [
                    AppTheme.accentPurple.withValues(alpha: 0.08),
                    AppTheme.accentTeal.withValues(alpha: 0.05),
                  ],
          ),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.04),
          ),
        ),
        child: Row(
          children: [
            // Circular progress
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0
                          ? AppTheme.accentTeal
                          : AppTheme.accentPurple,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress >= 1.0 ? 'Tebrikler! 🎉' : 'Bugünkü İlerleme',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completed görev tamamlandı · $total bekliyor',
                    style: TextStyle(
                      color: AppTheme.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          _buildChip(context, 'Tümü', TaskFilter.all, isDark),
          const SizedBox(width: 8),
          _buildChip(context, 'Bugün', TaskFilter.today, isDark),
          const SizedBox(width: 8),
          _buildChip(context, 'Bu Hafta', TaskFilter.thisWeek, isDark),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label,
    TaskFilter filter,
    bool isDark,
  ) {
    final isSelected = _filter == filter;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _filter = filter);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? AppTheme.accentTeal.withValues(alpha: isDark ? 0.2 : 0.15)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04)),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentTeal.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? AppTheme.accentTeal
                : AppTheme.textSecondary(context),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, TaskLoaded state, bool isDark) {
    List<Task> tasks = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekEnd = today.add(const Duration(days: 7));

    switch (_filter) {
      case TaskFilter.all:
        tasks = state.allTasks;
        break;
      case TaskFilter.today:
        tasks = state.allTasks.where((t) {
          if (t.dueDate == null) return false;
          final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
          return d.isAtSameMomentAs(today);
        }).toList();
        break;
      case TaskFilter.thisWeek:
        tasks = state.allTasks.where((t) {
          if (t.dueDate == null) return false;
          final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
          return !d.isBefore(today) && d.isBefore(weekEnd);
        }).toList();
        break;
    }

    // Sort: incomplete first, then by difficulty
    tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return b.difficultyScore.compareTo(a.difficultyScore);
    });

    if (tasks.isEmpty) {
      return _buildEmptyState(context);
    }

    // Check if all today's tasks are complete → trigger summary
    _checkDailySummary(state);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskItem(context, task, isDark);
      },
    );
  }

  void _checkDailySummary(TaskLoaded state) {
    if (_summaryShown) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayTasks = state.allTasks.where((t) {
      if (t.dueDate == null) return false;
      final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return d.isAtSameMomentAs(today);
    }).toList();

    if (todayTasks.isEmpty) return;

    final allCompleted = todayTasks.every((t) => t.isCompleted);
    if (allCompleted) {
      _summaryShown = true;
      final totalMinutes = todayTasks.fold<int>(
        0,
        (sum, t) => sum + (t.duration ?? 0),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, _) => DailySummaryScreen(
                completedCount: todayTasks.length,
                totalMinutes: totalMinutes,
              ),
              transitionsBuilder: (context, animation, _, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      });
    }
  }

  Widget _buildTaskItem(BuildContext context, Task task, bool isDark) {
    Color diffColor;
    if (task.difficultyScore <= 2) {
      diffColor = AppTheme.difficultyEasy;
    } else if (task.difficultyScore <= 3) {
      diffColor = AppTheme.difficultyMedium;
    } else {
      diffColor = AppTheme.difficultyHard;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => _showTaskOptions(context, task),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: isDark
                ? Colors.white.withValues(alpha: task.isCompleted ? 0.03 : 0.07)
                : (task.isCompleted
                      ? Colors.grey.withValues(alpha: 0.05)
                      : AppTheme.surfaceLight),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(
                      alpha: task.isCompleted ? 0.04 : 0.1,
                    )
                  : Colors.black.withValues(
                      alpha: task.isCompleted ? 0.03 : 0.05,
                    ),
            ),
            boxShadow: isDark || task.isCompleted
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Complete button
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref.read(taskProvider.notifier).toggleTaskCompletion(task.id);
                  if (!task.isCompleted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Tebrikler! Bir görevi daha tamamladın 🎉',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: AppTheme.accentPurple,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: task.isCompleted
                        ? AppTheme.accentTeal
                        : Colors.transparent,
                    border: Border.all(
                      color: task.isCompleted
                          ? AppTheme.accentTeal
                          : diffColor.withValues(alpha: 0.6),
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              // Task content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: task.isCompleted
                            ? AppTheme.textMuted(context)
                            : AppTheme.textPrimary(context),
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: task.isCompleted ? Colors.grey : diffColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          task.difficultyLabel,
                          style: TextStyle(
                            color: AppTheme.textMuted(context),
                            fontSize: 12,
                          ),
                        ),
                        if (task.duration != null) ...[
                          Text(
                            ' · ${task.duration} dk',
                            style: TextStyle(
                              color: AppTheme.textMuted(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Focus button
              if (!task.isCompleted)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FocusScreen(task: task),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.accentTeal.withValues(alpha: 0.12),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: AppTheme.accentTeal,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🎉', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'Görev yok!',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni görev eklemek için + butonuna bas',
            style: TextStyle(
              color: AppTheme.textSecondary(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTaskSheet(),
    );
  }

  void _showTaskOptions(BuildContext context, Task task) {
    final isDark = AppTheme.isDark(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (task.description != null && task.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  task.description!,
                  style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Focus
            _buildOptionTile(
              context,
              icon: Icons.play_arrow_rounded,
              title: 'Odaklan',
              color: AppTheme.accentTeal,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FocusScreen(task: task)),
                );
              },
            ),

            // Complete/Uncomplete
            _buildOptionTile(
              context,
              icon: task.isCompleted
                  ? Icons.undo_rounded
                  : Icons.check_circle_outline_rounded,
              title: task.isCompleted ? 'Geri Al' : 'Tamamla',
              color: AppTheme.accentPurple,
              onTap: () {
                Navigator.pop(context);
                ref.read(taskProvider.notifier).toggleTaskCompletion(task.id);
                if (!task.isCompleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Tebrikler! Bir görevi daha tamamladın 🎉',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: AppTheme.accentPurple,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),

            // Defer
            _buildOptionTile(
              context,
              icon: Icons.next_plan_outlined,
              title: 'Yarına Ertele',
              color: AppTheme.accentOrange,
              onTap: () {
                Navigator.pop(context);
                ref.read(taskProvider.notifier).deferToTomorrow(task.id);
              },
            ),

            // Delete
            _buildOptionTile(
              context,
              icon: Icons.delete_outline_rounded,
              title: 'Sil',
              color: Colors.redAccent,
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, task);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color.withValues(alpha: 0.12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: AppTheme.textPrimary(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  void _confirmDelete(BuildContext context, Task task) {
    final isDark = AppTheme.isDark(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Görevi Sil',
          style: TextStyle(
            color: AppTheme.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '"${task.title}" görevini silmek istediğine emin misin?',
          style: TextStyle(color: AppTheme.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'İptal',
              style: TextStyle(color: AppTheme.textMuted(context)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(taskProvider.notifier).deleteTask(task.id);
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Görev silindi, önüne bakmaya devam et 💪',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            child: const Text('Sil', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
