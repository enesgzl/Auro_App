import 'package:hive/hive.dart';

/// Task model with difficulty scoring for energy-aware task management
@HiveType(typeId: 2)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final DateTime? dueDate;

  @HiveField(4)
  final int difficultyScore; // 1-5 scale

  @HiveField(5)
  final bool isMiniTask;

  @HiveField(6)
  final String? parentTaskId; // For breaking down big tasks

  @HiveField(7)
  final bool isCompleted;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime? completedAt;

  @HiveField(10)
  final int? duration; // In minutes

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.difficultyScore,
    this.isMiniTask = false,
    this.parentTaskId,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.duration,
  });

  /// Keywords that indicate high difficulty tasks (score 4-5)
  static const List<String> highDifficultyKeywords = [
    'sunum',
    'presentation',
    'rapor',
    'report',
    'bütçe',
    'budget',
    'strateji',
    'strategy',
    'analiz',
    'analysis',
    'proje',
    'project',
    'tez',
    'thesis',
    'toplantı',
    'meeting',
    'planlama',
    'planning',
  ];

  /// Keywords that indicate medium difficulty tasks (score 3)
  static const List<String> mediumDifficultyKeywords = [
    'düzenle',
    'organize',
    'hazırla',
    'prepare',
    'gözden geçir',
    'review',
    'araştır',
    'research',
    'tasarla',
    'design',
    'yaz',
    'write',
  ];

  /// Keywords that indicate low difficulty tasks (score 1-2)
  static const List<String> lowDifficultyKeywords = [
    'mail',
    'email',
    'mesaj',
    'message',
    'ara',
    'call',
    'oku',
    'read',
    'kontrol',
    'check',
    'gönder',
    'send',
    'yanıtla',
    'reply',
  ];

  /// Auto-calculate difficulty score from task title
  static int calculateDifficultyFromTitle(String title) {
    final lowerTitle = title.toLowerCase();

    // Check for high difficulty keywords
    for (final keyword in highDifficultyKeywords) {
      if (lowerTitle.contains(keyword)) {
        return 5;
      }
    }

    // Check for medium difficulty keywords
    for (final keyword in mediumDifficultyKeywords) {
      if (lowerTitle.contains(keyword)) {
        return 3;
      }
    }

    // Check for low difficulty keywords
    for (final keyword in lowDifficultyKeywords) {
      if (lowerTitle.contains(keyword)) {
        return 2;
      }
    }

    // Default medium difficulty
    return 3;
  }

  /// Create a copy with updated fields
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    int? difficultyScore,
    bool? isMiniTask,
    String? parentTaskId,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    int? duration,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      difficultyScore: difficultyScore ?? this.difficultyScore,
      isMiniTask: isMiniTask ?? this.isMiniTask,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      duration: duration ?? this.duration,
    );
  }

  /// Check if task is suitable for current energy level
  bool isSuitableForEnergy(int energyLevel) {
    if (energyLevel <= 33) {
      // Low energy: only easy tasks (1-2)
      return difficultyScore <= 2;
    } else if (energyLevel <= 66) {
      // Medium energy: easy to medium tasks (1-4)
      return difficultyScore <= 4;
    }
    // High energy: all tasks
    return true;
  }

  /// Get difficulty label
  String get difficultyLabel {
    switch (difficultyScore) {
      case 1:
        return 'Çok Kolay';
      case 2:
        return 'Kolay';
      case 3:
        return 'Orta';
      case 4:
        return 'Zor';
      case 5:
        return 'Çok Zor';
      default:
        return 'Orta';
    }
  }
}

/// Manual Hive TypeAdapter for Task
class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 2;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      dueDate: fields[3] as DateTime?,
      difficultyScore: fields[4] as int,
      isMiniTask: fields[5] as bool,
      parentTaskId: fields[6] as String?,
      isCompleted: fields[7] as bool,
      createdAt: fields[8] as DateTime,
      completedAt: fields[9] as DateTime?,
      duration: fields[10] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.difficultyScore)
      ..writeByte(5)
      ..write(obj.isMiniTask)
      ..writeByte(6)
      ..write(obj.parentTaskId)
      ..writeByte(7)
      ..write(obj.isCompleted)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.completedAt)
      ..writeByte(10)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
