import 'dart:io';
    import 'dart:typed_data'; // Required for Uint8List
    import 'package:flutter/material.dart';
    import 'package:image_picker/image_picker.dart';
    import 'package:pdf/pdf.dart';
    import 'package:pdf/widgets.dart' as pw;
    import 'package:printing/printing.dart';

    import 'images_list.dart'; // Import local images_list.dart

    class PdfPreviewPage extends StatefulWidget {
      const PdfPreviewPage({super.key});

      @override
      State<PdfPreviewPage> createState() => _PdfPreviewPageState();
    }

    class _PdfPreviewPageState extends State<PdfPreviewPage> {
      final ImagesList imagesList = ImagesList(); // Use the singleton instance
      bool _isGenerating = false;

      // Generates PDF bytes asynchronously
      Future<Uint8List> _generatePdf(PdfPageFormat format) async {
        final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
        final List<XFile> images = imagesList.imagePaths;

        for (var imageFile in images) {
          final imageBytes = await File(imageFile.path).readAsBytes();
          final image = pw.MemoryImage(imageBytes);

          // Check if image data is valid before adding page
          // (Basic check, pw.MemoryImage might handle some errors internally)
          if (imageBytes.isNotEmpty) {
             pdf.addPage(
               pw.Page(
                 pageFormat: format,
                 build: (pw.Context context) {
                   // Center the image on the page
                   return pw.Center(
                     child: pw.Image(image, fit: pw.BoxFit.contain), // Use contain to avoid stretching
                   );
                 },
               ),
             );
          } else {
             print("Warning: Skipping empty or invalid image file: ${imageFile.path}");
          }
        }

        // Save the PDF document to bytes
        return pdf.save();
      }

      // Shares the generated PDF
      void _sharePdf() async {
        if (imagesList.imagePaths.isEmpty) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('No images to convert')),
           );
           return;
        }

        setState(() {
          _isGenerating = true; // Show progress indicator
        });

        try {
          // Generate PDF bytes
          final pdfBytes = await _generatePdf(PdfPageFormat.a4);

          // Use printing package to share the PDF
          await Printing.sharePdf(
              bytes: pdfBytes,
              filename: 'images_to_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf'
          );

        } catch (e) {
           if(mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Error generating/sharing PDF: $e')),
             );
           }
           print("Error generating/sharing PDF: $e"); // Log error for debugging
        } finally {
           if(mounted) {
             setState(() {
               _isGenerating = false; // Hide progress indicator regardless of success/failure
             });
           }
        }
      }

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Preview & Generate PDF'),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            actions: [
              // Show progress indicator or share button
              if (_isGenerating)
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                )
              else
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'Generate & Share PDF',
                  onPressed: _sharePdf, // Call the share function
                ),
            ],
          ),
          body: imagesList.imagePaths.isEmpty
              ? const Center(child: Text('No images selected. Go back to select images.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Adjust number of columns as needed
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: imagesList.imagePaths.length,
                  itemBuilder: (context, index) {
                    final imageFile = imagesList.imagePaths[index];
                    // Display image preview
                    return GridTile(
                      footer: GridTileBar( // Add footer to show image number
                         backgroundColor: Colors.black45,
                         title: Text(
                           'Image ${index + 1}',
                           textAlign: TextAlign.center,
                           style: const TextStyle(fontSize: 10, color: Colors.white),
                         ),
                      ),
                      child: Image.file(
                        File(imageFile.path),
                        fit: BoxFit.cover, // Cover the grid tile area
                        errorBuilder: (context, error, stackTrace) {
                           // Show placeholder if image fails to load
                           return Container(
                             color: Colors.grey[300],
                             child: const Center(child: Icon(Icons.error_outline, color: Colors.red)),
                           );
                        },
                      ),
                    );
                  },
                ),
        );
      }
    }
