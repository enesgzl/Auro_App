import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import '../../data/models/mood_entry.dart';
import '../../data/providers/mood_provider.dart';
import 'screens/mood_detail_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Use Future.microtask to avoid build conflicts if needed,
    // though the notifier constructor already loads.
    // Refreshing ensures we have latest data when visiting history.
    Future.microtask(() => ref.read(moodProvider.notifier).loadEntries());
  }

  @override
  Widget build(BuildContext context) {
    final moodState = ref.watch(moodProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tapestry of Time"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          // Subtle background gradient
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Color(0xFF1a1a1a)],
          ),
        ),
        child: _buildBody(moodState),
      ),
    );
  }

  Widget _buildBody(MoodState state) {
    if (state is MoodLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is MoodError) {
      return Center(child: Text("Error: ${state.message}"));
    } else if (state is MoodLoaded) {
      if (state.entries.isEmpty) {
        return Center(
          child: Text(
            "Your canvas is empty yet.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      }
      return _buildGrid(state.entries);
    }
    return const SizedBox.shrink();
  }

  Widget _buildGrid(List<MoodEntry> entries) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _MoodTile(entry: entry);
      },
    );
  }
}

class _MoodTile extends StatelessWidget {
  final MoodEntry entry;

  const _MoodTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = Color(entry.colorValue);
    final dateStr = DateFormat('MMM d').format(entry.date);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MoodDetailScreen(entry: entry)),
        );
      },
      child: Hero(
        tag: 'mood_orb_${entry.id}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            // Create a glowing/glassy effect for the tile
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.7),
                color.withValues(alpha: 0.3),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // "Artistic" blur blobs inside the tile
              Positioned(
                top: -10,
                right: -10,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Data content
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Wrap text in Material to avoid Hero text issues
                    Material(
                      color: Colors.transparent,
                      child: Text(
                        entry.moodLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [
                            Shadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: Text(
                        dateStr,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
