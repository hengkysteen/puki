import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseStorageService {
  static const String defaultMainPath = 'puki';

  // Allowed extensions and max file sizes (in MB)
  static const List<String> imageAllow = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg', 'webp'];
  static const List<String> fileAllow = ['pdf', 'b', 'doc', 'txt', 'rtf', 'xls', 'xlsx', 'csv', 'ppt', 'pptx', 'md'];
  static const double imageMaxSizeMB = 3; // in mb
  static const double fileMaxSizeMB = 2.0; // in mb

  static Future<String> upload({required File file, required String name, bool isImage = true}) async {
    String fileExt = file.path.split('.').last.toLowerCase();
    int fileSize = await file.length();

    _validateFile(fileExt, fileSize, isImage);

    String fileName = _generateFileName(name);
    String path = isImage ? '$defaultMainPath/images/$fileName' : '$defaultMainPath/files/$fileName';

    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(path);
    UploadTask uploadTask = firebaseStorageRef.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

    return await taskSnapshot.ref.getDownloadURL();
  }

  static Future<String> webUpload(Uint8List fileBytes, String name, String? mimeType, {bool isImage = true}) async {
    String fileExt = name.split('.').last.toLowerCase();
    int fileSize = fileBytes.length;

    _validateFile(fileExt, fileSize, isImage);

    mimeType ??= _getMimeType(fileExt);

    String fileName = _generateFileName(name);
    String path = isImage ? '$defaultMainPath/images/$fileName' : '$defaultMainPath/files/$fileName';

    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(path);
    UploadTask uploadTask = firebaseStorageRef.putData(fileBytes, SettableMetadata(contentType: mimeType));
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

    return await taskSnapshot.ref.getDownloadURL();
  }

  static void _validateFile(String fileExt, int fileSize, bool isImage) {
    List<String> allowedExtensions = isImage ? imageAllow : fileAllow;
    int maxSizeBytes = ((isImage ? imageMaxSizeMB : fileMaxSizeMB) * 1024 * 1024).toInt();

    if (!allowedExtensions.contains(fileExt)) {
      throw UnsupportedError("File type not allowed. Allowed types: ${allowedExtensions.join(', ')}");
    }

    if (fileSize > maxSizeBytes) {
      throw UnsupportedError("File size exceeds maximum allowed size of ${isImage ? imageMaxSizeMB : fileMaxSizeMB} MB");
    }
  }

  static String _getMimeType(String ext) {
    switch (ext) {
      // Images
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'svg':
        return 'image/svg+xml';
      case 'webp':
        return 'image/webp';

      // Documents
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      case 'rtf':
        return 'application/rtf';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'csv':
        return 'text/csv';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';

      // Default
      default:
        return 'application/octet-stream';
    }
  }

  static String _generateFileName(String originalFileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return "$timestamp-$originalFileName";
  }

  static String adjustImageUrlForPlatform({required String url, bool isFirebaseEmulator = false}) {
    if (!isFirebaseEmulator) {
      final uri = Uri.parse(url);
      const adjustedHost = kIsWeb ? 'localhost' : '10.0.2.2';
      return uri.replace(host: adjustedHost).toString();
    }
    return url;
  }
}
