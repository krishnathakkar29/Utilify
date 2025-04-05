import 'dart:async';
import 'package:flutter/material.dart';

enum PomodoroState { work, shortBreak, longBreak, idle }

class PomodoroTimerScreen extends StatefulWidget {
  const PomodoroTimerScreen({super.key});

  @override
  State<PomodoroTimerScreen> createState() => _PomodoroTimerScreenState();
}

class _PomodoroTimerScreenState extends State<PomodoroTimerScreen> {
  // --- Configuration ---
  Duration _workDuration = const Duration(minutes: 25);
  Duration _shortBreakDuration = const Duration(minutes: 5);
  Duration _longBreakDuration = const Duration(minutes: 15);
  int _cyclesBeforeLongBreak = 4;

  // --- State ---
  Timer? _timer;
  PomodoroState _currentState = PomodoroState.idle;
  Duration _remainingTime = Duration.zero;
  int _completedCycles = 0;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _resetTimer(); // Initialize with work duration
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration _getDurationForState(PomodoroState state) {
    switch (state) {
      case PomodoroState.work:
        return _workDuration;
      case PomodoroState.shortBreak:
        return _shortBreakDuration;
      case PomodoroState.longBreak:
        return _longBreakDuration;
      case PomodoroState.idle:
      default:
        return _workDuration; // Default to work duration when idle
    }
  }

  void _startTimer() {
    if (_isRunning || _remainingTime.inSeconds <= 0) return;

    // If starting from idle, set to work state
    if (_currentState == PomodoroState.idle) {
      _currentState = PomodoroState.work;
      _remainingTime = _getDurationForState(_currentState);
    }

    setState(() {
      _isRunning = true;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime -= const Duration(seconds: 1);
        });
      } else {
        _timer?.cancel();
        _moveToNextState();
      }
    });
  }

  void _pauseTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _currentState =
          PomodoroState.idle; // Or PomodoroState.work if you want it ready
      _completedCycles = 0;
      _remainingTime = _getDurationForState(
        PomodoroState.work,
      ); // Reset to work duration
    });
  }

  void _moveToNextState() {
    PomodoroState nextState;
    bool incrementCycle = false;

    switch (_currentState) {
      case PomodoroState.work:
        incrementCycle = true;
        if ((_completedCycles + 1) % _cyclesBeforeLongBreak == 0) {
          nextState = PomodoroState.longBreak;
        } else {
          nextState = PomodoroState.shortBreak;
        }
        break;
      case PomodoroState.shortBreak:
      case PomodoroState.longBreak:
        nextState = PomodoroState.work;
        break;
      case PomodoroState
          .idle: // Should not happen from timer end, but handle defensively
        nextState = PomodoroState.work;
        break;
    }

    setState(() {
      _isRunning = false; // Stop timer implicitly when moving state
      _currentState = nextState;
      _remainingTime = _getDurationForState(nextState);
      if (incrementCycle) {
        _completedCycles++;
      }
    });

    // Optionally auto-start the next timer or show a notification
    _showStateChangeDialog(nextState);
  }

  void _skipState() {
    _timer?.cancel();
    _moveToNextState(); // Move to the next state immediately
  }

  void _showStateChangeDialog(PomodoroState nextState) {
    final theme = Theme.of(context);
    String title;
    String content;
    switch (nextState) {
      case PomodoroState.work:
        title = 'Break Over!';
        content = 'Time to get back to work.';
        break;
      case PomodoroState.shortBreak:
        title = 'Work Session Complete!';
        content = 'Take a short break.';
        break;
      case PomodoroState.longBreak:
        title = 'Work Session Complete!';
        content = 'Time for a longer break.';
        break;
      case PomodoroState.idle:
        return; // Don't show dialog for idle
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: theme.primaryColorDark),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Optionally auto-start timer here: _startTimer();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  String _getStateText(PomodoroState state) {
    switch (state) {
      case PomodoroState.work:
        return 'Work';
      case PomodoroState.shortBreak:
        return 'Short Break';
      case PomodoroState.longBreak:
        return 'Long Break';
      case PomodoroState.idle:
        return 'Ready';
    }
  }

  IconData _getStateIcon(PomodoroState state) {
    switch (state) {
      case PomodoroState.work:
        return Icons.work_outline;
      case PomodoroState.shortBreak:
        return Icons.free_breakfast_outlined;
      case PomodoroState.longBreak:
        return Icons.self_improvement_outlined;
      case PomodoroState.idle:
        return Icons.play_circle_outline;
    }
  }

  Color _getStateColor(PomodoroState state, ThemeData theme) {
    switch (state) {
      case PomodoroState.work:
        return theme.primaryColor;
      case PomodoroState.shortBreak:
        return Colors.greenAccent[400]!;
      case PomodoroState.longBreak:
        return Colors.lightBlueAccent[400]!;
      case PomodoroState.idle:
        return Colors.grey[600]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stateColor = _getStateColor(_currentState, theme);
    final totalDuration = _getDurationForState(
      _currentState == PomodoroState.idle ? PomodoroState.work : _currentState,
    );

    return Scaffold(
      backgroundColor: theme.primaryColorDark,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
        ),
        centerTitle: true,
        title: Text(
          'Pomodoro Timer',
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 24),
        ),
        backgroundColor: theme.primaryColorDark,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // State Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getStateIcon(_currentState),
                    color: stateColor,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _getStateText(_currentState),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: stateColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                'Cycle: $_completedCycles',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 30),

              // Timer Display / Progress
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: CircularProgressIndicator(
                      value:
                          (totalDuration.inSeconds == 0 ||
                                  _remainingTime.inSeconds < 0)
                              ? 1.0
                              : _remainingTime.inSeconds /
                                  totalDuration.inSeconds,
                      strokeWidth: 12,
                      backgroundColor: stateColor.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(stateColor),
                    ),
                  ),
                  Text(
                    _formatDuration(_remainingTime),
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w300,
                      color: stateColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reset Button
                  _buildControlButton(
                    context,
                    icon: Icons.refresh,
                    label: 'Reset',
                    onPressed: _resetTimer,
                    color: Colors.orangeAccent,
                  ),

                  // Start/Pause Button
                  _buildControlButton(
                    context,
                    icon: _isRunning ? Icons.pause : Icons.play_arrow,
                    label: _isRunning ? 'Pause' : 'Start',
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    color: _isRunning ? Colors.redAccent : theme.primaryColor,
                    isLarge: true,
                  ),

                  // Skip Button (only show if running or paused in a state)
                  if (_currentState != PomodoroState.idle)
                    _buildControlButton(
                      context,
                      icon: Icons.skip_next,
                      label: 'Skip',
                      onPressed: _skipState,
                      color: Colors.blueAccent,
                    )
                  else // Placeholder
                    const SizedBox(width: 80),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    bool isLarge = false,
    bool isDisabled = false,
  }) {
    final theme = Theme.of(context);
    final effectiveColor = isDisabled ? Colors.grey[600] : color;
    final effectiveForegroundColor =
        isDisabled ? Colors.grey[800] : theme.primaryColorDark;

    return Column(
      children: [
        ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: effectiveColor,
            foregroundColor: effectiveForegroundColor,
            shape: const CircleBorder(),
            padding: EdgeInsets.all(isLarge ? 24 : 16),
            elevation: isDisabled ? 0 : 5,
          ),
          child: Icon(icon, size: isLarge ? 36 : 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: effectiveColor?.withOpacity(isDisabled ? 0.5 : 0.8),
          ),
        ),
      ],
    );
  }
}
