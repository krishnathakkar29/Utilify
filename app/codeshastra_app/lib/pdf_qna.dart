import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p; // For basename

class PdfChatScreen extends StatefulWidget {
  const PdfChatScreen({super.key});

  @override
  State<PdfChatScreen> createState() => _PdfChatScreenState();
}

class _PdfChatScreenState extends State<PdfChatScreen> {
  List<PlatformFile> _pickedFiles = [];
  final TextEditingController _questionController = TextEditingController();
  String _apiResponse = '';
  bool _isLoadingProcessing = false;
  bool _isLoadingAsking = false;
  bool _isProcessed = false;
  String _errorMessage = '';

  // --- Configuration ---
  // IMPORTANT: Replace with your actual backend URL
  final String _baseUrl =
      "https://reception-poultry-ec-booking.trycloudflare.com"; // Example: Use localhost for local dev
  // ---------------------

  Future<void> _pickPdfs() async {
    setState(() {
      _errorMessage = ''; // Clear previous errors
      _apiResponse = ''; // Clear previous response
      _isProcessed = false; // Reset processed state
    });
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _pickedFiles = result.files;
        });
      } else {
        // User canceled the picker
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File picking cancelled.')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error picking files: $e";
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking files: $e')));
      }
    }
  }

  Future<void> _askQuestion() async {
    if (!_isProcessed) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please process the PDFs first.')),
        );
      }
      return;
    }

    if (_questionController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a question.')),
        );
      }
      return;
    }

    setState(() {
      _isLoadingAsking = true;
      _errorMessage = '';
      _apiResponse = '';
    });

    final url = Uri.parse('$_baseUrl/ask_question');

    try {
      // Changed to regular http.post with JSON body
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'question': _questionController.text}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _apiResponse = responseData['response'] ?? 'No answer received.';
        });
      } else {
        final responseData = jsonDecode(response.body);
        setState(() {
          _errorMessage = responseData['error'] ?? 'Unknown error occurred';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network or server error while asking: $e";
      });
    } finally {
      setState(() {
        _isLoadingAsking = false;
      });
    }
  }

  Future<void> _processPdfs() async {
    if (_pickedFiles.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select PDF files first.')),
        );
      }
      return;
    }

    setState(() {
      _isLoadingProcessing = true;
      _errorMessage = '';
      _apiResponse = '';
      _isProcessed = false;
    });

    final url = Uri.parse('$_baseUrl/process_pdfs');
    var request = http.MultipartRequest('POST', url);

    // Add files to the request
    for (var file in _pickedFiles) {
      if (file.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'files', // Make sure this matches your Flask backend's expected field name
            file.path!,
            filename: file.name,
          ),
        );
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _apiResponse = responseData['message'] ?? 'Processing successful!';
          _isProcessed = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(_apiResponse)));
        }
      } else {
        final responseData = jsonDecode(response.body);
        setState(() {
          _errorMessage = responseData['error'] ?? 'Unknown error occurred';
          _isProcessed = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network or server error during processing: $e";
        _isProcessed = false;
      });
    } finally {
      setState(() {
        _isLoadingProcessing = false;
      });
    }
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
        title: const Text(
          'PDF Q&A',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColorDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Allows scrolling if content overflows
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- File Picker Section ---
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Select PDFs'),
                onPressed:
                    _isLoadingProcessing || _isLoadingAsking ? null : _pickPdfs,
              ),
              const SizedBox(height: 10),
              if (_pickedFiles.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Selected Files:",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        // Use Wrap for better layout of multiple files
                        spacing: 8.0, // Horizontal space between chips
                        runSpacing: 4.0, // Vertical space between lines
                        children:
                            _pickedFiles
                                .map(
                                  (file) => Chip(
                                    label: Text(
                                      p.basename(file.name),
                                    ), // Use path.basename
                                    onDeleted:
                                        _isLoadingProcessing || _isLoadingAsking
                                            ? null
                                            : () {
                                              setState(() {
                                                _pickedFiles.remove(file);
                                                _isProcessed =
                                                    false; // Need to reprocess if files change
                                                _apiResponse = '';
                                                _errorMessage = '';
                                              });
                                            },
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // --- Process Button ---
              if (_pickedFiles.isNotEmpty)
                ElevatedButton.icon(
                  icon:
                      _isLoadingProcessing
                          ? Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(2.0),
                            child: const CircularProgressIndicator(
                              strokeWidth: 3,
                            ),
                          )
                          : const Icon(Icons.cloud_upload),
                  label: const Text('Process PDFs'),
                  onPressed:
                      _isLoadingProcessing || _isLoadingAsking
                          ? null
                          : _processPdfs,
                ),
              const SizedBox(height: 20),

              // --- Question Input Section ---
              TextField(
                controller: _questionController,
                style: TextStyle(
                  // 👈 this sets the input text color
                  color: Theme.of(context).primaryColor,
                ),
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                  hintStyle: TextStyle(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                  labelText: 'Ask a question about the PDFs',
                  hintText: 'Enter your question here...',
                ),
                enabled:
                    _isProcessed &&
                    !_isLoadingAsking, // Enable only after processing
                maxLines: 3, // Allow multi-line questions
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon:
                    _isLoadingAsking
                        ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            strokeWidth: 3,
                          ),
                        )
                        : const Icon(Icons.question_answer),
                label: const Text('Ask Question'),
                onPressed:
                    _isProcessed && !_isLoadingAsking && !_isLoadingProcessing
                        ? _askQuestion
                        : null, // Enable only when ready
              ),
              const SizedBox(height: 20),

              // --- Response/Error Display Section ---
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Error: $_errorMessage',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (_apiResponse.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLoadingAsking
                            ? "Thinking..."
                            : (_isProcessed &&
                                    _apiResponse.contains('successful')
                                ? "Processing Status:"
                                : "Answer:"), // Better context label
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _apiResponse,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}
