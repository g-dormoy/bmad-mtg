import 'package:drift/drift.dart';

/// Database table definition for MTG cards.
///
/// Stores scanned card data with all metadata needed for
/// collection management and filtering.
@DataClassName('CardEntity')
class CardsTable extends Table {
  /// Primary key, auto-incremented.
  IntColumn get id => integer().autoIncrement()();

  /// Unique Scryfall card identifier.
  TextColumn get scryfallId => text().unique()();

  /// Card name (e.g., "Lightning Bolt").
  TextColumn get name => text()();

  /// Card type line (e.g., "Instant", "Creature — Human Wizard").
  TextColumn get type => text()();

  /// Oracle text (rules text) of the card.
  TextColumn get oracleText => text().nullable()();

  /// Mana cost string (e.g., "2UU", "{3}{R}").
  TextColumn get manaCost => text().nullable()();

  /// Color identity as comma-separated values (e.g., "W,U,B").
  TextColumn get colors => text().nullable()();

  /// Set code (e.g., "MKM", "LCI").
  TextColumn get setCode => text()();

  /// Local file path to the scanned card image.
  TextColumn get imagePath => text().nullable()();

  /// Number of copies owned.
  IntColumn get quantity => integer().withDefault(const Constant(1))();

  /// Timestamp when the card was first added.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  String get tableName => 'cards';
}
