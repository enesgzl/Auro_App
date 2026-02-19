import 'dart:math';
import '../models/motivational_message.dart';

class MessageRepository {
  /// Get a random message for a specific scenario
  MotivationalMessage? getMessageForScenario(String scenario) {
    return MotivationalMessages.getRandomMessage(scenario);
  }

  /// Get message based on energy level
  MotivationalMessage? getMessageForEnergy(int energyLevel) {
    final scenario = MotivationalMessages.getEnergyScenario(energyLevel);
    return getMessageForScenario(scenario);
  }

  /// Get message based on mood type index
  MotivationalMessage? getMessageForMood(int moodTypeIndex) {
    final scenario = MotivationalMessages.getMoodScenario(moodTypeIndex);
    return getMessageForScenario(scenario);
  }

  /// Get combined message for check-in (considers both energy and mood)
  String getCombinedCheckInMessage(int energyLevel, int moodTypeIndex) {
    // Primary message based on energy
    final energyMessage = getMessageForEnergy(energyLevel);

    // If stormy or cloudy mood, add mood-specific encouragement
    if (moodTypeIndex != 1) {
      // Not sunny
      final moodMessage = getMessageForMood(moodTypeIndex);
      if (moodMessage != null && energyMessage != null) {
        return '${energyMessage.message}\n\n${moodMessage.message}';
      }
    }

    return energyMessage?.message ?? 'Bugün için hazırsın.';
  }

  /// Get task deferred message
  MotivationalMessage? getTaskDeferredMessage() {
    return getMessageForScenario('task_deferred');
  }

  /// Get task completed message
  MotivationalMessage? getTaskCompletedMessage() {
    return getMessageForScenario('task_completed');
  }

  /// Get focus mode start message
  MotivationalMessage? getFocusStartMessage() {
    return getMessageForScenario('focus_start');
  }

  /// Get focus mode end message
  MotivationalMessage? getFocusEndMessage() {
    return getMessageForScenario('focus_end');
  }

  /// Get all messages for a scenario (for testing/preview)
  List<MotivationalMessage> getAllMessagesForScenario(String scenario) {
    return MotivationalMessages.getMessagesForScenario(scenario);
  }

  /// Get random encouraging message for any situation
  String getRandomEncouragement() {
    final allMessages = MotivationalMessages.allMessages;
    final random = Random();
    return allMessages[random.nextInt(allMessages.length)].message;
  }
}
