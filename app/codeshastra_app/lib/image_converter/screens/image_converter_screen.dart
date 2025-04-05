import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class ImageConverterScreen extends StatefulWidget {
  const ImageConverterScreen({super.key});

  @override
  State<ImageConverterScreen> createState() => _ImageConverterScreenState();
}

class _ImageConverterScreenState extends State<ImageConverterScreen> {
  final ApiService _apiService = ApiService();
  PlatformFile? _selectedFile;
  String _statusMessage = 'Select an image and choose a conversion format.';
  bool _isLoading = false;
  String? _lastSavedFilePath;
  String? _selectedFormat;

  // List of supported image formats
  final List<String> _supportedFormats = [
    'jpeg',
    'jpg',
    'png',
    'webp',
    'bmp',
    'gif',
    'tiff',
  ];

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

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Picking image...';
      _selectedFile = null;
      _lastSavedFilePath = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _supportedFormats,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        if (result.files.single.bytes != null) {
          setState(() {
            _selectedFile = result.files.single;
            _statusMessage = 'Image selected: ${_selectedFile!.name}';
          });
        } else {
          setState(() {
            _statusMessage = 'Error: Could not read image data.';
            _selectedFile = null;
          });
        }
      } else {
        setState(() {
          _statusMessage = 'Image selection cancelled.';
          _selectedFile = null;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error picking image: $e';
        _selectedFile = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _convertImage() async {
    if (_selectedFile == null || _selectedFile!.bytes == null) {
      setState(() {
        _statusMessage = 'Please select a valid image first.';
      });
      return;
    }

    if (_selectedFormat == null) {
      setState(() {
        _statusMessage = 'Please select a target format.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Uploading and converting...';
      _lastSavedFilePath = null;
    });

    try {
      final result = await _apiService.convertImage(
        _selectedFile!,
        _selectedFormat!,
      );

      if (result['success'] == true && result['filePath'] != null) {
        setState(() {
          _statusMessage =
              'Conversion successful!\nImage saved to Downloads folder\nFilename: ${result['fileName']}';
          _lastSavedFilePath = result['filePath'];
        });

        _showSuccessDialog(result['filePath'], result['fileName']);
      } else {
        setState(() {
          _statusMessage =
              'Conversion completed, but image could not be saved to Downloads.';
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
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text('Image Converted Successfully'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your image has been saved as:\n$fileName'),
              const SizedBox(height: 10),
              const Text('You can find it in your Downloads folder.'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                'Open Image',
                style: TextStyle(color: Color(0xFFD0E8B5)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _openFile(filePath);
              },
            ),
            TextButton(
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFFD0E8B5)),
              ),
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
          _statusMessage = 'Could not open image: ${result.message}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error opening image: $e';
      });
    }
  }

  String _getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    // Get current format of selected file
    String? currentFormat =
        _selectedFile != null ? _getFileExtension(_selectedFile!.name) : null;

    // Filter out the current format from available formats
    List<String> availableFormats =
        _supportedFormats
            .where(
              (format) =>
                  format != currentFormat &&
                  !(format == 'jpg' && currentFormat == 'jpeg') &&
                  !(format == 'jpeg' && currentFormat == 'jpg'),
            )
            .toList();

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
          'Image Converter',
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 24),
        ),
        backgroundColor: Theme.of(context).primaryColorDark,
        // foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                        Icons.image,
                        size: 50,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (_selectedFile != null) ...[
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Selected: ${_selectedFile!.name}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                      if (_lastSavedFilePath != null) ...[
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.image),
                          label: const Text('Open Converted Image'),
                          onPressed: () => _openFile(_lastSavedFilePath!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFD0E8B5),
                            foregroundColor: Colors.black,
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
                      icon: const Icon(Icons.file_upload, color: Colors.black),
                      label: const Text(
                        'Select Image',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: _pickImage,
                    ),
                    const SizedBox(height: 20),
                    if (_selectedFile != null) ...[
                      Text(
                        'Convert to:',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children:
                            availableFormats.map((format) {
                              return ChoiceChip(
                                label: Text(format.toUpperCase()),
                                selected: _selectedFormat == format,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFormat = selected ? format : null;
                                  });
                                },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.swap_horiz),
                        label: const Text('Convert Image'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Color(0xFFD0E8B5),
                          foregroundColor: Colors.black,
                        ),
                        onPressed:
                            _selectedFormat == null ? null : _convertImage,
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
