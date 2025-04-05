import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for input formatters

enum ConversionCategory { length, weight, temperature }

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  ConversionCategory _selectedCategory = ConversionCategory.length;
  String? _fromUnit;
  String? _toUnit;
  final TextEditingController _inputController = TextEditingController();
  String _result = '';

  // Define units for each category
  final Map<ConversionCategory, List<String>> _units = {
    ConversionCategory.length: ['Meters', 'Kilometers', 'Feet', 'Miles'],
    ConversionCategory.weight: ['Kilograms', 'Grams', 'Pounds', 'Ounces'],
    ConversionCategory.temperature: ['Celsius', 'Fahrenheit', 'Kelvin'],
  };

  // Conversion logic (simplified)
  double _convert(
    double value,
    String from,
    String to,
    ConversionCategory category,
  ) {
    if (from == to) return value;

    // Normalize to a base unit first, then convert to target
    double baseValue;

    // --- Length ---
    if (category == ConversionCategory.length) {
      // To Meters
      switch (from) {
        case 'Kilometers':
          baseValue = value * 1000;
          break;
        case 'Feet':
          baseValue = value * 0.3048;
          break;
        case 'Miles':
          baseValue = value * 1609.34;
          break;
        case 'Meters':
        default:
          baseValue = value;
          break;
      }
      // From Meters
      switch (to) {
        case 'Kilometers':
          return baseValue / 1000;
        case 'Feet':
          return baseValue / 0.3048;
        case 'Miles':
          return baseValue / 1609.34;
        case 'Meters':
        default:
          return baseValue;
      }
    }
    // --- Weight ---
    else if (category == ConversionCategory.weight) {
      // To Kilograms
      switch (from) {
        case 'Grams':
          baseValue = value / 1000;
          break;
        case 'Pounds':
          baseValue = value * 0.453592;
          break;
        case 'Ounces':
          baseValue = value * 0.0283495;
          break;
        case 'Kilograms':
        default:
          baseValue = value;
          break;
      }
      // From Kilograms
      switch (to) {
        case 'Grams':
          return baseValue * 1000;
        case 'Pounds':
          return baseValue / 0.453592;
        case 'Ounces':
          return baseValue / 0.0283495;
        case 'Kilograms':
        default:
          return baseValue;
      }
    }
    // --- Temperature ---
    else if (category == ConversionCategory.temperature) {
      // To Celsius
      switch (from) {
        case 'Fahrenheit':
          baseValue = (value - 32) * 5 / 9;
          break;
        case 'Kelvin':
          baseValue = value - 273.15;
          break;
        case 'Celsius':
        default:
          baseValue = value;
          break;
      }
      // From Celsius
      switch (to) {
        case 'Fahrenheit':
          return (baseValue * 9 / 5) + 32;
        case 'Kelvin':
          return baseValue + 273.15;
        case 'Celsius':
        default:
          return baseValue;
      }
    }
    return 0.0; // Should not happen
  }

  void _performConversion() {
    final double? inputValue = double.tryParse(_inputController.text);
    if (inputValue != null && _fromUnit != null && _toUnit != null) {
      final double convertedValue = _convert(
        inputValue,
        _fromUnit!,
        _toUnit!,
        _selectedCategory,
      );
      setState(() {
        _result = '${convertedValue.toStringAsFixed(2)} $_toUnit';
      });
    } else {
      setState(() {
        _result = '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Set initial units for the default category
    _setInitialUnits(_selectedCategory);
    _inputController.addListener(_performConversion);
  }

  @override
  void dispose() {
    _inputController.removeListener(_performConversion);
    _inputController.dispose();
    super.dispose();
  }

  void _setInitialUnits(ConversionCategory category) {
    final categoryUnits = _units[category]!;
    setState(() {
      _fromUnit = categoryUnits.isNotEmpty ? categoryUnits[0] : null;
      _toUnit =
          categoryUnits.length > 1
              ? categoryUnits[1]
              : (categoryUnits.isNotEmpty ? categoryUnits[0] : null);
      _inputController.clear(); // Clear input when category changes
      _result = ''; // Clear result
    });
    _performConversion(); // Recalculate if there's initial input (though cleared)
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUnits = _units[_selectedCategory]!;

    return Scaffold(
      // backgroundColor: theme.primaryColorDark,
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
          'Unit Convertions',
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 24),
        ),
        // foregroundColor: theme.appBarTheme.foregroundColor,
        backgroundColor: theme.primaryColorDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Selection
            _buildDropdown<ConversionCategory>(
              label: 'Category',
              // labelStyle: TextStyle(
              //   color: Colors.white,
              // ),
              // backgroundColor: theme.primaryColorDark,
              value: _selectedCategory,
              items: ConversionCategory.values,
              onChanged: (ConversionCategory? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                    _setInitialUnits(
                      newValue,
                    ); // Reset units for the new category
                  });
                }
              },
              itemLabelBuilder:
                  (category) =>
                      category.name[0].toUpperCase() +
                      category.name.substring(1), // Capitalize enum name
            ),
            const SizedBox(height: 20),

            // Input Value
            TextField(
              controller: _inputController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d+\.?\d*'),
                ), // Allow numbers and one decimal point
              ],
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.primaryColor, width: 2.0),
                ),
                labelText: 'Enter Value',
                prefixIcon: Icon(
                  Icons.numbers,
                  color: theme.primaryColor.withOpacity(0.7),
                ),
              ),
              style: TextStyle(color: Colors.white, fontSize: 18),
              onChanged: (_) => _performConversion(),
            ),
            const SizedBox(height: 20),

            // Unit Selection Row
            Row(
              children: [
                Expanded(
                  child: _buildDropdown<String>(
                    label: 'From',
                    value: _fromUnit,
                    items: currentUnits,
                    onChanged: (String? newValue) {
                      setState(() {
                        _fromUnit = newValue;
                      });
                      _performConversion();
                    },
                    itemLabelBuilder: (unit) => unit,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(
                    Icons.swap_horiz,
                    color: theme.primaryColor,
                    size: 30,
                  ),
                ),
                Expanded(
                  child: _buildDropdown<String>(
                    label: 'To',
                    value: _toUnit,
                    items: currentUnits,
                    onChanged: (String? newValue) {
                      setState(() {
                        _toUnit = newValue;
                      });
                      _performConversion();
                    },
                    itemLabelBuilder: (unit) => unit,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Result Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Result:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _result.isEmpty ? '-' : _result,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: 28,
                      color: theme.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build styled Dropdowns consistently
  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemLabelBuilder,
    // required Color backgroundColor, // Function to get display label
  }) {
    final theme = Theme.of(context);
    // Ensure the value exists in the items list, otherwise DropdownButtonFormField might error
    final T? validValue = items.contains(value) ? value : null;

    return DropdownButtonFormField<T>(
      value: validValue,
      items:
          items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabelBuilder(item),
                style: TextStyle(color: Colors.white),
              ), // Item text color
            );
          }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelStyle: TextStyle(color: Colors.white),
        labelText: label,
        // Use theme's input decoration for consistency
      ),
      dropdownColor:
          theme.primaryColorDark, // Background color of the dropdown menu
      iconEnabledColor: theme.primaryColor, // Dropdown arrow color
      style: TextStyle(
        color: Colors.white,
      ), // Selected item text color in the button
    );
  }
}
