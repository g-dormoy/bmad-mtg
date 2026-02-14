import 'package:meta/meta.dart';

/// Image URIs from a Scryfall card response.
///
/// Contains URLs for various image sizes and crops.
@immutable
class ScryfallImageUris {
  /// Creates a new [ScryfallImageUris] instance.
  const ScryfallImageUris({
    required this.small,
    required this.normal,
    required this.large,
    required this.png,
    required this.artCrop,
    required this.borderCrop,
  });

  /// Creates a [ScryfallImageUris] from a JSON map.
  factory ScryfallImageUris.fromJson(Map<String, dynamic> json) {
    return ScryfallImageUris(
      small: json['small'] as String,
      normal: json['normal'] as String,
      large: json['large'] as String,
      png: json['png'] as String,
      artCrop: json['art_crop'] as String,
      borderCrop: json['border_crop'] as String,
    );
  }

  /// 146x204 JPG thumbnail.
  final String small;

  /// 488x680 JPG standard size.
  final String normal;

  /// 672x936 JPG high resolution.
  final String large;

  /// 745x1040 PNG lossless.
  final String png;

  /// Art-only crop.
  final String artCrop;

  /// 480x680 JPG border crop.
  final String borderCrop;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScryfallImageUris &&
        other.small == small &&
        other.normal == normal &&
        other.large == large &&
        other.png == png &&
        other.artCrop == artCrop &&
        other.borderCrop == borderCrop;
  }

  @override
  int get hashCode {
    return Object.hash(small, normal, large, png, artCrop, borderCrop);
  }

  @override
  String toString() {
    return 'ScryfallImageUris(small: $small, normal: $normal, '
        'large: $large, png: $png)';
  }
}

/// Domain model representing a card from the Scryfall API.
///
/// Manually written immutable class (no Freezed code-gen due to
/// build_runner limitations with Homebrew Flutter SDK).
@immutable
class ScryfallCard {
  /// Creates a new [ScryfallCard] instance.
  const ScryfallCard({
    required this.id,
    required this.name,
    required this.typeLine,
    required this.cmc,
    required this.setCode,
    required this.setName,
    required this.rarity,
    this.manaCost,
    this.colors,
    this.oracleText,
    this.imageUris,
  });

  /// Creates a [ScryfallCard] from a Scryfall API JSON response.
  ///
  /// Handles multi-faced cards by extracting `image_uris` from
  /// `card_faces[0]` when top-level `image_uris` is null.
  factory ScryfallCard.fromJson(Map<String, dynamic> json) {
    final imageUrisJson = json['image_uris'] as Map<String, dynamic>? ??
        ((json['card_faces'] as List<dynamic>?)?.first
            as Map<String, dynamic>?)?['image_uris'] as Map<String, dynamic>?;

    final colorsJson = json['colors'] as List<dynamic>?;

    return ScryfallCard(
      id: json['id'] as String,
      name: json['name'] as String,
      typeLine: json['type_line'] as String,
      manaCost: json['mana_cost'] as String?,
      cmc: (json['cmc'] as num).toDouble(),
      colors: colorsJson != null
          ? List<String>.unmodifiable(
              colorsJson.map((e) => e as String),
            )
          : null,
      setCode: json['set'] as String,
      setName: json['set_name'] as String,
      oracleText: json['oracle_text'] as String?,
      rarity: json['rarity'] as String,
      imageUris: imageUrisJson != null
          ? ScryfallImageUris.fromJson(imageUrisJson)
          : null,
    );
  }

  /// Unique Scryfall card identifier (UUID).
  final String id;

  /// Card name (e.g., "Lightning Bolt" or "Front // Back").
  final String name;

  /// Card type line (e.g., "Instant" or "Creature — Human Wizard").
  final String typeLine;

  /// Mana cost string (e.g., "{R}"). Null for lands.
  final String? manaCost;

  /// Converted mana cost / mana value (e.g., 1.0).
  final double cmc;

  /// Color identity in WUBRG notation (e.g., ["R"]). Null for colorless.
  final List<String>? colors;

  /// Set code (e.g., "lea", "cmm").
  final String setCode;

  /// Full set name (e.g., "Limited Edition Alpha").
  final String setName;

  /// Oracle (rules) text. Null for some special cards.
  final String? oracleText;

  /// Rarity: "common", "uncommon", "rare", or "mythic".
  final String rarity;

  /// Image URIs at various sizes. Null if no images available.
  final ScryfallImageUris? imageUris;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScryfallCard) return false;
    return other.id == id &&
        other.name == name &&
        other.typeLine == typeLine &&
        other.manaCost == manaCost &&
        other.cmc == cmc &&
        _listEquals(other.colors, colors) &&
        other.setCode == setCode &&
        other.setName == setName &&
        other.oracleText == oracleText &&
        other.rarity == rarity &&
        other.imageUris == imageUris;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      typeLine,
      manaCost,
      cmc,
      colors != null ? Object.hashAll(colors!) : null,
      setCode,
      setName,
      oracleText,
      rarity,
      imageUris,
    );
  }

  @override
  String toString() {
    return 'ScryfallCard(id: $id, name: $name, typeLine: $typeLine, '
        'manaCost: $manaCost, setCode: $setCode, rarity: $rarity)';
  }
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
