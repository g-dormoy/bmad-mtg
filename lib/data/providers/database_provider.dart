import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mtg/data/database/app_database.dart';
import 'package:mtg/data/database/daos/cards_dao.dart';
import 'package:mtg/data/repositories/card_repository.dart';

/// Provider for the application database singleton.
///
/// Creates a single database instance that persists for the app lifetime.
/// Disposes the database connection when the provider is disposed.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Provider for the CardsDao.
///
/// Depends on the database provider to access the DAO.
final cardsDaoProvider = Provider<CardsDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.cardsDao;
});

/// Provider for the CardRepository.
///
/// Depends on the CardsDao provider for data access.
final cardRepositoryProvider = Provider<CardRepository>((ref) {
  final dao = ref.watch(cardsDaoProvider);
  return CardRepository(dao);
});
