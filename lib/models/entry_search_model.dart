import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_settings_model.dart';

class EntrySearchModel with ChangeNotifier {
  final TranslationMode _translationMode;
  String _searchString;
  SearchSettingsModel _searchSettingsModel;
  Stream<Entry> _entryStream;
  LinkedHashSet<Entry> _entries;
  ScrollController _scrollController;
  bool _favoritesOnly;

  String get searchString => _searchString;

  SearchSettingsModel get searchSettingsModel => _searchSettingsModel;

  Stream<Entry> get entryStream => _entryStream;

  List<Entry> get entries => _entries.toList();

  ScrollController get scrollController => _scrollController;

  bool get isEmpty => _searchString.isEmpty;

  bool get favoritesOnly => _favoritesOnly;

  EntrySearchModel._(
      this._translationMode,
      this._searchString,
      this._searchSettingsModel,
      this._entries,
      this._scrollController,
      this._favoritesOnly) {
    _initializeStream();
  }

  void _initializeStream() {
    Stream<Entry> stream;
    if (_favoritesOnly) {
      _entries = LinkedHashSet();
      stream =
          MyApp.db.getFavorites(_translationMode, startAfter: entries.length);
    } else {
      stream = MyApp.db.getEntries(_translationMode,
          searchString: searchString,
          startAfter: entries.length,
          searchOptions: searchSettingsModel);
    }
    _entryStream = stream.map((entry) {
      if (!_entries.add(entry))
        print('WARNING: added duplicate entry ${entry.urlEncodedHeadword}. '
            'Set:\n${_entries.toList()}');
      return entry;
    });
    _scrollController = ScrollController(
        initialScrollOffset:
            _scrollController.hasClients ? _scrollController.offset : 0.0);
  }

  EntrySearchModel.empty(TranslationMode translationMode, bool favoritesOnly)
      : this._(translationMode, '', SearchSettingsModel.empty(),
            LinkedHashSet(), ScrollController(), favoritesOnly);

  void onSearchStringChanged({
    String newSearchString,
    SearchSettingsModel newSearchSettings,
    bool newBookmarksOnly,
  }) {
    // Do nothing if nothing has changed
    if ((newSearchString ?? _searchString) == _searchString &&
        (newSearchSettings ?? _searchSettingsModel) == _searchSettingsModel &&
        (newBookmarksOnly ?? _favoritesOnly) == _favoritesOnly) return;
    _searchString = newSearchString ?? _searchString;
    _searchSettingsModel = newSearchSettings ?? _searchSettingsModel;
    _favoritesOnly = newBookmarksOnly ?? _favoritesOnly;
    _entries = LinkedHashSet();
    _initializeStream();
    _scrollController = ScrollController();
    notifyListeners();
  }

  void resetStream() => _initializeStream();
}
