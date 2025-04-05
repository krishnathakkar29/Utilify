import 'dart:io';
import 'package:codeshastra_app/pdf_tools/services/pdf_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;

class SplitSection extends StatefulWidget {
  const SplitSection({super.key});

  @override
  State<SplitSection> createState() => _SplitSectionState();
}

class _SplitSectionState extends State<SplitSection> {
  final PdfApiService _apiService = PdfApiService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _startPageController = TextEditingController();
  final TextEditingController _endPageController = TextEditingController();

  File? _selectedFile;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _pickFile() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
      _selectedFile = null; // Reset previous selection
    });
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error picking file: $e";
      });
    }
  }

  Future<void> _splitFile() async {
    if (_selectedFile == null) {
      setState(() {
        _errorMessage = "Please select a PDF file to split.";
      });
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return; // Validation failed
    }

    final int startPage = int.parse(_startPageController.text);
    final int endPage = int.parse(_endPageController.text);

    if (startPage <= 0 || endPage <= 0 || startPage > endPage) {
      setState(() {
        _errorMessage =
            "Invalid page range. Start page must be >= 1 and less than or equal to end page.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final resultPath = await _apiService.splitPdf(
        _selectedFile!,
        startPage,
        endPage,
      );
      if (resultPath != null) {
        setState(() {
          _successMessage = "File split successfully!";
          _selectedFile = null; // Clear selection
          _startPageController.clear();
          _endPageController.clear();
          _formKey.currentState?.reset();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Split PDF saved to temporary location.'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => OpenFile.open(resultPath),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        setState(() {
          _errorMessage = "Failed to split file. API did not return a path.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error splitting file: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _startPageController.dispose();
    _endPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // backgroundColor:
    // Theme.of(context).primaryColorDark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Split PDF File',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(
                Icons.file_upload,
                color: Colors.black,
                size: 20,
              ),
              label: Text(
                'Select PDF',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              onPressed: _isLoading ? null : _pickFile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            const SizedBox(height: 15),
            if (_selectedFile != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Selected: ${p.basename(_selectedFile!.path)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _startPageController,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ), // text color
              decoration: InputDecoration(
                labelText: 'Start Page',
                labelStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                ), // label color
                hintText: 'e.g., 1',
                hintStyle: TextStyle(
                  color: Theme.of(context).primaryColor.withOpacity(0.6),
                ), // hint color
                prefixIcon: Icon(
                  Icons.first_page,
                  color: Theme.of(context).primaryColor, // icon color
                  size: 20,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter start page';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'Invalid page number';
                }
                return null;
              },
            ),

            const SizedBox(height: 15),
            TextFormField(
              controller: _endPageController,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ), // text color
              decoration: InputDecoration(
                labelText: 'End Page',
                labelStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                ), // label color
                hintText: 'e.g., 1',
                hintStyle: TextStyle(
                  color: Theme.of(context).primaryColor.withOpacity(0.6),
                ), // hint color
                prefixIcon: Icon(
                  Icons.last_page,
                  color: Theme.of(context).primaryColor, // icon color
                  size: 20,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter end page';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'Invalid page number';
                }
                return null;
              },
            ),

            // TextFormField(
            //   controller: _endPageController,
            //   decoration: const InputDecoration(
            //     labelText: 'End Page',
            //     hintText: 'e.g., 5',
            //     prefixIcon: Icon(Icons.last_page),
            //   ),
            //   keyboardType: TextInputType.number,
            //   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return 'Please enter end page';
            //     }
            //     if (int.tryParse(value) == null || int.parse(value) <= 0) {
            //       return 'Invalid page number';
            //     }
            //     // Optional: Add cross-field validation in the _splitFile method
            //     return null;
            //   },
            // ),
            const SizedBox(height: 25),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.splitscreen),
                label: const Text('Split File'),
                onPressed: _selectedFile == null ? null : _splitFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            if (_successMessage != null)
              Text(
                _successMessage!,
                style: TextStyle(color: Colors.greenAccent[400]),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
