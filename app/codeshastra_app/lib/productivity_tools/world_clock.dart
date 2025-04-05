import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
// For date formatting

class WorldClockScreen extends StatefulWidget {
  const WorldClockScreen({super.key});

  @override
  State<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends State<WorldClockScreen> {
  List<String> _selectedTimezones = [
    'America/New_York',
    'Europe/London',
    'Asia/Tokyo',
    'Australia/Sydney',
  ]; // Default timezones
  Timer? _timer;
  Map<String, tz.TZDateTime> _currentTimes = {};

  // Get all available timezone locations
  final List<String> _allTimezones =
      tz.timeZoneDatabase.locations.keys.toList()..sort();

  @override
  void initState() {
    super.initState();
    _updateTimes(); // Initial update
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimes();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTimes() {
    if (!mounted) return; // Avoid calling setState if the widget is disposed
    final now = tz.TZDateTime.now(tz.local);
    final Map<String, tz.TZDateTime> updatedTimes = {};
    for (String tzName in _selectedTimezones) {
      try {
        final location = tz.getLocation(tzName);
        updatedTimes[tzName] = tz.TZDateTime.from(now, location);
      } catch (e) {
        // Handle cases where a timezone might be invalid (shouldn't happen with db keys)
        print("Error loading timezone $tzName: $e");
        // Optionally remove the invalid timezone here
      }
    }
    setState(() {
      _currentTimes = updatedTimes;
    });
  }

  void _addTimezone() async {
    final String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Timezone'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _allTimezones.length,
              itemBuilder: (context, index) {
                final tzName = _allTimezones[index];
                // Filter out already selected timezones
                if (_selectedTimezones.contains(tzName)) {
                  return Container(); // Don't show already selected ones
                }
                return ListTile(
                  title: Text(
                    tzName.replaceAll('_', ' '),
                  ), // Make it more readable
                  onTap: () {
                    Navigator.of(context).pop(tzName);
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    if (selected != null && !_selectedTimezones.contains(selected)) {
      setState(() {
        _selectedTimezones.add(selected);
        _selectedTimezones.sort(); // Keep the list sorted
      });
      _updateTimes(); // Update immediately after adding
    }
  }

  void _removeTimezone(String tzName) {
    setState(() {
      _selectedTimezones.remove(tzName);
    });
    _updateTimes(); // Update times after removal
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          'World Clock',
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 24),
        ),
        backgroundColor: theme.primaryColorDark,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: Theme.of(context).primaryColor,
            ),
            tooltip: 'Add Timezone',
            onPressed: _addTimezone,
          ),
        ],
      ),
      body:
          _selectedTimezones.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hourglass_empty,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'No timezones added yet.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add, size: 18),
                      label: Text('Add Timezone'),
                      onPressed: _addTimezone,
                    ),
                  ],
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: _selectedTimezones.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final tzName = _selectedTimezones[index];
                  final currentTime = _currentTimes[tzName];
                  final locationName = tzName
                      .split('/')
                      .last
                      .replaceAll('_', ' ');
                  final regionName = tzName
                      .split('/')
                      .first
                      .replaceAll('_', ' ');

                  if (currentTime == null) {
                    // Show loading or error state for this specific timezone
                    return ListTile(
                      title: Text(locationName),
                      subtitle: Text(regionName),
                      trailing: const CircularProgressIndicator(strokeWidth: 2),
                    );
                  }

                  final timeString = DateFormat('HH:mm:ss').format(currentTime);
                  final dateString = DateFormat(
                    'EEE, MMM d',
                  ).format(currentTime);
                  final offset = currentTime.timeZoneOffset;
                  final offsetHours = offset.inHours;
                  final offsetMinutes = offset.inMinutes.remainder(60).abs();
                  final offsetString =
                      'UTC${offsetHours >= 0 ? '+' : ''}$offsetHours${offsetMinutes == 0 ? '' : ':${offsetMinutes.toString().padLeft(2, '0')}'}';

                  return ListTile(
                    leading: Icon(
                      Icons.watch_later_outlined,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(
                      locationName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      '$regionName\n$dateString ($offsetString)',
                      style: TextStyle(color: Colors.grey),
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeString,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: theme.primaryColor,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent.withOpacity(0.7),
                          ),
                          tooltip: 'Remove Timezone',
                          onPressed: () => _removeTimezone(tzName),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
