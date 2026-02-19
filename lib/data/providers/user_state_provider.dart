import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_state.dart';
import '../repositories/user_state_repository.dart';

// Repository Provider
final userStateRepositoryProvider = Provider<UserStateRepository>((ref) {
  return UserStateRepository();
});

/// Transient provider to track if user has checked in *during this session*
final isSessionCheckedInProvider = StateProvider<bool>((ref) => false);

// State definitions
abstract class UserStateState {}

class UserStateInitial extends UserStateState {}

class UserStateLoading extends UserStateState {}

class UserStateLoaded extends UserStateState {
  final UserState? todayState;
  final bool hasCheckedInToday;

  UserStateLoaded({this.todayState, required this.hasCheckedInToday});
}

class UserStateError extends UserStateState {
  final String message;
  UserStateError(this.message);
}

// Notifier
class UserStateNotifier extends StateNotifier<UserStateState> {
  final UserStateRepository _repository;

  UserStateNotifier(this._repository) : super(UserStateInitial()) {
    checkTodayState();
  }

  /// Check if user has checked in today
  Future<void> checkTodayState() async {
    try {
      state = UserStateLoading();
      final todayState = await _repository.getTodayState();
      state = UserStateLoaded(
        todayState: todayState,
        hasCheckedInToday: todayState != null,
      );
    } catch (e) {
      state = UserStateError("Failed to check state: $e");
    }
  }

  /// Save a new check-in
  Future<void> saveCheckIn(UserState userState) async {
    try {
      await _repository.saveState(userState);
      state = UserStateLoaded(todayState: userState, hasCheckedInToday: true);
    } catch (e) {
      state = UserStateError("Failed to save check-in: $e");
    }
  }

  /// Get current energy level (or default if not checked in)
  int getCurrentEnergyLevel() {
    if (state is UserStateLoaded) {
      final loaded = state as UserStateLoaded;
      return loaded.todayState?.energyLevel ?? 50;
    }
    return 50; // Default mid energy
  }

  /// Check if user needs to check in
  bool needsCheckIn() {
    if (state is UserStateLoaded) {
      return !(state as UserStateLoaded).hasCheckedInToday;
    }
    return true;
  }
}

// Global Provider
final userStateProvider =
    StateNotifierProvider<UserStateNotifier, UserStateState>((ref) {
      final repository = ref.watch(userStateRepositoryProvider);
      return UserStateNotifier(repository);
    });

// Convenience providers
final hasCheckedInTodayProvider = Provider<bool>((ref) {
  final state = ref.watch(userStateProvider);
  if (state is UserStateLoaded) {
    return state.hasCheckedInToday;
  }
  return false;
});

final currentEnergyLevelProvider = Provider<int>((ref) {
  final state = ref.watch(userStateProvider);
  if (state is UserStateLoaded && state.todayState != null) {
    return state.todayState!.energyLevel;
  }
  return 50; // Default
});

final todayUserStateProvider = Provider<UserState?>((ref) {
  final state = ref.watch(userStateProvider);
  if (state is UserStateLoaded) {
    return state.todayState;
  }
  return null;
});
