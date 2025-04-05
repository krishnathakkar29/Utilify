// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import '../services/api_service.dart';
// import 'dart:typed_data'; // Required for PlatformFile bytes

// class ExceltoCsv extends StatefulWidget {
//   const ExceltoCsv({super.key});

//   @override
//   State<ExceltoCsv> createState() => _ExceltoCsvState();
// }

// class _ExceltoCsvState extends State<ExceltoCsv> {
//   final ApiService _apiService = ApiService();
//   PlatformFile? _selectedFile;
//   String _statusMessage = 'Select a file and choose a conversion type.';
//   bool _isLoading = false;

//   Future<void> _pickFile(List<String> allowedExtensions) async {
//     setState(() {
//       _isLoading = true;
//       _statusMessage = 'Picking file...';
//       _selectedFile = null; // Reset selected file
//     });
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: allowedExtensions,
//         withData: true, // Crucial for web to get bytes
//       );

//       if (result != null && result.files.isNotEmpty) {
//         // Ensure bytes are loaded (especially important for web)
//         if (result.files.single.bytes != null) {
//           setState(() {
//             _selectedFile = result.files.single;
//             _statusMessage = 'File selected: ${_selectedFile!.name}';
//           });
//         } else {
//           setState(() {
//             _statusMessage = 'Error: Could not read file data.';
//             _selectedFile = null;
//           });
//         }
//       } else {
//         // User canceled the picker
//         setState(() {
//           _statusMessage = 'File selection cancelled.';
//           _selectedFile = null;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _statusMessage = 'Error picking file: $e';
//         _selectedFile = null;
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _convertFile(String conversionType) async {
//     if (_selectedFile == null || _selectedFile!.bytes == null) {
//       setState(() {
//         _statusMessage = 'Please select a valid file first.';
//       });
//       return;
//     }

//     // Double check file extension before sending
//     final fileName = _selectedFile!.name.toLowerCase();
//     if (conversionType == 'excel-to-csv' &&
//         !fileName.endsWith('.xlsx') &&
//         !fileName.endsWith('.xls')) {
//       setState(() {
//         _statusMessage =
//             'Invalid file type for Excel to CSV. Please select an .xlsx or .xls file.';
//       });
//       return;
//     }
//     if (conversionType == 'csv-to-excel' && !fileName.endsWith('.csv')) {
//       setState(() {
//         _statusMessage =
//             'Invalid file type for CSV to Excel. Please select a .csv file.';
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _statusMessage = 'Uploading and converting...';
//     });

//     try {
//       // Modified to get the result object
//       final result = await _apiService.convertFile(
//         _selectedFile!,
//         conversionType,
//       );

//       // Check if file was saved successfully
//       if (result['success'] == true && result['filePath'] != null) {
//         setState(() {
//           _statusMessage =
//               'Conversion successful!\nFile saved to: ${result['fileName']}\n'
//               'Location: ${result['filePath']}';
//           _selectedFile = null; // Clear selection after successful conversion
//         });

//         // Optional: Show a dialog to open the file
//         _showFileActionDialog(result['filePath'], result['fileName']);
//       } else {
//         setState(() {
//           _statusMessage = 'Conversion completed, but file could not be saved.';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _statusMessage = 'Conversion failed: $e';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _showFileActionDialog(String filePath, String fileName) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('File Converted'),
//           content: Text(
//             'Your file "$fileName" has been saved. What would you like to do?',
//           ),
//           actions: [
//             TextButton(
//               child: Text('Open'),
//               onPressed: () async {
//                 Navigator.of(context).pop();

//                 // Requires open_file package
//                 // await OpenFile.open(filePath);

//                 // For now, just update status message
//                 setState(() {
//                   _statusMessage =
//                       'To open the file, add the open_file package to your project.';
//                 });
//               },
//             ),
//             TextButton(
//               child: Text('Share'),
//               onPressed: () async {
//                 Navigator.of(context).pop();

//                 // Requires share_plus package
//                 // await Share.shareFiles([filePath], text: 'Converted file: $fileName');

//                 // For now, just update status message
//                 setState(() {
//                   _statusMessage =
//                       'To share the file, add the share_plus package to your project.';
//                 });
//               },
//             ),
//             TextButton(
//               child: Text('Close'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // New method to save file to device
//   Future<String?> _saveFileToDevice(
//     Uint8List data,
//     String conversionType,
//     String originalFileName,
//   ) async {
//     try {
//       // Generate output filename based on conversion type
//       String outputFileName;
//       if (conversionType == 'excel-to-csv') {
//         outputFileName = originalFileName.replaceAll(
//           RegExp(r'\.xlsx$|\.xls$'),
//           '.csv',
//         );
//       } else {
//         outputFileName = originalFileName.replaceAll(
//           RegExp(r'\.csv$'),
//           '.xlsx',
//         );
//       }

//       // For Android/iOS: Save to app's documents directory
//       // You'll need to add 'path_provider' package
//       final directory = await getApplicationDocumentsDirectory();
//       final path = '${directory.path}/$outputFileName';
//       final file = File(path);
//       await file.writeAsBytes(data);

//       // Optional: Open the file or share it
//       // You can use plugins like 'open_file' or 'share_plus' to open or share the file

//       return path;
//     } catch (e) {
//       print('Error saving file: $e');
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('File Converter'),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         foregroundColor: Theme.of(context).colorScheme.onPrimary,
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               Card(
//                 elevation: 4,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       Icon(
//                         Icons.insert_drive_file,
//                         size: 50,
//                         color: Theme.of(context).colorScheme.secondary,
//                       ),
//                       const SizedBox(height: 15),
//                       Text(
//                         _statusMessage,
//                         textAlign: TextAlign.center,
//                         style: Theme.of(context).textTheme.titleMedium,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               if (_isLoading)
//                 const Center(child: CircularProgressIndicator())
//               else
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.file_upload),
//                       label: const Text('Select Excel (.xlsx, .xls)'),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 15),
//                         backgroundColor: Theme.of(context).colorScheme.primary,
//                         foregroundColor:
//                             Theme.of(context).colorScheme.onPrimary,
//                       ),
//                       onPressed: () => _pickFile(['xlsx', 'xls']),
//                     ),
//                     const SizedBox(height: 15),
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.file_upload),
//                       label: const Text('Select CSV (.csv)'),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 15),
//                         backgroundColor: Theme.of(context).colorScheme.primary,
//                         foregroundColor:
//                             Theme.of(context).colorScheme.onPrimary,
//                       ),
//                       onPressed: () => _pickFile(['csv']),
//                     ),
//                     const SizedBox(height: 30),
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.swap_horiz),
//                       label: const Text('Convert Excel to CSV'),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 15),
//                         backgroundColor:
//                             Theme.of(context).colorScheme.secondary,
//                         foregroundColor:
//                             Theme.of(context).colorScheme.onSecondary,
//                       ),
//                       // Disable button if no file or wrong type selected or loading
//                       onPressed:
//                           (_selectedFile == null ||
//                                   _isLoading ||
//                                   !(_selectedFile!.name.toLowerCase().endsWith(
//                                         '.xlsx',
//                                       ) ||
//                                       _selectedFile!.name
//                                           .toLowerCase()
//                                           .endsWith('.xls')))
//                               ? null
//                               : () => _convertFile('excel-to-csv'),
//                     ),
//                     const SizedBox(height: 15),
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.swap_horiz),
//                       label: const Text('Convert CSV to Excel'),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 15),
//                         backgroundColor:
//                             Theme.of(context).colorScheme.secondary,
//                         foregroundColor:
//                             Theme.of(context).colorScheme.onSecondary,
//                       ),
//                       // Disable button if no file or wrong type selected or loading
//                       onPressed:
//                           (_selectedFile == null ||
//                                   _isLoading ||
//                                   !_selectedFile!.name.toLowerCase().endsWith(
//                                     '.csv',
//                                   ))
//                               ? null
//                               : () => _convertFile('csv-to-excel'),
//                     ),
//                   ],
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart'; // Optional: For opening files

