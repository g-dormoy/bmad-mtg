import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mtg/data/models/scryfall_card.dart';
import 'package:mtg/data/providers/database_provider.dart';
import 'package:mtg/data/providers/image_storage_provider.dart';
import 'package:mtg/data/repositories/card_repository.dart';
import 'package:mtg/feature/scanning/models/add_card_state.dart';
import 'package:mtg/feature/scanning/providers/card_recognition_provider.dart';

/// Orchestrates the add-card flow: save to DB, haptic feedback,
/// confirmation display, recognition reset, and background image download.
class AddCardNotifier extends Notifier<AddCardState> {
  @override
  AddCardState build() => const AddCardState.idle();

  /// Adds a recognized card to the collection.
  ///
  /// Debounces duplicate taps (ignores if already adding).
  /// Handles duplicate cards by incrementing quantity (via CardRepository).
  Future<void> addCard(ScryfallCard card) async {
    // Debounce: ignore tap if already adding
    if (state.status == AddCardStatus.adding) return;

    state = const AddCardState.adding();

    try {
      final repository = ref.read(cardRepositoryProvider);

      // 1. Save card to DB immediately (fast, local)
      await repository.addCard(
        scryfallId: card.id,
        name: card.name,
        type: card.typeLine,
        setCode: card.setCode,
        oracleText: card.oracleText,
        manaCost: card.manaCost,
        colors: card.colors?.join(','),
      );

      // 2. Show "Added!" + haptic
      state = const AddCardState.added();
      await HapticFeedback.mediumImpact();

      // 3. After brief delay, reset viewfinder
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      ref.read(cardRecognitionProvider.notifier).reset();
      state = const AddCardState.idle();

      // 4. Background: download image and update DB
      unawaited(_downloadImageInBackground(card, repository));
    } on Exception catch (e) {
      state = AddCardState.error('Failed to add card: $e');
    }
  }

  Future<void> _downloadImageInBackground(
    ScryfallCard card,
    CardRepository repository,
  ) async {
    try {
      final imageService = ref.read(imageStorageServiceProvider);
      final imageUrl = card.imageUris?.normal;
      if (imageUrl == null) return;

      final localPath = await imageService.saveCardImage(
        card.id,
        imageUrl,
      );
      if (localPath == null) return;

      // Update DB record with image path
      final savedCard = await repository.getCardByScryfallId(card.id);
      if (savedCard != null) {
        await repository.updateCard(
          savedCard.copyWith(imagePath: localPath),
        );
      }
    } on Exception {
      // Silently fail - card is already saved, image is non-critical
    }
  }
}

/// Provides the add-card flow state and notifier.
final addCardProvider =
    NotifierProvider<AddCardNotifier, AddCardState>(
  AddCardNotifier.new,
);
