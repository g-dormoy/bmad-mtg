import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mtg/data/database/app_database.dart';
import 'package:mtg/data/database/daos/cards_dao.dart';

import '../../test_utils/test_database.dart';

void main() {
  late AppDatabase db;
  late CardsDao dao;

  setUp(() {
    db = createTestDatabase();
    dao = db.cardsDao;
  });

  tearDown(() => db.close());

  group('CardsDao', () {
    group('insertCard', () {
      test('creates a new card record', () async {
        final id = await dao.insertCard(
          CardsTableCompanion.insert(
            scryfallId: TestCards.lightningBolt.scryfallId,
            name: TestCards.lightningBolt.name,
            type: TestCards.lightningBolt.type,
            setCode: TestCards.lightningBolt.setCode,
            manaCost: Value(TestCards.lightningBolt.manaCost),
            colors: Value(TestCards.lightningBolt.colors),
          ),
        );

        expect(id, greaterThan(0));
      });

      test('returns auto-incremented id', () async {
        final id1 = await dao.insertCard(
          CardsTableCompanion.insert(
            scryfallId: TestCards.lightningBolt.scryfallId,
            name: TestCards.lightningBolt.name,
            type: TestCards.lightningBolt.type,
            setCode: TestCards.lightningBolt.setCode,
          ),
        );

        final id2 = await dao.insertCard(
          CardsTableCompanion.insert(
            scryfallId: TestCards.counterspell.scryfallId,
            name: TestCards.counterspell.name,
            type: TestCards.counterspell.type,
            setCode: TestCards.counterspell.setCode,
          ),
        );

        expect(id2, greaterThan(id1));
      });
    });

    group('getCardByScryfallId', () {
      test('returns card when found', () async {
        await dao.insertCard(
          CardsTableCompanion.insert(
            scryfallId: TestCards.lightningBolt.scryfallId,
            name: TestCards.lightningBolt.name,
            type: TestCards.lightningBolt.type,
            setCode: TestCards.lightningBolt.setCode,
          ),
        );

        final card = await dao.getCardByScryfallId(
          TestCards.lightningBolt.scryfallId,
        );

        expect(card, isNotNull);
        expect(card!.name, equals(TestCards.lightningBolt.name));
        expect(card.type, equals(TestCards.lightningBolt.type));
      });

      test('returns null when not found', () async {
        final card = await dao.getCardByScryfallId('non-existent-id');

        expect(card, isNull);
      });
    });

    group('incrementQuantity', () {
      test('increases quantity by 1 and returns true', () async {
        final id = await dao.insertCard(
          CardsTableCompanion.insert(
            scryfallId: TestCards.lightningBolt.scryfallId,
            name: TestCards.lightningBolt.name,
            type: TestCards.lightningBolt.type,
            setCode: TestCards.lightningBolt.setCode,
          ),
        );

        // Initial quantity should be 1
        var card = await dao.getCardById(id);
        expect(card!.quantity, equals(1));

        // Increment quantity
        final result = await dao.incrementQuantity(id);

        // Should return true on success
        expect(result, isTrue);

        // Quantity should now be 2
        card = await dao.getCardById(id);
        expect(card!.quantity, equals(2));
      });

      test('returns false for non-existent card', () async {
        final result = await dao.incrementQuantity(999);

        expect(result, isFalse);
      });
    });

    group('getAllCards', () {
      test('returns empty list when no cards', () async {
        final cards = await dao.getAllCards();

        expect(cards, isEmpty);
      });

      test('returns all inserted cards', () async {
        await dao.insertCard(
          CardsTableCompanion.insert(
            scryfallId: TestCards.lightningBolt.scryfallId,
            name: TestCards.lightningBolt.name,
            type: TestCards.lightningBolt.type,
            setCode: TestCards.lightningBolt.setCode,
          ),
        );
        await dao.insertCard(
          CardsTableCompanion.insert(
            scryfallId: TestCards.counterspell.scryfallId,
            name: TestCards.counterspell.name,
            type: TestCards.counterspell.type,
            setCode: TestCards.counterspell.setCode,
          ),
        );

        final cards = await dao.getAllCards();

        expect(cards.length, equals(2));
      });
    });

    group('deleteCard', () {
      test('removes card from database', () async {
        final id = await dao.insertCard(
          CardsTableCompanion.insert(
            scryfallId: TestCards.lightningBolt.scryfallId,
            name: TestCards.lightningBolt.name,
            type: TestCards.lightningBolt.type,
            setCode: TestCards.lightningBolt.setCode,
          ),
        );

        final deleted = await dao.deleteCard(id);

        expect(deleted, equals(1));
        final card = await dao.getCardById(id);
        expect(card, isNull);
      });
    });

    group('getCardCount', () {
      test('returns 0 when no cards', () async {
        final count = await dao.getCardCount();

        expect(count, equals(0));
      });

      test('returns correct count', () async {
        await dao.insertCard(
          CardsTableCompanion.insert(
            scryfallId: TestCards.lightningBolt.scryfallId,
            name: TestCards.lightningBolt.name,
            type: TestCards.lightningBolt.type,
            setCode: TestCards.lightningBolt.setCode,
          ),
        );
        await dao.insertCard(
          CardsTableCompanion.insert(
            scryfallId: TestCards.counterspell.scryfallId,
            name: TestCards.counterspell.name,
            type: TestCards.counterspell.type,
            setCode: TestCards.counterspell.setCode,
          ),
        );

        final count = await dao.getCardCount();

        expect(count, equals(2));
      });
    });

    group('searchByName', () {
      test('finds cards by partial name match', () async {
        await dao.insertCard(
          CardsTableCompanion.insert(
            scryfallId: TestCards.lightningBolt.scryfallId,
            name: TestCards.lightningBolt.name,
            type: TestCards.lightningBolt.type,
            setCode: TestCards.lightningBolt.setCode,
          ),
        );
        await dao.insertCard(
          CardsTableCompanion.insert(
            scryfallId: TestCards.counterspell.scryfallId,
            name: TestCards.counterspell.name,
            type: TestCards.counterspell.type,
            setCode: TestCards.counterspell.setCode,
          ),
        );

        final results = await dao.searchByName('bolt');

        expect(results.length, equals(1));
        expect(results.first.name, equals('Lightning Bolt'));
      });

      test('search is case-insensitive', () async {
        await dao.insertCard(
          CardsTableCompanion.insert(
            scryfallId: TestCards.lightningBolt.scryfallId,
            name: TestCards.lightningBolt.name,
            type: TestCards.lightningBolt.type,
            setCode: TestCards.lightningBolt.setCode,
          ),
        );

        final results = await dao.searchByName('LIGHTNING');

        expect(results.length, equals(1));
      });

      test('empty search returns all cards', () async {
        await dao.insertCard(
          CardsTableCompanion.insert(
            scryfallId: TestCards.lightningBolt.scryfallId,
            name: TestCards.lightningBolt.name,
            type: TestCards.lightningBolt.type,
            setCode: TestCards.lightningBolt.setCode,
          ),
        );
        await dao.insertCard(
          CardsTableCompanion.insert(
            scryfallId: TestCards.counterspell.scryfallId,
            name: TestCards.counterspell.name,
            type: TestCards.counterspell.type,
            setCode: TestCards.counterspell.setCode,
          ),
        );

        final results = await dao.searchByName('');

        expect(results.length, equals(2));
      });

      test('search with SQL LIKE special characters does not cause injection', () async {
        // Insert a card with % in name (unlikely but possible)
        await dao.insertCard(
          CardsTableCompanion.insert(
            scryfallId: 'special-1',
            name: '100% True',
            type: 'Instant',
            setCode: 'TST',
          ),
        );
        await dao.insertCard(
          CardsTableCompanion.insert(
            scryfallId: TestCards.lightningBolt.scryfallId,
            name: TestCards.lightningBolt.name,
            type: TestCards.lightningBolt.type,
            setCode: TestCards.lightningBolt.setCode,
          ),
        );

        // Searching for "%" should only find the card with % in name,
        // not act as a wildcard matching everything
        final results = await dao.searchByName('%');

        expect(results.length, equals(1));
        expect(results.first.name, equals('100% True'));
      });

      test('handles special characters in card names', () async {
        await dao.insertCard(
          CardsTableCompanion.insert(
            scryfallId: 'aetherize-1',
            name: 'Ætherize',
            type: 'Instant',
            setCode: 'GTC',
          ),
        );

        // Search using lowercase 'therize' suffix since SQLite LOWER()
        // doesn't handle non-ASCII characters like Æ
        final results = await dao.searchByName('therize');

        expect(results.length, equals(1));
        expect(results.first.name, equals('Ætherize'));
      });
    });

    group('filterByColor', () {
      test('filters cards by color', () async {
        await dao.insertCard(
          CardsTableCompanion.insert(
            scryfallId: TestCards.lightningBolt.scryfallId,
            name: TestCards.lightningBolt.name,
            type: TestCards.lightningBolt.type,
            setCode: TestCards.lightningBolt.setCode,
            colors: const Value('R'),
          ),
        );
        await dao.insertCard(
          CardsTableCompanion.insert(
            scryfallId: TestCards.counterspell.scryfallId,
            name: TestCards.counterspell.name,
            type: TestCards.counterspell.type,
            setCode: TestCards.counterspell.setCode,
            colors: const Value('U'),
          ),
        );

        final redCards = await dao.filterByColor('R');

        expect(redCards.length, equals(1));
        expect(redCards.first.name, equals('Lightning Bolt'));
      });
    });
  });
}
