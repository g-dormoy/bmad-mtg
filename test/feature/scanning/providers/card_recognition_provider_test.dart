import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mtg/data/models/scryfall_card.dart';
import 'package:mtg/data/services/ocr_service.dart';
import 'package:mtg/data/services/scryfall_exception.dart';
import 'package:mtg/data/services/scryfall_service.dart';
import 'package:mtg/feature/scanning/models/recognition_state.dart';
import 'package:mtg/feature/scanning/providers/card_recognition_provider.dart';
import 'package:mtg/feature/scanning/providers/ocr_provider.dart';
import 'package:mtg/feature/scanning/providers/scryfall_provider.dart';

class MockOcrService extends Mock implements OcrService {}

class MockScryfallService extends Mock
    implements ScryfallService {}

class FakeInputImage extends Fake implements InputImage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockOcrService mockOcr;
  late MockScryfallService mockScryfall;
  late ProviderContainer container;

  const testCard = ScryfallCard(
    id: 'test-id',
    name: 'Lightning Bolt',
    typeLine: 'Instant',
    manaCost: '{R}',
    cmc: 1,
    setCode: 'lea',
    setName: 'Limited Edition Alpha',
    rarity: 'common',
  );

  setUpAll(() {
    registerFallbackValue(FakeInputImage());
  });

  setUp(() {
    mockOcr = MockOcrService();
    mockScryfall = MockScryfallService();
    container = ProviderContainer(
      overrides: [
        ocrServiceProvider.overrideWithValue(mockOcr),
        scryfallServiceProvider
            .overrideWithValue(mockScryfall),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('CardRecognitionNotifier', () {
    test('initial state is idle', () {
      final state =
          container.read(cardRecognitionProvider);

      expect(state.status, RecognitionStatus.idle);
    });

    test(
      'processFrame transitions to recognized on success',
      () async {
        when(() => mockOcr.extractCardName(any()))
            .thenAnswer((_) async => 'Lightning Bolt');
        when(
          () => mockScryfall.searchByName('Lightning Bolt'),
        ).thenAnswer((_) async => testCard);

        final notifier = container.read(
          cardRecognitionProvider.notifier,
        );
        await notifier.processFrame(FakeInputImage());

        final state =
            container.read(cardRecognitionProvider);
        expect(state.status, RecognitionStatus.recognized);
        expect(state.recognizedCard, testCard);
        expect(
          state.lastExtractedName,
          'Lightning Bolt',
        );
      },
    );

    test(
      'processFrame returns to idle when OCR returns null',
      () async {
        when(() => mockOcr.extractCardName(any()))
            .thenAnswer((_) async => null);

        final notifier = container.read(
          cardRecognitionProvider.notifier,
        );
        await notifier.processFrame(FakeInputImage());

        final state =
            container.read(cardRecognitionProvider);
        expect(state.status, RecognitionStatus.idle);
      },
    );

    test(
      'processFrame returns to idle on '
      'ScryfallNotFoundException',
      () async {
        when(() => mockOcr.extractCardName(any()))
            .thenAnswer((_) async => 'Unknown Card');
        when(
          () => mockScryfall.searchByName('Unknown Card'),
        ).thenThrow(
          const ScryfallNotFoundException('Card not found'),
        );

        final notifier = container.read(
          cardRecognitionProvider.notifier,
        );
        await notifier.processFrame(FakeInputImage());

        final state =
            container.read(cardRecognitionProvider);
        expect(state.status, RecognitionStatus.idle);
      },
    );

    test(
      'processFrame returns to idle on '
      'ScryfallAmbiguousException',
      () async {
        when(() => mockOcr.extractCardName(any()))
            .thenAnswer((_) async => 'Bolt');
        when(
          () => mockScryfall.searchByName('Bolt'),
        ).thenThrow(
          const ScryfallAmbiguousException('Ambiguous name'),
        );

        final notifier = container.read(
          cardRecognitionProvider.notifier,
        );
        await notifier.processFrame(FakeInputImage());

        final state =
            container.read(cardRecognitionProvider);
        expect(state.status, RecognitionStatus.idle);
      },
    );

    test(
      'processFrame sets error on ScryfallNetworkException',
      () async {
        when(() => mockOcr.extractCardName(any()))
            .thenAnswer((_) async => 'Lightning Bolt');
        when(
          () => mockScryfall.searchByName('Lightning Bolt'),
        ).thenThrow(
          const ScryfallNetworkException('Network error'),
        );

        final notifier = container.read(
          cardRecognitionProvider.notifier,
        );
        await notifier.processFrame(FakeInputImage());

        final state =
            container.read(cardRecognitionProvider);
        expect(state.status, RecognitionStatus.error);
        expect(state.errorMessage, 'Network error');
      },
    );

    test(
      'processFrame sets error on ScryfallServerException',
      () async {
        when(() => mockOcr.extractCardName(any()))
            .thenAnswer((_) async => 'Lightning Bolt');
        when(
          () => mockScryfall.searchByName('Lightning Bolt'),
        ).thenThrow(
          const ScryfallServerException('Server error: 500'),
        );

        final notifier = container.read(
          cardRecognitionProvider.notifier,
        );
        await notifier.processFrame(FakeInputImage());

        final state =
            container.read(cardRecognitionProvider);
        expect(state.status, RecognitionStatus.error);
        expect(state.errorMessage, 'Server error: 500');
      },
    );

    test(
      'processFrame returns to idle on OcrException',
      () async {
        when(() => mockOcr.extractCardName(any()))
            .thenThrow(
          const OcrException('OCR failed'),
        );

        final notifier = container.read(
          cardRecognitionProvider.notifier,
        );
        await notifier.processFrame(FakeInputImage());

        final state =
            container.read(cardRecognitionProvider);
        expect(state.status, RecognitionStatus.idle);
      },
    );

    test(
      'processFrame skips when already processing',
      () async {
        final completer = Completer<String?>();
        when(() => mockOcr.extractCardName(any()))
            .thenAnswer((_) => completer.future);

        final notifier = container.read(
          cardRecognitionProvider.notifier,
        );

        // First call – starts processing
        final future1 =
            notifier.processFrame(FakeInputImage());

        expect(
          container.read(cardRecognitionProvider).status,
          RecognitionStatus.processing,
        );

        // Second call – should be skipped (throttle)
        await notifier.processFrame(FakeInputImage());

        // Complete the first call
        completer.complete(null);
        await future1;

        // OCR should only have been called once
        verify(() => mockOcr.extractCardName(any()))
            .called(1);
      },
    );

    test(
      'same card name skips Scryfall when already recognized',
      () async {
        when(() => mockOcr.extractCardName(any()))
            .thenAnswer((_) async => 'Lightning Bolt');
        when(
          () => mockScryfall.searchByName('Lightning Bolt'),
        ).thenAnswer((_) async => testCard);

        final notifier = container.read(
          cardRecognitionProvider.notifier,
        );

        // First recognition
        await notifier.processFrame(FakeInputImage());
        expect(
          container.read(cardRecognitionProvider).status,
          RecognitionStatus.recognized,
        );

        // Second call with same name – should skip Scryfall
        await notifier.processFrame(FakeInputImage());

        expect(
          container.read(cardRecognitionProvider).status,
          RecognitionStatus.recognized,
        );

        // OCR called both times (checks if card changed)
        verify(() => mockOcr.extractCardName(any()))
            .called(2);
        // Scryfall only called once (dedup skips)
        verify(
          () => mockScryfall.searchByName('Lightning Bolt'),
        ).called(1);
      },
    );

    test('reset() returns to idle state', () async {
      // First recognize a card
      when(() => mockOcr.extractCardName(any()))
          .thenAnswer((_) async => 'Lightning Bolt');
      when(
        () => mockScryfall.searchByName('Lightning Bolt'),
      ).thenAnswer((_) async => testCard);

      final notifier = container.read(
        cardRecognitionProvider.notifier,
      );
      await notifier.processFrame(FakeInputImage());

      expect(
        container.read(cardRecognitionProvider).status,
        RecognitionStatus.recognized,
      );

      // Now reset
      notifier.reset();

      expect(
        container.read(cardRecognitionProvider).status,
        RecognitionStatus.idle,
      );
    });
  });
}
