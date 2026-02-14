import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mtg/data/services/ocr_service.dart';

/// Provides a singleton [OcrService] instance for text recognition.
///
/// The text recognizer is disposed when the provider is disposed.
final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService();
  ref.onDispose(service.dispose);
  return service;
});
