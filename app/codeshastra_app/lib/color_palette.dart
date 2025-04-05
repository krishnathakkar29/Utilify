import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class ColorPalette extends StatefulWidget {
  const ColorPalette({super.key});

  @override
  State<ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<ColorPalette> {
  File? _image;
  bool _isLoading = false;
  List<ColorInfo> _extractedColors = [];
  String? _error;

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _image = File(image.path);
          _error = null;
          _extractedColors = [];
        });
        await _extractColors();
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _extractColors() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Update the URL to include explicit protocol and host
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://reception-poultry-ec-booking.trycloudflare.com/extract-colors',
        ), // Use 10.0.2.2 for Android emulator
      );

      // Add headers for CORS
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath('image', _image!.path),
      );

      var response = await request.send();
      print('Response status code: ${response.statusCode}'); // Debug log

      var responseData = await response.stream.bytesToString();
      print('Response data: $responseData'); // Debug log

      var jsonData = json.decode(responseData);

      if (response.statusCode == 200) {
        setState(() {
          _extractedColors =
              (jsonData['colors'] as List)
                  .map(
                    (color) => ColorInfo(
                      hex: color['hex'],
                      rgb: (color['rgb'] as List).cast<int>(),
                      pixels: color['pixels'],
                    ),
                  )
                  .toList();
        });
      } else {
        setState(() {
          _error =
              'Failed to extract colors: ${jsonData['error'] ?? 'Unknown error'}';
        });
      }
    } catch (e) {
      print('Error details: $e'); // Debug log
      setState(() {
        _error = 'Error: $e';
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
      backgroundColor: Theme.of(context).primaryColorDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Color Palette Generator',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _buildImageSection(),
                if (_error != null) _buildErrorWidget(),
                if (_isLoading) _buildLoadingWidget(),
                if (_extractedColors.isNotEmpty) _buildColorsGrid(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickImage,
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Pick Image'),
        backgroundColor: Colors.blue[700],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child:
          _image == null
              ? Center(
                child: Text(
                  'No image selected',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
              : ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(_image!, fit: BoxFit.cover),
              ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Text(_error!, style: TextStyle(color: Colors.red[700])),
    );
  }

  Widget _buildColorsGrid() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Extracted Colors',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: _extractedColors.length,
            itemBuilder: (context, index) {
              final color = _extractedColors[index];
              return _buildColorCard(color);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorCard(ColorInfo color) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: color.hex));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${color.hex} copied to clipboard')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(
                    color.rgb[0],
                    color.rgb[1],
                    color.rgb[2],
                    1,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    color.hex,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${(color.pixels / 1000).toStringAsFixed(1)}K pixels',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorInfo {
  final String hex;
  final List<int> rgb;
  final int pixels;

  ColorInfo({required this.hex, required this.rgb, required this.pixels});
}
