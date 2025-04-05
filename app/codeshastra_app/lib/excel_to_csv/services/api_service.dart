// import 'package:http/http.dart' as http;
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart'; // For MediaType
// import 'dart:typed_data'; // For Uint8List
// import 'dart:io'; // For File operations
// import 'package:path_provider/path_provider.dart'; // Add this dependency

// class ApiService {
//   // IMPORTANT: Replace with your actual Flask API base URL
//   final String _baseUrl =
//       "https://modular-sold-refused-namibia.trycloudflare.com/"; // Example: "http://127.0.0.1:5000" or your deployed URL

//   Future<Map<String, dynamic>> convertFile(
//     PlatformFile file,
//     String conversionType,
//   ) async {
//     if (file.bytes == null) {
//       throw Exception("File data is null. Cannot upload.");
//     }

//     final endpoint =
//         conversionType == 'excel-to-csv' ? '/excel-to-csv' : '/csv-to-excel';
//     final uri = Uri.parse('$_baseUrl$endpoint');

//     var request = http.MultipartRequest('POST', uri);

//     // Add the file using bytes
//     request.files.add(
//       http.MultipartFile.fromBytes(
//         'file', // This 'file' key must match the key expected by your Flask API
//         file.bytes!,
//         filename: file.name,
//         // Optionally add content type if needed, though often inferred
//         contentType: MediaType('application', _getMimeType(file.name)),
//       ),
//     );

