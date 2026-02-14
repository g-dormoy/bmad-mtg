import 'package:flutter/foundation.dart';
import 'package:mtg/data/models/scryfall_card.dart';

/// Status of the card recognition pipeline.
enum RecognitionStatus {
  /// No recognition in progress; waiting for a stable frame.
  idle,

  /// OCR / Scryfall lookup in flight.
  processing,

  /// Card successfully identified via Scryfall.
  recognized,

  /// A non-recoverable error occurred (e.g. network failure).
  error,
}

/// Immutable state for the card recognition pipeline.
///
/// Manually written immutable class (no Freezed) following the project
/// pattern established by [ScryfallCard] and the `Card` model.
@immutable
class RecognitionState {
  const RecognitionState._({
    required this.status,
    this.recognizedCard,
    this.errorMessage,
    this.lastExtractedName,
  });

  /// Initial idle state – no recognition activity.
  const RecognitionState.idle()
      : this._(status: RecognitionStatus.idle);

  /// OCR or Scryfall call is in progress.
  const RecognitionState.processing()
      : this._(status: RecognitionStatus.processing);

  /// A card was successfully recognized.
  const RecognitionState.recognized(
    ScryfallCard card, {
    String? extractedName,
  }) : this._(
          status: RecognitionStatus.recognized,
          recognizedCard: card,
          lastExtractedName: extractedName,
        );

  /// An error occurred during recognition.
  const RecognitionState.error(String message)
      : this._(
          status: RecognitionStatus.error,
          errorMessage: message,
        );

  /// Current pipeline status.
  final RecognitionStatus status;

  /// The card returned by Scryfall when [status] is
  /// [RecognitionStatus.recognized].
  final ScryfallCard? recognizedCard;

  /// Human-readable error description when [status] is
  /// [RecognitionStatus.error].
  final String? errorMessage;

  /// The last card name extracted by OCR (used for deduplication).
  final String? lastExtractedName;

  /// Creates a copy with the given fields replaced.
  RecognitionState copyWith({
    RecognitionStatus? status,
    ScryfallCard? recognizedCard,
    String? errorMessage,
    String? lastExtractedName,
  }) {
    return RecognitionState._(
      status: status ?? this.status,
      recognizedCard: recognizedCard ?? this.recognizedCard,
      errorMessage: errorMessage ?? this.errorMessage,
      lastExtractedName: lastExtractedName ?? this.lastExtractedName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecognitionState &&
        other.status == status &&
        other.recognizedCard == recognizedCard &&
        other.errorMessage == errorMessage &&
        other.lastExtractedName == lastExtractedName;
  }

  @override
  int get hashCode {
    return Object.hash(status, recognizedCard, errorMessage, lastExtractedName);
  }

  @override
  String toString() {
    return 'RecognitionState(status: $status, '
        'recognizedCard: $recognizedCard, '
        'errorMessage: $errorMessage, '
        'lastExtractedName: $lastExtractedName)';
  }
}
