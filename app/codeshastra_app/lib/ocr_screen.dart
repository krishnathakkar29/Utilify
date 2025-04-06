// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:pdfx/pdfx.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart'; // Import permission_handler

// class OcrScreen extends StatefulWidget {
//   const OcrScreen({super.key});

//   @override
//   State<OcrScreen> createState() => _OcrScreenState();
// }

// class _OcrScreenState extends State<OcrScreen> {
//   // --- State Variables ---
//   File? _selectedPdfFile;
//   String _ocrResult = '';
//   bool _isLoading = false;
//   String? _errorMessage;
//   String _loadingMessage = '';
//   int _totalPages = 0;
//   int _processedPages = 0;

//   // --- Configuration ---
//   // IMPORTANT: Replace with your actual backend API URL
//   final String _apiUrl = 'http://10.0.2.2:5000/ocr'; // Use 10.0.2.2 for Android emulator accessing localhost

//   // --- Methods ---

//   Future<void> _requestPermissions() async {
//     // Request storage permission
//     var status = await Permission.storage.status;
//     if (!status.isGranted) {
//       status = await Permission.storage.request();
//       if (!status.isGranted) {
//         setState(() {
//           _errorMessage = 'Storage permission is required to pick files.';
//         });
//         // Optionally, show a dialog explaining why permission is needed
//         // and guide the user to settings using openAppSettings()
//       }
//     }
//   }


//   Future<void> _pickPdf() async {
//     await _requestPermissions(); // Request permission before picking

//     setState(() {
//       _errorMessage = null; // Clear previous errors
//       _ocrResult = ''; // Clear previous results
//       _selectedPdfFile = null; // Clear previous selection
//       _totalPages = 0;
//       _processedPages = 0;
//     });

//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf'],
//       );

//       if (result != null && result.files.single.path != null) {
//         setState(() {
//           _selectedPdfFile = File(result.files.single.path!);
//         });
//       } else {
//         // User canceled the picker
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('No PDF file selected.')),
//           );
//         }
//       }
//     } catch (e) {
//       print('Error picking PDF: $e');
//       setState(() {
//         _errorMessage = 'Error picking PDF: $e';
//       });
//     }
//   }

//   Future<void> _performOcr() async {
//     if (_selectedPdfFile == null) {
//       setState(() {
//         _errorMessage = 'Please select a PDF file first.';
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//       _ocrResult = '';
//       _loadingMessage = 'Initializing OCR...';
//       _totalPages = 0;
//       _processedPages = 0;
//     });

//     PdfController? pdfController;
//     Directory? tempDir;
//     List<String> pageTexts = [];

//     try {
//       // Get temporary directory
//       tempDir = await getTemporaryDirectory();

//       // Load PDF document
//       setState(() { _loadingMessage = 'Loading PDF...'; });
//       pdfController = PdfController(
//         document: PdfDocument.openFile(_selectedPdfFile!.path),
//       );

//       // Wait for the controller to be ready (important!)
//       await pdfController.loadDocument(PdfDocument.openFile(_selectedPdfFile!.path));
//       _totalPages = pdfController.pagesCount ?? 0;
//       if (_totalPages == 0) {
//         throw Exception("Could not read pages from PDF.");
//       }

//       setState(() { _loadingMessage = 'Processing $_totalPages pages...'; });

//       // Process each page
//       for (int i = 1; i <= _totalPages; i++) {
//         setState(() {
//           _processedPages = i;
//           _loadingMessage = 'Processing page $i of $_totalPages...';
//         });

//         final page = await pdfController.getPage(i);
//         if (page == null) {
//           print('Warning: Could not get page $i');
//           continue; // Skip if page data is null
//         }

//         // Render page to image (adjust quality/format as needed)
//         final pageImage = await page.render(
//           width: page.width * 2, // Increase resolution for better OCR
//           height: page.height * 2,
//           format: PdfPageImageFormat.jpeg,
//           quality: 90, // Adjust quality vs size
//         );
//         await page.close(); // Close page after rendering

//         if (pageImage == null) {
//           print('Warning: Could not render page $i to image');
//           continue; // Skip if rendering failed
//         }

//         // --- Send image to backend API ---
//         setState(() { _loadingMessage = 'Sending page $i for OCR...'; });
//         final String pageOcrText = await _uploadImageAndGetOcr(pageImage.bytes, 'page_$i.jpg');
//         pageTexts.add(pageOcrText);
//         // --- End Send ---