//     try {
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200) {
//         // Get the filename from Content-Disposition header or create one
//         String fileName = _getFileNameFromResponse(
//           response,
//           file.name,
//           conversionType,
//         );

//         // Get file data as bytes
//         Uint8List fileBytes = response.bodyBytes;

//         // Save file to device storage
//         String? filePath = await _saveFile(fileBytes, fileName);

//         print("File conversion successful, saved to: $filePath");

//         return {
//           'success': true,
//           'filePath': filePath,
//           'fileName': fileName,
//           'fileBytes': fileBytes,
//         };
//       } else {
//         // Try to parse error message from JSON response
//         String errorMessage = "Server error ${response.statusCode}";
//         try {
//           // Check if response body is valid JSON before decoding
//           if (response.headers['content-type']?.contains('application/json') ??
//               false) {
//             final errorJson = http.Response.bytes(
//               response.bodyBytes,
//               response.statusCode,
//               headers: response.headers,
//             );
//             final decoded = Uri.decodeFull(
//               errorJson.body,
//             ); // Decode potential URL encoding
//             // Attempt to decode JSON only if it looks like JSON
//             if (decoded.trim().startsWith('{') &&
//                 decoded.trim().endsWith('}')) {
//               final errorData = http.Response.bytes(
//                 response.bodyBytes,
//                 response.statusCode,
//                 headers: response.headers,
//               );
//               errorMessage = Uri.decodeFull(
//                 errorData.body,
//               ); // Use decoded JSON string
//             } else {
//               errorMessage = decoded; // Use decoded plain text if not JSON
//             }
//           } else {
//             errorMessage = Uri.decodeFull(
//               response.body,
//             ); // Decode plain text response
//           }
//         } catch (e) {
//           print("Could not parse error response: $e");
//           errorMessage = response.body; // Fallback to raw body
//         }
//         throw Exception('Failed to convert file: $errorMessage');
//       }
//     } on http.ClientException catch (e) {
//       // Handle network errors specifically
//       print("Network error: $e");
//       throw Exception(
//         "Network error: Could not connect to the server at $_baseUrl. Please ensure the server is running and accessible.",
//       );
//     } catch (e) {
//       print("Error during conversion request: $e");
//       throw Exception('An unexpected error occurred: $e');
//     }
//   }

//   // Extract filename from response headers or generate appropriate one
//   String _getFileNameFromResponse(
//     http.Response response,
//     String originalFileName,
//     String conversionType,
//   ) {
//     // Try to get filename from Content-Disposition header
//     String? contentDisposition = response.headers['content-disposition'];
//     if (contentDisposition != null &&
//         contentDisposition.contains('filename=')) {
//       // Extract filename from header
//       final RegExp regex = RegExp('filename="?([^"]*)"?');
//       final match = regex.firstMatch(contentDisposition);
//       if (match != null && match.groupCount >= 1) {
//         return match.group(1)!;
//       }
//     }

//     // If no filename in header, generate one based on conversion type
//     if (conversionType == 'excel-to-csv') {
//       return originalFileName.replaceAll(RegExp(r'\.xlsx$|\.xls$'), '') +
//           '.csv';
//     } else {
//       return originalFileName.replaceAll(RegExp(r'\.csv$'), '') + '.xlsx';
//     }
//   }

//   // Save file to device storage
//   Future<String?> _saveFile(Uint8List bytes, String fileName) async {
//     try {
//       // Get the downloads directory
//       Directory? directory;

//       // Use the application documents directory (works on all platforms)
//       directory = await getApplicationDocumentsDirectory();

//       // Create subdirectory for downloads if it doesn't exist
//       final downloadsDir = Directory('${directory.path}/Downloads');
//       if (!await downloadsDir.exists()) {
//         await downloadsDir.create(recursive: true);
//       }

//       // Create file path
//       final filePath = '${downloadsDir.path}/$fileName';

//       // Write bytes to file
//       final file = File(filePath);
//       await file.writeAsBytes(bytes);

//       return filePath;
//     } catch (e) {
//       print('Error saving file: $e');
//       return null;
//     }
//   }

//   String _getMimeType(String fileName) {
//     if (fileName.endsWith('.csv')) {
//       return 'text/csv';
//     } else if (fileName.endsWith('.xlsx')) {
//       return 'vnd.openxmlformats-officedocument.spreadsheetml.sheet';
//     } else if (fileName.endsWith('.xls')) {
//       return 'vnd.ms-excel';
//     }
//     return 'octet-stream'; // Default fallback
//   }
// }

import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'dart:typed_data'; // For Uint8List
import 'dart:io'; // For File operations
import 'package:path_provider/path_provider.dart'; // For getApplicationDocumentsDirectory
import 'package:permission_handler/permission_handler.dart'; // For storage permissions
import 'package:device_info_plus/device_info_plus.dart'; // For Android version check
import 'package:open_file/open_file.dart'; // For opening files

class ApiService {
  // IMPORTANT: Replace with your actual Flask API base URL
  final String _baseUrl =
      "https://reception-poultry-ec-booking.trycloudflare.com/";

  Future<Map<String, dynamic>> convertFile(
    PlatformFile file,
    String conversionType,
  ) async {
    if (file.bytes == null) {
      throw Exception("File data is null. Cannot upload.");
    }

    final endpoint =
        conversionType == 'excel-to-csv' ? '/excel-to-csv' : '/csv-to-excel';
    final uri = Uri.parse('$_baseUrl$endpoint');

    var request = http.MultipartRequest('POST', uri);

    // Add the file using bytes
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        file.bytes!,
        filename: file.name,
        contentType: MediaType('application', _getMimeType(file.name)),
      ),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Get the filename from Content-Disposition header or create one
        String fileName = _getFileNameFromResponse(
          response,
          file.name,
          conversionType,
        );

        // Get file data as bytes
        Uint8List fileBytes = response.bodyBytes;

        // Save file to public downloads directory and open it
        String? filePath = await _saveFileToDownloads(fileBytes, fileName);
        if (filePath != null) {
          // Open the file using open_file package
          OpenFile.open(filePath);
        }

        print("File conversion successful, saved to: $filePath");

        return {
          'success': true,
          'filePath': filePath,
          'fileName': fileName,
          'fileBytes': fileBytes,
        };
      } else {
        String errorMessage = "Server error ${response.statusCode}";
        try {
          if (response.headers['content-type']?.contains('application/json') ??
              false) {
            final errorData = Uri.decodeFull(response.body);
            errorMessage = errorData;
          } else {
            errorMessage = Uri.decodeFull(response.body);
          }
        } catch (e) {
          print("Could not parse error response: $e");
          errorMessage = response.body;
        }
        throw Exception('Failed to convert file: $errorMessage');
      }
    } on http.ClientException catch (e) {
      print("Network error: $e");
      throw Exception(
        "Network error: Could not connect to the server at $_baseUrl. Please ensure the server is running and accessible.",
      );
    } catch (e) {
      print("Error during conversion request: $e");
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Extract filename from response headers or generate appropriate one
  String _getFileNameFromResponse(
    http.Response response,
    String originalFileName,
    String conversionType,
  ) {
    // Try to get filename from Content-Disposition header
    String? contentDisposition = response.headers['content-disposition'];
    if (contentDisposition != null &&
        contentDisposition.contains('filename=')) {
      final RegExp regex = RegExp('filename="?([^"]*)"?');
      final match = regex.firstMatch(contentDisposition);
      if (match != null && match.groupCount >= 1) {
        return match.group(1)!;
      }
    }

    // If no filename in header, generate one based on conversion type
    if (conversionType == 'excel-to-csv') {
      return originalFileName.replaceAll(RegExp(r'\.xlsx$|\.xls$'), '') +
          '.csv';
    } else {
      return originalFileName.replaceAll(RegExp(r'\.csv$'), '') + '.xlsx';
    }
  }

  // Save file to device's public Downloads directory without using downloads_path_provider_28
  Future<String?> _saveFileToDownloads(Uint8List bytes, String fileName) async {
    try {
      // Check Android version to handle storage permissions correctly
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // For Android versions below API 29, request storage permission if needed
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
        // Use the standard Downloads folder path for Android
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else {
        // For iOS or other platforms, fallback to the app's documents directory
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      // Create file path
      final filePath = '${downloadsDir.path}/$fileName';

      // Write bytes to file
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      // Optionally scan file if needed
      await _scanFile(filePath);

      return filePath;
    } catch (e) {
      print('Error saving file to downloads: $e');

      // Fallback to app documents directory if saving to public storage fails
      try {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        return filePath;
      } catch (e) {
        print('Error saving file to app documents: $e');
        return null;
      }
    }
  }

  // This makes the file visible in the media store / gallery
  Future<void> _scanFile(String filePath) async {
    try {
      print("File saved at: $filePath");
      // If you want to scan the file so it appears in gallery apps,
      // you can use platform channels or a dedicated package.
    } catch (e) {
      print('Error scanning file: $e');
    }
  }

  String _getMimeType(String fileName) {
    if (fileName.endsWith('.csv')) {
      return 'text/csv';
    } else if (fileName.endsWith('.xlsx')) {
      return 'vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    } else if (fileName.endsWith('.xls')) {
      return 'vnd.ms-excel';
    }
    return 'octet-stream'; // Default fallback
  }
}

// download 28 wala code
// import 'package:http/http.dart' as http;
// import 'package:file_picker/file_picker.dart';
// import 'package:http_parser/http_parser.dart'; // For MediaType
// import 'dart:typed_data'; // For Uint8List
// import 'dart:io'; // For File operations
// import 'package:path_provider/path_provider.dart'; // For getApplicationDocumentsDirectory
// import 'package:permission_handler/permission_handler.dart'; // Add this for storage permissions
// import 'package:downloads_path_provider_28/downloads_path_provider_28.dart'; // For downloads directory
// import 'package:device_info_plus/device_info_plus.dart'; // For Android version check

// class ApiService {
//   // IMPORTANT: Replace with your actual Flask API base URL
//   final String _baseUrl =
//       "https://modular-sold-refused-namibia.trycloudflare.com/";

//   Future<Map<String, dynamic>> convertFile(
//     PlatformFile file,
//     String conversionType,
//   ) async {
//     if (file.bytes == null) {
//       throw Exception("File data is null. Cannot upload.");
//     }

//     final endpoint =
//         conversionType == 'excel-to-csv' ? '/excel-to-csv' : '/csv-to-excel';
//     final uri = Uri.parse('$_baseUrl$endpoint');

//     var request = http.MultipartRequest('POST', uri);

//     // Add the file using bytes
//     request.files.add(
//       http.MultipartFile.fromBytes(
//         'file',
//         file.bytes!,
//         filename: file.name,
//         contentType: MediaType('application', _getMimeType(file.name)),
//       ),
//     );

//     try {
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200) {
//         // Get the filename from Content-Disposition header or create one
//         String fileName = _getFileNameFromResponse(
//           response,
//           file.name,
//           conversionType,
//         );

//         // Get file data as bytes
//         Uint8List fileBytes = response.bodyBytes;

//         // Save file to public downloads directory
//         String? filePath = await _saveFileToDownloads(fileBytes, fileName);

//         print("File conversion successful, saved to: $filePath");

//         return {
//           'success': true,
//           'filePath': filePath,
//           'fileName': fileName,
//           'fileBytes': fileBytes,
//         };
//       } else {
//         // Error handling (unchanged from your original code)
//         String errorMessage = "Server error ${response.statusCode}";
//         try {
//           if (response.headers['content-type']?.contains('application/json') ??
//               false) {
//             final errorJson = http.Response.bytes(
//               response.bodyBytes,
//               response.statusCode,
//               headers: response.headers,
//             );
//             final decoded = Uri.decodeFull(errorJson.body);
//             if (decoded.trim().startsWith('{') &&
//                 decoded.trim().endsWith('}')) {
//               final errorData = http.Response.bytes(
//                 response.bodyBytes,
//                 response.statusCode,
//                 headers: response.headers,
//               );
//               errorMessage = Uri.decodeFull(errorData.body);
//             } else {
//               errorMessage = decoded;
//             }
//           } else {
//             errorMessage = Uri.decodeFull(response.body);
//           }
//         } catch (e) {
//           print("Could not parse error response: $e");
//           errorMessage = response.body;
//         }
//         throw Exception('Failed to convert file: $errorMessage');
//       }
//     } on http.ClientException catch (e) {
//       print("Network error: $e");
//       throw Exception(
//         "Network error: Could not connect to the server at $_baseUrl. Please ensure the server is running and accessible.",
//       );
//     } catch (e) {
//       print("Error during conversion request: $e");
//       throw Exception('An unexpected error occurred: $e');
//     }
//   }

//   // Extract filename from response headers or generate appropriate one
//   String _getFileNameFromResponse(
//     http.Response response,
//     String originalFileName,
//     String conversionType,
//   ) {
//     // Try to get filename from Content-Disposition header
//     String? contentDisposition = response.headers['content-disposition'];
//     if (contentDisposition != null &&
//         contentDisposition.contains('filename=')) {
//       final RegExp regex = RegExp('filename="?([^"]*)"?');
//       final match = regex.firstMatch(contentDisposition);
//       if (match != null && match.groupCount >= 1) {
//         return match.group(1)!;
//       }
//     }

//     // If no filename in header, generate one based on conversion type
//     if (conversionType == 'excel-to-csv') {
//       return originalFileName.replaceAll(RegExp(r'\.xlsx$|\.xls$'), '') +
//           '.csv';
//     } else {
//       return originalFileName.replaceAll(RegExp(r'\.csv$'), '') + '.xlsx';
//     }
//   }

//   // Save file to device's public Downloads directory
//   Future<String?> _saveFileToDownloads(Uint8List bytes, String fileName) async {
//     try {
//       // Check Android version to handle storage permissions correctly
//       final deviceInfo = DeviceInfoPlugin();
//       final androidInfo = await deviceInfo.androidInfo;

//       // For Android 10+ (API 29+), we use MediaStore API or the downloads path provider
//       // For earlier versions, we request storage permission
//       if (androidInfo.version.sdkInt < 29) {
//         // Request permission for older Android versions
//         var status = await Permission.storage.status;
//         if (!status.isGranted) {
//           status = await Permission.storage.request();
//           if (!status.isGranted) {
//             throw Exception("Storage permission is required to save files");
//           }
//         }
//       }

//       // Get the downloads directory path
//       Directory? downloadsDir;

//       try {
//         // Use the downloads_path_provider to get the downloads folder
//         downloadsDir = await DownloadsPathProvider.downloadsDirectory;
//       } catch (e) {
//         print("Error getting downloads directory: $e");
//         // Fallback to external storage directory
//         final directory = await getExternalStorageDirectory();
//         if (directory == null) {
//           throw Exception("Could not access external storage");
//         }
//         downloadsDir = directory;
//       }

//       // Create file path
//       final filePath = '${downloadsDir?.path}/$fileName';

//       // Write bytes to file
//       final file = File(filePath);
//       await file.writeAsBytes(bytes);

//       // Make the file visible in the media store
//       await _scanFile(filePath);

//       return filePath;
//     } catch (e) {
//       print('Error saving file to downloads: $e');

//       // Fallback to app documents directory if downloading to public storage fails
//       try {
//         final directory = await getApplicationDocumentsDirectory();
//         final filePath = '${directory.path}/$fileName';
//         final file = File(filePath);
//         await file.writeAsBytes(bytes);
//         return filePath;
//       } catch (e) {
//         print('Error saving file to app documents: $e');
//         return null;
//       }
//     }
//   }

//   // This makes the file visible in the media store / gallery
//   Future<void> _scanFile(String filePath) async {
//     try {
//       // You can use various methods to scan the file, like:
//       // 1. Using platform channels
//       // 2. Using plugins like media_scanner_scanner
//       // For simplicity, we're just logging it
//       print("File saved at: $filePath");

//       // If you add a media_scanner plugin, you would use it like:
//       // await MediaScannerScanner.scanFile(filePath);
//     } catch (e) {
//       print('Error scanning file: $e');
//     }
//   }

//   String _getMimeType(String fileName) {
//     if (fileName.endsWith('.csv')) {
//       return 'text/csv';
//     } else if (fileName.endsWith('.xlsx')) {
//       return 'vnd.openxmlformats-officedocument.spreadsheetml.sheet';
//     } else if (fileName.endsWith('.xls')) {
//       return 'vnd.ms-excel';
//     }
//     return 'octet-stream'; // Default fallback
//   }
// }
