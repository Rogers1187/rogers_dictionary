import 'package:collection/collection.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:flutter/material.dart';

import 'package:rogers_dictionary/clients/entry_builders.dart';
import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/models/search_model.dart';
import 'package:rogers_dictionary/pages/page_header.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/util/delayed.dart';
import 'package:rogers_dictionary/util/overflow_markdown.dart';
import 'package:rogers_dictionary/util/text_utils.dart';
import 'package:rogers_dictionary/widgets/search_page/headword_view.dart';
import 'package:rogers_dictionary/widgets/search_page/search_page_utils.dart';

class EntryViewPage extends StatelessWidget {
  const EntryViewPage({required this.selectedEntry, Key? key})
      : super(key: key);

  final SelectedEntry selectedEntry;

  @override
  Widget build(BuildContext context) {
    return Builder(
      key: ValueKey(selectedEntry.urlEncodedHeadword),
      builder: (context) {
        return FutureBuilder(
          future: selectedEntry.entry,
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
              header: headwordContent(
                context,
                entry,
                false,
                SearchModel.of(context).searchString,
              ),
              child: EntryViewBase._(entry, false),
            );
          },
        );
      },
    );
  }
}

class EntryViewPreview extends StatelessWidget {
  const EntryViewPreview({required this.entry, Key? key}) : super(key: key);

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: Theme.of(context).textTheme.copyWith(
              headline1: bold1(context),
              headline2: bold1(context),
              headline3: bold1(context),
            ),
      ),
      child: EntryViewBase._(entry, true),
    );
  }
}

class EntryViewBase extends StatelessWidget {
  EntryViewBase._(this.entry, this.preview) {
    if (entry.isNotFound) {
      FirebaseCrashlytics.instance.recordError(
        'Invalid headword ${entry.headword}',
        null,
      );
    }
  }

  final Entry entry;
  final bool preview;

  @override
  Widget build(BuildContext context) {
    return EntryView(
      entry: entry,
      preview: preview,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (preview) const HeadwordView(),
          if (!preview) const SizedBox(height: kPad),
          _buildTable(context),
          if (!preview) _buildEditorialNotes(context),
          if (!preview) _buildRelated(context),
        ],
      ),
    );
  }

  Widget _buildRelated(BuildContext context) {
    if (entry.related.isEmpty) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: kSectionSpacer),
        bold1Text(context, i18n.related.get(context)),
        const Divider(),
        ...entry.related.where((r) => r.isNotEmpty).map(
              (headword) => InkWell(
                borderRadius: BorderRadius.circular(kPad),
                child: Padding(
                  padding: const EdgeInsets.all(kPad),
                  child: OverflowMarkdown(
                    headword,
                    defaultStyle: Theme.of(context)
                        .textTheme
                        .bodyText2!
                        .copyWith(color: Colors.blue),
                  ),
                ),
                onTap: () {
                  DictionaryModel.instance.onHeadwordSelected(
                    context,
                    EntryUtils.urlEncode(headword),
                    referrer: SelectedEntryReferrer.relatedHeadword,
                  );
                },
              ),
            ),
      ],
    );
  }

  Widget _buildEditorialNotes(BuildContext context) {
    final Iterable<Widget> notes = entry.translations
        .where((t) => t.editorialNote.isNotEmpty)
        .map((t) => editorialText(context, t.editorialNote));
    if (notes.isEmpty) {
      return Container();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: kSectionSpacer),
        bold1Text(context, i18n.editorialNotes.get(context)),
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
        defaultVerticalAlignment: preview
            ? TableCellVerticalAlignment.middle
            : TableCellVerticalAlignment.top,
        children: _buildTranslations(context));
  }

  // Return a list of TableRows corresponding to each part of speech.
  List<TableRow> _buildTranslations(
    BuildContext context,
  ) {
    return entry.translations
        .groupListsBy((t) => t.partOfSpeech)
        .values
        .map((translations) {
      final partOfSpeech = translations.first.partOfSpeech;
      final inflections = translations.first.irregularInflections;
      return _buildPartOfSpeechTableRow(
        context: context,
        partOfSpeech: partOfSpeech,
        inflections: inflections,
        translations: translations,
      );
    }).toList();
  }

  TableRow _buildPartOfSpeechTableRow({
    required BuildContext context,
    required String partOfSpeech,
    required List<String> inflections,
    required List<Translation> translations,
  }) {
    String parenthetical = '';
    final hasParenthetical = translations
        .any((t) => t.dominantHeadwordParentheticalQualifier.isNotEmpty);
    if (preview)
      return TableRow(
        children: [
          Container(
            padding: translations.first != entry.translations.first
                ? const EdgeInsets.only(top: kPad / 2)
                : null,
            child: partOfSpeechText(context, partOfSpeech, preview),
            alignment: Alignment.topRight,
          ),
          Container(
            alignment: Alignment.topLeft,
            child: previewTranslationLine(
              context,
              translations,
            ),
          ),
        ],
      );
    return TableRow(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: partOfSpeechText(context, partOfSpeech, preview),
            ),
            irregularInflectionsTable(context, inflections),
            Indent(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: translations.map((t) {
                    final bool parentheticalChanged =
                        t.dominantHeadwordParentheticalQualifier !=
                            parenthetical;
                    parenthetical = t.dominantHeadwordParentheticalQualifier;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (parentheticalChanged)
                            Wrap(
                              children: parentheticalTexts(
                                context,
                                parenthetical,
                                false,
                              ),
                            ),
                          _translationContent(
                            context,
                            t,
                            hasParenthetical && parenthetical != '',
                            translations.indexOf(t) + 1,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _translationContent(
      BuildContext context, Translation translation, bool indent, int i) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Indent(
            child: translationLine(context, translation, i),
            size: indent ? null : 0.0),
        examplePhraseText(context, translation.examplePhrases),
      ],
    );
  }
}

class EntryView extends InheritedWidget {
  EntryView({
    required Entry entry,
    required bool preview,
    required Widget child,
  })  : entryData = EntryViewData(entry: entry, isPreview: preview),
        super(child: child);

  final EntryViewData entryData;

  Entry get entry => entryData.entry;

  bool get preview => entryData.isPreview;

  @override
  bool updateShouldNotify(covariant EntryView oldWidget) {
    return oldWidget.entryData.isPreview != entryData.isPreview ||
        oldWidget.entryData.entry != entryData.entry;
  }

  static EntryViewData of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<EntryView>()!.entryData;
  }
}

class EntryViewData {
  EntryViewData({required this.entry, required this.isPreview});

  final Entry entry;
  final bool isPreview;
}