//         // Optional: Clean up temporary image file if saved (not needed here as we use bytes)
//       }

//       setState(() {
//         _ocrResult = pageTexts.join('\n\n---\n\n'); // Join page results
//         _loadingMessage = 'OCR Complete!';
//       });

//     } catch (e) {
//       print('OCR Error: $e');
//       setState(() {
//         _errorMessage = 'An error occurred during OCR: $e';
//       });
//     } finally {
//       // Ensure PDF controller is disposed
//       pdfController?.dispose();
//       // Optional: Clean up temporary directory if needed, though OS usually handles it.
//       // if (tempDir != null && await tempDir.exists()) {
//       //   // await tempDir.delete(recursive: true); // Be careful with this
//       // }
//       setState(() {
//         _isLoading = false;
//         _loadingMessage = ''; // Clear loading message
//       });
//     }
//   }

//   Future<String> _uploadImageAndGetOcr(Uint8List imageData, String filename) async {
//     try {
//       var request = http.MultipartRequest('POST', Uri.parse(_apiUrl));

//       // Add image file to the request
//       request.files.add(http.MultipartFile.fromBytes(
//         'image', // Must match the key expected by the backend ("image")
//         imageData,
//         filename: filename, // Provide a filename
//       ));

//       // Send request
//       var streamedResponse = await request.send().timeout(const Duration(seconds: 90)); // Add timeout

//       // Get response
//       var response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200) {
//         var jsonResponse = jsonDecode(response.body);
//         if (jsonResponse.containsKey('text')) {
//           return jsonResponse['text'];
//         } else if (jsonResponse.containsKey('error')) {
//           throw Exception('API Error: ${jsonResponse['error']}');
//         } else {
//           throw Exception('Invalid API response format.');
//         }
//       } else {
//         print('API Error Status Code: ${response.statusCode}');
//         print('API Error Body: ${response.body}');
//         throw Exception('API request failed with status: ${response.statusCode}. Body: ${response.body}');
//       }
//     } on SocketException catch (e) {
//        print('Network Error: $e');
//        throw Exception('Network error: Could not connect to the server. Please check your connection and the API URL.');
//     } on http.ClientException catch (e) {
//       print('HTTP Client Error: $e');
//       throw Exception('Network error: ${e.message}');
//     } catch (e) {
//       print('Error uploading/processing image: $e');
//       rethrow; // Rethrow other exceptions
//     }
//   }


//   // --- Build Method ---
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PDF OCR Processor'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             // --- File Selection Card ---
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.picture_as_pdf,
//                       size: 50,
//                       color: Colors.red[700],
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       _selectedPdfFile == null
//                           ? 'No PDF Selected'
//                           : 'Selected: ${_selectedPdfFile!.path.split('/').last}', // Show only filename
//                       style: Theme.of(context).textTheme.titleMedium,
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 15),
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.file_upload),
//                       label: const Text('Pick PDF File'),
//                       onPressed: _isLoading ? null : _pickPdf,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // --- OCR Action Button ---
//             ElevatedButton.icon(
//               icon: const Icon(Icons.document_scanner_outlined),
//               label: const Text('Start OCR Process'),
//               onPressed: (_selectedPdfFile == null || _isLoading) ? null : _performOcr,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 15),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // --- Loading Indicator / Progress ---
//             if (_isLoading)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 20.0),
//                 child: Column(
//                   children: [
//                     const CircularProgressIndicator(),
//                     const SizedBox(height: 15),
//                     Text(
//                       _loadingMessage,
//                       style: TextStyle(color: Colors.deepPurple[700], fontWeight: FontWeight.w500),
//                       textAlign: TextAlign.center,
//                     ),
//                     if (_totalPages > 0)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8.0),
//                         child: LinearProgressIndicator(
//                           value: _processedPages / _totalPages,
//                           minHeight: 6,
//                           borderRadius: BorderRadius.circular(3),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),

//             // --- Error Message Display ---
//             if (_errorMessage != null)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 15.0),
//                 child: Card(
//                   color: Colors.red[100],
//                   child: Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Text(
//                       'Error: $_errorMessage',
//                       style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//               ),

//             // --- OCR Result Display ---
//             if (_ocrResult.isNotEmpty)
//               Card(
//                 elevation: 1,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'OCR Result:',
//                         style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           color: Colors.deepPurple[800],
//                         ),
//                       ),
//                       const Divider(height: 20, thickness: 1),
//                       SelectableText(
//                         _ocrResult,
//                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
