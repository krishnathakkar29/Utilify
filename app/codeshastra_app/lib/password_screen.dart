import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For jsonDecode and jsonEncode

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  // --- State Variables ---
  final TextEditingController _lengthController = TextEditingController(
    text: '20',
  );
  bool _useSymbols = true;
  String? _generatedPassword;
  bool _isGenerating = false;
  String? _generateError;

  final TextEditingController _checkPasswordController =
      TextEditingController();
  Map<String, dynamic>? _checkResult;
  bool _isChecking = false;
  String? _checkError;

  // --- API Base URL ---
  // Adjust this URL based on where your Flask API is running
  // Use 10.0.2.2 for Android emulator accessing localhost on the host machine
  // Use your machine's local IP if testing on a physical device on the same network
  // Use your deployed server URL if applicable
  final String _apiBaseUrl =
      'https://reception-poultry-ec-booking.trycloudflare.com';

  // --- API Call Functions ---
  Future<void> _generatePassword() async {
    if (_isGenerating) return;
    setState(() {
      _isGenerating = true;
      _generatedPassword = null;
      _generateError = null;
    });

    final int? length = int.tryParse(_lengthController.text);
    if (length == null || length <= 0) {
      setState(() {
        _generateError = 'Please enter a valid positive length.';
        _isGenerating = false;
      });
      return;
    }

    final url = Uri.parse('$_apiBaseUrl/generate-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'length': length, 'symbols': _useSymbols}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _generatedPassword = data['password'];
          _generateError = null;
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _generateError =
              data['error'] ??
              'Failed to generate password (Status code: ${response.statusCode})';
          _generatedPassword = null;
        });
      }
    } catch (e) {
      setState(() {
        _generateError = 'Error connecting to server: $e';
        _generatedPassword = null;
      });
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _checkPassword() async {
    if (_isChecking) return;
    final passwordToCheck = _checkPasswordController.text;
    if (passwordToCheck.isEmpty) {
      setState(() {
        _checkError = 'Please enter a password to check.';
        _checkResult = null;
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _checkResult = null;
      _checkError = null;
    });

    final url = Uri.parse('$_apiBaseUrl/check-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': passwordToCheck}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _checkResult = data;
          _checkError = null;
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _checkError =
              data['error'] ??
              'Failed to check password (Status code: ${response.statusCode})';
          _checkResult = null;
        });
      }
    } catch (e) {
      setState(() {
        _checkError = 'Error connecting to server: $e';
        _checkResult = null;
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme data

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
        ),
        centerTitle: true,
        title: Text(
          'Password Tools',
          style: TextStyle(
            color: theme.primaryColorDark,
            fontSize: 24,
          ), // Use dark color for title
        ),
        backgroundColor:
            theme.primaryColor, // Use primary color for AppBar background
        elevation: 1, // Subtle shadow
      ),
      body: SingleChildScrollView(
        // Allows scrolling if content overflows
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Generate Password Section ---
            _buildSectionCard(
              theme: theme,
              title: 'Generate Password',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _lengthController,
                    decoration: InputDecoration(
                      labelText: 'Password Length',
                      hintText: 'Enter desired length (e.g., 20)',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColorDark,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  // Row(
                  //   children: [
                  //     Text('Use Symbols:', style: theme.textTheme.bodyMedium),
                  //     const SizedBox(width: 10),
                  //     Switch(
                  //       value: _useSymbols,
                  //       onChanged: (value) {
                  //         setState(() {
                  //           _useSymbols = value;
                  //         });
                  //       },
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 16),
                  Center(
                    child:
                        _isGenerating
                            ? CircularProgressIndicator(
                              color: theme.primaryColorDark,
                            )
                            : ElevatedButton(
                              onPressed: _generatePassword,
                              child: Text(
                                'Generate',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                  ),
                  if (_generateError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _generateError!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (_generatedPassword != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Generated Password:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      // Allows copying the password
                      _generatedPassword!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontFamily: 'monospace', // Use monospace for passwords
                        fontSize: 16,
                        color: theme.primaryColorDark.withOpacity(0.8),
                        backgroundColor: theme.primaryColor.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24), // Spacer between sections
            // --- Check Password Strength Section ---
            _buildSectionCard(
              theme: theme,
              title: 'Check Password Strength',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _checkPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Password to Check',
                      hintText: 'Enter password',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColorDark,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  // TextField(
                  //   controller: _checkPasswordController,
                  //   decoration: const InputDecoration(
                  //     labelText: 'Password to Check',
                  //     hintText: 'Enter password',
                  //   ),
                  //   obscureText: true, // Hide password input
                  //   enableSuggestions: false,
                  //   autocorrect: false,
                  // ),
                  const SizedBox(height: 16),
                  Center(
                    child:
                        _isChecking
                            ? CircularProgressIndicator(
                              color: theme.primaryColorDark,
                            )
                            : ElevatedButton(
                              onPressed: _checkPassword,
                              child: Text(
                                'Check Strength',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                  ),
                  if (_checkError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _checkError!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (_checkResult != null) ...[
                    const SizedBox(height: 16),
                    _buildResultRow(
                      theme,
                      'Charset Size:',
                      _checkResult!['charset_size']?.toString() ?? 'N/A',
                    ),
                    _buildResultRow(
                      theme,
                      'Entropy (bits):',
                      _checkResult!['entropy']?.toString() ?? 'N/A',
                    ),
                    _buildResultRow(
                      theme,
                      'Est. Crack Time:',
                      _checkResult!['crack_time'] ?? 'N/A',
                    ),
                    _buildResultRow(
                      theme,
                      'Strength:',
                      _checkResult!['strength_feedback'] ?? 'N/A',
                      isBold: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build styled section cards
  Widget _buildSectionCard({
    required ThemeData theme,
    required String title,
    required Widget child,
  }) {
    return Card(
      // Using CardTheme defined in main.dart
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge, // Use titleLarge from theme
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  // Helper widget to build result rows for the check section
  Widget _buildResultRow(
    ThemeData theme,
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            width: 200,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color:
                    isBold
                        ? theme.primaryColorDark
                        : theme.primaryColorDark.withOpacity(0.8),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _lengthController.dispose();
    _checkPasswordController.dispose();
    super.dispose();
  }
}

// import 'package:codeshastra_app/models/pass_strength.dart';
// import 'package:codeshastra_app/models/password_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // For Clipboard
// import 'package:provider/provider.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// // import '../providers/password_provider.dart';
// // import '../models/password_strength.dart';

// class PasswordToolScreen extends StatefulWidget {
//   const PasswordToolScreen({super.key});

//   @override
//   State<PasswordToolScreen> createState() => _PasswordToolScreenState();
// }

// class _PasswordToolScreenState extends State<PasswordToolScreen> {
//   final TextEditingController _checkPasswordController =
//       TextEditingController();
//   final FocusNode _checkPasswordFocusNode = FocusNode(); // To dismiss keyboard

//   @override
//   void dispose() {
//     _checkPasswordController.dispose();
//     _checkPasswordFocusNode.dispose();
//     super.dispose();
//   }

//   void _showToast(String message, {bool isError = false}) {
//     Fluttertoast.showToast(
//       msg: message,
//       toastLength: Toast.LENGTH_SHORT,
//       gravity: ToastGravity.BOTTOM,
//       backgroundColor: isError ? Colors.redAccent : Colors.green,
//       textColor: Colors.white,
//       fontSize: 16.0,
//     );
//   }

//   void _copyToClipboard(String text) {
//     if (text.isNotEmpty) {
//       Clipboard.setData(ClipboardData(text: text));
//       _showToast("Password copied to clipboard!");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Access the provider
//     final passwordProvider = Provider.of<PasswordProvider>(context);
//     final theme = Theme.of(context); // Access theme data

//     return GestureDetector(
//       // To dismiss keyboard on tap outside
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Password Generator & Checker'),
//           centerTitle: true,
//         ),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // --- Password Generator Section ---
//               _buildSectionCard(
//                 context: context,
//                 title: 'Generate Secure Password',
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Length: ${passwordProvider.passwordLength.round()}',
//                       style: theme.textTheme.titleMedium,
//                     ),
//                     Slider(
//                       value: passwordProvider.passwordLength,
//                       min: 8,
//                       max: 64,
//                       divisions: 56,
//                       label: passwordProvider.passwordLength.round().toString(),
//                       onChanged:
//                           passwordProvider.isLoading
//                               ? null
//                               : (value) =>
//                                   passwordProvider.setPasswordLength(value),
//                     ),
//                     SwitchListTile(
//                       title: Text(
//                         'Include Symbols (@#\$%)',
//                         style: theme.textTheme.titleMedium,
//                       ),
//                       value: passwordProvider.useSymbols,
//                       onChanged:
//                           passwordProvider.isLoading
//                               ? null
//                               : (value) =>
//                                   passwordProvider.setUseSymbols(value),
//                       activeColor: theme.colorScheme.primary,
//                       contentPadding: EdgeInsets.zero,
//                     ),
//                     const SizedBox(height: 16),
//                     if (passwordProvider.isLoading &&
//                         passwordProvider.lastAction == ActionType.generate)
//                       const Center(child: CircularProgressIndicator())
//                     else
//                       Center(
//                         child: ElevatedButton.icon(
//                           icon: const Icon(Icons.vpn_key),
//                           label: const Text('Generate'),
//                           onPressed: () async {
//                             try {
//                               await passwordProvider.generatePassword();
//                               _showToast("Password generated!");
//                             } catch (e) {
//                               _showToast(
//                                 "Error: ${e.toString()}",
//                                 isError: true,
//                               );
//                             }
//                           },
//                         ),
//                       ),
//                     const SizedBox(height: 16),
//                     if (passwordProvider.generatedPassword.isNotEmpty)
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: theme.primaryColorDark.withOpacity(0.7),
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(
//                             color: theme.colorScheme.primary.withOpacity(0.5),
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: SelectableText(
//                                 passwordProvider.generatedPassword,
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   fontSize: 16,
//                                   letterSpacing: 1.2,
//                                 ),
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.copy),
//                               onPressed:
//                                   () => _copyToClipboard(
//                                     passwordProvider.generatedPassword,
//                                   ),
//                               tooltip: 'Copy to Clipboard',
//                               color: theme.colorScheme.primary,
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // --- Password Checker Section ---
//               _buildSectionCard(
//                 context: context,
//                 title: 'Check Password Strength',
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     TextField(
//                       controller: _checkPasswordController,
//                       focusNode: _checkPasswordFocusNode,
//                       decoration: const InputDecoration(
//                         labelText: 'Enter password to check',
//                         suffixIcon: Icon(Icons.password),
//                       ),
//                       obscureText: true,
//                       enabled: !passwordProvider.isLoading,
//                     ),
//                     const SizedBox(height: 16),
//                     if (passwordProvider.isLoading &&
//                         passwordProvider.lastAction == ActionType.check)
//                       const Center(child: CircularProgressIndicator())
//                     else
//                       Center(
//                         child: ElevatedButton.icon(
//                           icon: const Icon(Icons.security),
//                           label: const Text('Check Strength'),
//                           onPressed: () async {
//                             final password = _checkPasswordController.text;
//                             if (password.isEmpty) {
//                               _showToast(
//                                 "Please enter a password to check.",
//                                 isError: true,
//                               );
//                               return;
//                             }
//                             _checkPasswordFocusNode
//                                 .unfocus(); // Dismiss keyboard
//                             try {
//                               await passwordProvider.checkPasswordStrength(
//                                 password,
//                               );
//                               _showToast("Password strength checked!");
//                             } catch (e) {
//                               _showToast(
//                                 "Error: ${e.toString()}",
//                                 isError: true,
//                               );
//                             }
//                           },
//                         ),
//                       ),
//                     const SizedBox(height: 16),
//                     // Display Strength Results
//                     if (passwordProvider.passwordStrength != null)
//                       _buildStrengthResults(
//                         context,
//                         passwordProvider.passwordStrength!,
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionCard({
//     required BuildContext context,
//     required String title,
//     required Widget child,
//   }) {
//     final theme = Theme.of(context);
//     return Card(
//       // elevation: 4, // Already set in theme
//       // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Already set in theme
//       // color: theme.primaryColorDark, // Already set in theme
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: theme.textTheme.titleLarge?.copyWith(
//                 color: theme.colorScheme.primary,
//               ),
//             ),
//             const SizedBox(height: 16),
//             child,
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStrengthResults(
//     BuildContext context,
//     PasswordStrength strength,
//   ) {
//     final theme = Theme.of(context);
//     Color strengthColor;
//     IconData strengthIcon;

//     switch (strength.strengthFeedback.toLowerCase()) {
//       case 'very weak':
//       case 'weak':
//         strengthColor = Colors.redAccent;
//         strengthIcon = Icons.thumb_down_alt_rounded;
//         break;
//       case 'moderate':
//         strengthColor = Colors.orangeAccent;
//         strengthIcon = Icons.thumbs_up_down_rounded;
//         break;
//       case 'strong':
//       case 'very strong':
//         strengthColor = Colors.green;
//         strengthIcon = Icons.thumb_up_alt_rounded;
//         break;
//       default:
//         strengthColor = theme.colorScheme.primary; // Default color
//         strengthIcon = Icons.help_outline_rounded;
//     }

//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: theme.primaryColorDark.withOpacity(0.7),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: strengthColor.withOpacity(0.8)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(strengthIcon, color: strengthColor, size: 20),
//               const SizedBox(width: 8),
//               Text(
//                 'Strength: ${strength.strengthFeedback}',
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   color: strengthColor,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           _buildResultRow(context, 'Entropy:', '${strength.entropy} bits'),
//           _buildResultRow(context, 'Est. Crack Time:', strength.crackTime),
//           _buildResultRow(
//             context,
//             'Character Set Size:',
//             strength.charsetSize.toString(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildResultRow(BuildContext context, String label, String value) {
//     final theme = Theme.of(context);
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: theme.textTheme.bodyMedium?.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           Flexible(
//             child: Text(
//               value,
//               style: theme.textTheme.bodyMedium,
//               textAlign: TextAlign.end,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
