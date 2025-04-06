// import 'package:codeshastra_app/video_apiservice.dart';
import 'package:codeshastra_app/video_converter/video_apiservice.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
// import '../services/api_service.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class VideoConverterScreen extends StatefulWidget {
  const VideoConverterScreen({super.key});

  @override
  State<VideoConverterScreen> createState() => _VideoConverterScreenState();
}

class _VideoConverterScreenState extends State<VideoConverterScreen> {
  final ApiService _apiService = ApiService();
  PlatformFile? _selectedFile;
  String _statusMessage = 'Select a video and choose a conversion format.';
  bool _isLoading = false;
  String? _lastSavedFilePath;
  String? _selectedFormat;

  // List of supported video formats (example)
  final List<String> _supportedFormats = [
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm',
    'flv',
  ];

  // Request storage permission if needed
  Future<void> _checkPermissions() async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
    // Add other permissions if needed, e.g., manageExternalStorage for broader access
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _pickVideo() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Picking video...';
      _selectedFile = null;
      _lastSavedFilePath = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video, // Or use custom with allowedExtensions
        // allowedExtensions: _supportedFormats, // Uncomment if using FileType.custom
        withData: true, // Be cautious with large files
      );

      if (result != null && result.files.isNotEmpty) {
        // For large files, consider using result.files.single.path instead of bytes
        if (result.files.single.bytes != null ||
            result.files.single.path != null) {
          setState(() {
            _selectedFile = result.files.single;
            _statusMessage = 'Video selected: ${_selectedFile!.name}';
          });
        } else {
          setState(() {
            _statusMessage = 'Error: Could not read video data or path.';
            _selectedFile = null;
          });
        }
      } else {
        setState(() {
          _statusMessage = 'Video selection cancelled.';
          _selectedFile = null;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error picking video: $e';
        _selectedFile = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _convertVideo() async {
    if (_selectedFile == null) {
      // Check path or bytes depending on how you handle large files
      setState(() {
        _statusMessage = 'Please select a valid video first.';
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
      // *** IMPORTANT: Ensure ApiService has a convertVideo method ***
      // This method should handle file upload (potentially streaming for large files)
      // and return the path/details of the converted file.
      final result = await _apiService.convertVideo(
        _selectedFile!, // Pass the PlatformFile
        _selectedFormat!,
      );

      if (result['success'] == true && result['filePath'] != null) {
        setState(() {
          _statusMessage =
              'Conversion successful!\nVideo saved to Downloads folder\nFilename: ${result['fileName']}';
          _lastSavedFilePath = result['filePath'];
        });

        _showSuccessDialog(result['filePath'], result['fileName']);
      } else {
        setState(() {
          _statusMessage =
              result['message'] ?? 'Conversion failed or file not saved.';
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
          title: const Text('Video Converted Successfully'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your video has been saved as:\n$fileName'),
              const SizedBox(height: 10),
              const Text('You can find it in your Downloads folder.'),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'Open Video',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _openFile(filePath);
              },
            ),
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(color: Theme.of(context).primaryColor),
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
        // Show a snackbar or update status message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open video: ${result.message}')),
        );
        setState(() {
          _statusMessage = 'Could not open video: ${result.message}';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening video: $e')));
      setState(() {
        _statusMessage = 'Error opening video: $e';
      });
    }
  }

  String _getFileExtension(String fileName) {
    try {
      return fileName.split('.').last.toLowerCase();
    } catch (e) {
      return ''; // Handle cases where there might not be an extension
    }
  }

  @override
  Widget build(BuildContext context) {
    String? currentFormat =
        _selectedFile != null ? _getFileExtension(_selectedFile!.name) : null;

    List<String> availableFormats =
        _supportedFormats.where((format) => format != currentFormat).toList();

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
          'Video Converter',
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 24),
        ),
        backgroundColor: Theme.of(context).primaryColorDark,
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
                        Icons.video_library, // Changed Icon
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
                          icon: const Icon(Icons.movie), // Changed Icon
                          label: const Text('Open Converted Video'),
                          onPressed: () => _openFile(_lastSavedFilePath!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD0E8B5),
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
                        'Select Video', // Changed Text
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: _pickVideo, // Changed method call
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
                                // Consider adding styling for selected/unselected chips
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.swap_horiz),
                        label: const Text(
                          'Convert Video',
                          // style: TextStyle(color: Colors.white),
                        ), // Changed Text
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFD0E8B5),
                          foregroundColor: Colors.black,
                        ),
                        onPressed:
                            _selectedFormat == null
                                ? null
                                : _convertVideo, // Changed method call
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
