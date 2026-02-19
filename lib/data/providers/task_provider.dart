import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';
import 'user_state_provider.dart';

// Repository Provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

// State definitions
abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> allTasks;
  final List<Task> suitableTasks; // Filtered by current energy
  final Map<String, int> stats;

  TaskLoaded({
    required this.allTasks,
    required this.suitableTasks,
    required this.stats,
  });

  /// Get incomplete tasks only
  List<Task> get incompleteTasks =>
      allTasks.where((t) => !t.isCompleted).toList();

  /// Get completed tasks only
  List<Task> get completedTasks =>
      allTasks.where((t) => t.isCompleted).toList();
}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}

// Notifier
class TaskNotifier extends StateNotifier<TaskState> {
  final TaskRepository _repository;
  final Ref _ref;

  TaskNotifier(this._repository, this._ref) : super(TaskInitial()) {
    loadTasks();
  }

  /// Load all tasks
  Future<void> loadTasks() async {
    try {
      state = TaskLoading();
      final allTasks = await _repository.getAllTasks();
      final energyLevel = _ref.read(currentEnergyLevelProvider);
      final suitableTasks = await _repository.getTasksForEnergy(energyLevel);
      final stats = await _repository.getTaskStats();

      state = TaskLoaded(
        allTasks: allTasks,
        suitableTasks: suitableTasks,
        stats: stats,
      );
    } catch (e) {
      state = TaskError("Failed to load tasks: $e");
    }
  }

  /// Add a new task
  Future<void> addTask(Task task) async {
    try {
      await _repository.addTask(task);
      await loadTasks();
    } catch (e) {
      state = TaskError("Failed to add task: $e");
    }
  }

  /// Update a task
  Future<void> updateTask(Task task) async {
    try {
      await _repository.updateTask(task);
      await loadTasks();
    } catch (e) {
      state = TaskError("Failed to update task: $e");
    }
  }

  /// Complete a task
  Future<void> completeTask(String taskId) async {
    try {
      await _repository.completeTask(taskId);
      await loadTasks();
    } catch (e) {
      state = TaskError("Failed to complete task: $e");
    }
  }

  /// Toggle task completion
  Future<void> toggleTaskCompletion(String taskId) async {
    try {
      final task = await _repository.getTask(taskId);
      if (task != null) {
        final updated = task.copyWith(
          isCompleted: !task.isCompleted,
          completedAt: !task.isCompleted ? DateTime.now() : null,
        );
        await _repository.updateTask(updated);
        await loadTasks();
      }
    } catch (e) {
      state = TaskError("Failed to toggle task: $e");
    }
  }

  /// Defer task to tomorrow
  Future<void> deferToTomorrow(String taskId) async {
    try {
      await _repository.deferTaskToTomorrow(taskId);
      await loadTasks();
    } catch (e) {
      state = TaskError("Failed to defer task: $e");
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _repository.deleteTask(taskId);
      await loadTasks();
    } catch (e) {
      state = TaskError("Failed to delete task: $e");
    }
  }

  /// Create a mini task from parent
  Future<void> createMiniTask({
    required String parentTaskId,
    required String title,
    required String id,
  }) async {
    try {
      await _repository.createMiniTask(
        parentTaskId: parentTaskId,
        title: title,
        id: id,
      );
      await loadTasks();
    } catch (e) {
      state = TaskError("Failed to create mini task: $e");
    }
  }
}

// Global Provider
final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TaskNotifier(repository, ref);
});

// Convenience providers

/// Gets only incomplete tasks
final incompleteTasksProvider = Provider<List<Task>>((ref) {
  final state = ref.watch(taskProvider);
  if (state is TaskLoaded) {
    return state.incompleteTasks;
  }
  return [];
});

/// Gets tasks suitable for current energy level
final suitableTasksProvider = Provider<List<Task>>((ref) {
  final state = ref.watch(taskProvider);
  if (state is TaskLoaded) {
    return state.suitableTasks;
  }
  return [];
});

/// Gets task statistics
final taskStatsProvider = Provider<Map<String, int>>((ref) {
  final state = ref.watch(taskProvider);
  if (state is TaskLoaded) {
    return state.stats;
  }
  return {'total': 0, 'incomplete': 0, 'completed': 0, 'todayCompleted': 0};
});

/// Gets the most urgent task (first incomplete task suitable for energy)
final urgentTaskProvider = Provider<Task?>((ref) {
  final suitable = ref.watch(suitableTasksProvider);
  final incomplete = suitable.where((t) => !t.isCompleted).toList();
  if (incomplete.isEmpty) return null;
  return incomplete.first;
});
