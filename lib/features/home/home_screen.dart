import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme.dart';
import '../../data/providers/user_state_provider.dart';
import '../../data/providers/task_provider.dart';
import '../../data/models/task_model.dart';
import '../calendar/calendar_screen.dart';
import '../focus/focus_screen.dart';
import '../tasks/tasks_screen.dart';
import '../tasks/widgets/add_task_sheet.dart';
import '../check_in/widgets/aurora_background.dart';
import '../settings/settings_screen.dart';
import '../../data/services/smart_planner_service.dart';
import '../tasks/widgets/smart_task_list.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardView(),
    const CalendarScreen(),
    const TasksScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.backgroundBlack : AppTheme.surfaceLight,
          border: Border(
            top: BorderSide(color: AppTheme.dividerColor(context), width: 1),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            HapticFeedback.selectionClick();
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.accentTeal,
          unselectedItemColor: AppTheme.textMuted(context),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Özet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Takvim',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              activeIcon: Icon(Icons.check_circle),
              label: 'Görevler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Ayarlar',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? Container(
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
                onPressed: () => _showAddTaskSheet(context),
                backgroundColor: AppTheme.accentPurple,
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            )
          : null,
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
}

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStateAsync = ref.watch(userStateProvider);
    final stats = ref.watch(taskStatsProvider);
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Background
          if (isDark)
            const Positioned.fill(child: AuroraBackground(energyLevel: 0.4)),
          if (isDark)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
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
                      AppTheme.accentTeal.withValues(alpha: 0.05),
                      AppTheme.accentPurple.withValues(alpha: 0.03),
                    ],
                  ),
                ),
              ),
            ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header Row ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderGreeting(context, userStateAsync),
                      _buildSOSButton(context),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ── Title & AI Insight ──
                  _buildPremiumHeader(context, userStateAsync),
                  const SizedBox(height: 24),

                  // ── Quick Stats Row ──
                  _buildQuickStats(context, stats),
                  const SizedBox(height: 24),

                  // ── Smart Hero Card ──
                  Builder(
                    builder: (context) {
                      final tasksAsync = ref.watch(taskProvider);
                      if (tasksAsync is TaskLoaded) {
                        final todayTasks = _getTodayTasks(tasksAsync.allTasks);
                        final topTask = _getTopHeroTask(
                          todayTasks,
                          userStateAsync,
                        );
                        if (topTask != null) {
                          return _buildHeroTaskCard(context, ref, topTask);
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 32),

                  // ── Today's Task List ──
                  Builder(
                    builder: (context) {
                      final tasksAsync = ref.watch(taskProvider);
                      final tasks = tasksAsync is TaskLoaded
                          ? _getTodayTasks(tasksAsync.allTasks)
                          : <Task>[];
                      final topTask = _getTopHeroTask(tasks, userStateAsync);

                      if (tasksAsync is TaskLoaded) {
                        if (tasks.isEmpty) {
                          return _buildAllDoneState(context);
                        }
                        return SmartTaskList(
                          tasks: tasks,
                          excludeTaskId: topTask?.id,
                          energyLevel: (userStateAsync is UserStateLoaded)
                              ? userStateAsync.todayState?.energyLevel ?? 50
                              : 50,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 32),

                  // ── AI Suggestions ──
                  _buildAiSuggestions(context, isDark),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Stats Row (TODAY only) ──
  Widget _buildQuickStats(BuildContext context, Map<String, int> stats) {
    final isDark = AppTheme.isDark(context);
    final todayCompleted = stats['todayCompleted'] ?? 0;
    final todayTotal = stats['todayTotal'] ?? 0;
    final todayPending = todayTotal - todayCompleted;
    return Row(
      children: [
        _buildStatChip(
          context,
          icon: Icons.check_circle_outline,
          value: '$todayCompleted',
          label: 'Tamamlanan',
          color: AppTheme.accentTeal,
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _buildStatChip(
          context,
          icon: Icons.pending_actions_outlined,
          value: '${todayPending < 0 ? 0 : todayPending}',
          label: 'Bekleyen',
          color: AppTheme.accentOrange,
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _buildStatChip(
          context,
          icon: Icons.today_outlined,
          value: '$todayTotal',
          label: 'Bugün',
          color: AppTheme.accentPurple,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark
              ? color.withValues(alpha: 0.12)
              : color.withValues(alpha: 0.08),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.25 : 0.15),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary(context),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary(context),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderGreeting(BuildContext context, UserStateState userState) {
    final hour = DateTime.now().hour;
    String greeting = 'Merhaba';
    String emoji = '👋';
    if (hour < 6) {
      greeting = 'İyi Geceler';
      emoji = '🌙';
    } else if (hour < 12) {
      greeting = 'Günaydın';
      emoji = '☀️';
    } else if (hour < 18) {
      greeting = 'Tünaydın';
      emoji = '🌤️';
    } else {
      greeting = 'İyi Akşamlar';
      emoji = '🌗';
    }

    // Get username
    final box = Hive.box('app_settings');
    final username = box.get('username', defaultValue: '') as String;
    final displayName = username.isNotEmpty ? ', $username' : '';

    return Text(
      "$greeting$displayName $emoji",
      style: TextStyle(
        color: AppTheme.textSecondary(context),
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context, UserStateState userState) {
    String aiInsight = "Bugün nasıl hissediyorsun?";

    if (userState is UserStateLoaded) {
      if (userState.todayState != null) {
        final energy = userState.todayState!.energyLevel;
        if (energy > 80) {
          aiInsight = "Enerjin harika! Zorlu görevlere odaklanabiliriz. 🔥";
        } else if (energy < 40) {
          aiInsight = "Enerjin düşük, bugün sakin ilerleyelim. 🌿";
        } else {
          aiInsight = "Dengeli bir gün, akışı takip edelim. 🕊️";
        }
      }
    }

    final isDark = AppTheme.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Auro Dashboard",
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary(context),
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.accentTeal.withValues(alpha: 0.1)
                : AppTheme.accentTeal.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.accentTeal.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            aiInsight,
            style: TextStyle(
              color: isDark
                  ? AppTheme.accentTeal.withValues(alpha: 0.9)
                  : AppTheme.accentTeal,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Filter tasks to today only
  List<Task> _getTodayTasks(List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return tasks.where((t) {
      if (t.dueDate == null) return false;
      final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return d.isAtSameMomentAs(today);
    }).toList();
  }

  Task? _getTopHeroTask(List<Task> tasks, UserStateState userState) {
    // Only use incomplete tasks for hero
    final incomplete = tasks.where((t) => !t.isCompleted).toList();
    if (incomplete.isEmpty) return null;
    if (userState is! UserStateLoaded) {
      return incomplete.first;
    }
    final energy = userState.todayState?.energyLevel ?? 50;
    final sorted = SmartPlannerService().getSmartOrder(incomplete, energy);
    return sorted.firstOrNull;
  }

  Widget _buildHeroTaskCard(BuildContext context, WidgetRef ref, Task task) {
    final isDark = AppTheme.isDark(context);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.04),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.accentPurple.withValues(alpha: 0.1),
                  AppTheme.accentTeal.withValues(alpha: 0.08),
                ],
              ),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : AppTheme.accentPurple.withValues(alpha: 0.15),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: _heroCardContent(context, ref, task),
    );
  }

  Widget _heroCardContent(BuildContext context, WidgetRef ref, Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "SIRADAKİ ODAK",
            style: TextStyle(
              color: AppTheme.accentTeal,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            task.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: AppTheme.textPrimary(context),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${task.duration ?? 15} dk · ${task.difficultyLabel}',
            style: TextStyle(
              color: AppTheme.textSecondary(context),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FocusScreen(task: task),
                ),
              );
            },
            child: Container(
              width: 180,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [AppTheme.accentTeal, AppTheme.accentPurple],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentTeal.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 6),
                  Text(
                    "Odaklan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSButton(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.vibrate();
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => const BreathingOverlay(),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1A1A1A)
              : Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.red.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          "SOS",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.redAccent,
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildAllDoneState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.accentTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.accentTeal.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Text("🎉", style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            "Bugünkü Görevler Bitti!",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Harika iş çıkardın. İstersen yarına göz atabilirsin.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary(context),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              // Switch to calendar tab (index 1)
              final homeState = context
                  .findAncestorStateOfType<_HomeScreenState>();
              if (homeState != null) {
                homeState.setState(() => homeState._currentIndex = 1);
              }
            },
            child: Text(
              "Yarına Göz At →",
              style: TextStyle(
                color: AppTheme.accentTeal,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSuggestions(BuildContext context, bool isDark) {
    final suggestions = [
      "🌿 **Doğa Yürüyüşü**: Bugün 15 dk açık havada yürü, zihnini tazele.",
      "💧 **Su Molası**: Her saat başı bir bardak su içmeyi unutma.",
      "📚 **Okuma Saati**: Yatmadan önce 10 sayfa kitap oku.",
      "🧘‍♂️ **Zihin Molası**: 5 dakika hiçbir şey yapmadan sadece dur.",
    ];
    final random = (DateTime.now().day) % suggestions.length;
    final suggestion = suggestions[random];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "GÜNLÜK AI ÖNERİSİ",
          style: TextStyle(
            color: AppTheme.accentPurple,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF2A2A2A), const Color(0xFF1F1F1F)]
                  : [Colors.white, Colors.grey.shade50],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppTheme.accentPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  suggestion.replaceAll('**', ''), // Simple cleanup for now
                  style: TextStyle(
                    color: AppTheme.textPrimary(context),
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Breathing Overlay (kept from original) ──
class BreathingOverlay extends StatefulWidget {
  const BreathingOverlay({super.key});

  @override
  State<BreathingOverlay> createState() => _BreathingOverlayState();
}

class _BreathingOverlayState extends State<BreathingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _pulseController;
  late Animation<double> _breathAnimation;
  String _phase = 'Nefes Al';
  int _secondsLeft = 300;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _breathAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _startBreathingCycle();
  }

  void _startBreathingCycle() async {
    while (mounted && _secondsLeft > 0) {
      // Inhale
      setState(() => _phase = 'Nefes Al...');
      _breathController.forward();
      await Future.delayed(const Duration(seconds: 4));

      if (!mounted) return;

      // Hold
      setState(() => _phase = 'Tut...');
      await Future.delayed(const Duration(seconds: 4));

      if (!mounted) return;

      // Exhale
      setState(() => _phase = 'Nefes Ver...');
      _breathController.reverse();
      await Future.delayed(const Duration(seconds: 4));

      if (!mounted) return;
      setState(() => _secondsLeft -= 12);
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background
          Container(color: Colors.black.withValues(alpha: 0.9)),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _phase,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _breathAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 160 * _breathAnimation.value,
                      height: 160 * _breathAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.accentTeal.withValues(alpha: 0.6),
                            AppTheme.accentTeal.withValues(alpha: 0.1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentTeal.withValues(alpha: 0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 60),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Kapat',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
