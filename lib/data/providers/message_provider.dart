import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/message_repository.dart';

// Repository Provider
final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository();
});

// Message Provider - provides context-aware messages
final checkInMessageProvider =
    Provider.family<String, ({int energyLevel, int moodTypeIndex})>((
      ref,
      params,
    ) {
      final repository = ref.watch(messageRepositoryProvider);
      return repository.getCombinedCheckInMessage(
        params.energyLevel,
        params.moodTypeIndex,
      );
    });

// Individual scenario message providers
final taskDeferredMessageProvider = Provider<String>((ref) {
  final repository = ref.watch(messageRepositoryProvider);
  return repository.getTaskDeferredMessage()?.message ??
      'Yarın tekrar deneriz.';
});

final taskCompletedMessageProvider = Provider<String>((ref) {
  final repository = ref.watch(messageRepositoryProvider);
  return repository.getTaskCompletedMessage()?.message ?? 'Tamamlandı!';
});

final focusStartMessageProvider = Provider<String>((ref) {
  final repository = ref.watch(messageRepositoryProvider);
  return repository.getFocusStartMessage()?.message ?? 'Odaklan.';
});

final focusEndMessageProvider = Provider<String>((ref) {
  final repository = ref.watch(messageRepositoryProvider);
  return repository.getFocusEndMessage()?.message ?? 'Süre doldu.';
});

// Random encouragement provider
final randomEncouragementProvider = Provider<String>((ref) {
  final repository = ref.watch(messageRepositoryProvider);
  return repository.getRandomEncouragement();
});
