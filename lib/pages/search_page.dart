import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/widgets/search_page/search_bar.dart';

import 'package:rogers_dictionary/widgets/search_page/selected_entry_switcher.dart';
import 'package:rogers_dictionary/widgets/translation_mode_switcher.dart';

class SearchPage extends StatelessWidget {
  static const String route = 'search';

  static bool matchesUri(Uri uri) => uri.pathSegments.contains(route);

  @override
  Widget build(BuildContext context) {
    return const TranslationModeSwitcher(
      header: SearchBar(),
      child: SelectedEntrySwitcher(),
    );
  }
}
