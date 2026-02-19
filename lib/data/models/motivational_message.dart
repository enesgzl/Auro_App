/// Represents a motivational message for different scenarios
class MotivationalMessage {
  final String id;
  final String
  scenario; // 'low_energy_morning', 'high_energy_morning', 'task_deferred', etc.
  final String message;
  final String tone; // 'compassionate', 'energizing', 'neutral'

  const MotivationalMessage({
    required this.id,
    required this.scenario,
    required this.message,
    required this.tone,
  });

  factory MotivationalMessage.fromJson(Map<String, dynamic> json) {
    return MotivationalMessage(
      id: json['id'] as String,
      scenario: json['scenario'] as String,
      message: json['message'] as String,
      tone: json['tone'] as String? ?? 'neutral',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'scenario': scenario, 'message': message, 'tone': tone};
  }
}

/// Predefined messages for the app (embedded - no external JSON needed)
class MotivationalMessages {
  static const List<MotivationalMessage> allMessages = [
    // Low Energy Morning Messages (Compassionate)
    MotivationalMessage(
      id: 'low_1',
      scenario: 'low_energy_morning',
      message:
          'Tamam, bugün kahraman olmaya gerek yok. Sadece gemiyi yüzdürelim yeter.',
      tone: 'compassionate',
    ),
    MotivationalMessage(
      id: 'low_2',
      scenario: 'low_energy_morning',
      message: 'Bugün rölantideyiz. Sadece en acilleri yapalım.',
      tone: 'compassionate',
    ),
    MotivationalMessage(
      id: 'low_3',
      scenario: 'low_energy_morning',
      message: 'Düşük enerji mi? Sorun değil. Küçük adımlar da adımdır.',
      tone: 'compassionate',
    ),
    MotivationalMessage(
      id: 'low_4',
      scenario: 'low_energy_morning',
      message: 'Kendine nazik ol bugün. Yarın daha güçlü olacaksın.',
      tone: 'compassionate',
    ),
    MotivationalMessage(
      id: 'low_5',
      scenario: 'low_energy_morning',
      message: 'Bazen en cesur şey, yavaşlamayı kabul etmektir.',
      tone: 'compassionate',
    ),

    // Medium Energy Morning Messages (Neutral/Encouraging)
    MotivationalMessage(
      id: 'med_1',
      scenario: 'medium_energy_morning',
      message: 'Fena değil! Dengeli bir gün için hazırsın.',
      tone: 'neutral',
    ),
    MotivationalMessage(
      id: 'med_2',
      scenario: 'medium_energy_morning',
      message: 'Orta tempoda gidiyoruz. Akıllıca seçimler yapalım.',
      tone: 'neutral',
    ),
    MotivationalMessage(
      id: 'med_3',
      scenario: 'medium_energy_morning',
      message: 'Bugün için iyi bir başlangıç. Önceliklere odaklanalım.',
      tone: 'neutral',
    ),

    // High Energy Morning Messages (Energizing)
    MotivationalMessage(
      id: 'high_1',
      scenario: 'high_energy_morning',
      message: 'Harika! Bugün o bekleyen zor işi aradan çıkarabiliriz.',
      tone: 'energizing',
    ),
    MotivationalMessage(
      id: 'high_2',
      scenario: 'high_energy_morning',
      message: 'Enerji dolu bir gün! Büyük adımlar atma zamanı.',
      tone: 'energizing',
    ),
    MotivationalMessage(
      id: 'high_3',
      scenario: 'high_energy_morning',
      message: 'Full güç! Bugün ertelediğin o işi bitirebilirsin.',
      tone: 'energizing',
    ),
    MotivationalMessage(
      id: 'high_4',
      scenario: 'high_energy_morning',
      message: 'Süper enerji! Zor görevi bugün için planla.',
      tone: 'energizing',
    ),

    // Task Deferred Messages (Compassionate)
    MotivationalMessage(
      id: 'defer_1',
      scenario: 'task_deferred',
      message: 'Sorun değil, zamanı gelmemişti.',
      tone: 'compassionate',
    ),
    MotivationalMessage(
      id: 'defer_2',
      scenario: 'task_deferred',
      message: 'Yarına daha taze kafayla yaparsın.',
      tone: 'compassionate',
    ),
    MotivationalMessage(
      id: 'defer_3',
      scenario: 'task_deferred',
      message: 'Ertelemek bazen en akıllı karardır.',
      tone: 'compassionate',
    ),
    MotivationalMessage(
      id: 'defer_4',
      scenario: 'task_deferred',
      message: 'Bu iş senden kaçmaz. Yarın tekrar deneriz.',
      tone: 'compassionate',
    ),

    // Task Completed Messages (Positive)
    MotivationalMessage(
      id: 'done_1',
      scenario: 'task_completed',
      message: 'Güzel iş! Bir adım daha attın.',
      tone: 'energizing',
    ),
    MotivationalMessage(
      id: 'done_2',
      scenario: 'task_completed',
      message: 'Tamamlandı. Sen bunu yaptın!',
      tone: 'energizing',
    ),
    MotivationalMessage(
      id: 'done_3',
      scenario: 'task_completed',
      message: 'Bir iş daha bitti. İlerliyorsun!',
      tone: 'energizing',
    ),

    // Focus Mode Start Messages
    MotivationalMessage(
      id: 'focus_1',
      scenario: 'focus_start',
      message: 'Sadece 5 dakika. Başlamak yeterli.',
      tone: 'neutral',
    ),
    MotivationalMessage(
      id: 'focus_2',
      scenario: 'focus_start',
      message: 'Şimdi odaklan. Dünya 5 dakika bekleyebilir.',
      tone: 'neutral',
    ),

    // Focus Mode End Messages
    MotivationalMessage(
      id: 'focus_end_1',
      scenario: 'focus_end',
      message: 'Süre doldu. Devam mı, mola mı?',
      tone: 'neutral',
    ),
    MotivationalMessage(
      id: 'focus_end_2',
      scenario: 'focus_end',
      message: '5 dakika geçti. Nasıl hissediyorsun?',
      tone: 'neutral',
    ),

    // Cloudy Mood Messages
    MotivationalMessage(
      id: 'cloudy_1',
      scenario: 'mood_cloudy',
      message: 'Bulutlu bir gün. Her şey netleşmek zorunda değil.',
      tone: 'compassionate',
    ),
    MotivationalMessage(
      id: 'cloudy_2',
      scenario: 'mood_cloudy',
      message: 'Sisli zihin mi? Basit işlerle başla, netlik gelir.',
      tone: 'compassionate',
    ),

    // Stormy Mood Messages
    MotivationalMessage(
      id: 'stormy_1',
      scenario: 'mood_stormy',
      message: 'Fırtınalı bir gün. Kendini zorlamana gerek yok.',
      tone: 'compassionate',
    ),
    MotivationalMessage(
      id: 'stormy_2',
      scenario: 'mood_stormy',
      message: 'Stresli mi? Önce derin bir nefes. Sonra küçük bir iş.',
      tone: 'compassionate',
    ),

    // Sunny Mood Messages
    MotivationalMessage(
      id: 'sunny_1',
      scenario: 'mood_sunny',
      message: 'Güneşli bir zihin! Bu enerjiyi değerlendir.',
      tone: 'energizing',
    ),
    MotivationalMessage(
      id: 'sunny_2',
      scenario: 'mood_sunny',
      message: 'Berrak bir gün. Yaratıcı işler için ideal!',
      tone: 'energizing',
    ),
  ];

  /// Get messages for a specific scenario
  static List<MotivationalMessage> getMessagesForScenario(String scenario) {
    return allMessages.where((m) => m.scenario == scenario).toList();
  }

  /// Get a random message for a scenario
  static MotivationalMessage? getRandomMessage(String scenario) {
    final messages = getMessagesForScenario(scenario);
    if (messages.isEmpty) return null;
    messages.shuffle();
    return messages.first;
  }

  /// Get scenario based on energy level
  static String getEnergyScenario(int energyLevel) {
    if (energyLevel <= 33) return 'low_energy_morning';
    if (energyLevel <= 66) return 'medium_energy_morning';
    return 'high_energy_morning';
  }

  /// Get scenario based on mood type index
  static String getMoodScenario(int moodTypeIndex) {
    switch (moodTypeIndex) {
      case 0:
        return 'mood_cloudy';
      case 1:
        return 'mood_sunny';
      case 2:
        return 'mood_stormy';
      default:
        return 'mood_cloudy';
    }
  }
}
