import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mtg/data/services/ocr_service.dart';
import 'package:mtg/data/services/scryfall_exception.dart';
import 'package:mtg/data/services/scryfall_service.dart';
import 'package:mtg/feature/scanning/models/recognition_state.dart';
import 'package:mtg/feature/scanning/providers/ocr_provider.dart';
import 'package:mtg/feature/scanning/providers/scryfall_provider.dart';

/// Notifier that orchestrates the card recognition pipeline:
/// OCR text extraction → Scryfall lookup → state update.
class CardRecognitionNotifier
    extends Notifier<RecognitionState> {
  late OcrService _ocrService;
  late ScryfallService _scryfallService;

  @override
  RecognitionState build() {
    _ocrService = ref.read(ocrServiceProvider);
    _scryfallService = ref.read(scryfallServiceProvider);
    return const RecognitionState.idle();
  }

  /// Processes a single camera frame through the recognition
  /// pipeline.
  ///
  /// Skips processing if already in [RecognitionStatus.processing]
  /// state (throttle). Transitions through processing → recognized
  /// or back to idle/error depending on results.
  Future<void> processFrame(InputImage image) async {
    // Throttle: skip if already processing a previous frame
    if (state.status == RecognitionStatus.processing) return;

    // Capture previous state before transitioning – needed
    // for deduplication check after OCR completes.
    final previousState = state;

    state = const RecognitionState.processing();

    try {
      final extractedName =
          await _ocrService.extractCardName(image);

      // OCR found no text – return to idle for retry
      if (extractedName == null) {
        state = const RecognitionState.idle();
        return;
      }

      // Skip Scryfall if same name already recognized
      // (sticky recognition – don't re-lookup the same card)
      if (previousState.status ==
              RecognitionStatus.recognized &&
          previousState.lastExtractedName == extractedName) {
        state = previousState;
        return;
      }

      final card =
          await _scryfallService.searchByName(extractedName);

      state = RecognitionState.recognized(
        card,
        extractedName: extractedName,
      );

      // Haptic feedback on successful recognition (~50ms)
      await HapticFeedback.lightImpact();
    } on OcrException {
      // OCR failure – silent retry on next frame
      state = const RecognitionState.idle();
    } on ScryfallNotFoundException {
      // Card not found – silent retry
      state = const RecognitionState.idle();
    } on ScryfallAmbiguousException {
      // Ambiguous name – silent retry
      state = const RecognitionState.idle();
    } on ScryfallNetworkException catch (e) {
      // Network error – surface to UI
      state = RecognitionState.error(e.message);
    } on ScryfallServerException catch (e) {
      // Server error – surface to UI
      state = RecognitionState.error(e.message);
    } on ScryfallException catch (e) {
      // Unexpected Scryfall errors (e.g. parse failures)
      state = RecognitionState.error(e.message);
    } on Exception {
      // Catch-all safety net for unexpected errors
      state = const RecognitionState.idle();
    }
  }

  /// Resets the recognition state to idle.
  ///
  /// Used when navigating away or restarting the camera.
  void reset() {
    state = const RecognitionState.idle();
  }
}

/// Provides the card recognition pipeline state.
final cardRecognitionProvider = NotifierProvider<
    CardRecognitionNotifier, RecognitionState>(
  CardRecognitionNotifier.new,
);
