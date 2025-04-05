import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Note: This is very similar to the Timer screen but simplified.
// It focuses on counting down from a single input value (seconds).

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  Timer? _timer;
  Duration _totalDuration = const Duration(seconds: 60); // Default 60 seconds
  Duration _remainingDuration = const Duration(seconds: 60);
  bool _isRunning = false;
  bool _isPaused = false;

  final TextEditingController _secondsController = TextEditingController(
    text: '60',
  );

  void _updateTotalDuration() {
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    setState(() {
      _totalDuration = Duration(seconds: seconds);
      if (!_isRunning) {
        // Only reset remaining if not running
        _remainingDuration = _totalDuration;
      }
    });
  }

  void _startCountdown() {
    if (_remainingDuration.inSeconds <= 0) return;

    setState(() {
      _isRunning = true;
      _isPaused = false;
      if (_remainingDuration == Duration.zero ||
          _remainingDuration == _totalDuration) {
        _remainingDuration = _totalDuration;
      }
    });

    _timer?.cancel();
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
          _remainingDuration = _totalDuration; // Reset
        });
        _showCountdownFinishedDialog();
      }
    });
  }

  void _pauseCountdown() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
        _isPaused = true;
      });
    }
  }

  void _resetCountdown() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _updateTotalDuration(); // Recalculate total based on input
      _remainingDuration = _totalDuration; // Reset remaining
    });
  }

  void _showCountdownFinishedDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.cardTheme.color,
          title: Text(
            'Countdown Finished',
            style: TextStyle(color: theme.primaryColor),
          ),
          content: Text(
            'The countdown has ended.',
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
    // Only show hours if necessary
    if (duration.inHours > 0) {
      String twoDigitHours = twoDigits(duration.inHours);
      return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  @override
  void initState() {
    super.initState();
    _secondsController.addListener(_updateTotalDuration);
    _updateTotalDuration(); // Initial calculation
  }

  @override
  void dispose() {
    _timer?.cancel();
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
        title: const Text('Countdown'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Input Field (only visible when not running/paused)
              if (!_isRunning && !_isPaused)
                SizedBox(
                  width: 150, // Wider for potentially larger numbers
                  child: TextField(
                    controller: _secondsController,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Seconds',
                      labelStyle: TextStyle(
                        color: theme.primaryColor.withOpacity(0.7),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: theme.primaryColor.withOpacity(0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: theme.primaryColor.withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: theme.primaryColor,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                    ),
                    onChanged: (_) => _updateTotalDuration(),
                  ),
                ),
              const SizedBox(height: 30),

              // Time Display / Progress
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
                              ? 1.0
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
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: theme.primaryColor,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // Control Buttons (same logic as Timer)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (showReset)
                    _buildControlButton(
                      context,
                      icon: Icons.refresh,
                      label: 'Reset',
                      onPressed: _resetCountdown,
                      color: Colors.orangeAccent,
                    )
                  else
                    const SizedBox(width: 80),

                  if (showPause)
                    _buildControlButton(
                      context,
                      icon: Icons.pause,
                      label: 'Pause',
                      onPressed: _pauseCountdown,
                      color: Colors.redAccent,
                      isLarge: true,
                    )
                  else
                    _buildControlButton(
                      context,
                      icon: Icons.play_arrow,
                      label: _isPaused ? 'Resume' : 'Start',
                      onPressed: canStart || _isPaused ? _startCountdown : null,
                      color: theme.primaryColor,
                      isLarge: true,
                      isDisabled: !(canStart || _isPaused),
                    ),

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
