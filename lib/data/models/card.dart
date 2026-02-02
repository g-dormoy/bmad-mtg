import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

import 'package:mtg/data/database/app_database.dart';

/// Domain model for an MTG card.
///
/// This is a simple immutable class representing a card in the collection.
/// Uses manual implementation instead of Freezed due to build_runner
/// limitations with the Homebrew Flutter SDK.
@immutable
class Card {
  /// Creates a new Card instance.
  const Card({
    this.id,
    required this.scryfallId,
    required this.name,
    required this.type,
    required this.setCode,
    this.oracleText,
    this.manaCost,
    this.colors,
    this.imagePath,
    this.quantity = 1,
    this.createdAt,
  });

  /// Database ID (null for new cards).
  final int? id;

  /// Unique Scryfall card identifier.
  final String scryfallId;

  /// Card name.
  final String name;

  /// Card type line.
  final String type;

  /// Set code.
  final String setCode;

  /// Oracle text (rules text) of the card.
  final String? oracleText;

  /// Mana cost string.
  final String? manaCost;

  /// Color identity as comma-separated values.
  final String? colors;

  /// Local file path to the scanned card image.
  final String? imagePath;

  /// Number of copies owned.
  final int quantity;

  /// Timestamp when the card was first added.
  final DateTime? createdAt;

  /// Creates a Card from a database entity.
  factory Card.fromEntity(CardEntity entity) {
    return Card(
      id: entity.id,
      scryfallId: entity.scryfallId,
      name: entity.name,
      type: entity.type,
      setCode: entity.setCode,
      oracleText: entity.oracleText,
      manaCost: entity.manaCost,
      colors: entity.colors,
      imagePath: entity.imagePath,
      quantity: entity.quantity,
      createdAt: entity.createdAt,
    );
  }

  /// Converts to a Drift companion for database insertion.
  CardsTableCompanion toCompanion() {
    return CardsTableCompanion.insert(
      scryfallId: scryfallId,
      name: name,
      type: type,
      setCode: setCode,
      oracleText: Value(oracleText),
      manaCost: Value(manaCost),
      colors: Value(colors),
      imagePath: Value(imagePath),
      quantity: Value(quantity),
    );
  }

  /// Creates a copy with modified fields.
  Card copyWith({
    int? id,
    String? scryfallId,
    String? name,
    String? type,
    String? setCode,
    String? oracleText,
    String? manaCost,
    String? colors,
    String? imagePath,
    int? quantity,
    DateTime? createdAt,
  }) {
    return Card(
      id: id ?? this.id,
      scryfallId: scryfallId ?? this.scryfallId,
      name: name ?? this.name,
      type: type ?? this.type,
      setCode: setCode ?? this.setCode,
      oracleText: oracleText ?? this.oracleText,
      manaCost: manaCost ?? this.manaCost,
      colors: colors ?? this.colors,
      imagePath: imagePath ?? this.imagePath,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Returns a list of color codes from the colors string.
  List<String> get colorList {
    if (colors == null || colors!.isEmpty) return [];
    return colors!.split(',').map((c) => c.trim()).toList();
  }

  /// Returns true if this card is multicolored.
  bool get isMulticolor => colorList.length > 1;

  /// Returns true if this card is colorless.
  bool get isColorless => colors == null || colors!.isEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Card &&
        other.id == id &&
        other.scryfallId == scryfallId &&
        other.name == name &&
        other.type == type &&
        other.setCode == setCode &&
        other.oracleText == oracleText &&
        other.manaCost == manaCost &&
        other.colors == colors &&
        other.imagePath == imagePath &&
        other.quantity == quantity &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      scryfallId,
      name,
      type,
      setCode,
      oracleText,
      manaCost,
      colors,
      imagePath,
      quantity,
      createdAt,
    );
  }

  @override
  String toString() {
    return 'Card(id: $id, scryfallId: $scryfallId, name: $name, '
        'type: $type, setCode: $setCode, oracleText: $oracleText, '
        'manaCost: $manaCost, colors: $colors, quantity: $quantity)';
  }
}
