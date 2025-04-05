import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCountry = 'United States of America';
  String _toCountry = 'India';
  String _result = '';
  bool _isLoading = false;
  String? _error;

  final List<String> _countries = [
    'Afganistan',
    'Albania',
    'Alergia',
    'American Samoa',
    'Andorra',
    'Angola',
    'Anguilla',
    'Antigua and Barbuda',
    'Argentina',
    'Armenia',
    'Aruba',
    'Australia',
    'Austria',
    'Azerbaijan',
    'Bahamas',
    'Bahrain',
    'Bangladesh',
    'Barbados',
    'Belarus',
    'Belgium',
    'Belize',
    'Benin',
    'Bermuda',
    'Bhutan',
    'Bolivia',
    'Bonaire',
    'Boznia and herzegovina',
    'Botswana',
    'Bouvet',
    'Brazil',
    'British Indian Ocean Terriotory',
    'Brunei Daraussalam',
    'Bulgaria',
    'Burkina',
    'Burundi',
    'Cape Verde',
    'Cambodia',
    'Cameroon',
    'Canada',
    'Cayman Islands',
    'Central African Repulic',
    'Chad',
    'Chile',
    'China',
    'Christmas Island',
    'Cocos Islands',
    'Colombia',
    'Comoros',
    'The Democratic Repulic of Congo',
    'The Cook Islands',
    'Costa Rica',
    'Croatia',
    'Cuba',
    'CuraÇao',
    'Cyprus',
    'Czech Repulic',
    'Ivory Coast',
    'Denmark',
    'Djibouti',
    'Dominica',
    'The Dominican Republic',
    'Equador',
    'Egypt',
    'El Salvador',
    'Equatorial Guniea',
    'Eritrea',
    'Estonia',
    'Ethipia',
    'The Falkland',
    'The Faroe',
    'Fiji',
    'Finland',
    'France',
    'French Guiana',
    'French Polynesia',
    'French Southern Territores',
    'Gabon',
    'Gambia',
    'Georgia',
    'Germany',
    'Ghana',
    'Gibraltar',
    'Greece',
    'Greenland',
    'Grenada',
    'Guadeloupe',
    'Guam',
    'Guatemala',
    'Guernsey',
    'Guniea',
    'Guinea-Bisaau',
    'Guyana',
    'Haiti',
    'Holy See',
    'Honduras',
    'Hong Kong',
    'Hungary',
    'Iceland',
    'India',
    'Indonesia',
    'Iran',
    'Iraq',
    'Ireland',
    'Isle of man',
    'Israel',
    'Italy',
    'Jamaica',
    'Japan',
    'Jersey',
    'Jordan',
    'Kazakstan',
    'Kenya',
    'Kiribati',
    'North Korea',
    'South Korea',
    'Kuwait',
    'Kyrgyzstan',
    'Lao',
    'Latvia',
    'Lebanon',
    'Lesotho',
    'Liberia',
    'Libya',
    'Liechensteain',
    'Lithuania',
    'Luxembourg',
    'Macao',
    'Madagascar',
    'Malawi',
    'Malaysia',
    'Maldives',
    'Mali',
    'Malta',
    'The Marshall Islands',
    'Martinque',
    'Mauritania',
    'Mauritius',
    'Mayotte',
    'Mexico',
    'Micronesia',
    'Moldova',
    'Monaco',
    'Mongolia',
    'Montenegro',
    'Montserrat',
    'Morocco',
    'Mozambique',
    'Myanmar',
    'Namibia',
    'Nauru',
    'Nepal',
    'The Netherlands',
    'New Caledonia',
    'New Zealand',
    'Nicaragua',
    'Niger',
    'Nigeria',
    'Niue',
    'Nolfolf Island',
    'Northern Mariana Islands',
    'Norway',
    'Oman',
    'Pakistan',
    'Palau',
    'Panama',
    'Papua New Guinea',
    'Paraguay',
    'Peru',
    'Philippines',
    'Pitcairn',
    'Poland',
    'Portugal',
    'Puerto Rico',
    'Qatar',
    'North Macedonia',
    'Romania',
    'Russia',
    'Rwanda',
    'Réunion',
    'Saint Barts',
    'Saint Helena',
    'Saint Kitts and Nevis',
    'Saint Lucia',
    'Saint Martin',
    'Saint Pierre and Miquelon',
    'Saint Vincent and the Grenadines',
    'Samoa',
    'San Marino',
    'Sao Tome and Principe',
    'Saudi Arabia',
    'Senegal',
    'Serbia',
    'Seychelles',
    'Sierra Leone',
    'Singapore',
    'Sint Maarten',
    'Slovakia',
    'Slovenia',
    'Solomon Islands',
    'Somalia',
    'South Africa',
    'South Sudan',
    'Spain',
    'Sri Lanka',
    'Sudan',
    'Suriname',
    'Svalbard and Jan Mayen',
    'Swaziland',
    'Sweden',
    'Switzerland',
    'Syria',
    'Taiwan',
    'Tajikistan',
    'Tanzania',
    'Thailand',
    'Timor-leste',
    'Togo',
    'Tokelau',
    'Tonga',
    'Trinidad and Tobago',
    'Tunisia',
    'Turkey',
    'Turkmenistan',
    'Turks and Caicos Islands',
    'Tuvalu',
    'Uganda',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States Minor Outlying Islands',
    'United States of America',
    'Uruguay',
    'Uzbekistan',
    'Vanuatu',
    'Venezuela',
    'Vietnam',
    'British Virgin Islands',
    'US Virgin Islands',
    'Wallis and Futuna',
    'Western Sahara',
    'Yemen',
    'Zambia',
    'Zimbabwe',
    'Åland Islands',
  ];

  final String _apiUrl =
      'https://reception-poultry-ec-booking.trycloudflare.com/convert_currency';

  Future<void> _convertCurrency() async {
    final String amountStr = _amountController.text.trim();

    if (_fromCountry.isEmpty || _toCountry.isEmpty || amountStr.isEmpty) {
      setState(() {
        _error = 'Please fill in all fields.';
        _result = '';
      });
      return;
    }

    final double? amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      setState(() {
        _error = 'Please enter a valid positive amount.';
        _result = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = '';
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'from': _fromCountry,
          'to': _toCountry,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final convertedAmount = data['converted'];
        final toCode = data['to_code'];
        setState(() {
          _result = '${convertedAmount.toStringAsFixed(2)} $toCode';
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _error =
              data['error'] ??
              'An unknown error occurred (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to connect to the server. $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _swapCountries() {
    setState(() {
      final temp = _fromCountry;
      _fromCountry = _toCountry;
      _toCountry = temp;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColorDark,
      appBar: AppBar(
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          'Currency Converter',
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        backgroundColor: theme.primaryColorDark,
        // foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          color: theme.cardColor.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Amount Input
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.money_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                // From Country Dropdown
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _fromCountry,
                  items:
                      _countries
                          .map(
                            (country) => DropdownMenuItem(
                              value: country,
                              child: Text(country),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _fromCountry = value);
                  },
                  decoration: const InputDecoration(
                    labelText: 'From Country',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                ),
                const SizedBox(height: 15),

                // Swap Icon
                Center(
                  child: IconButton(
                    onPressed: _swapCountries,
                    icon: Icon(
                      Icons.swap_vert,
                      size: 32,
                      color: theme.primaryColorDark,
                    ),
                    tooltip: 'Swap Countries',
                  ),
                ),
                const SizedBox(height: 15),

                // To Country Dropdown
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _toCountry,
                  items:
                      _countries
                          .map(
                            (country) => DropdownMenuItem(
                              value: country,
                              child: Text(country),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _toCountry = value);
                  },
                  decoration: const InputDecoration(
                    labelText: 'To Country',
                    prefixIcon: Icon(Icons.flag),
                  ),
                ),
                const SizedBox(height: 30),

                // Convert Button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _convertCurrency,
                  icon:
                      _isLoading
                          ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(
                            Icons.currency_exchange,
                            color: Colors.black,
                          ),
                  label: Text(
                    _isLoading ? 'Converting...' : 'Convert',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 30),

                // Error or Result
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.redAccent.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      'Error: $_error',
                      style: TextStyle(color: Colors.red[100], fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (_result.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Converted Amount:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _result,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontSize: 28,
                            color: theme.primaryColorDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
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

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert'; // For jsonEncode and jsonDecode

// class CurrencyConverterScreen extends StatefulWidget {
//   const CurrencyConverterScreen({super.key});

//   @override
//   State<CurrencyConverterScreen> createState() =>
//       _CurrencyConverterScreenState();
// }

// class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _fromController = TextEditingController(
//     text: 'United States',
//   ); // Default example
//   final TextEditingController _toController = TextEditingController(
//     text: 'India',
//   ); // Default example
//   String _result = '';
//   bool _isLoading = false;
//   String? _error;

//   // IMPORTANT: Replace with your actual backend API URL
//   final String _apiUrl =
//       'https://modular-sold-refused-namibia.trycloudflare.com/convert_currency';

//   Future<void> _convertCurrency() async {
//     final String fromCountry = _fromController.text.trim();
//     final String toCountry = _toController.text.trim();
//     final String amountStr = _amountController.text.trim();

//     if (fromCountry.isEmpty || toCountry.isEmpty || amountStr.isEmpty) {
//       setState(() {
//         _error = 'Please fill in all fields.';
//         _result = '';
//       });
//       return;
//     }

//     final double? amount = double.tryParse(amountStr);
//     if (amount == null || amount <= 0) {
//       setState(() {
//         _error = 'Please enter a valid positive amount.';
//         _result = '';
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _error = null;
//       _result = '';
//     });

//     try {
//       final response = await http.post(
//         Uri.parse(_apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'from': fromCountry,
//           'to': toCountry,
//           'amount': amount,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final convertedAmount = data['converted'];
//         final toCode = data['to_code'];
//         setState(() {
//           _result = '${convertedAmount.toStringAsFixed(2)} $toCode';
//         });
//       } else {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _error =
//               data['error'] ??
//               'An unknown error occurred (${response.statusCode})';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _error = 'Failed to connect to the server. $e';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _fromController.dispose();
//     _toController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.primaryColorDark,
//       appBar: AppBar(
//         title: const Text('Currency Converter'),
//         backgroundColor: theme.appBarTheme.backgroundColor,
//         foregroundColor: theme.appBarTheme.foregroundColor,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Amount Input
//             TextField(
//               controller: _amountController,
//               keyboardType: const TextInputType.numberWithOptions(
//                 decimal: true,
//               ),
//               inputFormatters: <TextInputFormatter>[
//                 FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
//               ],
//               decoration: InputDecoration(
//                 labelText: 'Amount',
//                 prefixIcon: Icon(
//                   Icons.attach_money,
//                   color: theme.primaryColor.withOpacity(0.7),
//                 ),
//               ),
//               style: TextStyle(color: Colors.white, fontSize: 18),
//             ),
//             const SizedBox(height: 20),

//             // From Country Input
//             TextField(
//               controller: _fromController,
//               decoration: InputDecoration(
//                 labelText: 'From Country',
//                 prefixIcon: Icon(
//                   Icons.flag_circle_outlined,
//                   color: theme.primaryColor.withOpacity(0.7),
//                 ),
//               ),
//               style: TextStyle(color: Colors.white, fontSize: 16),
//             ),
//             const SizedBox(height: 15),

//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: Icon(Icons.swap_vert, color: theme.primaryColor, size: 30),
//             ),

//             // To Country Input
//             TextField(
//               controller: _toController,
//               decoration: InputDecoration(
//                 labelText: 'To Country',
//                 prefixIcon: Icon(
//                   Icons.flag_circle,
//                   color: theme.primaryColor.withOpacity(0.7),
//                 ),
//               ),
//               style: TextStyle(color: Colors.white, fontSize: 16),
//             ),
//             const SizedBox(height: 30),

//             // Convert Button
//             ElevatedButton(
//               onPressed: _isLoading ? null : _convertCurrency,
//               child:
//                   _isLoading
//                       ? SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             theme.primaryColorDark ?? Colors.black,
//                           ),
//                         ),
//                       )
//                       : const Text('Convert'),
//             ),
//             const SizedBox(height: 30),

//             // Result Display
//             if (_error != null)
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.redAccent.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
//                 ),
//                 child: Text(
//                   'Error: $_error',
//                   style: TextStyle(color: Colors.red[100], fontSize: 15),
//                   textAlign: TextAlign.center,
//                 ),
//               ),

//             if (_result.isNotEmpty)
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: theme.primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: theme.primaryColor.withOpacity(0.3),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       'Converted Amount:',
//                       style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       _result,
//                       style: theme.textTheme.headlineMedium?.copyWith(
//                         fontSize: 28,
//                         color: theme.primaryColor,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
