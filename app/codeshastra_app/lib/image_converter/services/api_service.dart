import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ImageConverterScreen(),
    ),
  );
}

class ImageConverterScreen extends StatefulWidget {
  @override
  State<ImageConverterScreen> createState() => _ImageConverterScreenState();
}

class _ImageConverterScreenState extends State<ImageConverterScreen> {
  String? _status;
  bool _isLoading = false;

  void _pickAndConvertImage() async {
    setState(() {
      _status = null;
      _isLoading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        // Choose format (change this to allow user selection)
        String targetFormat = 'png';

        final response = await ApiService().convertImage(file, targetFormat);

        setState(() {
          _status = "✅ Saved to: ${response['filePath']}";
        });
      } else {
        setState(() {
          _status = "❌ No image selected";
        });
      }
    } catch (e) {
      setState(() {
        _status = "❌ Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image Converter")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.image),
              label: Text("Pick and Convert Image"),
              onPressed: _isLoading ? null : _pickAndConvertImage,
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            if (_status != null) Text(_status!),
          ],
        ),
      ),
    );
  }
}

class ApiService {
  final String _baseUrl =
      "https://reception-poultry-ec-booking.trycloudflare.com";

  Future<Map<String, dynamic>> convertImage(
    PlatformFile file,
    String targetFormat,
  ) async {
    if (file.bytes == null) {
      throw Exception("Image file data is null. Cannot upload.");
    }

    final uri = Uri.parse('$_baseUrl/convert_img');

    var request = http.MultipartRequest('POST', uri);
    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        file.bytes!,
        filename: file.name,
        contentType: MediaType('image', _getImageMimeType(file.name)),
      ),
    );

    request.fields['format'] = targetFormat;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final fileName = 'converted.$targetFormat';
      Uint8List fileBytes = response.bodyBytes;

      String? filePath = await _saveFileToDownloads(fileBytes, fileName);
      if (filePath != null) {
        await OpenFile.open(filePath);
      }

      return {
        'success': true,
        'filePath': filePath,
        'fileName': fileName,
        'fileBytes': fileBytes,
      };
    } else {
      final errorMsg = Uri.decodeFull(response.body);
      throw Exception("Failed to convert image: $errorMsg");
    }
  }

  String _getImageMimeType(String fileName) {
    if (fileName.endsWith('.png')) return 'png';
    if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) return 'jpeg';
    if (fileName.endsWith('.webp')) return 'webp';
    if (fileName.endsWith('.bmp')) return 'bmp';
    if (fileName.endsWith('.gif')) return 'gif';
    if (fileName.endsWith('.tiff')) return 'tiff';
    return 'jpeg';
  }

  Future<String?> _saveFileToDownloads(Uint8List bytes, String fileName) async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt < 29) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            throw Exception("Storage permission is required to save files");
          }
        }
      }

      Directory downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      final filePath = '${downloadsDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      await _scanFile(filePath);
      return filePath;
    } catch (e) {
      print('Error saving image: $e');

      try {
        final directory = await getApplicationDocumentsDirectory();
        final fallbackPath = '${directory.path}/$fileName';
        final file = File(fallbackPath);
        await file.writeAsBytes(bytes);
        return fallbackPath;
      } catch (e) {
        print('Fallback save also failed: $e');
        return null;
      }
    }
  }

  Future<void> _scanFile(String filePath) async {
    print("File saved at: $filePath");
    // Optionally scan file for gallery
  }
}
