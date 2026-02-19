import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../focus/focus_screen.dart';
import '../../core/theme.dart';
import '../../data/providers/task_provider.dart';
import '../../data/models/task_model.dart';
import '../tasks/widgets/add_task_sheet.dart';
import '../check_in/widgets/aurora_background.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final isDark = AppTheme.isDark(context);

    // Build events map
    Map<DateTime, List<Task>> events = {};
    if (taskState is TaskLoaded) {
      for (final task in taskState.allTasks) {
        if (task.dueDate != null) {
          final key = DateTime(
            task.dueDate!.year,
            task.dueDate!.month,
            task.dueDate!.day,
          );
          events.putIfAbsent(key, () => []);
          events[key]!.add(task);
        }
      }
    }

    final selectedTasks = _getTasksForDay(events, _selectedDay ?? _focusedDay);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background
          if (isDark)
            const Positioned.fill(child: AuroraBackground(energyLevel: 0.3)),
          if (isDark)
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.4)),
            ),
          if (!isDark)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.backgroundLight,
                      AppTheme.accentPurple.withValues(alpha: 0.03),
                    ],
                  ),
                ),
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Takvim',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                          Text(
                            DateFormat(
                              'MMMM yyyy',
                              'tr_TR',
                            ).format(_focusedDay),
                            style: TextStyle(
                              color: AppTheme.accentTeal,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      // Add task button
                      GestureDetector(
                        onTap: () => _showAddTaskSheet(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: isDark
                                ? AppTheme.accentPurple.withValues(alpha: 0.2)
                                : AppTheme.accentPurple.withValues(alpha: 0.1),
                            border: Border.all(
                              color: AppTheme.accentPurple.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.add_rounded,
                            color: AppTheme.accentPurple,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Calendar
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildCalendarCard(context, events, isDark),
                        const SizedBox(height: 16),
                        // Day header
                        _buildDayHeader(context, selectedTasks),
                        // Task list for selected day
                        if (selectedTasks.isEmpty)
                          _buildEmptyState(context)
                        else
                          ...selectedTasks.map(
                            (task) =>
                                _buildTaskTile(context, ref, task, isDark),
                          ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(
    BuildContext context,
    Map<DateTime, List<Task>> events,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : AppTheme.surfaceLight,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: TableCalendar<Task>(
            firstDay: DateTime.now().subtract(const Duration(days: 30)),
            lastDay: DateTime.now().add(const Duration(days: 90)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) =>
                _selectedDay != null && isSameDay(_selectedDay!, day),
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            onDaySelected: (selectedDay, focusedDay) {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() => _focusedDay = focusedDay);
            },
            eventLoader: (day) {
              final key = DateTime(day.year, day.month, day.day);
              return events[key] ?? [];
            },
            locale: 'tr_TR',
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(
                Icons.chevron_left_rounded,
                color: AppTheme.textPrimary(context),
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textPrimary(context),
              ),
              titleTextStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary(context),
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: AppTheme.textMuted(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              weekendStyle: TextStyle(
                color: AppTheme.accentPink.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(
                color: AppTheme.accentTeal.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.accentTeal, AppTheme.accentPurple],
                ),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              defaultTextStyle: TextStyle(
                color: AppTheme.textPrimary(context),
                fontWeight: FontWeight.w500,
              ),
              weekendTextStyle: TextStyle(
                color: AppTheme.accentPink.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
              markersMaxCount: 3,
              markersAlignment: Alignment.bottomCenter,
              markerDecoration: const BoxDecoration(),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;
                return Positioned(
                  bottom: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildDifficultyMarkers(events),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDifficultyMarkers(List<Task> events) {
    // Show up to 3 difficulty-colored dots
    final tasks = events.take(3).toList();
    return tasks.map((task) {
      Color color;
      if (task.isCompleted) {
        color = Colors.grey;
      } else if (task.difficultyScore <= 2) {
        color = AppTheme.difficultyEasy;
      } else if (task.difficultyScore <= 3) {
        color = AppTheme.difficultyMedium;
      } else {
        color = AppTheme.difficultyHard;
      }
      return Container(
        width: 6,
        height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
    }).toList();
  }

  Widget _buildDayHeader(BuildContext context, List<Task> tasks) {
    final day = _selectedDay ?? _focusedDay;
    final isToday = isSameDay(day, DateTime.now());
    final completedCount = tasks.where((t) => t.isCompleted).length;
    final totalCount = tasks.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isToday ? 'Bugün' : _formatDate(day),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              if (totalCount > 0)
                Text(
                  '$completedCount / $totalCount görev tamamlandı',
                  style: TextStyle(
                    color: AppTheme.textSecondary(context),
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          if (totalCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: completedCount == totalCount
                    ? AppTheme.accentTeal.withValues(alpha: 0.15)
                    : AppTheme.accentOrange.withValues(alpha: 0.12),
              ),
              child: Text(
                completedCount == totalCount ? '✅ Bitti' : '⏳ Devam',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: completedCount == totalCount
                      ? AppTheme.accentTeal
                      : AppTheme.accentOrange,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(
    BuildContext context,
    WidgetRef ref,
    Task task,
    bool isDark,
  ) {
    Color diffColor;
    if (task.difficultyScore <= 2) {
      diffColor = AppTheme.difficultyEasy;
    } else if (task.difficultyScore <= 3) {
      diffColor = AppTheme.difficultyMedium;
    } else {
      diffColor = AppTheme.difficultyHard;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          _showTaskOptions(context, ref, task);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppTheme.surfaceLight,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
            ),
          ),
          child: Row(
            children: [
              // Difficulty dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted ? Colors.grey : diffColor,
                ),
              ),
              const SizedBox(width: 14),
              // Task info
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
                    if (task.duration != null)
                      Text(
                        '${task.duration} dk · ${task.difficultyLabel}',
                        style: TextStyle(
                          color: AppTheme.textMuted(context),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              // Complete toggle
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref.read(taskProvider.notifier).toggleTaskCompletion(task.id);
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    task.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: task.isCompleted
                        ? AppTheme.accentTeal
                        : AppTheme.textMuted(context),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskOptions(BuildContext context, WidgetRef ref, Task task) {
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
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.play_arrow_rounded,
                color: AppTheme.accentTeal,
              ),
              title: Text(
                'Odaklan',
                style: TextStyle(color: AppTheme.textPrimary(context)),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FocusScreen(task: task)),
                );
              },
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: Icon(
                task.isCompleted
                    ? Icons.undo_rounded
                    : Icons.check_circle_outline_rounded,
                color: AppTheme.accentPurple,
              ),
              title: Text(
                task.isCompleted ? 'Geri Al' : 'Tamamla',
                style: TextStyle(color: AppTheme.textPrimary(context)),
              ),
              onTap: () {
                Navigator.pop(context);
                ref.read(taskProvider.notifier).toggleTaskCompletion(task.id);
              },
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(
                Icons.next_plan_outlined,
                color: AppTheme.accentOrange,
              ),
              title: Text(
                'Yarına Ertele',
                style: TextStyle(color: AppTheme.textPrimary(context)),
              ),
              onTap: () {
                Navigator.pop(context);
                ref.read(taskProvider.notifier).deferToTomorrow(task.id);
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Text('🎯', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Bu güne ait görev yok',
            style: GoogleFonts.poppins(
              color: AppTheme.textSecondary(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Yeni görev ekleyerek başla',
            style: TextStyle(color: AppTheme.textMuted(context), fontSize: 13),
          ),
        ],
      ),
    );
  }

  List<Task> _getTasksForDay(Map<DateTime, List<Task>> events, DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return events[key] ?? [];
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMMM, EEEE', 'tr_TR').format(date);
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTaskSheet(),
    );
  }
}
