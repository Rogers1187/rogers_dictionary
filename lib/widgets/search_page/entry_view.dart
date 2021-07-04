import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:collection/collection.dart';

import 'package:rogers_dictionary/entry_database/entry_builders.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';
import 'package:rogers_dictionary/util/delayed.dart';
import 'package:rogers_dictionary/util/overflow_markdown.dart';
import 'package:rogers_dictionary/util/text_utils.dart';
import 'package:rogers_dictionary/pages/page_header.dart';

class EntryView extends StatelessWidget {
  const EntryView._instance(this._entry, this._preview);

  final Entry _entry;
  final bool _preview;

  static Widget asPage(BuildContext context) => Builder(
        key: ValueKey(SearchPageModel.of(context).currSelectedHeadword),
        builder: (context) {
          final SearchPageModel searchPageModel = SearchPageModel.of(context);
          if (!searchPageModel.hasSelection)
            return Container(color: Theme.of(context).backgroundColor);
          return FutureBuilder(
            future: searchPageModel.currSelectedEntry.value!.entry,
            builder: (context, AsyncSnapshot<Entry> snap) {
              if (!snap.hasData || snap.data == null)
                // Only display if loading is slow.
                return Delayed(
                  initialChild: Container(),
                  child: Container(),
                  delay: const Duration(milliseconds: 50),
                );
              final Entry entry = snap.data!;
              return PageHeader(
                header: headwordLine(
                    context, entry, false, searchPageModel.searchString),
                child: EntryView._instance(entry, false),
              );
            },
          );
        },
      );

  static Widget asPreview(Entry entry) => EntryView._instance(entry, true);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_preview)
          headwordLine(context, _entry, _preview,
              SearchPageModel.of(context).searchString),
        _buildTable(context),
        if (!_preview) _buildEditorialNotes(context),
        if (!_preview) _buildRelated(context),
      ],
    );
  }

  Widget _buildRelated(BuildContext context) {
    if (_entry.related.isEmpty) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 48),
        bold1Text(context, 'Related'),
        const Divider(),
        ..._entry.related.where((r) => r.isNotEmpty).map(
              (headword) => TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  minimumSize: MaterialStateProperty.all(Size.zero),
                  visualDensity: VisualDensity.compact,
                ),
                child: OverflowMarkdown(
                  headword,
                  defaultStyle: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: Colors.blue),
                ),
                onPressed: () {
                  DictionaryPageModel.readFrom(context).onHeadwordSelected(
                    context,
                    EntryUtils.urlEncode(headword),
                    isRelated: true,
                  );
                },
              ),
            ),
      ],
    );
  }

  Widget _buildEditorialNotes(BuildContext context) {
    final Iterable<Widget> notes = _entry.translations
        .where((t) => t.editorialNote.isNotEmpty)
        .map((t) => editorialText(context, t.editorialNote));
    if (notes.isEmpty) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 48),
        bold1Text(context, 'Editorial Notes'),
        const Divider(),
        ...notes,
      ],
    );
  }

  Widget _buildTable(BuildContext context) {
    return Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        children: _buildTranslations(context));
  }

  // Return a list of TableRows corresponding to each part of speech.
  List<TableRow> _buildTranslations(
    BuildContext context,
  ) {
    return _entry.translations
        .groupListsBy((t) => t.partOfSpeech)
        .values
        .map((translations) {
      final partOfSpeech = translations.first.partOfSpeech;
      final inflections = translations.first.irregularInflections;
      return _buildPartOfSpeechTableRow(
          context, partOfSpeech, inflections, translations);
    }).toList();
  }

  TableRow _buildPartOfSpeechTableRow(BuildContext context, String partOfSpeech,
      List<String> inflections, List<Translation> translations) {
    String parenthetical = '';
    final hasParenthetical = translations
        .any((t) => t.dominantHeadwordParentheticalQualifier.isNotEmpty);
    if (_preview)
      return TableRow(children: [
        Container(
          child: partOfSpeechText(context, partOfSpeech, _preview),
          alignment: Alignment.centerRight,
        ),
        Container(
          padding: const EdgeInsets.only(top: 10),
          child: previewTranslationLine(
            context,
            translations.first,
            translations.length != 1,
          ),
        ),
      ]);
    return TableRow(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            partOfSpeechText(context, partOfSpeech, _preview),
            irregularInflectionsTable(context, inflections),
            Indent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: translations.map((t) {
                  final bool parentheticalChanged =
                      t.dominantHeadwordParentheticalQualifier != parenthetical;
                  parenthetical = t.dominantHeadwordParentheticalQualifier;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (parentheticalChanged)
                        Wrap(
                          children:
                              parentheticalTexts(context, parenthetical, false),
                        ),
                      if (!parentheticalChanged) const SizedBox(height: 5),
                      _translationContent(
                        context,
                        t,
                        hasParenthetical && parenthetical != '',
                        translations.indexOf(t) + 1,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _translationContent(
      BuildContext context, Translation translation, bool indent, int i) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Indent(
              child: translationLine(context, translation, i),
              size: indent ? null : 0.0),
          examplePhraseText(context, translation.examplePhrases),
          const SizedBox(height: 0),
        ],
      ),
    );
  }
}
