import 'package:hive/hive.dart';

/// Enum representing the user's mental/mood state
enum MoodType {
  cloudy, // ☁️ Bulutlu - unclear, foggy mind
  sunny, // ☀️ Güneşli - clear, positive mind
  stormy, // ⛈️ Fırtınalı - stressed, chaotic mind
}

/// User's daily energy and mood state for the check-in system
@HiveType(typeId: 1)
class UserState extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int energyLevel; // 1-100 scale (1-33: Low, 34-66: Medium, 67-100: High)

  @HiveField(3)
  final int moodTypeIndex; // Store as index for Hive compatibility

  @HiveField(4)
  final DateTime checkinTime;

  UserState({
    required this.id,
    required this.date,
    required this.energyLevel,
    required this.moodTypeIndex,
    required this.checkinTime,
  });

  /// Get the MoodType enum value
  MoodType get moodType => MoodType.values[moodTypeIndex];

  /// Check if energy is low (1-33)
  bool get isLowEnergy => energyLevel <= 33;

  /// Check if energy is medium (34-66)
  bool get isMediumEnergy => energyLevel > 33 && energyLevel <= 66;

  /// Check if energy is high (67-100)
  bool get isHighEnergy => energyLevel > 66;

  /// Get energy level as a category string
  String get energyCategory {
    if (isLowEnergy) return 'low';
    if (isMediumEnergy) return 'medium';
    return 'high';
  }

  /// Check if this state is from today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

/// Manual Hive TypeAdapter for UserState
class UserStateAdapter extends TypeAdapter<UserState> {
  @override
  final int typeId = 1;

  @override
  UserState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserState(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      energyLevel: fields[2] as int,
      moodTypeIndex: fields[3] as int,
      checkinTime: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserState obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.energyLevel)
      ..writeByte(3)
      ..write(obj.moodTypeIndex)
      ..writeByte(4)
      ..write(obj.checkinTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
