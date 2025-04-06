import 'package:codeshastra_app/audio_converter/audio_apiservice.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
// Import the dedicated audio API service
// import '../services/audio_api_service.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class AudioConverterScreen extends StatefulWidget {
  const AudioConverterScreen({super.key});

  @override
  State<AudioConverterScreen> createState() => _AudioConverterScreenState();
}

class _AudioConverterScreenState extends State<AudioConverterScreen> {
  // Use the dedicated AudioApiService
  final AudioApiService _audioApiService = AudioApiService();
  PlatformFile? _selectedFile;
  String _statusMessage =
      'Select an audio file and choose a conversion format.';
  bool _isLoading = false;
  String? _lastSavedFilePath;
  String? _selectedFormat;

  // List of supported audio formats (example)
  final List<String> _supportedFormats = [
    'mp3',
    'wav',
    'aac',
    'ogg',
    'flac',
    'm4a',
  ];

  // Request storage permission if needed
  Future<void> _checkPermissions() async {
    // Requesting storage permission is complex due to scoped storage on newer Android.
    // Simple `Permission.storage.request()` might not be enough for saving to Downloads.
    // Consider `Permission.manageExternalStorage` (requires strong justification for Play Store)
    // or using MediaStore API via platform channels/plugins.
    // For basic access needed by path_provider's getExternalStorageDirectory:
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        print("Storage permission denied.");
        // Optionally show a message to the user
      }
    }
    // Add other permissions if needed (e.g., audio access if recording)
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _pickAudio() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Picking audio file...';
      _selectedFile = null;
      _lastSavedFilePath = null;
      _selectedFormat = null; // Reset format selection
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        // For large files, `withData: false` is better, rely on `result.files.single.path`
        withData:
            false, // Set to false to prefer path, especially for audio/video
        // allowedExtensions: _supportedFormats, // Uncomment if using FileType.custom
      );

      if (result != null && result.files.isNotEmpty) {
        // Prioritize path, but check bytes as fallback if withData was true
        if (result.files.single.path != null ||
            result.files.single.bytes != null) {
          setState(() {
            _selectedFile = result.files.single;
            _statusMessage = 'Audio selected: ${_selectedFile!.name}';
            // Reset selected format when a new file is picked
            _selectedFormat = null;
            // Automatically select the first available format if desired, or leave null
          });
        } else {
          setState(() {
            _statusMessage = 'Error: Could not get audio file path or data.';
            _selectedFile = null;
          });
        }
      } else {
        setState(() {
          _statusMessage = 'Audio selection cancelled.';
          _selectedFile = null;
        });
      }
    } catch (e) {
      print("Error picking audio: $e");
      setState(() {
        _statusMessage = 'Error picking audio: $e';
        _selectedFile = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _convertAudio() async {
    if (_selectedFile == null) {
      setState(() {
        _statusMessage = 'Please select a valid audio file first.';
      });
      return;
    }
    // Ensure either path or bytes are available based on your API service needs
    if (_selectedFile!.path == null && _selectedFile!.bytes == null) {
      setState(() {
        _statusMessage = 'Selected file has no path or data.';
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
      _statusMessage = 'Processing and converting...'; // Updated message
      _lastSavedFilePath = null;
    });

    try {
      // Call the dedicated audio service method
      final result = await _audioApiService.convertAudio(
        _selectedFile!,
        _selectedFormat!,
      );

      if (result['success'] == true && result['filePath'] != null) {
        setState(() {
          _statusMessage =
              'Conversion successful!\nAudio saved\nFilename: ${result['fileName']}';
          _lastSavedFilePath = result['filePath'];
          // Optionally clear selection after successful conversion
          // _selectedFile = null;
          // _selectedFormat = null;
        });

        _showSuccessDialog(result['filePath'], result['fileName']);
      } else {
        setState(() {
          _statusMessage =
              result['message'] ?? 'Conversion failed or file not saved.';
          _lastSavedFilePath = null; // Ensure no stale path
        });
      }
    } catch (e) {
      print("Error during audio conversion call: $e");
      setState(() {
        _statusMessage = 'Conversion process failed: $e';
        _lastSavedFilePath = null;
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
          backgroundColor: Theme.of(context).primaryColor, // Use theme color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFFD0E8B5)),
              SizedBox(width: 10),
              Text(
                'Audio Converted',
                style: TextStyle(color: Colors.black),
              ), // Use theme text color
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Saved as:', style: TextStyle(color: Colors.grey)),
              Text(
                fileName,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text('Location:', style: TextStyle(color: Colors.grey)),
              // Show only the directory part for brevity if path is long
              Text(
                filePath.substring(0, filePath.lastIndexOf('/')),
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
              // Text('You can find it in your Downloads folder (or app specific folder).', style: TextStyle(color: Colors.white70)),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'Open Audio',
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _openFile(filePath);
              },
            ),
            TextButton(
              child: Text(
                'Close',
                style: TextStyle(color: Theme.of(context).primaryColorDark),
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
      print("Attempting to open file: $filePath");
      final result = await OpenFile.open(filePath);

      if (result.type == ResultType.done) {
        print("File open request sent successfully.");
        // No state change needed here usually, OS handles opening
      } else if (result.type == ResultType.noAppToOpen) {
        print("Error opening file: No application found to open $filePath");
        setState(() {
          _statusMessage = 'No app found to open this audio type.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not open audio: No app available for this file type.',
            ),
          ),
        );
      } else {
        print("Error opening file: ${result.message}");
        setState(() {
          _statusMessage = 'Could not open audio: ${result.message}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open audio: ${result.message}')),
        );
      }
    } catch (e) {
      print("Exception opening file: $e");
      setState(() {
        _statusMessage = 'Error opening audio: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening audio: $e')));
    }
  }

  String _getFileExtension(String fileName) {
    try {
      if (fileName.contains('.')) {
        return fileName.split('.').last.toLowerCase();
      }
      return ''; // No extension found
    } catch (e) {
      print("Error getting file extension: $e");
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    String? currentFormat =
        _selectedFile != null ? _getFileExtension(_selectedFile!.name) : null;

    // Filter out the current format from available formats
    List<String> availableFormats =
        _supportedFormats.where((format) => format != currentFormat).toList();

    // Ensure _selectedFormat is valid if a file is selected
    if (_selectedFile != null &&
        _selectedFormat != null &&
        !availableFormats.contains(_selectedFormat!)) {
      // If the current format was previously selected but is no longer available (e.g., file changed), reset it
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Check if the widget is still in the tree
          setState(() {
            _selectedFormat = null;
          });
        }
      });
    }

    return Scaffold(
      // Use theme colors
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          // Use theme icon color
          child: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
        ),
        centerTitle: true,
        title: Text(
          'Audio Converter',
          // Use theme text style
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColorDark,
        elevation: 0, // Flat app bar
      ),
      body: Center(
        child: SingleChildScrollView(
          // Allow scrolling if content overflows
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Card(
                  elevation: 4,
                  color: Theme.of(context).cardColor, // Use theme card color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.audiotrack,
                          size: 50,
                          // Use theme secondary color
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          _statusMessage,
                          textAlign: TextAlign.center,
                          // Use theme text style
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                        if (_selectedFile != null) ...[
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              // Use theme surface variant color
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Selected: ${_selectedFile!.name}',
                              // Use theme body medium style
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).indicatorColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        if (_lastSavedFilePath != null) ...[
                          const SizedBox(height: 15),
                          ElevatedButton.icon(
                            icon: const Icon(
                              Icons.play_circle_fill,
                              color: Colors.black,
                            ),
                            label: const Text(
                              'Open Converted Audio',
                              style: TextStyle(color: Colors.black),
                            ),
                            onPressed: () => _openFile(_lastSavedFilePath!),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFFD0E8B5,
                              ), // Keep specific button color
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                        icon: const Icon(
                          Icons.file_upload,
                          color: Colors.black,
                        ),
                        label: const Text(
                          'Select Audio File',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          // Use theme primary color for button
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor:
                              Colors.black, // Explicit text color contrast
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _pickAudio,
                      ),
                      const SizedBox(height: 20),
                      // Only show format selection and convert button if a file is selected
                      if (_selectedFile != null) ...[
                        Text(
                          'Convert to:',
                          style: TextStyle(
                            // Use theme primary color
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8, // Reduced spacing
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children:
                              availableFormats.map((format) {
                                bool isSelected = _selectedFormat == format;
                                return ChoiceChip(
                                  label: Text(format.toUpperCase()),
                                  selected: isSelected,
                                  // Use theme colors for chip
                                  selectedColor: Theme.of(context).primaryColor,
                                  backgroundColor:
                                      Theme.of(
                                        context,
                                      ).chipTheme.backgroundColor,
                                  labelStyle: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.black
                                            : Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedFormat =
                                          selected ? format : null;
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color:
                                          isSelected
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey.shade400,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.swap_horiz,
                            color: Colors.black,
                          ),
                          label: const Text(
                            'Convert Audio',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: const Color(
                              0xFFD0E8B5,
                            ), // Keep specific button color
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            // Disable button if no format is selected
                            disabledBackgroundColor: Colors.grey.shade400,
                          ),
                          // Disable onPressed if no format is selected or if loading
                          onPressed:
                              (_selectedFormat == null || _isLoading)
                                  ? null
                                  : _convertAudio,
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
