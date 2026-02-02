import 'package:drift/drift.dart';

import 'package:mtg/data/database/app_database.dart';
import 'package:mtg/data/database/tables/cards_table.dart';

part 'cards_dao.g.dart';

/// Data Access Object for cards table operations.
///
/// Provides type-safe CRUD operations for MTG cards.
@DriftAccessor(tables: [CardsTable])
class CardsDao extends DatabaseAccessor<AppDatabase> with _$CardsDaoMixin {
  /// Creates a new CardsDao instance.
  CardsDao(super.db);

  /// Inserts a new card into the database.
  ///
  /// Returns the auto-generated ID of the inserted card.
  Future<int> insertCard(CardsTableCompanion card) {
    return into(cardsTable).insert(card);
  }

  /// Retrieves all cards from the database.
  Future<List<CardEntity>> getAllCards() {
    return select(cardsTable).get();
  }

  /// Retrieves a card by its database ID.
  Future<CardEntity?> getCardById(int id) {
    return (select(cardsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Retrieves a card by its Scryfall ID.
  ///
  /// Useful for duplicate detection during scanning.
  Future<CardEntity?> getCardByScryfallId(String scryfallId) {
    return (select(cardsTable)..where((t) => t.scryfallId.equals(scryfallId)))
        .getSingleOrNull();
  }

  /// Updates an existing card.
  ///
  /// Returns true if a row was updated.
  Future<bool> updateCard(CardEntity card) {
    return update(cardsTable).replace(card);
  }

  /// Deletes a card by its database ID.
  ///
  /// Returns the number of deleted rows.
  Future<int> deleteCard(int id) {
    return (delete(cardsTable)..where((t) => t.id.equals(id))).go();
  }

  /// Increments the quantity of an existing card atomically.
  ///
  /// Used when scanning a duplicate card.
  /// Returns true if a card was found and updated, false otherwise.
  Future<bool> incrementQuantity(int id) async {
    final rowsAffected = await customUpdate(
      'UPDATE cards SET quantity = quantity + 1 WHERE id = ?',
      variables: [Variable<int>(id)],
      updates: {cardsTable},
    );
    return rowsAffected > 0;
  }

  /// Gets the total count of unique cards.
  Future<int> getCardCount() async {
    final count = cardsTable.id.count();
    final query = selectOnly(cardsTable)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Gets the total count of all cards (including quantities).
  Future<int> getTotalQuantity() async {
    final sum = cardsTable.quantity.sum();
    final query = selectOnly(cardsTable)..addColumns([sum]);
    final result = await query.getSingle();
    return result.read(sum) ?? 0;
  }

  /// Searches cards by name (case-insensitive partial match).
  ///
  /// Uses custom SQL with ESCAPE clause to properly handle special characters.
  Future<List<CardEntity>> searchByName(String query) async {
    final escaped = query
        .toLowerCase()
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    final results = await customSelect(
      "SELECT * FROM cards WHERE LOWER(name) LIKE '%' || ? || '%' ESCAPE '\\'",
      variables: [Variable<String>(escaped)],
      readsFrom: {cardsTable},
    ).get();
    return results.map((row) => cardsTable.map(row.data)).toList();
  }

  /// Filters cards by color (checks if color is in the colors field).
  ///
  /// Uses custom SQL with ESCAPE clause to properly handle special characters.
  Future<List<CardEntity>> filterByColor(String color) async {
    final escaped = color
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    final results = await customSelect(
      "SELECT * FROM cards WHERE colors LIKE '%' || ? || '%' ESCAPE '\\'",
      variables: [Variable<String>(escaped)],
      readsFrom: {cardsTable},
    ).get();
    return results.map((row) => cardsTable.map(row.data)).toList();
  }

  /// Filters cards by type (partial match).
  ///
  /// Uses custom SQL with ESCAPE clause to properly handle special characters.
  Future<List<CardEntity>> filterByType(String type) async {
    final escaped = type
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    final results = await customSelect(
      "SELECT * FROM cards WHERE type LIKE '%' || ? || '%' ESCAPE '\\'",
      variables: [Variable<String>(escaped)],
      readsFrom: {cardsTable},
    ).get();
    return results.map((row) => cardsTable.map(row.data)).toList();
  }

  /// Filters cards by set code.
  Future<List<CardEntity>> filterBySetCode(String setCode) {
    return (select(cardsTable)..where((t) => t.setCode.equals(setCode))).get();
  }

  /// Gets all unique set codes in the collection.
  Future<List<String>> getUniqueSets() async {
    final query = selectOnly(cardsTable, distinct: true)
      ..addColumns([cardsTable.setCode]);
    final results = await query.get();
    return results.map((row) => row.read(cardsTable.setCode)!).toList();
  }
}
