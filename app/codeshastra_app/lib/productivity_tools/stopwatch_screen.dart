import 'dart:async';
import 'package:flutter/material.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _elapsedTime = '00:00:00.000';

  void _startStopwatch() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        if (!_stopwatch.isRunning) {
          timer.cancel(); // Stop timer if stopwatch was stopped externally
        } else {
          setState(() {
            _elapsedTime = _formatTime(_stopwatch.elapsedMilliseconds);
          });
        }
      });
    }
  }

  void _stopStopwatch() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
      // Update state one last time to ensure final time is displayed
      setState(() {
        _elapsedTime = _formatTime(_stopwatch.elapsedMilliseconds);
      });
    }
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    _stopwatch.stop(); // Ensure it's stopped
    _timer?.cancel();
    setState(() {
      _elapsedTime = '00:00:00.000';
    });
  }

  String _formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate() % 100;
    int seconds = (milliseconds / 1000).truncate() % 60;
    int minutes = (milliseconds / (1000 * 60)).truncate() % 60;
    int hours = (milliseconds / (1000 * 60 * 60)).truncate();

    String hoursStr = hours.toString().padLeft(2, '0');
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    String hundredsStr = hundreds.toString().padLeft(
      2,
      '0',
    ); // Changed to 2 digits for hundreds

    return '$hoursStr:$minutesStr:$secondsStr.$hundredsStr';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isRunning = _stopwatch.isRunning;

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
          'Stopwatch',
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 24),
        ),
        backgroundColor: theme.primaryColorDark,
        // foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Time Display
              Text(
                _elapsedTime,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight:
                      FontWeight
                          .w300, // Lighter font weight for futuristic feel
                  color: theme.primaryColor,
                  fontFeatures: const [
                    FontFeature.tabularFigures(),
                  ], // Monospaced digits
                ),
              ),
              const SizedBox(height: 60),

              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reset Button (only visible when not running and time > 0)
                  if (!isRunning && _stopwatch.elapsedMilliseconds > 0)
                    _buildControlButton(
                      context,
                      icon: Icons.refresh,
                      label: 'Reset',
                      onPressed: _resetStopwatch,
                      color: Colors.orangeAccent,
                    )
                  else // Placeholder to keep spacing consistent
                    SizedBox(width: 80), // Adjust width as needed
                  // Start/Stop Button
                  _buildControlButton(
                    context,
                    icon: isRunning ? Icons.pause : Icons.play_arrow,
                    label: isRunning ? 'Stop' : 'Start',
                    onPressed: isRunning ? _stopStopwatch : _startStopwatch,
                    color: isRunning ? Colors.redAccent : theme.primaryColor,
                    isLarge: true,
                  ),

                  // Placeholder for spacing symmetry
                  SizedBox(width: 80), // Adjust width as needed
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
    required VoidCallback onPressed,
    required Color color,
    bool isLarge = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: theme.primaryColorDark,
            shape: const CircleBorder(),
            padding: EdgeInsets.all(isLarge ? 24 : 16),
            elevation: 5,
          ),
          child: Icon(icon, size: isLarge ? 36 : 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: color.withOpacity(0.8))),
      ],
    );
  }
}
