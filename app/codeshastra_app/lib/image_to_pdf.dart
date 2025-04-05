//working 1 without download and open
// import 'dart:io';
// import 'package:codeshastra_app/utility/sizedbox_util.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:intl/intl.dart';

// class ImageToPdfScreen extends StatefulWidget {
//   const ImageToPdfScreen({super.key});

//   @override
//   State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
// }

// class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
//   final List<XFile> _selectedImages = [];
//   late pw.Document pdf;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     pdf = pw.Document();
//     _checkPermissions();
//   }

//   Future<void> _checkPermissions() async {
//     var storageStatus = await Permission.storage.status;
//     if (!storageStatus.isGranted) {
//       await Permission.storage.request();
//     }

//     var cameraStatus = await Permission.camera.status;
//     if (!cameraStatus.isGranted) {
//       await Permission.camera.request();
//     }
//   }

//   Future<void> _pickImageFromGallery() async {
//     try {
//       final pickedFiles = await ImagePicker().pickMultiImage();
//       if (pickedFiles.isNotEmpty) {
//         setState(() {
//           _selectedImages.addAll(pickedFiles);
//         });
//       }
//     } catch (e) {
//       _showError('Error picking images: $e');
//     }
//   }

//   Future<void> _pickImageFromCamera() async {
//     try {
//       final pickedFile = await ImagePicker().pickImage(
//         source: ImageSource.camera,
//         imageQuality: 85,
//       );
//       if (pickedFile != null) {
//         setState(() {
//           _selectedImages.add(pickedFile);
//         });
//       }
//     } catch (e) {
//       _showError('Error capturing image: $e');
//     }
//   }

//   Future<void> _createPdf() async {
//     if (_selectedImages.isEmpty) {
//       _showError('Please select at least one image');
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       pdf = pw.Document();

//       for (var image in _selectedImages) {
//         final bytes = await File(image.path).readAsBytes();
//         final imageWidget = pw.MemoryImage(bytes);

//         pdf.addPage(
//           pw.Page(
//             pageFormat: PdfPageFormat.a4,
//             build: (pw.Context context) {
//               return pw.Center(
//                 child: pw.Image(imageWidget, fit: pw.BoxFit.contain),
//               );
//             },
//           ),
//         );
//       }

//       await _savePdf();
//       setState(() {
//         _selectedImages.clear();
//       });
//     } catch (e) {
//       _showError('Error creating PDF: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _savePdf() async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
//       final file = File('${directory.path}/PDF_$timestamp.pdf');

