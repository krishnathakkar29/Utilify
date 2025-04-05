import 'dart:io';
import 'package:codeshastra_app/pdf_tools/services/pdf_api_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;

class RotateSection extends StatefulWidget {
  const RotateSection({super.key});

  @override
  State<RotateSection> createState() => _RotateSectionState();
}

class _RotateSectionState extends State<RotateSection> {
  final PdfApiService _apiService = PdfApiService();
  File? _selectedFile;
  int _selectedAngle = 90; // Default angle
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

  Future<void> _rotateFile() async {
    if (_selectedFile == null) {
      setState(() {
        _errorMessage = "Please select a PDF file to rotate.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final resultPath = await _apiService.rotatePdf(
        _selectedFile!,
        _selectedAngle,
      );
      if (resultPath != null) {
        setState(() {
          _successMessage = "File rotated successfully!";
          _selectedFile = null; // Clear selection
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rotated PDF saved to temporary location.'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => OpenFile.open(resultPath),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        setState(() {
          _errorMessage = "Failed to rotate file. API did not return a path.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error rotating file: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // backgroundColor:
    // Theme.of(context).primaryColorDark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Rotate PDF File',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.file_upload, color: Colors.black, size: 20),
            label: const Text(
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
          Text(
            'Select Rotation Angle (Clockwise):',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            value: _selectedAngle,
            items:
                [90, 180, 270].map((int angle) {
                  return DropdownMenuItem<int>(
                    value: angle,
                    child: Text('$angle Degrees'),
                  );
                }).toList(),
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedAngle = newValue;
                });
              }
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.rotate_right),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).inputDecorationTheme.fillColor,
            ),
            dropdownColor: Theme.of(context).cardColor,
          ),
          const SizedBox(height: 25),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton.icon(
              icon: const Icon(Icons.rotate_90_degrees_ccw),
              label: const Text('Rotate File'),
              onPressed: _selectedFile == null ? null : _rotateFile,
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
    );
  }
}
