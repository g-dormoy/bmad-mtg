import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mtg/data/services/image_storage_service.dart';

/// Provider for the [ImageStorageService].
///
/// Disposes the service (and its Dio client) when no longer needed.
final imageStorageServiceProvider = Provider<ImageStorageService>((ref) {
  final service = ImageStorageService();
  ref.onDispose(service.dispose);
  return service;
});
