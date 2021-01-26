import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';
import 'package:rogers_dictionary/util/delayed.dart';
import 'package:rogers_dictionary/widgets/dictionary_bottom_navigation_bar.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/entry_search.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/entry_view.dart';
import 'package:rogers_dictionary/widgets/slide_entrance_exit.dart';

class SearchPage extends StatelessWidget {
  static bool matchesRoute(Uri uri) =>
      ListEquality().equals(uri.pathSegments, ['search']);

  @override
  Widget build(BuildContext context) {
    final dictionaryPageModel = SearchPageModel.of(context);
    final primaryColor =
        dictionaryPageModel.isEnglish ? Colors.indigo : Colors.amber;
    final secondaryColor = dictionaryPageModel.isEnglish
        ? Colors.indigo.shade100
        : Colors.amber.shade100;

    return ListenableProvider.value(
      value: dictionaryPageModel.entrySearchModel,
      child: Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: AppBarTheme(color: primaryColor, elevation: 0.0),
          primaryColor: primaryColor,
          accentColor: secondaryColor,
        ),
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  Text(dictionaryPageModel.isEnglish
                      ? 'English to Spanish'
                      : 'Spanish to English'),
                  IconButton(
                    icon: Icon(
                      Icons.info,
                      size: 30.0,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            body: Column(
              children: [
                Expanded(child: _buildOrientedPage(context, EntrySearch())),
                Delayed(
                  delay: Duration(milliseconds: 1),
                  initialChild: DictionaryBottomNavigationBar(
                      translationMode:
                          dictionaryPageModel.transitionFrom?.translationMode ??
                              dictionaryPageModel.translationMode),
                  child: DictionaryBottomNavigationBar(
                      translationMode: dictionaryPageModel.translationMode),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrientedPage(BuildContext context, EntrySearch entrySearch) {
    final dictionaryPageModel = SearchPageModel.of(context);
    final animation = ModalRoute.of(context).animation;
    final secondaryAnimation = ModalRoute.of(context).secondaryAnimation;

    return LayoutBuilder(
      builder: (context, constraints) {
        switch (MediaQuery.of(context).orientation) {
          case Orientation.portrait:
            return Stack(
              children: [
                Container(
                  color: Colors.transparent,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                ),
                if (dictionaryPageModel.hasSelection)
                  Positioned(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: AnimatedBuilder(
                      animation: animation,
                      builder: (context, _) => SlideEntranceExit(
                        offset: Offset(
                            dictionaryPageModel.isTransitionToSelectedHeadword
                                ? -1.0
                                : 1.0,
                            0.0),
                        entranceAnimation:
                            dictionaryPageModel.isTransitionFromTranslationMode
                                ? kAlwaysCompleteAnimation
                                : animation,
                        exitAnimation:
                            dictionaryPageModel.isTransitionFromTranslationMode
                                ? kAlwaysDismissedAnimation
                                : secondaryAnimation,
                        child: EntryView.asPage(),
                      ),
                    ),
                  ),
                if (!dictionaryPageModel.hasSelection)
                  Positioned(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: SlideEntranceExit(
                      offset: Offset(-1.0, 0.0),
                      entranceAnimation:
                          dictionaryPageModel.isTransitionFromTranslationMode
                              ? kAlwaysCompleteAnimation
                              : animation,
                      exitAnimation:
                          dictionaryPageModel.isTransitionFromTranslationMode
                              ? kAlwaysDismissedAnimation
                              : secondaryAnimation,
                      child: DecoratedBox(
                        child: Row(
                          children: [
                            Expanded(child: entrySearch),
                          ],
                        ),
                        decoration: BoxDecoration(),
                      ),
                    ),
                  ),
              ],
            );
          case Orientation.landscape:
            return Stack(
              children: [
                AnimatedBuilder(
                  animation: secondaryAnimation,
                  builder: (context, _) => Container(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      color: secondaryAnimation.isCompleted ||
                              secondaryAnimation.isDismissed
                          ? Colors.transparent
                          : Theme.of(context).scaffoldBackgroundColor),
                ),
                Positioned(
                  left: constraints.maxWidth / 3.0,
                  height: constraints.maxHeight,
                  width: 2.0 * constraints.maxWidth / 3.0,
                  child: SlideEntranceExit(
                    offset: dictionaryPageModel.hasSelection
                        ? Offset(-1.0, 0.0)
                        : Offset.zero,
                    entranceAnimation:
                        dictionaryPageModel.isTransitionFromTranslationMode
                            ? kAlwaysCompleteAnimation
                            : CurvedAnimation(
                                parent: animation, curve: Interval(0.5, 1.0)),
                    exitAnimation:
                        dictionaryPageModel.isTransitionFromTranslationMode
                            ? kAlwaysDismissedAnimation
                            : CurvedAnimation(
                                parent: secondaryAnimation,
                                curve: Interval(0.0, 0.5),
                              ),
                    child: EntryView.asPage(),
                  ),
                ),
                Positioned(
                  width: constraints.maxWidth / 3.0,
                  height: constraints.maxHeight,
                  child: SlideEntranceExit(
                    offset: Offset.zero,
                    entranceAnimation: kAlwaysCompleteAnimation,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                      ),
                      child: Row(
                        children: [
                          Expanded(child: entrySearch),
                          VerticalDivider(width: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          default:
            return Container();
        }
      },
    );
  }
}
