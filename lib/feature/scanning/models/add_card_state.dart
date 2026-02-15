import 'package:flutter/foundation.dart';

/// Status of the add-card operation.
enum AddCardStatus {
  /// No add operation in progress.
  idle,

  /// Card is being saved to the database.
  adding,

  /// Card was saved successfully.
  added,

  /// An error occurred while saving.
  error,
}

/// Immutable state for the add-card flow.
///
/// Tracks the current status and optional error message.
@immutable
class AddCardState {
  const AddCardState._({
    required this.status,
    this.errorMessage,
  });

  /// No add operation in progress.
  const AddCardState.idle()
      : this._(status: AddCardStatus.idle);

  /// Card is being saved.
  const AddCardState.adding()
      : this._(status: AddCardStatus.adding);

  /// Card was saved successfully.
  const AddCardState.added()
      : this._(status: AddCardStatus.added);

  /// An error occurred while saving.
  const AddCardState.error(String message)
      : this._(
          status: AddCardStatus.error,
          errorMessage: message,
        );

  /// Current add-card status.
  final AddCardStatus status;

  /// Error description when [status] is [AddCardStatus.error].
  final String? errorMessage;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddCardState &&
        other.status == status &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(status, errorMessage);

  @override
  String toString() {
    return 'AddCardState(status: $status, errorMessage: $errorMessage)';
  }
}
