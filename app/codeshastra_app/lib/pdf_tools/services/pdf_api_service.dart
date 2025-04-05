import 'dart:io';
// import 'package:dio/dio.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PdfApiService {
  // IMPORTANT: Replace with your actual backend URL
  // If running Flask locally and using Android Emulator: 'http://10.0.2.2:5000'
  // If running Flask locally and using iOS Simulator or physical device: Use your machine's local IP address (e.g., 'http://192.168.1.100:5000')
  final String _baseUrl =
      'https://reception-poultry-ec-booking.trycloudflare.com/'; // <-- CHANGE THIS
  final Dio _dio = Dio();

  Future<String?> _downloadFile(Response response, String operation) async {
    if (response.statusCode == 200) {
      final directory = await getTemporaryDirectory();
      // Extract filename from content-disposition header if available
      String filename =
          '${operation}_output_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final header = response.headers.value('content-disposition');
      if (header != null) {
        final match = RegExp('filename="?([^"]+)"?').firstMatch(header);
        if (match != null && match.groupCount > 0) {
          filename = match.group(1)!;
        }
      }
      final filePath = p.join(directory.path, filename);
      final file = File(filePath);
      await file.writeAsBytes(response.data as List<int>);
      return filePath;
    } else {
      throw Exception(
        'API Error: ${response.statusCode} ${response.statusMessage}',
      );
    }
  }

  Future<String?> mergePdfs(List<File> files) async {
    try {
      final formData = FormData();
      for (var file in files) {
        formData.files.add(
          MapEntry(
            'files', // Must match the key expected by the backend ('files')
            await MultipartFile.fromFile(
              file.path,
              filename: p.basename(file.path),
            ),
          ),
        );
      }

      final response = await _dio.post(
        '$_baseUrl/merge',
        data: formData,
        options: Options(
          responseType: ResponseType.bytes, // Important for receiving file data
        ),
      );
      return _downloadFile(response, 'merged');
    } on DioException catch (e) {
      // Handle Dio specific errors (network, timeout, etc.)
      print('DioError merging PDFs: ${e.message}');
      if (e.response != null) {
        print('Error Response data: ${e.response?.data}');
        print('Error Response headers: ${e.response?.headers}');
      } else {
        print('Error sending request: ${e.message}');
      }
      rethrow; // Re-throw to be caught by the UI layer
    } catch (e) {
      print('Error merging PDFs: $e');
      rethrow;
    }
  }

  Future<String?> splitPdf(File file, int startPage, int endPage) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: p.basename(file.path),
        ),
        'start_page': startPage,
        'end_page': endPage,
      });

      final response = await _dio.post(
        '$_baseUrl/split',
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );
      return _downloadFile(response, 'split');
    } on DioException catch (e) {
      print('DioError splitting PDF: ${e.message}');
      if (e.response != null) {
        print('Error Response data: ${e.response?.data}');
        print('Error Response headers: ${e.response?.headers}');
      } else {
        print('Error sending request: ${e.message}');
      }
      rethrow;
    } catch (e) {
      print('Error splitting PDF: $e');
      rethrow;
    }
  }

  Future<String?> rotatePdf(File file, int angle) async {
    // Ensure angle is one of the valid values if necessary (e.g., 90, 180, 270)
    if (![90, 180, 270].contains(angle)) {
      throw ArgumentError('Angle must be 90, 180, or 270');
    }

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: p.basename(file.path),
        ),
        'angle': angle,
      });

      final response = await _dio.post(
        '$_baseUrl/rotate',
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );
      return _downloadFile(response, 'rotated');
    } on DioException catch (e) {
      print('DioError rotating PDF: ${e.message}');
      if (e.response != null) {
        print('Error Response data: ${e.response?.data}');
        print('Error Response headers: ${e.response?.headers}');
      } else {
        print('Error sending request: ${e.message}');
      }
      rethrow;
    } catch (e) {
      print('Error rotating PDF: $e');
      rethrow;
    }
  }
}
