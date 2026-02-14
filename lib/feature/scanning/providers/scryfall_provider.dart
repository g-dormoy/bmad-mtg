import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mtg/data/services/scryfall_service.dart';

/// Provides a singleton [ScryfallService] instance for card lookups.
///
/// The Dio instance is disposed when the provider is disposed.
final scryfallServiceProvider = Provider<ScryfallService>((ref) {
  final service = ScryfallService();
  ref.onDispose(service.dispose);
  return service;
});
