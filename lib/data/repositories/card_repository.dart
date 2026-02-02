import 'package:drift/drift.dart';

import 'package:mtg/data/database/app_database.dart';
import 'package:mtg/data/database/daos/cards_dao.dart';
import 'package:mtg/data/models/card.dart';

/// Repository for managing card data operations.
///
/// Provides a clean interface for card CRUD operations,
/// abstracting the underlying database implementation.
/// Returns domain [Card] objects instead of database entities.
class CardRepository {
  /// Creates a new CardRepository with the given DAO.
  CardRepository(this._dao);

  final CardsDao _dao;

  /// Adds a card to the collection.
  ///
  /// If the card already exists (by Scryfall ID), increments
  /// the quantity instead of creating a duplicate.
  /// Returns true if successful, false if increment failed unexpectedly.
  Future<bool> addCard({
    required String scryfallId,
    required String name,
    required String type,
    required String setCode,
    String? oracleText,
    String? manaCost,
    String? colors,
    String? imagePath,
  }) async {
    final existing = await _dao.getCardByScryfallId(scryfallId);
    if (existing != null) {
      return _dao.incrementQuantity(existing.id);
    } else {
      await _dao.insertCard(
        CardsTableCompanion.insert(
          scryfallId: scryfallId,
          name: name,
          type: type,
          setCode: setCode,
          oracleText: Value(oracleText),
          manaCost: Value(manaCost),
          colors: Value(colors),
          imagePath: Value(imagePath),
        ),
      );
      return true;
    }
  }

  /// Adds a card from a [Card] domain object.
  /// Returns true if successful, false if increment failed unexpectedly.
  Future<bool> addCardFromModel(Card card) async {
    final existing = await _dao.getCardByScryfallId(card.scryfallId);
    if (existing != null) {
      return _dao.incrementQuantity(existing.id);
    } else {
      await _dao.insertCard(card.toCompanion());
      return true;
    }
  }

  /// Retrieves all cards in the collection as domain models.
  Future<List<Card>> getCards() async {
    final entities = await _dao.getAllCards();
    return entities.map(Card.fromEntity).toList();
  }

  /// Retrieves a card by its database ID.
  Future<Card?> getCard(int id) async {
    final entity = await _dao.getCardById(id);
    return entity != null ? Card.fromEntity(entity) : null;
  }

  /// Retrieves a card by its Scryfall ID.
  Future<Card?> getCardByScryfallId(String scryfallId) async {
    final entity = await _dao.getCardByScryfallId(scryfallId);
    return entity != null ? Card.fromEntity(entity) : null;
  }

  /// Updates an existing card.
  Future<bool> updateCard(Card card) async {
    if (card.id == null) {
      throw ArgumentError('Cannot update card without an ID');
    }
    final entity = CardEntity(
      id: card.id!,
      scryfallId: card.scryfallId,
      name: card.name,
      type: card.type,
      setCode: card.setCode,
      oracleText: card.oracleText,
      manaCost: card.manaCost,
      colors: card.colors,
      imagePath: card.imagePath,
      quantity: card.quantity,
      createdAt: card.createdAt ?? DateTime.now(),
    );
    return _dao.updateCard(entity);
  }

  /// Deletes a card by its database ID.
  Future<int> deleteCard(int id) async {
    return _dao.deleteCard(id);
  }

  /// Gets the count of unique cards in the collection.
  Future<int> getCardCount() async {
    return _dao.getCardCount();
  }

  /// Gets the total quantity of all cards (including duplicates).
  Future<int> getTotalQuantity() async {
    return _dao.getTotalQuantity();
  }

  /// Searches cards by name (case-insensitive partial match).
  Future<List<Card>> searchByName(String query) async {
    final entities = await _dao.searchByName(query);
    return entities.map(Card.fromEntity).toList();
  }

  /// Filters cards by color.
  Future<List<Card>> filterByColor(String color) async {
    final entities = await _dao.filterByColor(color);
    return entities.map(Card.fromEntity).toList();
  }

  /// Filters cards by type.
  Future<List<Card>> filterByType(String type) async {
    final entities = await _dao.filterByType(type);
    return entities.map(Card.fromEntity).toList();
  }

  /// Filters cards by set code.
  Future<List<Card>> filterBySetCode(String setCode) async {
    final entities = await _dao.filterBySetCode(setCode);
    return entities.map(Card.fromEntity).toList();
  }

  /// Gets all unique set codes in the collection.
  Future<List<String>> getUniqueSets() async {
    return _dao.getUniqueSets();
  }
}
