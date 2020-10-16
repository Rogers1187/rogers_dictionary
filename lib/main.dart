import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/dictionary/dictionary_page.dart';

import 'entry_database/entry_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final Future<FirebaseApp> isInitialized = Firebase.initializeApp();
  static final EntryDatabase db = FirestoreDatabase();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dictionary',
      home: DictionaryPage(),
      theme: ThemeData(
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
    );
  }
}
