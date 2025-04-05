import 'dart:math';
import 'package:flutter/material.dart';

class RandomNumberScreen extends StatefulWidget {
  const RandomNumberScreen({super.key});

  @override
  State<RandomNumberScreen> createState() => _RandomNumberScreenState();
}

class _RandomNumberScreenState extends State<RandomNumberScreen> {
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();
  String _result = '';
  bool _isFloat = false;

  void _generateRandom() {
    final min = double.tryParse(_minController.text);
    final max = double.tryParse(_maxController.text);

    if (min == null || max == null || min >= max) {
      setState(() {
        _result = 'Enter valid range';
      });
      return;
    }

    final random = Random();
    final value =
        _isFloat
            ? min + random.nextDouble() * (max - min)
            : min.toInt() + random.nextInt(max.toInt() - min.toInt() + 1);

    setState(() {
      _result = _isFloat ? value.toStringAsFixed(4) : value.toString();
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
        title: const Text('Random Number Generator'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _minController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Minimum',
                hintText: 'Enter minimum value',
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                hintStyle: TextStyle(color: Theme.of(context).primaryColor),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
              cursorColor: Theme.of(context).primaryColor,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),

            const SizedBox(height: 10),
            TextField(
              controller: _maxController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Maximum',
                hintText: 'Enter maximum value',
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                hintStyle: TextStyle(color: Theme.of(context).primaryColor),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
              cursorColor: Theme.of(context).primaryColor,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),

            // TextField(
            //   controller: _maxController,
            //   keyboardType: TextInputType.number,
            //   decoration: const InputDecoration(
            //     labelText: 'Maximum',
            //     hintText: 'Enter maximum value',
            //   ),
            // ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: _isFloat,
                  onChanged: (val) {
                    setState(() => _isFloat = val ?? false);
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),

                const Text(
                  "Generate Float",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
              ),
              onPressed: _generateRandom,
              child: Text(
                "Generate",
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _result,
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