class ExceltoCsv extends StatefulWidget {
  const ExceltoCsv({super.key});

  @override
  State<ExceltoCsv> createState() => _ExceltoCsvState();
}

class _ExceltoCsvState extends State<ExceltoCsv> {
  final ApiService _apiService = ApiService();
  PlatformFile? _selectedFile;
  String _statusMessage = 'Select a file and choose a conversion type.';
  bool _isLoading = false;
  String? _lastSavedFilePath;

  // Request storage permission if needed (for Android < 10)
  Future<void> _checkPermissions() async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _pickFile(List<String> allowedExtensions) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Picking file...';
      _selectedFile = null;
      _lastSavedFilePath = null;
    });
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        if (result.files.single.bytes != null) {
          setState(() {
            _selectedFile = result.files.single;
            _statusMessage = 'File selected: ${_selectedFile!.name}';
          });
        } else {
          setState(() {
            _statusMessage = 'Error: Could not read file data.';
            _selectedFile = null;
          });
        }
      } else {
        setState(() {
          _statusMessage = 'File selection cancelled.';
          _selectedFile = null;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error picking file: $e';
        _selectedFile = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _convertFile(String conversionType) async {
    if (_selectedFile == null || _selectedFile!.bytes == null) {
      setState(() {
        _statusMessage = 'Please select a valid file first.';
      });
      return;
    }

    // Double check file extension before sending
    final fileName = _selectedFile!.name.toLowerCase();
    if (conversionType == 'excel-to-csv' &&
        !fileName.endsWith('.xlsx') &&
        !fileName.endsWith('.xls')) {
      setState(() {
        _statusMessage =
            'Invalid file type for Excel to CSV. Please select an .xlsx or .xls file.';
      });
      return;
    }
    if (conversionType == 'csv-to-excel' && !fileName.endsWith('.csv')) {
      setState(() {
        _statusMessage =
            'Invalid file type for CSV to Excel. Please select a .csv file.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Uploading and converting...';
      _lastSavedFilePath = null;
    });

    try {
      final result = await _apiService.convertFile(
        _selectedFile!,
        conversionType,
      );

      if (result['success'] == true && result['filePath'] != null) {
        setState(() {
          _statusMessage =
              'Conversion successful!\nFile saved to Downloads folder\nFilename: ${result['fileName']}';
          _selectedFile = null;
          _lastSavedFilePath = result['filePath'];
        });

        _showSuccessDialog(result['filePath'], result['fileName']);
      } else {
        setState(() {
          _statusMessage =
              'Conversion completed, but file could not be saved to Downloads.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Conversion failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(String filePath, String fileName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('File Converted Successfully'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your file has been saved as:\n$fileName'),
              const SizedBox(height: 10),
              const Text('You can find it in your Downloads folder.'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Open File'),
              onPressed: () {
                Navigator.of(context).pop();
                _openFile(filePath);
              },
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        setState(() {
          _statusMessage = 'Could not open file: ${result.message}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error opening file: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
        ),
        title: const Text('File Converter'),
        backgroundColor: Theme.of(context).primaryColorDark,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.insert_drive_file,
                        size: 50,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (_lastSavedFilePath != null) ...[
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Open Saved File'),
                          onPressed: () => _openFile(_lastSavedFilePath!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.tertiary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.file_upload),
                      label: const Text('Select Excel (.xlsx, .xls)'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () => _pickFile(['xlsx', 'xls']),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.file_upload),
                      label: const Text('Select CSV (.csv)'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () => _pickFile(['csv']),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Convert Excel to CSV'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondary,
                      ),
                      onPressed:
                          (_selectedFile == null ||
                                  _isLoading ||
                                  !(_selectedFile!.name.toLowerCase().endsWith(
                                        '.xlsx',
                                      ) ||
                                      _selectedFile!.name
                                          .toLowerCase()
                                          .endsWith('.xls')))
                              ? null
                              : () => _convertFile('excel-to-csv'),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Convert CSV to Excel'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondary,
                      ),
                      onPressed:
                          (_selectedFile == null ||
                                  _isLoading ||
                                  !_selectedFile!.name.toLowerCase().endsWith(
                                    '.csv',
                                  ))
                              ? null
                              : () => _convertFile('csv-to-excel'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
