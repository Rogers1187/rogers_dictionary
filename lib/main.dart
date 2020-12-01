import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';
import 'package:rogers_dictionary/util/focus_utils.dart';

import 'entry_database/entry_database.dart';
import 'pages/page_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final Future<FirebaseApp> isInitialized = Firebase.initializeApp();
  static final EntryDatabase db = FirestoreDatabase();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          child: MaterialApp(
            title: 'Dictionary',
            onGenerateRoute: PageRouter.generateRoute,
            initialRoute: DictionaryPage.route,
            theme: ThemeData(
              textTheme: TextTheme(
                headline1: TextStyle(fontSize: 36.0, color: Colors.black, fontWeight: FontWeight.bold),
                bodyText1: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
                bodyText2: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
              ),
              accentIconTheme: IconThemeData(
                color: Colors.black38,
              ),
              appBarTheme: AppBarTheme(
                color: Colors.amberAccent
              ),
              selectedRowColor: Colors.amber.shade50,
              shadowColor: Colors.grey.withOpacity(.5),
            ),
          ),
          onTap: () => unFocus(context),
      );
  }
}
