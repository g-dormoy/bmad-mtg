import 'package:flutter_test/flutter_test.dart';
import 'package:mtg/data/models/scryfall_card.dart';

void main() {
  group('ScryfallImageUris', () {
    test('fromJson parses all image URI fields', () {
      final json = <String, dynamic>{
        'small':
            'https://cards.scryfall.io/small/front/e/2/e2d1f0a2.jpg',
        'normal':
            'https://cards.scryfall.io/normal/front/e/2/e2d1f0a2.jpg',
        'large':
            'https://cards.scryfall.io/large/front/e/2/e2d1f0a2.jpg',
        'png':
            'https://cards.scryfall.io/png/front/e/2/e2d1f0a2.png',
        'art_crop':
            'https://cards.scryfall.io/art_crop/front/e/2/e2d1f0a2.jpg',
        'border_crop':
            'https://cards.scryfall.io/border_crop/front/e/2/e2d1f0a2.jpg',
      };

      final uris = ScryfallImageUris.fromJson(json);

      expect(uris.small, contains('small'));
      expect(uris.normal, contains('normal'));
      expect(uris.large, contains('large'));
      expect(uris.png, contains('png'));
      expect(uris.artCrop, contains('art_crop'));
      expect(uris.borderCrop, contains('border_crop'));
    });
  });

  group('ScryfallCard', () {
    group('fromJson', () {
      test('parses a complete Scryfall API response', () {
        final json = _lightningBoltJson();

        final card = ScryfallCard.fromJson(json);

        expect(card.id, equals('e2d1f0a2-c8d5-47a2-ba29-5e813c275ed8'));
        expect(card.name, equals('Lightning Bolt'));
        expect(card.typeLine, equals('Instant'));
        expect(card.manaCost, equals('{R}'));
        expect(card.cmc, equals(1.0));
        expect(card.colors, equals(['R']));
        expect(card.setCode, equals('lea'));
        expect(card.setName, equals('Limited Edition Alpha'));
        expect(
          card.oracleText,
          equals('Lightning Bolt deals 3 damage to any target.'),
        );
        expect(card.rarity, equals('common'));
        expect(card.imageUris, isNotNull);
        expect(card.imageUris!.normal, contains('normal'));
      });

      test('handles null/missing optional fields', () {
        final json = <String, dynamic>{
          'id': 'abc-123',
          'name': 'Forest',
          'type_line': 'Basic Land — Forest',
          'mana_cost': null,
          'cmc': 0.0,
          'colors': <dynamic>[],
          'set': 'lea',
          'set_name': 'Limited Edition Alpha',
          'oracle_text': null,
          'rarity': 'common',
          'image_uris': {
            'small': 'https://example.com/small.jpg',
            'normal': 'https://example.com/normal.jpg',
            'large': 'https://example.com/large.jpg',
            'png': 'https://example.com/card.png',
            'art_crop': 'https://example.com/art.jpg',
            'border_crop': 'https://example.com/border.jpg',
          },
        };

        final card = ScryfallCard.fromJson(json);

        expect(card.manaCost, isNull);
        expect(card.oracleText, isNull);
        expect(card.colors, isEmpty);
        expect(card.cmc, equals(0.0));
      });

      test(
        'extracts image_uris from card_faces[0] when top-level is null',
        () {
          final json = _multiFacedCardJson();

          final card = ScryfallCard.fromJson(json);

          expect(card.imageUris, isNotNull);
          expect(card.imageUris!.normal, contains('front'));
          expect(card.name, equals('Delver of Secrets // Insectile Aberration'));
        },
      );

      test('handles missing image_uris and card_faces gracefully', () {
        final json = <String, dynamic>{
          'id': 'no-img',
          'name': 'Mystery Card',
          'type_line': 'Unknown',
          'cmc': 0.0,
          'set': 'test',
          'set_name': 'Test Set',
          'rarity': 'common',
        };

        final card = ScryfallCard.fromJson(json);

        expect(card.imageUris, isNull);
        expect(card.colors, isNull);
        expect(card.manaCost, isNull);
      });

      test('colors list is correctly parsed from JSON array', () {
        final json = _lightningBoltJson();
        json['colors'] = <dynamic>['W', 'U', 'B'];

        final card = ScryfallCard.fromJson(json);

        expect(card.colors, equals(['W', 'U', 'B']));
        expect(card.colors!.length, equals(3));
      });
    });

    group('equality', () {
      test('two cards with same data are equal', () {
        final card1 = ScryfallCard.fromJson(_lightningBoltJson());
        final card2 = ScryfallCard.fromJson(_lightningBoltJson());

        expect(card1, equals(card2));
        expect(card1.hashCode, equals(card2.hashCode));
      });

      test('two cards with different data are not equal', () {
        final json1 = _lightningBoltJson();
        final json2 = _lightningBoltJson();
        json2['name'] = 'Shock';

        final card1 = ScryfallCard.fromJson(json1);
        final card2 = ScryfallCard.fromJson(json2);

        expect(card1, isNot(equals(card2)));
      });
    });
  });
}

