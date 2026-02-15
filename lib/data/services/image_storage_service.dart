import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Downloads and saves card images to the local file system.
///
/// Images are stored in `{appDocuments}/card_images/{scryfallId}.jpg`.
class ImageStorageService {
  /// Creates an [ImageStorageService] with the given [Dio] client.
  ImageStorageService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  final Dio _dio;

  /// Downloads a card image and saves it locally.
  ///
  /// Returns the local file path on success, or `null` on failure.
  /// Never throws - all errors are caught and return `null`.
  Future<String?> saveCardImage(
    String scryfallId,
    String imageUrl,
  ) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory(p.join(appDir.path, 'card_images'));
      if (!imageDir.existsSync()) {
        await imageDir.create(recursive: true);
      }

      final filePath = p.join(imageDir.path, '$scryfallId.jpg');
      await _dio.download(imageUrl, filePath);
      return filePath;
    } on Exception {
      return null;
    }
  }

  /// Closes the underlying HTTP client.
  void dispose() {
    _dio.close();
  }
}
