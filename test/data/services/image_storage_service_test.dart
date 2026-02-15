import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mtg/data/services/image_storage_service.dart';

class MockDio extends Mock implements Dio {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDio mockDio;
  late ImageStorageService service;
  late Directory tempDir;

  setUp(() async {
    mockDio = MockDio();
    service = ImageStorageService(dio: mockDio);

    // Create a real temp directory for tests
    tempDir = await Directory.systemTemp.createTemp('image_storage_test_');

    // Mock path_provider's getApplicationDocumentsDirectory
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return tempDir.path;
        }
        return null;
      },
    );
  });

  tearDown(() async {
    // Clean up temp directory
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
  });

  group('ImageStorageService', () {
    group('saveCardImage', () {
      test('successful download returns local file path', () async {
        when(
          () => mockDio.download(
            'https://cards.scryfall.io/normal/test.jpg',
            any<String>(),
          ),
        ).thenAnswer(
          (_) async => Response(
            statusCode: 200,
            requestOptions: RequestOptions(
              path: 'https://cards.scryfall.io/normal/test.jpg',
            ),
          ),
        );

        final result = await service.saveCardImage(
          'test-id-123',
          'https://cards.scryfall.io/normal/test.jpg',
        );

        expect(result, isNotNull);
        expect(result, contains('card_images'));
        expect(result, contains('test-id-123.jpg'));
      });

      test('creates card_images directory if missing', () async {
        when(
          () => mockDio.download(
            'https://cards.scryfall.io/normal/test.jpg',
            any<String>(),
          ),
        ).thenAnswer(
          (_) async => Response(
            statusCode: 200,
            requestOptions: RequestOptions(
              path: 'https://cards.scryfall.io/normal/test.jpg',
            ),
          ),
        );

        // Verify directory doesn't exist yet
        final imageDir = Directory('${tempDir.path}/card_images');
        expect(imageDir.existsSync(), isFalse);

        await service.saveCardImage(
          'test-id-123',
          'https://cards.scryfall.io/normal/test.jpg',
        );

        // Verify directory was created
        expect(imageDir.existsSync(), isTrue);
      });

      test('returns null on network error (does not throw)', () async {
        when(
          () => mockDio.download(
            'https://cards.scryfall.io/normal/test.jpg',
            any<String>(),
          ),
        ).thenThrow(
          DioError(
            requestOptions: RequestOptions(
              path: 'https://cards.scryfall.io/normal/test.jpg',
            ),
            type: DioErrorType.connectionTimeout,
            message: 'Connection timed out',
          ),
        );

        final result = await service.saveCardImage(
          'test-id-123',
          'https://cards.scryfall.io/normal/test.jpg',
        );

        expect(result, isNull);
      });

      test('returns null on file system error (does not throw)', () async {
        when(
          () => mockDio.download(
            'https://cards.scryfall.io/normal/test.jpg',
            any<String>(),
          ),
        ).thenThrow(
          const FileSystemException('Permission denied'),
        );

        final result = await service.saveCardImage(
          'test-id-123',
          'https://cards.scryfall.io/normal/test.jpg',
        );

        expect(result, isNull);
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
