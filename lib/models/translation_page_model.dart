import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:rogers_dictionary/models/search_page_model.dart';

import 'dialogues_page_model.dart';

enum TranslationMode {
  English,
  Spanish,
}

class TranslationPageModel {
  TranslationPageModel({
    required this.translationMode,
  })  : searchPageModel = SearchPageModel(
          translationMode: translationMode,
          isBookmarkedOnly: false,
        ),
        bookmarksPageModel = SearchPageModel(
          translationMode: translationMode,
          isBookmarkedOnly: true,
        ),
        layerLink = LayerLink();

  // Translation mode state.
  final TranslationMode translationMode;

  final SearchPageModel searchPageModel;

  final SearchPageModel bookmarksPageModel;

  final LayerLink layerLink;

  static final DialoguesPageModel _dialoguesPageModel = DialoguesPageModel();

  DialoguesPageModel get dialoguesPageModel => _dialoguesPageModel;

  bool get isEnglish => translationMode == TranslationMode.English;

  static TranslationPageModel of(BuildContext context) =>
      context.read<TranslationPageModel>();
}
