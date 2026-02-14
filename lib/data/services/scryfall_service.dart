import 'package:dio/dio.dart';
import 'package:mtg/data/models/scryfall_card.dart';
import 'package:mtg/data/services/scryfall_exception.dart';

/// Service that looks up MTG cards via Scryfall's fuzzy search API.
///
/// Uses a dedicated [Dio] instance configured for the Scryfall public API.
/// Does NOT use the project's ApiProvider - Scryfall requires no
/// authentication.
class ScryfallService {
  /// Creates a [ScryfallService] with an optional [Dio] instance.
  ///
  /// If [dio] is not provided, a default instance is created with
  /// Scryfall-specific configuration. Pass a custom [Dio] for testing.
  ScryfallService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.scryfall.com',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {
                  'User-Agent': 'MTGCollectionApp/1.0',
                  'Accept': 'application/json',
                },
              ),
            );

  final Dio _dio;

  /// Searches for a card by name using Scryfall's fuzzy search.
  ///
  /// Returns a [ScryfallCard] on success.
  ///
  /// Throws:
  /// - [ScryfallNotFoundException] if no card matches the name.
  /// - [ScryfallAmbiguousException] if multiple cards match.
  /// - [ScryfallNetworkException] on network/timeout errors.
  /// - [ScryfallServerException] on 5xx server errors.
  Future<ScryfallCard> searchByName(String fuzzyName) async {
    final trimmed = fuzzyName.trim();
    if (trimmed.isEmpty) {
      throw const ScryfallNotFoundException('Card name cannot be empty');
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/cards/named',
        queryParameters: {'fuzzy': trimmed},
      );
      return ScryfallCard.fromJson(response.data!);
    } on DioError catch (e) {
      _handleDioError(e);
    } on ScryfallException {
      rethrow;
    } catch (e) {
      throw ScryfallException('Failed to parse card response', e);
    }
  }

  Never _handleDioError(DioError e) {
    final response = e.response;

    if (response != null) {
      final statusCode = response.statusCode ?? 0;

      if (statusCode == 404) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['type'] == 'ambiguous') {
          throw ScryfallAmbiguousException(
            data['details'] as String? ?? 'Ambiguous card name',
          );
        }
        throw const ScryfallNotFoundException('Card not found');
      }

      if (statusCode >= 500) {
        throw ScryfallServerException(
          'Server error: $statusCode',
          e,
        );
      }

      // Other 4xx errors (400 bad request, 429 rate limit, etc.)
      throw ScryfallServerException(
        'HTTP error: $statusCode',
        e,
      );
    }

    // Network errors (no connectivity, timeout, connection refused)
    if (e.type == DioErrorType.connectionTimeout ||
        e.type == DioErrorType.receiveTimeout ||
        e.type == DioErrorType.sendTimeout ||
        e.type == DioErrorType.connectionError) {
      throw ScryfallNetworkException('Network error: ${e.message}', e);
    }

    throw ScryfallNetworkException(
      'Request failed: ${e.message}',
      e,
    );
  }

  /// Releases resources held by the Dio instance.
  void dispose() {
    _dio.close();
  }
}
