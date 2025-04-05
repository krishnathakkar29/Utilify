import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Data Models
class Task {
  final String id;
  String name;
  Duration totalDuration;
  bool isTracking;
  DateTime? currentStartTime;

  Task({
    required this.id,
    required this.name,
    this.totalDuration = Duration.zero,
    this.isTracking = false,
    this.currentStartTime,
  });
}

class TimeEntry {
  final String id;
  final String taskId;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;

  TimeEntry({
    required this.id,
    required this.taskId,
    required this.startTime,
    required this.endTime,
    required this.duration,
  });
}

class TimesheetScreen extends StatefulWidget {
  const TimesheetScreen({super.key});

  @override
  State<TimesheetScreen> createState() => _TimesheetScreenState();
}

class _TimesheetScreenState extends State<TimesheetScreen> {
  // In-memory storage (replace with database for persistence)
  List<Task> _tasks = [];
  List<TimeEntry> _timeEntries = [];
  Timer? _uiUpdateTimer; // Timer to update durations of active tasks

  @override
  void initState() {
    super.initState();
    // Timer to update the UI for running tasks every second
    _uiUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_tasks.any((task) => task.isTracking)) {
        setState(() {}); // Trigger rebuild to update durations
      }
    });
  }

  @override
  void dispose() {
    _uiUpdateTimer?.cancel();
    super.dispose();
  }

  void _addTask() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Task Name'),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).primaryColor.withOpacity(0.7),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Add',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _tasks.add(
                      Task(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                      ),
                    );
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _startTracking(Task task) {
    // Stop any other currently tracking task first (optional, depends on desired behavior)
    // _tasks.where((t) => t.isTracking && t.id != task.id).forEach(_stopTracking);

    setState(() {
      task.isTracking = true;
      task.currentStartTime = DateTime.now();
    });
  }

  void _stopTracking(Task task) {
    if (!task.isTracking || task.currentStartTime == null) return;

    final endTime = DateTime.now();
    final startTime = task.currentStartTime!;
    final duration = endTime.difference(startTime);

    setState(() {
      task.isTracking = false;
      task.currentStartTime = null;
      task.totalDuration += duration;

      // Add a time entry log
      _timeEntries.add(
        TimeEntry(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          taskId: task.id,
          startTime: startTime,
          endTime: endTime,
          duration: duration,
        ),
      );
    });
  }

  void _deleteTask(Task task) {
    // Optional: Confirmation dialog
    setState(() {
      // Stop tracking if active
      if (task.isTracking) {
        _stopTracking(task); // Stop and log time before deleting
      }
      // Remove task and its entries
      _timeEntries.removeWhere((entry) => entry.taskId == task.id);
      _tasks.removeWhere((t) => t.id == task.id);
    });
  }

  Duration _getCurrentlyTrackedDuration(Task task) {
    if (task.isTracking && task.currentStartTime != null) {
      return DateTime.now().difference(task.currentStartTime!);
    }
    return Duration.zero;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (hours > 0) {
      return "${hours}h ${minutes}m ${seconds}s";
    } else if (duration.inMinutes > 0) {
      return "${minutes}m ${seconds}s";
    } else {
      return "${seconds}s";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2, // Tasks and Log
      child: Scaffold(
        backgroundColor: theme.primaryColorDark,
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Theme.of(context).primaryColor,
            ),
          ),
          centerTitle: true,
          title: Text(
            'TimeSheets',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 24,
            ),
          ),
          backgroundColor: theme.primaryColorDark,
          foregroundColor: theme.appBarTheme.foregroundColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.add_task, color: Theme.of(context).primaryColor),
              tooltip: 'Add Task',
              onPressed: _addTask,
            ),
          ],
          bottom: TabBar(
            indicatorColor: theme.primaryColor,
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(icon: Icon(Icons.list_alt), text: 'Tasks'),
              Tab(icon: Icon(Icons.history), text: 'Log'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tasks Tab
            _buildTasksList(theme),
            // Log Tab
            _buildLogList(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList(ThemeData theme) {
    if (_tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt_outlined, size: 60, color: Colors.white54),
            const SizedBox(height: 15),
            Text('No tasks created yet.', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.add, size: 18),
              label: Text('Add Task'),
              onPressed: _addTask,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: _tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = _tasks[index];
        final currentDuration = _getCurrentlyTrackedDuration(task);
        final displayDuration = task.totalDuration + currentDuration;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Icon(
            task.isTracking
                ? Icons.pause_circle_filled
                : Icons.play_circle_outline,
            color: task.isTracking ? Colors.redAccent : theme.primaryColor,
            size: 36,
          ),
          title: Text(
            task.name,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Total: ${_formatDuration(displayDuration)}',
            style: TextStyle(
              color: task.isTracking ? theme.primaryColor : Colors.white70,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.redAccent.withOpacity(0.7),
            ),
            tooltip: 'Delete Task',
            onPressed: () => _deleteTask(task),
          ),
          onTap: () {
            if (task.isTracking) {
              _stopTracking(task);
            } else {
              _startTracking(task);
            }
          },
        );
      },
    );
  }

  Widget _buildLogList(ThemeData theme) {
    if (_timeEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 60, color: Colors.white54),
            const SizedBox(height: 15),
            Text(
              'No time entries recorded yet.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    // Sort entries by end time, newest first
    final sortedEntries = List<TimeEntry>.from(_timeEntries)
      ..sort((a, b) => b.endTime.compareTo(a.endTime));

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedEntries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        // Find the task name (handle if task was deleted)
        final taskName =
            _tasks
                .firstWhere(
                  (t) => t.id == entry.taskId,
                  orElse: () => Task(id: '', name: 'Deleted Task'),
                )
                .name;
        final startTimeStr = DateFormat('MMM d, HH:mm').format(entry.startTime);
        final endTimeStr = DateFormat('HH:mm').format(entry.endTime);
        final durationStr = _formatDuration(entry.duration);

        return ListTile(
          leading: Icon(Icons.timer_outlined, color: Colors.grey),
          title: Text(
            taskName,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '$startTimeStr - $endTimeStr',
            style: TextStyle(
              color: Colors.grey,
              // fontWeight: FontWeight.w500,
              // fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          trailing: Text(
            durationStr,
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        );
      },
    );
  }
}
