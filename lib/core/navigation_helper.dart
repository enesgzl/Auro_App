import 'package:flutter/material.dart';
import '../../features/focus/focus_screen.dart';
import '../../data/models/task_model.dart';

// Helper to navigate to focus
void navigateToFocus(BuildContext context, Task task) {
  // Using direct navigation for now or context.push if route exists
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (context) => FocusScreen(task: task)));
}
