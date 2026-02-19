import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood_entry.dart';
import '../repositories/mood_repository.dart';

// Repository Provider
final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  return MoodRepository();
});

// State definitions
abstract class MoodState {}

class MoodInitial extends MoodState {}

class MoodLoading extends MoodState {}

class MoodLoaded extends MoodState {
  final List<MoodEntry> entries;
  MoodLoaded(this.entries);
}

class MoodError extends MoodState {
  final String message;
  MoodError(this.message);
}

// Notifier
class MoodNotifier extends StateNotifier<MoodState> {
  final MoodRepository _repository;

  MoodNotifier(this._repository) : super(MoodInitial()) {
    loadEntries();
  }

  Future<void> loadEntries() async {
    try {
      state = MoodLoading();
      final entries = await _repository.getAllEntries();
      state = MoodLoaded(entries);
    } catch (e) {
      state = MoodError("Failed to load entries: $e");
    }
  }

  Future<void> addEntry(MoodEntry entry) async {
    try {
      await _repository.addEntry(entry);
      // Reload to update the list
      await loadEntries();
    } catch (e) {
      state = MoodError("Failed to add entry: $e");
    }
  }
}

// Global Provider
final moodProvider = StateNotifierProvider<MoodNotifier, MoodState>((ref) {
  final repository = ref.watch(moodRepositoryProvider);
  return MoodNotifier(repository);
});
