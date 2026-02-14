import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mtg/data/services/ocr_service.dart';

class MockTextRecognizer extends Mock implements TextRecognizer {}

class MockRecognizedText extends Mock implements RecognizedText {}

class MockTextBlock extends Mock implements TextBlock {}

class MockTextLine extends Mock implements TextLine {}

void main() {
  late MockTextRecognizer mockRecognizer;
  late OcrService ocrService;
  late InputImage testImage;

  setUp(() {
    mockRecognizer = MockTextRecognizer();
    ocrService = OcrService.withRecognizer(mockRecognizer);
    testImage = InputImage.fromFilePath('/test/image.jpg');
  });

  group('OcrService', () {
    group('extractText', () {
      test('returns recognized text from image', () async {
        final mockResult = MockRecognizedText();
        when(() => mockResult.text).thenReturn('Lightning Bolt');
        when(() => mockRecognizer.processImage(testImage))
            .thenAnswer((_) async => mockResult);

        final result = await ocrService.extractText(testImage);

        expect(result, equals('Lightning Bolt'));
        verify(() => mockRecognizer.processImage(testImage)).called(1);
      });

      test('returns empty string for blank image', () async {
        final mockResult = MockRecognizedText();
        when(() => mockResult.text).thenReturn('');
        when(() => mockRecognizer.processImage(testImage))
            .thenAnswer((_) async => mockResult);

        final result = await ocrService.extractText(testImage);

        expect(result, isEmpty);
      });
    });

    group('extractCardName', () {
      test('returns null when no text blocks are found', () async {
        final mockResult = MockRecognizedText();
        when(() => mockResult.blocks).thenReturn([]);
        when(() => mockRecognizer.processImage(testImage))
            .thenAnswer((_) async => mockResult);

        final result = await ocrService.extractCardName(testImage);

        expect(result, isNull);
      });

      test('returns the topmost text line as card name candidate', () async {
        // Create a block with card name at top (y=10)
        final topLine = MockTextLine();
        when(() => topLine.text).thenReturn('Lightning Bolt');
        final topBlock = MockTextBlock();
        when(() => topBlock.lines).thenReturn([topLine]);
        when(() => topBlock.boundingBox)
            .thenReturn(const Rect.fromLTWH(10, 10, 200, 30));

        // Create a block with card type below (y=200)
        final bottomLine = MockTextLine();
        when(() => bottomLine.text).thenReturn('Instant');
        final bottomBlock = MockTextBlock();
        when(() => bottomBlock.lines).thenReturn([bottomLine]);
        when(() => bottomBlock.boundingBox)
            .thenReturn(const Rect.fromLTWH(10, 200, 200, 30));

        final mockResult = MockRecognizedText();
        when(() => mockResult.blocks).thenReturn([bottomBlock, topBlock]);
        when(() => mockRecognizer.processImage(testImage))
            .thenAnswer((_) async => mockResult);

        final result = await ocrService.extractCardName(testImage);

        expect(result, equals('Lightning Bolt'));
      });

      test('skips text lines shorter than 2 characters', () async {
        // Create a block with a single character at top
        final shortLine = MockTextLine();
        when(() => shortLine.text).thenReturn('X');
        final shortBlock = MockTextBlock();
        when(() => shortBlock.lines).thenReturn([shortLine]);
        when(() => shortBlock.boundingBox)
            .thenReturn(const Rect.fromLTWH(10, 5, 20, 10));

        // Create a block with the actual name below
        final nameLine = MockTextLine();
        when(() => nameLine.text).thenReturn('Black Lotus');
        final nameBlock = MockTextBlock();
        when(() => nameBlock.lines).thenReturn([nameLine]);
        when(() => nameBlock.boundingBox)
            .thenReturn(const Rect.fromLTWH(10, 20, 200, 30));

        final mockResult = MockRecognizedText();
        when(() => mockResult.blocks).thenReturn([shortBlock, nameBlock]);
        when(() => mockRecognizer.processImage(testImage))
            .thenAnswer((_) async => mockResult);

        final result = await ocrService.extractCardName(testImage);

        expect(result, equals('Black Lotus'));
      });

      test('returns null when all text lines are too short', () async {
        final shortLine = MockTextLine();
        when(() => shortLine.text).thenReturn('A');
        final block = MockTextBlock();
        when(() => block.lines).thenReturn([shortLine]);
        when(() => block.boundingBox)
            .thenReturn(const Rect.fromLTWH(10, 10, 20, 10));

        final mockResult = MockRecognizedText();
        when(() => mockResult.blocks).thenReturn([block]);
        when(() => mockRecognizer.processImage(testImage))
            .thenAnswer((_) async => mockResult);

        final result = await ocrService.extractCardName(testImage);

        expect(result, isNull);
      });
    });

    group('error handling', () {
      test('extractText throws OcrException on recognizer failure', () async {
        when(() => mockRecognizer.processImage(testImage))
            .thenThrow(Exception('ML Kit internal error'));

        expect(
          () => ocrService.extractText(testImage),
          throwsA(isA<OcrException>()),
        );
      });

      test('extractCardName throws OcrException on recognizer failure',
          () async {
        when(() => mockRecognizer.processImage(testImage))
            .thenThrow(Exception('ML Kit internal error'));

        expect(
          () => ocrService.extractCardName(testImage),
          throwsA(isA<OcrException>()),
        );
      });
    });

    group('dispose', () {
      test('closes the text recognizer', () {
        when(() => mockRecognizer.close()).thenAnswer((_) async {});

        ocrService.dispose();

        verify(() => mockRecognizer.close()).called(1);
      });
    });
  });
}
