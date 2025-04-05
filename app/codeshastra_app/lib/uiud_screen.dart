import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class UuidGeneratorScreen extends StatefulWidget {
  const UuidGeneratorScreen({super.key});

  @override
  State<UuidGeneratorScreen> createState() => _UuidGeneratorScreenState();
}

class _UuidGeneratorScreenState extends State<UuidGeneratorScreen> {
  String _uuid = '';
  final Uuid _uuidGen = const Uuid();

  void _generateUuid() {
    setState(() {
      _uuid = _uuidGen.v4();
    });
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
        title: const Text('UUID Generator'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Theme.of(context).primaryColorDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                ),
                onPressed: _generateUuid,
                child: Text(
                  "Generate UUID",
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SelectableText(
              _uuid,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
