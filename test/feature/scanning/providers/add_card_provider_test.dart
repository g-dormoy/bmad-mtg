import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mtg/data/models/card.dart';
import 'package:mtg/data/models/scryfall_card.dart';
import 'package:mtg/data/providers/database_provider.dart';
import 'package:mtg/data/providers/image_storage_provider.dart';
import 'package:mtg/data/repositories/card_repository.dart';
import 'package:mtg/data/services/image_storage_service.dart';
import 'package:mtg/feature/scanning/models/add_card_state.dart';
import 'package:mtg/feature/scanning/models/recognition_state.dart';
import 'package:mtg/feature/scanning/providers/add_card_provider.dart';
import 'package:mtg/feature/scanning/providers/card_recognition_provider.dart';

class MockCardRepository extends Mock implements CardRepository {}

class MockImageStorageService extends Mock
    implements ImageStorageService {}

class _TestCardRecognitionNotifier
    extends CardRecognitionNotifier {
  @override
  RecognitionState build() => const RecognitionState.idle();

  bool resetCalled = false;

  @override
  void reset() {
    resetCalled = true;
    super.reset();
  }
}

const _testCard = ScryfallCard(
  id: 'test-id-123',
  name: 'Lightning Bolt',
  typeLine: 'Instant',
  manaCost: '{R}',
  cmc: 1,
  colors: ['R'],
  setCode: 'lea',
  setName: 'Limited Edition Alpha',
  rarity: 'common',
  imageUris: ScryfallImageUris(
    small: 'https://cards.scryfall.io/small/test.jpg',
    normal: 'https://cards.scryfall.io/normal/test.jpg',
    large: 'https://cards.scryfall.io/large/test.jpg',
    png: 'https://cards.scryfall.io/png/test.png',
    artCrop: 'https://cards.scryfall.io/art_crop/test.jpg',
    borderCrop: 'https://cards.scryfall.io/border_crop/test.jpg',
  ),
);

