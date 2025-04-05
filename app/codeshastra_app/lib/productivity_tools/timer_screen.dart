import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  Duration _totalDuration = Duration.zero;
  Duration _remainingDuration = Duration.zero;
  bool _isRunning = false;
  bool _isPaused = false;

  final TextEditingController _hoursController = TextEditingController(
    text: '0',
  );
  final TextEditingController _minutesController = TextEditingController(
    text: '5',
  );
  final TextEditingController _secondsController = TextEditingController(
    text: '0',
  );

  void _updateTotalDuration() {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    setState(() {
      _totalDuration = Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
      );
      if (!_isRunning) {
        // Only reset remaining if not running
        _remainingDuration = _totalDuration;
      }
    });
  }

  void _startTimer() {
    if (_remainingDuration.inSeconds <= 0)
      return; // Don't start if duration is zero

    setState(() {
      _isRunning = true;
      _isPaused = false;
      // If resuming, use remaining duration. If starting fresh, use total.
      if (_remainingDuration == Duration.zero ||
          _remainingDuration == _totalDuration) {
        _remainingDuration = _totalDuration;
      }
    });

    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingDuration.inSeconds > 0) {
        setState(() {
          _remainingDuration -= const Duration(seconds: 1);
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
          _isPaused = false;
          _remainingDuration = _totalDuration; // Reset for next run
        });
        // Optional: Add a notification/sound here
        _showTimerFinishedDialog();
      }
    });
  }

  void _pauseTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
        _isPaused = true;
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _updateTotalDuration(); // Recalculate total based on input fields
      _remainingDuration =
          _totalDuration; // Reset remaining to the current total
    });
  }

  void _showTimerFinishedDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.cardTheme.color,
          title: Text(
            'Timer Finished',
            style: TextStyle(color: theme.primaryColor),
          ),
          content: Text(
            'The timer has completed.',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: theme.primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
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
    String twoDigitHours = twoDigits(duration.inHours);
    return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void initState() {
    super.initState();
    _hoursController.addListener(_updateTotalDuration);
    _minutesController.addListener(_updateTotalDuration);
    _secondsController.addListener(_updateTotalDuration);
    _updateTotalDuration(); // Initial calculation
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool canStart = _totalDuration.inSeconds > 0 && !_isRunning;
    bool showPause = _isRunning;
    bool showResume = _isPaused;
    bool showReset =
        _isRunning || _isPaused || _remainingDuration != _totalDuration;

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
          'Timer',
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 24),
        ),
        backgroundColor: theme.primaryColorDark,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          // Added for smaller screens
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Time Input Fields (only visible when timer is not running or paused)
              if (!_isRunning && !_isPaused)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimeInput(_hoursController, 'HH'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        ':',
                        style: TextStyle(
                          fontSize: 32,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    _buildTimeInput(_minutesController, 'MM'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        ':',
                        style: TextStyle(
                          fontSize: 32,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    _buildTimeInput(_secondsController, 'SS'),
                  ],
                ),
              const SizedBox(height: 30),

              // Time Display or Progress Indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value:
                          (_totalDuration.inSeconds == 0 ||
                                  _remainingDuration.inSeconds < 0)
                              ? 1.0 // Full circle if total is 0 or somehow negative remaining
                              : _remainingDuration.inSeconds /
                                  _totalDuration.inSeconds,
                      strokeWidth: 10,
                      backgroundColor: theme.primaryColor.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.primaryColor,
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(_remainingDuration),
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w300,
                      color: theme.primaryColor,
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
                  if (showReset)
                    _buildControlButton(
                      context,
                      icon: Icons.refresh,
                      label: 'Reset',
                      onPressed: _resetTimer,
                      color: Colors.orangeAccent,
                    )
                  else // Placeholder for spacing
                    const SizedBox(width: 80),

                  if (showPause) // Show Pause button
                    _buildControlButton(
                      context,
                      icon: Icons.pause,
                      label: 'Pause',
                      onPressed: _pauseTimer,
                      color: Colors.redAccent,
                      isLarge: true,
                    )
                  else // Show Start/Resume button
                    _buildControlButton(
                      context,
                      icon: Icons.play_arrow,
                      label: _isPaused ? 'Resume' : 'Start',
                      onPressed:
                          canStart || _isPaused
                              ? _startTimer
                              : null, // Disable if duration is 0 or already running
                      color: theme.primaryColor,
                      isLarge: true,
                      isDisabled: !(canStart || _isPaused),
                    ),

                  // Placeholder for spacing symmetry
                  const SizedBox(width: 80),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInput(TextEditingController controller, String hint) {
    return SizedBox(
      width: 65,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 32,
          color: Colors.white,
          fontWeight: FontWeight.w300,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white38, fontSize: 28),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (_) => _updateTotalDuration(),
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed, // Make nullable for disabled state
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
