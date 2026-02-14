import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:mtg/data/database/daos/cards_dao.dart';
import 'package:mtg/data/database/tables/cards_table.dart';

part 'app_database.g.dart';

/// Main application database using Drift (SQLite).
///
/// Contains the cards table for storing MTG card collection data.
@DriftDatabase(
  tables: [CardsTable],
  daos: [CardsDao],
)
class AppDatabase extends _$AppDatabase {
  /// Creates a new database instance with the default connection.
  AppDatabase() : super(_openConnection());

  /// Creates a database instance for testing with a custom executor.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Create indexes for efficient filtering
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_cards_name ON cards(name)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_cards_colors ON cards(colors)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_cards_type ON cards(type)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_cards_set_code ON cards(set_code)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_cards_mana_cost ON cards(mana_cost)',
        );
      },
    );
  }
}

/// Opens a connection to the SQLite database file.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mtg.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
