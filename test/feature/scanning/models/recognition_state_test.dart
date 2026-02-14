import 'package:flutter_test/flutter_test.dart';
import 'package:mtg/data/models/scryfall_card.dart';
import 'package:mtg/feature/scanning/models/recognition_state.dart';

void main() {
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

  const testCard2 = ScryfallCard(
    id: 'test-id-2',
    name: 'Counterspell',
    typeLine: 'Instant',
    manaCost: '{U}{U}',
    cmc: 2,
    setCode: 'lea',
    setName: 'Limited Edition Alpha',
    rarity: 'uncommon',
  );

  group('RecognitionState factory constructors', () {
    test('idle() creates state with idle status', () {
      const state = RecognitionState.idle();

      expect(state.status, RecognitionStatus.idle);
      expect(state.recognizedCard, isNull);
      expect(state.errorMessage, isNull);
      expect(state.lastExtractedName, isNull);
    });

    test('processing() creates state with processing status', () {
      const state = RecognitionState.processing();

      expect(state.status, RecognitionStatus.processing);
      expect(state.recognizedCard, isNull);
      expect(state.errorMessage, isNull);
      expect(state.lastExtractedName, isNull);
    });

    test('recognized() creates state with card', () {
      const state = RecognitionState.recognized(testCard);

      expect(state.status, RecognitionStatus.recognized);
      expect(state.recognizedCard, testCard);
      expect(state.errorMessage, isNull);
      expect(state.lastExtractedName, isNull);
    });

    test(
      'recognized() creates state with card and extracted name',
      () {
        const state = RecognitionState.recognized(
          testCard,
          extractedName: 'Lightning Bolt',
        );

        expect(state.status, RecognitionStatus.recognized);
        expect(state.recognizedCard, testCard);
        expect(
          state.lastExtractedName,
          'Lightning Bolt',
        );
      },
    );

    test('error() creates state with error message', () {
      const state = RecognitionState.error('Network failure');

      expect(state.status, RecognitionStatus.error);
      expect(state.recognizedCard, isNull);
      expect(state.errorMessage, 'Network failure');
      expect(state.lastExtractedName, isNull);
    });
  });

  group('RecognitionState equality', () {
    test('two idle states are equal', () {
      const a = RecognitionState.idle();
      const b = RecognitionState.idle();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('two processing states are equal', () {
      const a = RecognitionState.processing();
      const b = RecognitionState.processing();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('two recognized states with same card are equal', () {
      const a = RecognitionState.recognized(testCard);
      const b = RecognitionState.recognized(testCard);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('two error states with same message are equal', () {
      const a = RecognitionState.error('fail');
      const b = RecognitionState.error('fail');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different statuses are not equal', () {
      const idle = RecognitionState.idle();
      const processing = RecognitionState.processing();

      expect(idle, isNot(equals(processing)));
    });

    test(
      'recognized states with different cards are not equal',
      () {
        const a = RecognitionState.recognized(testCard);
        const b = RecognitionState.recognized(testCard2);

        expect(a, isNot(equals(b)));
      },
    );

    test(
      'error states with different messages are not equal',
      () {
        const a = RecognitionState.error('fail 1');
        const b = RecognitionState.error('fail 2');

        expect(a, isNot(equals(b)));
      },
    );

    test('identical instance is equal', () {
      const state = RecognitionState.idle();

      expect(state, equals(state));
    });

    test('is not equal to non-RecognitionState object', () {
      const state = RecognitionState.idle();

      expect(state, isNot(equals('not a state')));
    });
  });

  group('RecognitionState copyWith', () {
    test('creates copy with updated status', () {
      const original = RecognitionState.idle();
      final copy = original.copyWith(
        status: RecognitionStatus.processing,
      );

      expect(copy.status, RecognitionStatus.processing);
      expect(copy.recognizedCard, isNull);
    });

    test('creates copy with updated card', () {
      const original = RecognitionState.idle();
      final copy = original.copyWith(
        recognizedCard: testCard,
      );

      expect(copy.recognizedCard, testCard);
      expect(copy.status, RecognitionStatus.idle);
    });

    test('creates copy with updated error message', () {
      const original = RecognitionState.idle();
      final copy = original.copyWith(errorMessage: 'error');

      expect(copy.errorMessage, 'error');
    });

    test('creates copy with updated extracted name', () {
      const original = RecognitionState.idle();
      final copy = original.copyWith(
        lastExtractedName: 'Bolt',
      );

      expect(copy.lastExtractedName, 'Bolt');
    });

    test('preserves fields not updated', () {
      const original = RecognitionState.recognized(
        testCard,
        extractedName: 'Lightning Bolt',
      );
      final copy = original.copyWith(
        status: RecognitionStatus.idle,
      );

      expect(copy.status, RecognitionStatus.idle);
      expect(copy.recognizedCard, testCard);
      expect(
        copy.lastExtractedName,
        'Lightning Bolt',
      );
    });
  });

  group('RecognitionState toString', () {
    test('idle state produces readable output', () {
      const state = RecognitionState.idle();
      final str = state.toString();

      expect(str, contains('RecognitionState'));
      expect(str, contains('idle'));
    });

    test('recognized state includes card info', () {
      const state = RecognitionState.recognized(testCard);
      final str = state.toString();

      expect(str, contains('recognized'));
      expect(str, contains('Lightning Bolt'));
    });

    test('error state includes error message', () {
      const state = RecognitionState.error('Network failure');
      final str = state.toString();

      expect(str, contains('error'));
      expect(str, contains('Network failure'));
    });
  });
}
