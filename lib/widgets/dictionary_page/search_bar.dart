import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/search_options.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/search_options_view.dart';

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  FocusNode _focusNode;
  bool _hasText;
  TextEditingController _controller;

  DictionaryPageModel get dictionaryPageModel =>
      DictionaryPageModel.of(context);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_focusNode == null) {
      _focusNode = FocusNode();
      if (dictionaryPageModel.searchBarHasFocus)
        //_focusNode.requestFocus();
        _focusNode.addListener(
            () => dictionaryPageModel.searchBarHasFocus = _focusNode.hasFocus);
    }
    _controller = _controller ??
        TextEditingController(text: dictionaryPageModel.searchString);
    _hasText = _hasText ?? dictionaryPageModel.searchString.isNotEmpty;
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                fit: FlexFit.tight,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40.0),
                    child: Container(
                      color: Theme.of(context).backgroundColor,
                      child: TextField(
                        focusNode: _focusNode,
                        style: TextStyle(fontSize: 20.0),
                        controller: _controller,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: _hasText
                              ? IconButton(
                                  onPressed: () {
                                    _controller.clear();
                                    _onSearchChanged(newSearchString: '');
                                  },
                                  icon: Icon(Icons.clear),
                                )
                              : null,
                          hintText: 'search...',
                          border: InputBorder.none,
                        ),
                        onChanged: (searchString) =>
                            _onSearchChanged(newSearchString: searchString),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 12.0, top: 4.0),
                decoration: BoxDecoration(
                    color: dictionaryPageModel.expandSearchOptions
                        ? Theme.of(context).accentColor
                        : Theme.of(context).primaryColor,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(40.0))),
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 30.0,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.more_vert),
                  color: Colors.white,
                  onPressed: () => setState(() =>
                      dictionaryPageModel.expandSearchOptions =
                          !dictionaryPageModel.expandSearchOptions),
                ),
              ),
            ],
          ),
          if (dictionaryPageModel.expandSearchOptions)
            SearchOptionsView(
                onSearchChanged: (newSearchOptions) =>
                    _onSearchChanged(newSearchOptions: newSearchOptions)),
        ],
      ),
    );
  }

  void _onSearchChanged(
      {String newSearchString, SearchOptions newSearchOptions}) {
    DictionaryPageModel.onSearchChanged(
        context,
        newSearchString ?? DictionaryPageModel.of(context).searchString,
        newSearchOptions ?? DictionaryPageModel.of(context).searchOptions);
    setState(() {
      _hasText = newSearchString?.isNotEmpty ?? _hasText;
    });
  }
}
