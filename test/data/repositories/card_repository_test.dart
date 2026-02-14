import 'package:flutter_test/flutter_test.dart';
import 'package:mtg/data/database/app_database.dart';
import 'package:mtg/data/repositories/card_repository.dart';

import '../../test_utils/test_database.dart';

void main() {
  late AppDatabase db;
  late CardRepository repository;

  setUp(() {
    db = createTestDatabase();
    repository = CardRepository(db.cardsDao);
  });

  tearDown(() => db.close());

  group('CardRepository', () {
    group('addCard', () {
      test('adds a new card to the database', () async {
        await repository.addCard(
          scryfallId: TestCards.lightningBolt.scryfallId,
          name: TestCards.lightningBolt.name,
          type: TestCards.lightningBolt.type,
          setCode: TestCards.lightningBolt.setCode,
          manaCost: TestCards.lightningBolt.manaCost,
          colors: TestCards.lightningBolt.colors,
        );

        final cards = await repository.getCards();

        expect(cards.length, equals(1));
        expect(cards.first.name, equals(TestCards.lightningBolt.name));
      });

      test('increments quantity for duplicate card', () async {
        // Add card first time
        await repository.addCard(
          scryfallId: TestCards.lightningBolt.scryfallId,
          name: TestCards.lightningBolt.name,
          type: TestCards.lightningBolt.type,
          setCode: TestCards.lightningBolt.setCode,
        );

        // Add same card again
        await repository.addCard(
          scryfallId: TestCards.lightningBolt.scryfallId,
          name: TestCards.lightningBolt.name,
          type: TestCards.lightningBolt.type,
          setCode: TestCards.lightningBolt.setCode,
        );

        final cards = await repository.getCards();

        expect(cards.length, equals(1)); // Still only one card
        expect(cards.first.quantity, equals(2)); // But quantity is 2
      });

      test('returns true on successful add', () async {
        final result = await repository.addCard(
          scryfallId: TestCards.lightningBolt.scryfallId,
          name: TestCards.lightningBolt.name,
          type: TestCards.lightningBolt.type,
          setCode: TestCards.lightningBolt.setCode,
        );

        expect(result, isTrue);
      });

      test('stores oracleText when provided', () async {
        await repository.addCard(
          scryfallId: TestCards.lightningBolt.scryfallId,
          name: TestCards.lightningBolt.name,
          type: TestCards.lightningBolt.type,
          setCode: TestCards.lightningBolt.setCode,
          oracleText: TestCards.lightningBolt.oracleText,
        );

        final cards = await repository.getCards();

        expect(cards.first.oracleText, equals(TestCards.lightningBolt.oracleText));
      });
    });

    group('getCards', () {
      test('returns empty list when no cards', () async {
        final cards = await repository.getCards();

        expect(cards, isEmpty);
      });

      test('returns all cards in collection', () async {
        await repository.addCard(
          scryfallId: TestCards.lightningBolt.scryfallId,
          name: TestCards.lightningBolt.name,
          type: TestCards.lightningBolt.type,
          setCode: TestCards.lightningBolt.setCode,
        );
        await repository.addCard(
          scryfallId: TestCards.counterspell.scryfallId,
          name: TestCards.counterspell.name,
          type: TestCards.counterspell.type,
          setCode: TestCards.counterspell.setCode,
        );

        final cards = await repository.getCards();

        expect(cards.length, equals(2));
      });

      test('returns Card domain objects with helper methods', () async {
        await repository.addCard(
          scryfallId: TestCards.nicoBolas.scryfallId,
          name: TestCards.nicoBolas.name,
          type: TestCards.nicoBolas.type,
          setCode: TestCards.nicoBolas.setCode,
          colors: TestCards.nicoBolas.colors,
        );

        final cards = await repository.getCards();
        final card = cards.first;

        // Verify domain model helper methods work
        expect(card.isMulticolor, isTrue);
        expect(card.colorList, containsAll(['U', 'B', 'R']));
      });
    });

    group('getCardCount', () {
      test('returns 0 when no cards', () async {
        final count = await repository.getCardCount();

        expect(count, equals(0));
      });

      test('returns correct unique card count', () async {
        await repository.addCard(
          scryfallId: TestCards.lightningBolt.scryfallId,
          name: TestCards.lightningBolt.name,
          type: TestCards.lightningBolt.type,
          setCode: TestCards.lightningBolt.setCode,
        );
        // Add duplicate
        await repository.addCard(
          scryfallId: TestCards.lightningBolt.scryfallId,
          name: TestCards.lightningBolt.name,
          type: TestCards.lightningBolt.type,
          setCode: TestCards.lightningBolt.setCode,
        );
        await repository.addCard(
          scryfallId: TestCards.counterspell.scryfallId,
          name: TestCards.counterspell.name,
          type: TestCards.counterspell.type,
          setCode: TestCards.counterspell.setCode,
        );

        final count = await repository.getCardCount();

        expect(count, equals(2)); // 2 unique cards, not 3
      });
    });

    group('getTotalQuantity', () {
      test('returns total quantity including duplicates', () async {
        await repository.addCard(
          scryfallId: TestCards.lightningBolt.scryfallId,
          name: TestCards.lightningBolt.name,
          type: TestCards.lightningBolt.type,
          setCode: TestCards.lightningBolt.setCode,
        );
        // Add 3 more copies
        await repository.addCard(
          scryfallId: TestCards.lightningBolt.scryfallId,
          name: TestCards.lightningBolt.name,
          type: TestCards.lightningBolt.type,
          setCode: TestCards.lightningBolt.setCode,
        );
        await repository.addCard(
          scryfallId: TestCards.lightningBolt.scryfallId,
          name: TestCards.lightningBolt.name,
          type: TestCards.lightningBolt.type,
          setCode: TestCards.lightningBolt.setCode,
        );
        await repository.addCard(
          scryfallId: TestCards.lightningBolt.scryfallId,
          name: TestCards.lightningBolt.name,
          type: TestCards.lightningBolt.type,
          setCode: TestCards.lightningBolt.setCode,
        );

        final total = await repository.getTotalQuantity();

        expect(total, equals(4)); // 4 copies of Lightning Bolt
      });
    });

    group('searchByName', () {
      test('finds cards matching search query', () async {
        await repository.addCard(
          scryfallId: TestCards.lightningBolt.scryfallId,
          name: TestCards.lightningBolt.name,
          type: TestCards.lightningBolt.type,
          setCode: TestCards.lightningBolt.setCode,
        );
        await repository.addCard(
          scryfallId: TestCards.counterspell.scryfallId,
          name: TestCards.counterspell.name,
          type: TestCards.counterspell.type,
          setCode: TestCards.counterspell.setCode,
        );

        final results = await repository.searchByName('light');

        expect(results.length, equals(1));
        expect(results.first.name, equals('Lightning Bolt'));
      });
    });

    group('deleteCard', () {
      test('removes card from collection', () async {
        await repository.addCard(
          scryfallId: TestCards.lightningBolt.scryfallId,
          name: TestCards.lightningBolt.name,
          type: TestCards.lightningBolt.type,
          setCode: TestCards.lightningBolt.setCode,
        );

        final cards = await repository.getCards();
        final cardId = cards.first.id!;

        await repository.deleteCard(cardId);

        final count = await repository.getCardCount();
        expect(count, equals(0));
      });
    });

    group('getUniqueSets', () {
      test('returns all unique set codes', () async {
        await repository.addCard(
          scryfallId: TestCards.lightningBolt.scryfallId,
          name: TestCards.lightningBolt.name,
          type: TestCards.lightningBolt.type,
          setCode: TestCards.lightningBolt.setCode,
        );
        await repository.addCard(
          scryfallId: TestCards.counterspell.scryfallId,
          name: TestCards.counterspell.name,
          type: TestCards.counterspell.type,
          setCode: TestCards.counterspell.setCode,
        );

        final sets = await repository.getUniqueSets();

        expect(sets.length, equals(2));
        expect(sets, containsAll(['M21', 'MH2']));
      });
    });
  });
}
