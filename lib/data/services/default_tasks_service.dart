import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import 'dart:math';

class DefaultTasksService {
  Future<List<Task>> seedDefaultTasks() async {
    final box = await Hive.openBox<Task>('tasks');
    final now = DateTime.now();

    // Check if we have tasks for TODAY
    final hasTodayTasks = box.values.any((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == now.year &&
          t.dueDate!.month == now.month &&
          t.dueDate!.day == now.day;
    });

    if (hasTodayTasks) return [];

    final List<Task> newTasks = [];

    final random = Random();

    // Generate tasks for 5 days (Today - 1 to Today + 3)
    for (int i = -1; i <= 3; i++) {
      final date = now.add(Duration(days: i));

      for (int j = 0; j < 5; j++) {
        final task = Task(
          id: const Uuid().v4(),
          title: _getSampleTitle(j, i),
          description: 'Bu otomatik oluşturulmuş bir örnek görevdir.',
          difficultyScore: random.nextInt(5) + 1,
          createdAt: DateTime.now(),
          dueDate: date,
          duration: 15 + random.nextInt(45), // 15-60 min
          isCompleted: i < 0 && j < 3, // Past tasks partially completed
        );
        newTasks.add(task);
        await box.put(task.id, task);
      }
    }

    return newTasks;
  }

  String _getSampleTitle(int index, int dayOffset) {
    final titles = [
      'Sabah Yürüyüşü',
      'Kitap Oku',
      'E-postaları Kontrol Et',
      'Su İçmeyi Unutma',
      'Kodlama Çalış',
      'Evi Toparla',
      'Film İzle',
      'Alışveriş Listesi Hazırla',
      'Arkadaşını Ara',
      'Meditasyon Yap',
    ];
    return '${titles[index % titles.length]} (${dayOffset == 0 ? "Bugün" : "${dayOffset} Gün"})';
  }
}
