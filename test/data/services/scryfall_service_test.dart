import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mtg/data/models/scryfall_card.dart';
import 'package:mtg/data/services/scryfall_exception.dart';
import 'package:mtg/data/services/scryfall_service.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late ScryfallService service;

  setUp(() {
    mockDio = MockDio();
    service = ScryfallService(dio: mockDio);
  });

  group('ScryfallService', () {
    group('searchByName', () {
      test('calls correct endpoint with fuzzy parameter', () async {
        when(
          () => mockDio.get<Map<String, dynamic>>(
            '/cards/named',
            queryParameters: {'fuzzy': 'Lightning Bolt'},
          ),
        ).thenAnswer(
          (_) async => Response(
            data: _lightningBoltResponse(),
            statusCode: 200,
            requestOptions: RequestOptions(path: '/cards/named'),
          ),
        );

        await service.searchByName('Lightning Bolt');

        verify(
          () => mockDio.get<Map<String, dynamic>>(
            '/cards/named',
            queryParameters: {'fuzzy': 'Lightning Bolt'},
          ),
        ).called(1);
      });

      test('successful response returns parsed ScryfallCard', () async {
        when(
          () => mockDio.get<Map<String, dynamic>>(
            '/cards/named',
            queryParameters: {'fuzzy': 'Lightning Bolt'},
          ),
        ).thenAnswer(
          (_) async => Response(
            data: _lightningBoltResponse(),
            statusCode: 200,
            requestOptions: RequestOptions(path: '/cards/named'),
          ),
        );

        final card = await service.searchByName('Lightning Bolt');

        expect(card, isA<ScryfallCard>());
        expect(card.name, equals('Lightning Bolt'));
        expect(card.typeLine, equals('Instant'));
        expect(card.manaCost, equals('{R}'));
        expect(card.setCode, equals('lea'));
      });

      test('404 response throws ScryfallNotFoundException', () async {
        final requestOptions = RequestOptions(path: '/cards/named');
        when(
          () => mockDio.get<Map<String, dynamic>>(
            '/cards/named',
            queryParameters: {'fuzzy': 'xyznonexistent'},
          ),
        ).thenThrow(
          DioError.badResponse(
            statusCode: 404,
            requestOptions: requestOptions,
            response: Response(
              data: <String, dynamic>{
                'object': 'error',
                'code': 'not_found',
                'status': 404,
                'details': 'No cards found matching "xyznonexistent".',
              },
              statusCode: 404,
              requestOptions: requestOptions,
            ),
          ),
        );

        expect(
          () => service.searchByName('xyznonexistent'),
          throwsA(isA<ScryfallNotFoundException>()),
        );
      });

      test(
        '404 with ambiguous type throws ScryfallAmbiguousException',
        () async {
          final requestOptions = RequestOptions(path: '/cards/named');
          when(
            () => mockDio.get<Map<String, dynamic>>(
              '/cards/named',
              queryParameters: {'fuzzy': 'nissa'},
            ),
          ).thenThrow(
            DioError.badResponse(
              statusCode: 404,
              requestOptions: requestOptions,
              response: Response(
                data: <String, dynamic>{
                  'object': 'error',
                  'code': 'not_found',
                  'type': 'ambiguous',
                  'status': 404,
                  'details':
                      'Too many cards match ambiguous name "nissa".',
                },
                statusCode: 404,
                requestOptions: requestOptions,
              ),
            ),
          );

          expect(
            () => service.searchByName('nissa'),
            throwsA(
              isA<ScryfallAmbiguousException>().having(
                (e) => e.message,
                'message',
                contains('nissa'),
              ),
            ),
          );
        },
      );

      test(
        'DioError with timeout type throws ScryfallNetworkException',
        () async {
          when(
            () => mockDio.get<Map<String, dynamic>>(
              '/cards/named',
              queryParameters: {'fuzzy': 'Lightning Bolt'},
            ),
          ).thenThrow(
            DioError(
              requestOptions: RequestOptions(path: '/cards/named'),
              type: DioErrorType.connectionTimeout,
              message: 'Connection timed out',
            ),
          );

          expect(
            () => service.searchByName('Lightning Bolt'),
            throwsA(isA<ScryfallNetworkException>()),
          );
        },
      );

      test(
        'DioError with connectionError throws ScryfallNetworkException',
        () async {
          when(
            () => mockDio.get<Map<String, dynamic>>(
              '/cards/named',
              queryParameters: {'fuzzy': 'Lightning Bolt'},
            ),
          ).thenThrow(
            DioError(
              requestOptions: RequestOptions(path: '/cards/named'),
              type: DioErrorType.connectionError,
              message: 'Connection refused',
            ),
          );

          expect(
            () => service.searchByName('Lightning Bolt'),
            throwsA(isA<ScryfallNetworkException>()),
          );
        },
      );

      test(
        'malformed JSON response throws ScryfallException',
        () async {
          when(
            () => mockDio.get<Map<String, dynamic>>(
              '/cards/named',
              queryParameters: {'fuzzy': 'Lightning Bolt'},
            ),
          ).thenAnswer(
            (_) async => Response(
              data: <String, dynamic>{
                'unexpected': 'data',
              },
              statusCode: 200,
              requestOptions:
                  RequestOptions(path: '/cards/named'),
            ),
          );

          expect(
            () => service.searchByName('Lightning Bolt'),
            throwsA(isA<ScryfallException>()),
          );
        },
      );

      test(
        'empty name throws ScryfallNotFoundException',
        () async {
          expect(
            () => service.searchByName(''),
            throwsA(isA<ScryfallNotFoundException>()),
          );

          expect(
            () => service.searchByName('   '),
            throwsA(isA<ScryfallNotFoundException>()),
          );
        },
      );

      test('500 response throws ScryfallServerException', () async {
        final requestOptions = RequestOptions(path: '/cards/named');
        when(
          () => mockDio.get<Map<String, dynamic>>(
            '/cards/named',
            queryParameters: {'fuzzy': 'Lightning Bolt'},
          ),
        ).thenThrow(
          DioError.badResponse(
            statusCode: 500,
            requestOptions: requestOptions,
            response: Response(
              data: 'Internal Server Error',
              statusCode: 500,
              requestOptions: requestOptions,
            ),
          ),
        );

        expect(
          () => service.searchByName('Lightning Bolt'),
          throwsA(isA<ScryfallServerException>()),
        );
      });
    });

    group('dispose', () {
      test('closes the Dio instance', () {
        when(() => mockDio.close()).thenReturn(null);

        service.dispose();

        verify(() => mockDio.close()).called(1);
      });
    });
  });
}

Map<String, dynamic> _lightningBoltResponse() => <String, dynamic>{
      'id': 'e2d1f0a2-c8d5-47a2-ba29-5e813c275ed8',
      'name': 'Lightning Bolt',
      'type_line': 'Instant',
      'mana_cost': '{R}',
      'cmc': 1.0,
      'colors': <dynamic>['R'],
      'set': 'lea',
      'set_name': 'Limited Edition Alpha',
      'oracle_text': 'Lightning Bolt deals 3 damage to any target.',
      'rarity': 'common',
      'image_uris': <String, dynamic>{
        'small': 'https://cards.scryfall.io/small/front/e/2/e2d1f0a2.jpg',
        'normal': 'https://cards.scryfall.io/normal/front/e/2/e2d1f0a2.jpg',
        'large': 'https://cards.scryfall.io/large/front/e/2/e2d1f0a2.jpg',
        'png': 'https://cards.scryfall.io/png/front/e/2/e2d1f0a2.png',
        'art_crop':
            'https://cards.scryfall.io/art_crop/front/e/2/e2d1f0a2.jpg',
        'border_crop':
            'https://cards.scryfall.io/border_crop/front/e/2/e2d1f0a2.jpg',
      },
    };