const _testCardNoImage = ScryfallCard(
  id: 'test-id-456',
  name: 'Plains',
  typeLine: 'Basic Land',
  cmc: 0,
  setCode: 'lea',
  setName: 'Limited Edition Alpha',
  rarity: 'common',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
      const Card(
        scryfallId: 'fallback',
        name: 'Fallback',
        type: 'Instant',
        setCode: 'lea',
      ),
    );
  });

  late MockCardRepository mockRepository;
  late MockImageStorageService mockImageService;
  late _TestCardRecognitionNotifier testRecognitionNotifier;
  late ProviderContainer container;

  // Track haptic feedback calls
  final hapticCalls = <String>[];

  setUp(() {
    mockRepository = MockCardRepository();
    mockImageService = MockImageStorageService();
    testRecognitionNotifier = _TestCardRecognitionNotifier();

    container = ProviderContainer(
      overrides: [
        cardRepositoryProvider.overrideWithValue(mockRepository),
        imageStorageServiceProvider
            .overrideWithValue(mockImageService),
        cardRecognitionProvider.overrideWith(
          () => testRecognitionNotifier,
        ),
      ],
    );

    hapticCalls.clear();

    // Mock HapticFeedback method channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall methodCall) async {
        if (methodCall.method == 'HapticFeedback.vibrate') {
          hapticCalls.add(methodCall.arguments as String);
        }
        return null;
      },
    );
  });

  tearDown(() {
    container.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('AddCardNotifier', () {
    test('initial state is idle', () {
      final state = container.read(addCardProvider);

      expect(state.status, AddCardStatus.idle);
      expect(state.errorMessage, isNull);
    });

    test('addCard saves card to repository', () async {
      when(
        () => mockRepository.addCard(
          scryfallId: any(named: 'scryfallId'),
          name: any(named: 'name'),
          type: any(named: 'type'),
          setCode: any(named: 'setCode'),
          oracleText: any(named: 'oracleText'),
          manaCost: any(named: 'manaCost'),
          colors: any(named: 'colors'),
        ),
      ).thenAnswer((_) async => true);
      when(
        () => mockImageService.saveCardImage(
          any(),
          any(),
        ),
      ).thenAnswer((_) async => null);

      final notifier = container.read(addCardProvider.notifier);
      await notifier.addCard(_testCard);

      verify(
        () => mockRepository.addCard(
          scryfallId: 'test-id-123',
          name: 'Lightning Bolt',
          type: 'Instant',
          setCode: 'lea',
          manaCost: '{R}',
          colors: 'R',
        ),
      ).called(1);
    });

    test(
      'addCard transitions state: idle -> adding -> added -> idle',
      () async {
        final states = <AddCardStatus>[];
        container.listen<AddCardState>(
          addCardProvider,
          (_, next) => states.add(next.status),
        );

        when(
          () => mockRepository.addCard(
            scryfallId: any(named: 'scryfallId'),
            name: any(named: 'name'),
            type: any(named: 'type'),
            setCode: any(named: 'setCode'),
            oracleText: any(named: 'oracleText'),
            manaCost: any(named: 'manaCost'),
            colors: any(named: 'colors'),
          ),
        ).thenAnswer((_) async => true);
        when(
          () => mockImageService.saveCardImage(
            any(),
            any(),
          ),
        ).thenAnswer((_) async => null);

        final notifier = container.read(addCardProvider.notifier);
        await notifier.addCard(_testCard);

        expect(
          states,
          [
            AddCardStatus.adding,
            AddCardStatus.added,
            AddCardStatus.idle,
          ],
        );
      },
    );

    test('addCard triggers haptic feedback', () async {
      when(
        () => mockRepository.addCard(
          scryfallId: any(named: 'scryfallId'),
          name: any(named: 'name'),
          type: any(named: 'type'),
          setCode: any(named: 'setCode'),
          oracleText: any(named: 'oracleText'),
          manaCost: any(named: 'manaCost'),
          colors: any(named: 'colors'),
        ),
      ).thenAnswer((_) async => true);
      when(
        () => mockImageService.saveCardImage(
          any(),
          any(),
        ),
      ).thenAnswer((_) async => null);

      final notifier = container.read(addCardProvider.notifier);
      await notifier.addCard(_testCard);

      expect(
        hapticCalls,
        contains('HapticFeedbackType.mediumImpact'),
      );
    });

    test('addCard resets recognition provider after delay', () async {
      when(
        () => mockRepository.addCard(
          scryfallId: any(named: 'scryfallId'),
          name: any(named: 'name'),
          type: any(named: 'type'),
          setCode: any(named: 'setCode'),
          oracleText: any(named: 'oracleText'),
          manaCost: any(named: 'manaCost'),
          colors: any(named: 'colors'),
        ),
      ).thenAnswer((_) async => true);
      when(
        () => mockImageService.saveCardImage(
          any(),
          any(),
        ),
      ).thenAnswer((_) async => null);

      final notifier = container.read(addCardProvider.notifier);
      await notifier.addCard(_testCard);

      expect(testRecognitionNotifier.resetCalled, isTrue);
    });

    test(
      'addCard debounces duplicate taps (second call while adding '
      'is ignored)',
      () async {
        when(
          () => mockRepository.addCard(
            scryfallId: any(named: 'scryfallId'),
            name: any(named: 'name'),
            type: any(named: 'type'),
            setCode: any(named: 'setCode'),
            oracleText: any(named: 'oracleText'),
            manaCost: any(named: 'manaCost'),
            colors: any(named: 'colors'),
          ),
        ).thenAnswer((_) async => true);
        when(
          () => mockImageService.saveCardImage(
            any(),
            any(),
          ),
        ).thenAnswer((_) async => null);

        final notifier = container.read(addCardProvider.notifier);

        // Start first add (don't await)
        final future1 = notifier.addCard(_testCard);

        // Immediately try a second add (should be ignored)
        final future2 = notifier.addCard(_testCard);

        await Future.wait([future1, future2]);

        // Repository should only be called once
        verify(
          () => mockRepository.addCard(
            scryfallId: any(named: 'scryfallId'),
            name: any(named: 'name'),
            type: any(named: 'type'),
            setCode: any(named: 'setCode'),
            oracleText: any(named: 'oracleText'),
            manaCost: any(named: 'manaCost'),
            colors: any(named: 'colors'),
          ),
        ).called(1);
      },
    );

    test(
      'addCard handles repository errors gracefully (state -> error)',
      () async {
        when(
          () => mockRepository.addCard(
            scryfallId: any(named: 'scryfallId'),
            name: any(named: 'name'),
            type: any(named: 'type'),
            setCode: any(named: 'setCode'),
            oracleText: any(named: 'oracleText'),
            manaCost: any(named: 'manaCost'),
            colors: any(named: 'colors'),
          ),
        ).thenThrow(Exception('Database error'));

        final notifier = container.read(addCardProvider.notifier);
        await notifier.addCard(_testCard);

        final state = container.read(addCardProvider);
        expect(state.status, AddCardStatus.error);
        expect(state.errorMessage, contains('Database error'));
      },
    );

    test(
      'addCard fires background image download and updates '
      'DB with image path',
      () async {
        when(
          () => mockRepository.addCard(
            scryfallId: any(named: 'scryfallId'),
            name: any(named: 'name'),
            type: any(named: 'type'),
            setCode: any(named: 'setCode'),
            oracleText: any(named: 'oracleText'),
            manaCost: any(named: 'manaCost'),
            colors: any(named: 'colors'),
          ),
        ).thenAnswer((_) async => true);
        when(
          () => mockImageService.saveCardImage(
            'test-id-123',
            'https://cards.scryfall.io/normal/test.jpg',
          ),
        ).thenAnswer((_) async => '/path/to/test-id-123.jpg');
        when(
          () => mockRepository.getCardByScryfallId('test-id-123'),
        ).thenAnswer(
          (_) async => const Card(
            id: 1,
            scryfallId: 'test-id-123',
            name: 'Lightning Bolt',
            type: 'Instant',
            setCode: 'lea',
          ),
        );
        when(
          () => mockRepository.updateCard(any()),
        ).thenAnswer((_) async => true);

        final notifier = container.read(addCardProvider.notifier);
        await notifier.addCard(_testCard);

        // Allow background task to fully complete
        // (multiple async steps: saveCardImage →
        //  getCardByScryfallId → updateCard)
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        // Verify image was downloaded
        verify(
          () => mockImageService.saveCardImage(
            'test-id-123',
            'https://cards.scryfall.io/normal/test.jpg',
          ),
        ).called(1);

        // Verify DB was queried for existing card
        verify(
          () => mockRepository.getCardByScryfallId(
            'test-id-123',
          ),
        ).called(1);

        // Verify DB was updated with image path
        final captured = verify(
          () => mockRepository.updateCard(captureAny()),
        ).captured;
        expect(captured, hasLength(1));
        final updatedCard = captured.first as Card;
        expect(
          updatedCard.imagePath,
          '/path/to/test-id-123.jpg',
        );
      },
    );

    test(
      'addCard skips image download when imageUris is null',
      () async {
        when(
          () => mockRepository.addCard(
            scryfallId: any(named: 'scryfallId'),
            name: any(named: 'name'),
            type: any(named: 'type'),
            setCode: any(named: 'setCode'),
            oracleText: any(named: 'oracleText'),
            manaCost: any(named: 'manaCost'),
            colors: any(named: 'colors'),
          ),
        ).thenAnswer((_) async => true);

        final notifier = container.read(addCardProvider.notifier);
        await notifier.addCard(_testCardNoImage);

        // Allow background task to complete
        await Future<void>.delayed(Duration.zero);

        // Image service should never be called
        verifyNever(
          () => mockImageService.saveCardImage(
            any(),
            any(),
          ),
        );
      },
    );
  });
}
