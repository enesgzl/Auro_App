import 'package:hive_flutter/hive_flutter.dart';
import '../models/mood_entry.dart';

class MoodRepository {
  static const String boxName = 'mood_entries';

  Future<Box<MoodEntry>> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<MoodEntry>(boxName);
    }
    return await Hive.openBox<MoodEntry>(boxName);
  }

  Future<void> addEntry(MoodEntry entry) async {
    final box = await _getBox();
    await box.put(entry.id, entry);
  }

  Future<List<MoodEntry>> getAllEntries() async {
    final box = await _getBox();
    // Return sorted by date descending (newest first)
    final entries = box.values.toList();
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  Future<void> deleteEntry(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
}
