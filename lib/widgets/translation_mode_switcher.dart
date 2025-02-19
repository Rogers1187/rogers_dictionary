import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/util/constants.dart';

class TranslationModeSwitcher extends StatefulWidget {
  const TranslationModeSwitcher({required this.child, this.header});

  final Widget child;

  final Widget? header;

  @override
  _TranslationModeSwitcherState createState() =>
      _TranslationModeSwitcherState();
}

class _TranslationModeSwitcherState extends State<TranslationModeSwitcher> {
  PageController? _controller;

  @override
  void didChangeDependencies() {
    if (_controller == null) {
      final DictionaryPageModel dictionaryModel =
          DictionaryPageModel.readFrom(context);
      _controller = PageController(
        initialPage:
            translationModeToIndex(dictionaryModel.currTranslationMode),

      );
      _controller!.addListener(() {
        dictionaryModel.pageOffset.value = _controller!.page!;
      });
      dictionaryModel.translationPageModel.addListener(() {
        final int targetPage = translationModeToIndex(
            dictionaryModel.translationPageModel.value.translationMode);
        // If the controller isn't attached yet then the PageView will be
        // properly constructed via initialPage.
        if (!_controller!.hasClients ||
            _controller!.page!.round() == targetPage) {
          return;
        }
        _controller!.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
        );
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          if (widget.header != null) widget.header!,
          Expanded(child: pages(context)),
        ],
      ),
      elevation: kHighElevation,
    );
  }

  Widget pages(BuildContext context) {
    final DictionaryPageModel dictionaryModel = DictionaryPageModel.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return PageView(
          controller: _controller,
          onPageChanged: (int index) => DictionaryPageModel.readFrom(context)
              .onTranslationModeChanged(context, indexToTranslationMode(index)),
          children: [
            Provider<TranslationPageModel>.value(
              value: dictionaryModel.englishPageModel,
              builder: (BuildContext context, _) => Theme(
                data: Theme.of(context).copyWith(
                    primaryColor: primaryColor(TranslationMode.English)),
                child: widget.child,
              ),
            ),
            Provider<TranslationPageModel>.value(
              value: dictionaryModel.spanishPageModel,
              builder: (BuildContext context, _) => Theme(
                data: Theme.of(context).copyWith(
                    primaryColor: primaryColor(TranslationMode.Spanish)),
                child: widget.child,
              ),
            ),
          ],
        );
      },
    );
  }
}
