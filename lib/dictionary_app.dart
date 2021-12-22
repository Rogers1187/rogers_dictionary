import 'package:feedback/feedback.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info/package_info.dart';

import 'package:rogers_dictionary/clients/dictionary_database/dictionary_database.dart';
import 'package:rogers_dictionary/clients/dictionary_database/sqflite_database.dart';
import 'package:rogers_dictionary/clients/feedback_sender.dart';
import 'package:rogers_dictionary/clients/snack_bar_notifier.dart';
import 'package:rogers_dictionary/clients/text_to_speech.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';
import 'package:rogers_dictionary/widgets/get_dictionary_feedback.dart';

class DictionaryApp extends StatefulWidget {
  // Client instances.
  static final DictionaryDatabase db = SqfliteDatabase();
  static final TextToSpeech textToSpeech = TextToSpeech();
  static final Future<PackageInfo> packageInfo = PackageInfo.fromPlatform();
  static final FirebaseAnalytics analytics = FirebaseAnalytics();
  static late SnackBarNotifier _snackBarNotifier;
  static late FeedbackSender _feedback;

  static SnackBarNotifier get snackBarNotifier => _snackBarNotifier;

  static FeedbackSender get feedback => _feedback;

  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  _DictionaryAppState createState() => _DictionaryAppState();
}

class _DictionaryAppState extends State<DictionaryApp> {
  @override
  Future<void> dispose() async {
    await DictionaryApp.textToSpeech.dispose();
    await DictionaryApp.db.dispose();
    await DictionaryApp.feedback.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: BetterFeedback(
        mode: FeedbackMode.draw,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        feedbackBuilder: (BuildContext context, OnSubmit onSubmit) =>
            GetDictionaryFeedback(onSubmit),
        child: MaterialApp(
          title: 'Rogers Dictionary',
          home: Builder(builder: (context) {
            DictionaryApp._snackBarNotifier = SnackBarNotifier(context);
            DictionaryApp._feedback = FeedbackSender(
              locale: Localizations.localeOf(context),
              feedbackController: BetterFeedback.of(context),
            );
            return DictionaryPage();
          }),
          theme: ThemeData(
            selectedRowColor: Colors.grey.shade200,
            textTheme: TextTheme(
              headline1: GoogleFonts.roboto(
                fontSize: 30,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              headline2: GoogleFonts.roboto(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              bodyText2: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('es', ''),
          ],
        ),
      ),
    );
  }
}
