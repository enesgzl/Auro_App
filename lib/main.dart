import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme.dart';
import 'features/home/home_screen.dart';
import 'features/check_in/check_in_screen.dart';
import 'features/tasks/tasks_screen.dart';
import 'features/login/login_screen.dart';
import 'features/onboarding/magic_onboarding_screen.dart';
import 'data/models/mood_entry.dart';
import 'data/models/user_state.dart';
import 'data/models/task_model.dart';
import 'data/providers/user_state_provider.dart';
import 'data/providers/theme_provider.dart';
import 'data/providers/task_provider.dart';
import 'data/services/default_tasks_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting
  await initializeDateFormatting('tr_TR', null);

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(MoodEntryAdapter());
  Hive.registerAdapter(UserStateAdapter());
  Hive.registerAdapter(TaskAdapter());

  // Open boxes
  await Hive.openBox<MoodEntry>('mood_entries');
  await Hive.openBox<UserState>('user_states');
  await Hive.openBox<Task>('tasks');
  await Hive.openBox('app_settings');

  runApp(const ProviderScope(child: AuroApp()));
}

class AuroApp extends ConsumerWidget {
  const AuroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Auro',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: _createRouter(ref),
    );
  }

  GoRouter _createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        // Check login status
        final box = Hive.box('app_settings');
        final isLoggedIn = box.get('isLoggedIn', defaultValue: false) as bool;

        if (!isLoggedIn && state.matchedLocation != '/login') {
          return '/login';
        }

        if (isLoggedIn && state.matchedLocation == '/login') {
          return '/';
        }

        // Check if user has done check-in THIS SESSION
        final isSessionCheckedIn = ref.read(isSessionCheckedInProvider);

        if (state.matchedLocation == '/') {
          if (!isSessionCheckedIn) {
            return '/check-in';
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const MagicOnboardingScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreenWrapper(),
        ),
        GoRoute(
          path: '/check-in',
          builder: (context, state) => const CheckInScreen(),
        ),
        GoRoute(
          path: '/tasks',
          builder: (context, state) => const TasksScreen(),
        ),
      ],
    );
  }
}

/// Wrapper for HomeScreen that checks loading status and seeds tasks
class HomeScreenWrapper extends ConsumerStatefulWidget {
  const HomeScreenWrapper({super.key});

  @override
  ConsumerState<HomeScreenWrapper> createState() => _HomeScreenWrapperState();
}

class _HomeScreenWrapperState extends ConsumerState<HomeScreenWrapper> {
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _seedTasks();
  }

  Future<void> _seedTasks() async {
    if (_seeded) return;
    _seeded = true;
    final service = DefaultTasksService();
    final tasks = await service.seedDefaultTasks();
    if (tasks.isNotEmpty) {
      // Reload tasks after seeding
      ref.read(taskProvider.notifier).loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userStateState = ref.watch(userStateProvider);

    if (userStateState is UserStateLoading) {
      return Scaffold(
        backgroundColor: AppTheme.bg(context),
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.accentTeal),
        ),
      );
    }

    return const HomeScreen();
  }
}