//       await file.writeAsBytes(await pdf.save());

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('PDF saved successfully to ${file.path}'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       _showError('Error saving PDF: $e');
//     }
//   }

//   void _showError(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).primaryColorDark,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         backgroundColor: Theme.of(context).primaryColorDark,
//         title: const Text(
//           'Image to PDF',
//           style: TextStyle(color: Colors.white),
//         ),
//         actions: [
//           if (_selectedImages.isNotEmpty)
//             IconButton(
//               icon: const Icon(Icons.delete, color: Colors.white),
//               tooltip: 'Clear Images',
//               onPressed: () {
//                 setState(() => _selectedImages.clear());
//               },
//             ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Expanded(
//                 child:
//                     _selectedImages.isEmpty
//                         ? Center(
//                           child: Text(
//                             'No images selected',
//                             style: TextStyle(color: Colors.white70),
//                           ),
//                         )
//                         : GridView.builder(
//                           padding: const EdgeInsets.all(8),
//                           gridDelegate:
//                               const SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 3,
//                                 crossAxisSpacing: 8,
//                                 mainAxisSpacing: 8,
//                               ),
//                           itemCount: _selectedImages.length,
//                           itemBuilder: (context, index) {
//                             return ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Image.file(
//                                 File(_selectedImages[index].path),
//                                 fit: BoxFit.cover,
//                               ),
//                             );
//                           },
//                         ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 100.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     Column(
//                       children: [
//                         FloatingActionButton(
//                           heroTag: 'gallery',
//                           onPressed: _isLoading ? null : _pickImageFromGallery,
//                           backgroundColor: Colors.blue[700],
//                           child: const Icon(
//                             Icons.photo_library,
//                             color: Colors.white,
//                           ),
//                         ),
//                         vSize(5),
//                         Text("Gallery", style: TextStyle(color: Colors.white)),
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         FloatingActionButton(
//                           heroTag: 'camera',
//                           onPressed: _isLoading ? null : _pickImageFromCamera,
//                           backgroundColor: Colors.blue[700],
//                           child: const Icon(
//                             Icons.camera_alt,
//                             color: Colors.white,
//                           ),
//                         ),
//                         vSize(5),
//                         Text("Camera", style: TextStyle(color: Colors.white)),
//                       ],
//                     ),

//                     Column(
//                       children: [
//                         FloatingActionButton(
//                           heroTag: 'generate',
//                           onPressed: _isLoading ? null : _createPdf,
//                           backgroundColor: Colors.green[700],
//                           child: const Icon(
//                             Icons.picture_as_pdf,
//                             color: Colors.white,
//                           ),
//                         ),
//                         vSize(5),
//                         Text("Make Pdf", style: TextStyle(color: Colors.white)),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (_isLoading)
//             Container(
//               color: Colors.black54,
//               child: const Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:codeshastra_app/utility/sizedbox_util.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart'; // For opening files

class ImageToPdfScreen extends StatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  final List<XFile> _selectedImages = [];
  late pw.Document pdf;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    pdf = pw.Document();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }

    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFiles = await ImagePicker().pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles);
        });
      }
    } catch (e) {
      _showError('Error picking images: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(pickedFile);
        });
      }
    } catch (e) {
      _showError('Error capturing image: $e');
    }
  }

  Future<void> _createPdf() async {
    if (_selectedImages.isEmpty) {
      _showError('Please select at least one image');
      return;
    }

    setState(() => _isLoading = true);

    try {
      pdf = pw.Document();

      for (var image in _selectedImages) {
        final bytes = await File(image.path).readAsBytes();
        final imageWidget = pw.MemoryImage(bytes);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(imageWidget, fit: pw.BoxFit.contain),
              );
            },
          ),
        );
      }

      await _savePdf();
      setState(() {
        _selectedImages.clear();
      });
    } catch (e) {
      _showError('Error creating PDF: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePdf() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/PDF_$timestamp.pdf');

      await file.writeAsBytes(await pdf.save());

      // Open the saved PDF file using open_file package
      OpenFile.open(file.path);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved successfully to ${file.path}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showError('Error saving PDF: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
        ),
        backgroundColor: Theme.of(context).primaryColorDark,
        title: const Text(
          'Image to PDF',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (_selectedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              tooltip: 'Clear Images',
              onPressed: () {
                setState(() => _selectedImages.clear());
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child:
                    _selectedImages.isEmpty
                        ? Center(
                          child: Text(
                            'No images selected',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                        : GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_selectedImages[index].path),
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 100.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'gallery',
                          onPressed: _isLoading ? null : _pickImageFromGallery,
                          backgroundColor: Colors.blue[700],
                          child: const Icon(
                            Icons.photo_library,
                            color: Colors.white,
                          ),
                        ),
                        vSize(5),
                        Text("Gallery", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'camera',
                          onPressed: _isLoading ? null : _pickImageFromCamera,
                          backgroundColor: Colors.blue[700],
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                        ),
                        vSize(5),
                        Text("Camera", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    Column(
                      children: [
                        FloatingActionButton(
                          heroTag: 'generate',
                          onPressed: _isLoading ? null : _createPdf,
                          backgroundColor: Colors.green[700],
                          child: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.white,
                          ),
                        ),
                        vSize(5),
                        Text("Make Pdf", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

////kharab
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:intl/intl.dart';

// class ImageToPdfScreen extends StatefulWidget {
//   const ImageToPdfScreen({super.key});

//   @override
//   State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
// }

// class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
//   final List<XFile> _selectedImages = [];
//   late pw.Document pdf;

//   @override
//   void initState() {
//     super.initState();
//     pdf = pw.Document();
//   }

//   Future<void> _pickImageFromGallery() async {
//     final status = await Permission.storage.request();
//     if (!status.isGranted) return;

//     final pickedFiles = await ImagePicker().pickMultiImage();
//     if (pickedFiles.isNotEmpty) {
//       setState(() {
//         _selectedImages.addAll(pickedFiles);
//       });
//     }
//   }

//   Future<void> _pickImageFromCamera() async {
//     final status = await Permission.camera.request();
//     if (!status.isGranted) return;

//     final pickedFile = await ImagePicker().pickImage(
//       source: ImageSource.camera,
//     );
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImages.add(pickedFile);
//       });
//     }
//   }

//   Future<void> _createPdf() async {
//     if (_selectedImages.isEmpty) return;

//     pdf = pw.Document(); // Reinitialize in case of previous PDF

//     for (var image in _selectedImages) {
//       final bytes = await File(image.path).readAsBytes();
//       final imageWidget = pw.MemoryImage(bytes);

//       pdf.addPage(
//         pw.Page(
//           pageFormat: PdfPageFormat.a4,
//           build: (pw.Context context) {
//             return pw.Center(
//               child: pw.Image(imageWidget, fit: pw.BoxFit.contain),
//             );
//           },
//         ),
//       );
//     }

//     await _savePdf();
//     setState(() {
//       _selectedImages.clear();
//     });
//   }

//   Future<void> _savePdf() async {
//     final status = await Permission.storage.request();
//     if (!status.isGranted) return;

//     final directory = await getExternalStorageDirectory();
//     final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
//     final file = File('${directory?.path}/PDF_$timestamp.pdf');

//     await file.writeAsBytes(await pdf.save());

//     if (!mounted) return;
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('✅ PDF saved to ${file.path}')));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Image to PDF Converter'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete),
//             tooltip: 'Clear Images',
//             onPressed: () {
//               setState(() {
//                 _selectedImages.clear();
//               });
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child:
//                 _selectedImages.isEmpty
//                     ? const Center(child: Text('No images selected'))
//                     : GridView.builder(
//                       padding: const EdgeInsets.all(8),
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 3,
//                             crossAxisSpacing: 4,
//                             mainAxisSpacing: 4,
//                           ),
//                       itemCount: _selectedImages.length,
//                       itemBuilder: (context, index) {
//                         return Image.file(
//                           File(_selectedImages[index].path),
//                           fit: BoxFit.cover,
//                         );
//                       },
//                     ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 FloatingActionButton(
//                   heroTag: 'gallery',
//                   onPressed: _pickImageFromGallery,
//                   tooltip: 'Add from Gallery',
//                   child: const Icon(Icons.photo_library),
//                 ),
//                 FloatingActionButton(
//                   heroTag: 'camera',
//                   onPressed: _pickImageFromCamera,
//                   tooltip: 'Add from Camera',
//                   child: const Icon(Icons.camera_alt),
//                 ),
//                 FloatingActionButton(
//                   heroTag: 'generate',
//                   onPressed: _createPdf,
//                   tooltip: 'Generate PDF',
//                   backgroundColor: Colors.green,
//                   child: const Icon(Icons.picture_as_pdf),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
