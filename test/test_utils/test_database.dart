import 'package:drift/native.dart';
import 'package:mtg/data/database/app_database.dart';

/// Creates an in-memory database for testing.
///
/// Each call creates a fresh database instance that is isolated
/// from other tests.
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

/// Test fixture data for cards.
class TestCards {
  /// A sample Lightning Bolt card.
  static const lightningBolt = (
    scryfallId: 'abc-123',
    name: 'Lightning Bolt',
    type: 'Instant',
    setCode: 'M21',
    oracleText: 'Lightning Bolt deals 3 damage to any target.',
    manaCost: '{R}',
    colors: 'R',
  );

  /// A sample Counterspell card.
  static const counterspell = (
    scryfallId: 'def-456',
    name: 'Counterspell',
    type: 'Instant',
    setCode: 'MH2',
    oracleText: 'Counter target spell.',
    manaCost: '{U}{U}',
    colors: 'U',
  );

  /// A sample Llanowar Elves card.
  static const llanowarElves = (
    scryfallId: 'ghi-789',
    name: 'Llanowar Elves',
    type: 'Creature — Elf Druid',
    setCode: 'M19',
    oracleText: '{T}: Add {G}.',
    manaCost: '{G}',
    colors: 'G',
  );

  /// A multicolor card.
  static const nicoBolas = (
    scryfallId: 'jkl-012',
    name: 'Nicol Bolas, Dragon-God',
    type: 'Legendary Planeswalker — Bolas',
    setCode: 'WAR',
    oracleText: 'Nicol Bolas, Dragon-God has all loyalty abilities of all other planeswalkers on the battlefield.',
    manaCost: '{U}{B}{B}{B}{R}',
    colors: 'U,B,R',
  );
}
