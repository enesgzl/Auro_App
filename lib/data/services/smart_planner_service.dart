import '../../features/tasks/widgets/task_card.dart'; // For logic if needed, but mainly model
import '../models/task_model.dart';
import 'dart:math';

class SmartPlannerService {
  /// Sorts tasks based on the user's energy level.
  ///
  /// [tasks]: The list of incomplete tasks.
  /// [energyLevel]: 0-100.
  List<Task> getSmartOrder(List<Task> tasks, int energyLevel) {
    final incomplete = tasks.where((t) => !t.isCompleted).toList();
    if (incomplete.isEmpty) return [];

    // Calculate a score for each task
    // Higher score = higher priority
    incomplete.sort((a, b) {
      final scoreA = _calculateTaskScore(a, energyLevel);
      final scoreB = _calculateTaskScore(b, energyLevel);
      return scoreB.compareTo(scoreA); // Descending
    });

    return incomplete;
  }

  /// Suggests the single best task for right now.
  Task? getSuggestion(List<Task> tasks, int energyLevel) {
    final sorted = getSmartOrder(tasks, energyLevel);
    if (sorted.isEmpty) return null;
    return sorted.first;
  }

  double _calculateTaskScore(Task task, int energyLevel) {
    double score = 0;

    // 1. Difficulty Alignment
    // Difficulty is 1-5 (assumed 1=easy, 5=hard)
    // Energy is 0-100

    if (energyLevel > 66) {
      // High Energy: Prioritize Hard Tasks (Eat the Frog)
      score += task.difficultyScore * 20;
    } else if (energyLevel < 33) {
      // Low Energy: Prioritize Easy Tasks (Quick Wins)
      // Invert difficulty: Easy(1) becomes 5, Hard(5) becomes 1
      score += (6 - task.difficultyScore) * 20;
    } else {
      // Medium Energy: Balanced, slight preference for medium diff
      score += task.difficultyScore * 10;
    }

    // 2. Due Date Urgency
    if (task.dueDate != null) {
      final daysUntilDue = task.dueDate!.difference(DateTime.now()).inDays;
      if (daysUntilDue < 0) {
        score += 50; // Overdue!
      } else if (daysUntilDue == 0) {
        score += 30; // Due today
      } else if (daysUntilDue <= 2) {
        score += 15; // Due soon
      }
    }

    // 3. Mini Task Bonus (for Low Energy)
    if (energyLevel < 33 && task.isMiniTask) {
      score += 15;
    }

    // 4. Random noise to break ties/stagnation slightly
    // score += Random().nextDouble() * 5;

    return score;
  }
}
