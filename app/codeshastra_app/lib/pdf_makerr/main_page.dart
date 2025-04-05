import 'dart:typed_data';

import 'package:codeshastra_app/pdf_maker/images_list.dart';
import 'package:codeshastra_app/pdf_makerr/images_list.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  ImagesList imagesList = ImagesList();

  Future<PermissionStatus> storagePermissionStatus() async {
    PermissionStatus status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status;
  }

  Future<PermissionStatus> cameraPermissionStatus() async {
    PermissionStatus status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    return status;
  }

  void pickGalleryImage() async {
    PermissionStatus status = await storagePermissionStatus();
    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        imagesList.clearImagesList();
        imagesList.imagePaths.addAll(images);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectedImages(images: images),
          ),
        );
      }
    }
  }

  void captureCameraImages() async {
    PermissionStatus status = await cameraPermissionStatus();
    if (status.isGranted) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        imagesList.clearImagesList();
        imagesList.imagePaths.add(image);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectedImages(images: [image]),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Images To Pdf"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MaterialButton(
              color: Colors.teal,
              textColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              onPressed: pickGalleryImage,
              child: const Text("Gallery Images"),
            ),
            const Gap(10),
            MaterialButton(
              color: Colors.teal,
              textColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              onPressed: captureCameraImages,
              child: const Text("Capture Image"),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectedImages extends StatelessWidget {
  final List<XFile> images;

  const SelectedImages({super.key, required this.images});

  Future<Uint8List> _generatePdf(List<XFile> images) async {
    final pdf = pw.Document();

    for (final image in images) {
      final bytes = await image.readAsBytes();
      final imageData = img.decodeImage(bytes);

      if (imageData != null) {
        final resizedImage = img.copyResize(imageData, width: 500);
        final jpegBytes = img.encodeJpg(resizedImage);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(
                  pw.MemoryImage(jpegBytes),
                  fit: pw.BoxFit.contain,
                ),
              );
            },
          ),
        );
      }
    }

    return pdf.save();
  }

  Future<void> _savePdf() async {
    final Uint8List pdfBytes = await _generatePdf(images);
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File('${dir.path}/images.pdf');
    await file.writeAsBytes(pdfBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selected Images'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await _savePdf();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF saved to documents folder')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final pdfBytes = await _generatePdf(images);
              await Printing.sharePdf(bytes: pdfBytes, filename: 'images.pdf');
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Image.file(File(images[index].path), fit: BoxFit.cover);
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
//     import 'package:gap/gap.dart';
//     import 'package:image_picker/image_picker.dart';
//     import 'package:permission_handler/permission_handler.dart';

//     import 'images_list.dart'; // Import local images_list.dart
//     import 'pdf_preview_page.dart'; // Import the preview page

//     class MainPage extends StatefulWidget {
//       const MainPage({super.key});

//       @override
//       State<MainPage> createState() => _MainPageState();
//     }

//     class _MainPageState extends State<MainPage> {
//       final ImagesList imagesList = ImagesList(); // Use the singleton instance

//       // Helper function to request permissions
//       Future<bool> _requestPermission(Permission permission) async {
//         PermissionStatus status = await permission.status;
//         if (!status.isGranted) {
//           status = await permission.request();
//         }
//         // Check again after requesting
//         if (!status.isGranted) {
//            if (mounted) {
//              ScaffoldMessenger.of(context).showSnackBar(
//                SnackBar(content: Text('${permission.toString().split('.').last} permission denied')),
//              );
//            }
//            return false;
//         }
//         return true;
//       }

//       Future<void> _pickGalleryImages() async {
//         // Request photos permission (preferred for gallery)
//         bool photosGranted = await _requestPermission(Permission.photos);
//         // Fallback for older Android if photos permission isn't sufficient/available
//         if (!photosGranted) {
//            bool storageGranted = await _requestPermission(Permission.storage);
//            if (!storageGranted) return; // Exit if no permission
//         }

//         final ImagePicker picker = ImagePicker();
//         try {
//           final List<XFile> images = await picker.pickMultiImage();

//           if (images.isNotEmpty) {
//             imagesList.clearImagesList(); // Clear previous selections
//             imagesList.addAllImages(images);

//             if (!mounted) return;
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const PdfPreviewPage()), // Navigate to preview page
//             );
//           } else {
//              if (!mounted) return;
//              ScaffoldMessenger.of(context).showSnackBar(
//                const SnackBar(content: Text('No images selected from gallery')),
//              );
//           }
//         } catch (e) {
//            if (!mounted) return;
//            ScaffoldMessenger.of(context).showSnackBar(
//              SnackBar(content: Text('Error picking images: $e')),
//            );
//         }
//       }

//       Future<void> _captureCameraImage() async {
//         bool cameraGranted = await _requestPermission(Permission.camera);
//         if (!cameraGranted) return; // Exit if no permission

//         final ImagePicker picker = ImagePicker();
//         try {
//           final XFile? image = await picker.pickImage(source: ImageSource.camera);

//           if (image != null) {
//             imagesList.clearImagesList(); // Clear previous selections
//             imagesList.addImage(image); // Add the single captured image

//             if (!mounted) return;
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const PdfPreviewPage()), // Navigate to preview page
//             );
//           } else {
//              if (!mounted) return;
//              ScaffoldMessenger.of(context).showSnackBar(
//                const SnackBar(content: Text('No image captured')),
//              );
//           }
//         } catch (e) {
//            if (!mounted) return;
//            ScaffoldMessenger.of(context).showSnackBar(
//              SnackBar(content: Text('Error capturing image: $e')),
//            );
//         }
//       }

//       @override
//       Widget build(BuildContext context) {
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text("Images To Pdf"),
//             centerTitle: true,
//             backgroundColor: Colors.teal,
//             foregroundColor: Colors.white,
//           ),
//           body: Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 MaterialButton(
//                   color: Colors.teal,
//                   textColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//                   onPressed: _pickGalleryImages,
//                   child: const Text("Select Gallery Images"),
//                 ),
//                 const Gap(20), // Increased gap
//                 MaterialButton(
//                   color: Colors.teal,
//                   textColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//                   onPressed: _captureCameraImage,
//                   child: const Text("Capture Camera Image"),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }
//     }
