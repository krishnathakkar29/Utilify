import 'dart:io';
import 'package:codeshastra_app/pdf_tools/services/pdf_api_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;

class MergeSection extends StatefulWidget {
  const MergeSection({super.key});

  @override
  State<MergeSection> createState() => _MergeSectionState();
}

class _MergeSectionState extends State<MergeSection> {
  final PdfApiService _apiService = PdfApiService();
  List<File> _selectedFiles = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _pickFiles() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.paths.map((path) => File(path!)).toList();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error picking files: $e";
      });
    }
  }

  Future<void> _mergeFiles() async {
    if (_selectedFiles.length < 2) {
      setState(() {
        _errorMessage = "Please select at least two PDF files to merge.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final resultPath = await _apiService.mergePdfs(_selectedFiles);
      if (resultPath != null) {
        setState(() {
          _successMessage = "Files merged successfully!";
          _selectedFiles = []; // Clear selection after success
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Merged PDF saved to temporary location.'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => OpenFile.open(resultPath),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        setState(() {
          _errorMessage = "Failed to merge files. API did not return a path.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error merging files: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Merge PDF Files',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.file_upload),
            label: const Text('Select PDFs (2 or more)'),
            onPressed: _isLoading ? null : _pickFiles,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
          const SizedBox(height: 15),
          if (_selectedFiles.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Files (${_selectedFiles.length}):',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _selectedFiles.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '• ${p.basename(_selectedFiles[index].path)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          const SizedBox(height: 25),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton.icon(
              icon: const Icon(Icons.merge_type),
              label: const Text('Merge Files'),
              onPressed: _selectedFiles.length < 2 ? null : _mergeFiles,
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
