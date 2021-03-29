import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_settings_model.dart';

import 'entry.dart';

// A database interface for fetching dictionary entries.
abstract class EntryDatabase {
  Map<String, bool> _englishFavoritesCache;
  Map<String, bool> _spanishFavoritesCache;

  EntryDatabase()
      : _englishFavoritesCache = {},
        _spanishFavoritesCache = {};

  // Fetch entries from the database.
  Stream<Entry> getEntries(
    TranslationMode translationMode, {
    String searchString,
    int startAfter,
    SearchSettingsModel searchOptions,
  });

  // Get the given entry from the database.
  Future<Entry> getEntry(
      TranslationMode translationMode, String urlEncodedHeadword);

  @mustCallSuper
  Future<bool> setFavorite(TranslationMode translationMode,
          String urlEncodedHeadword, bool favorite) =>
      Future.value(_getCache(translationMode)[urlEncodedHeadword] = favorite);

  Stream<Entry> getFavorites(TranslationMode translationMode, {int startAfter});

  bool isFavorite(TranslationMode translationMode, String urlEncodedHeadword) {
    return _getCache(translationMode)[urlEncodedHeadword];
  }

  Map<String, bool> _getCache(TranslationMode translationMode) =>
      translationMode == TranslationMode.English
          ? _englishFavoritesCache
          : _spanishFavoritesCache;
}