Map<String, dynamic> _lightningBoltJson() => <String, dynamic>{
      'id': 'e2d1f0a2-c8d5-47a2-ba29-5e813c275ed8',
      'name': 'Lightning Bolt',
      'type_line': 'Instant',
      'mana_cost': '{R}',
      'cmc': 1.0,
      'colors': <dynamic>['R'],
      'set': 'lea',
      'set_name': 'Limited Edition Alpha',
      'oracle_text': 'Lightning Bolt deals 3 damage to any target.',
      'rarity': 'common',
      'image_uris': <String, dynamic>{
        'small': 'https://cards.scryfall.io/small/front/e/2/e2d1f0a2.jpg',
        'normal': 'https://cards.scryfall.io/normal/front/e/2/e2d1f0a2.jpg',
        'large': 'https://cards.scryfall.io/large/front/e/2/e2d1f0a2.jpg',
        'png': 'https://cards.scryfall.io/png/front/e/2/e2d1f0a2.png',
        'art_crop':
            'https://cards.scryfall.io/art_crop/front/e/2/e2d1f0a2.jpg',
        'border_crop':
            'https://cards.scryfall.io/border_crop/front/e/2/e2d1f0a2.jpg',
      },
    };

Map<String, dynamic> _multiFacedCardJson() => <String, dynamic>{
      'id': 'multi-face-123',
      'name': 'Delver of Secrets // Insectile Aberration',
      'type_line': 'Creature — Human Wizard // Creature — Human Insect',
      'mana_cost': '{U}',
      'cmc': 1.0,
      'colors': <dynamic>['U'],
      'set': 'isd',
      'set_name': 'Innistrad',
      'oracle_text': null,
      'rarity': 'common',
      'image_uris': null,
      'card_faces': <dynamic>[
        <String, dynamic>{
          'name': 'Delver of Secrets',
          'image_uris': <String, dynamic>{
            'small':
                'https://cards.scryfall.io/small/front/delver.jpg',
            'normal':
                'https://cards.scryfall.io/normal/front/delver.jpg',
            'large':
                'https://cards.scryfall.io/large/front/delver.jpg',
            'png':
                'https://cards.scryfall.io/png/front/delver.png',
            'art_crop':
                'https://cards.scryfall.io/art_crop/front/delver.jpg',
            'border_crop':
                'https://cards.scryfall.io/border_crop/front/delver.jpg',
          },
        },
        <String, dynamic>{
          'name': 'Insectile Aberration',
          'image_uris': <String, dynamic>{
            'small':
                'https://cards.scryfall.io/small/back/delver.jpg',
            'normal':
                'https://cards.scryfall.io/normal/back/delver.jpg',
            'large':
                'https://cards.scryfall.io/large/back/delver.jpg',
            'png':
                'https://cards.scryfall.io/png/back/delver.png',
            'art_crop':
                'https://cards.scryfall.io/art_crop/back/delver.jpg',
            'border_crop':
                'https://cards.scryfall.io/border_crop/back/delver.jpg',
          },
        },
      ],
    };
