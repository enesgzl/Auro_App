import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_state.dart';

class UserStateRepository {
  static const String boxName = 'user_states';

  Future<Box<UserState>> _getBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<UserState>(boxName);
    }
    return await Hive.openBox<UserState>(boxName);
  }

  /// Save a new user state (check-in)
  Future<void> saveState(UserState state) async {
    final box = await _getBox();
    await box.put(state.id, state);
  }

  /// Get today's check-in state if exists
  Future<UserState?> getTodayState() async {
    final box = await _getBox();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Find today's entry
    try {
      return box.values.firstWhere((state) {
        final stateDate = DateTime(
          state.date.year,
          state.date.month,
          state.date.day,
        );
        return stateDate.isAtSameMomentAs(today);
      });
    } catch (e) {
      return null;
    }
  }

  /// Check if user has checked in today
  Future<bool> hasCheckedInToday() async {
    final todayState = await getTodayState();
    return todayState != null;
  }

  /// Get all states (history)
  Future<List<UserState>> getAllStates() async {
    final box = await _getBox();
    final states = box.values.toList();
    states.sort((a, b) => b.date.compareTo(a.date));
    return states;
  }

  /// Get the most recent state
  Future<UserState?> getLatestState() async {
    final box = await _getBox();
    if (box.isEmpty) return null;

    final states = box.values.toList();
    states.sort((a, b) => b.checkinTime.compareTo(a.checkinTime));
    return states.first;
  }

  /// Delete a state
  Future<void> deleteState(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
  }

  // --- User Settings (Name) ---
  static const String settingsBoxName = 'user_settings';

  Future<Box> _getSettingsBox() async {
    if (Hive.isBoxOpen(settingsBoxName)) {
      return Hive.box(settingsBoxName);
    }
    return await Hive.openBox(settingsBoxName);
  }

  Future<void> saveUserName(String name) async {
    final box = await _getSettingsBox();
    await box.put('user_name', name);
  }

  Future<String?> getUserName() async {
    final box = await _getSettingsBox();
    return box.get('user_name') as String?;
  }
}
