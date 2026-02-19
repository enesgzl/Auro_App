import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../data/models/mood_entry.dart';
import '../../data/providers/mood_provider.dart';

class AtlasScreen extends ConsumerWidget {
  const AtlasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodState = ref.watch(moodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Duygu Atlası"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Colors.black],
          ),
        ),
        child: moodState is MoodLoaded
            ? _buildAtlasGrid(context, moodState.entries)
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildAtlasGrid(BuildContext context, List<MoodEntry> entries) {
    // Generate a list of last 35 days (5 weeks) for the grid
    final now = DateTime.now();
    final List<DateTime> days = List.generate(
      35,
      (i) => now.subtract(Duration(days: 34 - i)),
    );

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "Yaşamının Isı Haritası",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final dayEntries = entries
                    .where(
                      (e) =>
                          e.date.year == day.year &&
                          e.date.month == day.month &&
                          e.date.day == day.day,
                    )
                    .toList();

                Color cellColor = Colors.white.withValues(alpha: 0.05);
                if (dayEntries.isNotEmpty) {
                  // If multiple entries, average or take latest
                  cellColor = Color(dayEntries.last.colorValue);
                }

                return GestureDetector(
                  onTap: () => _showDayDetail(context, day, dayEntries),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 20)),
                    decoration: BoxDecoration(
                      color: cellColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: dayEntries.isNotEmpty
                          ? [
                              BoxShadow(
                                color: cellColor.withValues(alpha: 0.4),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                      border: Border.all(
                        color: day.day == now.day
                            ? Colors.white54
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "${day.day}",
                        style: TextStyle(
                          color: dayEntries.isNotEmpty
                              ? Colors.white
                              : Colors.white24,
                          fontSize: 10,
                          fontWeight: day.day == now.day
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildLegend(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Aura Tonları",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              _legendItem("Mutlu/Enerjik", const Color(0xFFFFD93D)),
              _legendItem("Sakin/Huzurlu", const Color(0xFF95E1D3)),
              _legendItem("Üzgün/Yalnız", const Color(0xFF4D96FF)),
              _legendItem("Stresli/Endişeli", const Color(0xFFE84545)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
      ],
    );
  }

  void _showDayDetail(
    BuildContext context,
    DateTime day,
    List<MoodEntry> entries,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassmorphicContainer(
        width: double.infinity,
        height: 400,
        borderRadius: 30,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.black.withValues(alpha: 0.9),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [Colors.white24, Colors.white10],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('d MMMM yyyy').format(day),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (entries.isEmpty)
                const Center(
                  child: Text(
                    "Bu gün henüz bir aura kaydetmemişsin.",
                    style: TextStyle(color: Colors.white38),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final item = entries[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(item.colorValue).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Color(
                              item.colorValue,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Color(item.colorValue),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.moodLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  DateFormat('HH:mm').format(item.date),
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              "%${(item.intensity * 100).toInt()}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
