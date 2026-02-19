import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

class TaskRepository {
  static const String boxName = 'tasks';

  Future<Box<Task>> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<Task>(boxName);
    }
    return await Hive.openBox<Task>(boxName);
  }

  /// Add a new task
  Future<void> addTask(Task task) async {
    final box = await _getBox();
    await box.put(task.id, task);
  }

  /// Update an existing task
  Future<void> updateTask(Task task) async {
    final box = await _getBox();
    await box.put(task.id, task);
  }

  /// Get all tasks
  Future<List<Task>> getAllTasks() async {
    final box = await _getBox();
    final tasks = box.values.toList();
    // Sort by: incomplete first, then by due date, then by creation date
    tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return a.createdAt.compareTo(b.createdAt);
    });
    return tasks;
  }

  /// Get incomplete tasks only
  Future<List<Task>> getIncompleteTasks() async {
    final tasks = await getAllTasks();
    return tasks.where((t) => !t.isCompleted).toList();
  }

  /// Get tasks suitable for current energy level
  Future<List<Task>> getTasksForEnergy(int energyLevel) async {
    final tasks = await getIncompleteTasks();
    return tasks.where((t) => t.isSuitableForEnergy(energyLevel)).toList();
  }

  /// Get tasks with difficulty <= maxDifficulty
  Future<List<Task>> getTasksByMaxDifficulty(int maxDifficulty) async {
    final tasks = await getIncompleteTasks();
    return tasks.where((t) => t.difficultyScore <= maxDifficulty).toList();
  }

  /// Get mini tasks for a parent task
  Future<List<Task>> getMiniTasks(String parentTaskId) async {
    final box = await _getBox();
    return box.values.where((t) => t.parentTaskId == parentTaskId).toList();
  }

  /// Get today's tasks (due today or no due date but created today)
  Future<List<Task>> getTodaysTasks() async {
    final tasks = await getIncompleteTasks();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return tasks.where((t) {
      if (t.dueDate != null) {
        return t.dueDate!.isAfter(today.subtract(const Duration(seconds: 1))) &&
            t.dueDate!.isBefore(tomorrow);
      }
      // Include tasks created today if no due date
      return t.createdAt.isAfter(today.subtract(const Duration(seconds: 1)));
    }).toList();
  }

  /// Mark a task as completed
  Future<void> completeTask(String id) async {
    final box = await _getBox();
    final task = box.get(id);
    if (task != null) {
      final updated = task.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      await box.put(id, updated);
    }
  }

  /// Defer task to tomorrow
  Future<void> deferTaskToTomorrow(String id) async {
    final box = await _getBox();
    final task = box.get(id);
    if (task != null) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final updated = task.copyWith(
        dueDate: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0),
      );
      await box.put(id, updated);
    }
  }

  /// Delete a task
  Future<void> deleteTask(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  /// Get task by id
  Future<Task?> getTask(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  /// Create mini-task from parent task
  Future<Task> createMiniTask({
    required String parentTaskId,
    required String title,
    required String id,
  }) async {
    final parentTask = await getTask(parentTaskId);
    final miniTask = Task(
      id: id,
      title: title,
      parentTaskId: parentTaskId,
      isMiniTask: true,
      difficultyScore: 1, // Mini tasks are always easy
      createdAt: DateTime.now(),
      dueDate: parentTask?.dueDate,
    );
    await addTask(miniTask);
    return miniTask;
  }

  /// Get count statistics
  Future<Map<String, int>> getTaskStats() async {
    final tasks = await getAllTasks();
    final incomplete = tasks.where((t) => !t.isCompleted).length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayTasks = tasks.where((t) {
      if (t.dueDate == null) return false;
      final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return d.isAtSameMomentAs(today);
    }).toList();
    final todayCompleted = todayTasks.where((t) => t.isCompleted).length;

    return {
      'total': tasks.length,
      'incomplete': incomplete,
      'completed': completed,
      'todayCompleted': todayCompleted,
      'todayTotal': todayTasks.length,
    };
  }
}
