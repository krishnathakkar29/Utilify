import 'dart:async';
import 'package:flutter/material.dart';

class IdleTimeScreen extends StatefulWidget {
  const IdleTimeScreen({super.key});

  @override
  State<IdleTimeScreen> createState() => _IdleTimeScreenState();
}

class _IdleTimeScreenState extends State<IdleTimeScreen> {
  Timer? _idleTimer;
  final Duration _idleTimeout = const Duration(
    seconds: 15,
  ); // Set idle duration
  bool _isIdle = false;

  @override
  void initState() {
    super.initState();
    _resetIdleTimer();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    super.dispose();
  }

  void _resetIdleTimer() {
    if (!mounted) return;
    setState(() {
      _isIdle = false; // Mark as active when resetting
    });
    _idleTimer?.cancel();
    _idleTimer = Timer(_idleTimeout, _handleIdle);
    print("Idle timer reset"); // For debugging
  }

  void _handleIdle() {
    if (!mounted) return;
    setState(() {
      _isIdle = true;
    });
    print("User is idle!"); // For debugging
    _showIdleDialog();
  }

  void _showIdleDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false, // User must interact with the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you still there?'),
          content: const Text(
            'It looks like you\'ve been inactive for a while. Take a break or log your task?',
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'I\'m Back!',
                style: TextStyle(color: theme.primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _resetIdleTimer(); // Reset timer on interaction
              },
            ),
            TextButton(
              child: Text(
                'Take Break',
                style: TextStyle(color: Colors.orangeAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Optional: Navigate to break timer or just reset
                _resetIdleTimer();
              },
            ),
          ],
        );
      },
    );
  }

  // This function simulates user interaction within this screen
  void _simulateInteraction() {
    print("User interaction detected!"); // For debugging
    _resetIdleTimer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Wrap the main content with GestureDetector to detect taps anywhere on the screen
    return GestureDetector(
      onTap: _simulateInteraction, // Reset timer on any tap
      onPanDown: (_) => _simulateInteraction(), // Reset on drag start
      // Add other detectors (onScaleStart, etc.) if needed
      behavior:
          HitTestBehavior
              .opaque, // Ensure GestureDetector captures taps on empty space
      child: Scaffold(
        backgroundColor:
            _isIdle
                ? Colors.orange[900]?.withOpacity(0.5)
                : theme.primaryColorDark, // Visual feedback for idle
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
          title: const Text('Idle Time Detector'),
          backgroundColor: theme.appBarTheme.backgroundColor,
          foregroundColor: theme.appBarTheme.foregroundColor,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isIdle
                      ? Icons.pause_circle_filled_outlined
                      : Icons.run_circle_outlined,
                  size: 80,
                  color: _isIdle ? Colors.orangeAccent : theme.primaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  _isIdle ? 'Status: Idle' : 'Status: Active',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: _isIdle ? Colors.orangeAccent : theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'This screen simulates idle detection.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Tap anywhere to reset the ${_idleTimeout.inSeconds}-second timer.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _simulateInteraction, // Button also resets timer
                  child: const Text('Simulate Activity'),
                ),
                const SizedBox(height: 20),
                Text(
                  '(Note: Real system-wide idle detection is limited in mobile apps)',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
