import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Exception thrown when OCR text recognition fails.
class OcrException implements Exception {
  /// Creates an [OcrException] with the given [message] and optional [cause].
  const OcrException(this.message, [this.cause]);

  /// A human-readable description of the error.
  final String message;

  /// The underlying error that caused this exception, if any.
  final Object? cause;

  @override
  String toString() =>
      'OcrException: $message${cause != null ? ' (cause: $cause)' : ''}';
}

/// Service that extracts text from images using Google ML Kit's
/// on-device text recognition (Latin script).
class OcrService {
  /// Creates an [OcrService] with a Latin script text recognizer.
  OcrService() : _textRecognizer = TextRecognizer();

  /// Creates an [OcrService] with a custom [TextRecognizer].
  ///
  /// Useful for testing with a mock recognizer.
  OcrService.withRecognizer(TextRecognizer textRecognizer)
      : _textRecognizer = textRecognizer;

  final TextRecognizer _textRecognizer;

  /// Extracts all recognized text from the given [image].
  ///
  /// Returns the full recognized text as a concatenated string.
  /// Returns an empty string if no text is found.
  ///
  /// Throws [OcrException] if text recognition fails.
  Future<String> extractText(InputImage image) async {
    try {
      final recognizedText = await _textRecognizer.processImage(image);
      return recognizedText.text;
    } on OcrException {
      rethrow;
    } catch (e) {
      throw OcrException('Failed to extract text from image', e);
    }
  }

  /// Extracts the most likely card name from the given [image].
  ///
  /// Uses a heuristic based on vertical position: the topmost text block
  /// is most likely the card name on an MTG card.
  ///
  /// Returns `null` if no suitable text is found.
  ///
  /// Throws [OcrException] if text recognition fails.
  Future<String?> extractCardName(InputImage image) async {
    try {
      final recognizedText = await _textRecognizer.processImage(image);

      if (recognizedText.blocks.isEmpty) {
        return null;
      }

      // Sort blocks by vertical position (topmost first).
      final sortedBlocks = List<TextBlock>.from(recognizedText.blocks)
        ..sort(
          (a, b) => a.boundingBox.top.compareTo(b.boundingBox.top),
        );

      // Find the first block with a meaningful text line.
      for (final block in sortedBlocks) {
        for (final line in block.lines) {
          final text = line.text.trim();
          if (text.length >= 2) {
            return text;
          }
        }
      }

      return null;
    } on OcrException {
      rethrow;
    } catch (e) {
      throw OcrException('Failed to extract card name from image', e);
    }
  }

  /// Releases resources held by the text recognizer.
  ///
  /// Must be called when the service is no longer needed.
  void dispose() {
    _textRecognizer.close();
  }
}
