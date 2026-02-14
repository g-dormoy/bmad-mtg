/// Base exception for Scryfall API errors.
///
/// Follows the typed exception pattern established by OcrException
/// in Story 2.2.
class ScryfallException implements Exception {
  /// Creates a [ScryfallException] with the given [message] and optional
  /// [cause].
  const ScryfallException(this.message, [this.cause]);

  /// A human-readable description of the error.
  final String message;

  /// The underlying error that caused this exception, if any.
  final Object? cause;

  @override
  String toString() =>
      'ScryfallException: $message${cause != null ? ' (cause: $cause)' : ''}';
}

/// Thrown when a card is not found on Scryfall (404 without ambiguous type).
class ScryfallNotFoundException extends ScryfallException {
  /// Creates a [ScryfallNotFoundException] with the given [message].
  const ScryfallNotFoundException(super.message);

  @override
  String toString() => 'ScryfallNotFoundException: $message';
}

/// Thrown when a card name matches multiple cards on Scryfall
/// (404 with `type: "ambiguous"`).
class ScryfallAmbiguousException extends ScryfallException {
  /// Creates a [ScryfallAmbiguousException] with the given [message].
  const ScryfallAmbiguousException(super.message);

  @override
  String toString() => 'ScryfallAmbiguousException: $message';
}

/// Thrown on network errors (no connectivity, timeout).
class ScryfallNetworkException extends ScryfallException {
  /// Creates a [ScryfallNetworkException] with the given [message] and
  /// optional [cause].
  const ScryfallNetworkException(super.message, [super.cause]);

  @override
  String toString() {
    final suffix = cause != null ? ' (cause: $cause)' : '';
    return 'ScryfallNetworkException: $message$suffix';
  }
}

/// Thrown on server errors (5xx responses) or unexpected HTTP errors.
class ScryfallServerException extends ScryfallException {
  /// Creates a [ScryfallServerException] with the given [message] and
  /// optional [cause].
  const ScryfallServerException(super.message, [super.cause]);

  @override
  String toString() {
    final suffix = cause != null ? ' (cause: $cause)' : '';
    return 'ScryfallServerException: $message$suffix';
  }
}
