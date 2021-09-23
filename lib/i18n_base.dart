import 'package:rogers_dictionary/util/string_utils.dart';

//  Localization for DictionaryPage.
_CapMessage english = _CapMessage('english', 'inglés');
_CapMessage spanish = _CapMessage('spanish', 'español');

_CapMessage dictionary = _CapMessage('terms', 'términos');
_CapMessage bookmarks = _CapMessage('bookmarks', 'marcadores');
_CapMessage dialogues = _CapMessage('dialogues', 'diálogos');

// Localizations for the about page.
_CapMessage about = _CapMessage('about', 'sobre');

// Localization for EntryList.
_CapMessage search = _CapMessage('search', 'buscar');
Message enterTextHint = Message('Enter text above to search for a translation ',
    '¡Ingrese el texto arriba para buscar una traducción ');
Message noBookmarksHint = Message('No results! Try favoriting an entry first ',
    '¡No hay resultados! Primero, intenta marcar una entrada como favorita ');
Message typosHint = Message('No results! Check for typos ',
    '¡No hay resultados! Compruebe si hay errores tipográficos ');
Message swipeForSpanish = Message(
    'or swipe for spanish mode.', 'o desliza el dedo para al modo español.');
Message swipeForEnglish = Message(
    'or swipe for english mode.', 'o desliza el dedo para al modo inglés.');

// Localizations for EntryView.
Message irregularInflections =
    Message('Irregular Inflections', 'Inflexiones Irregulares');
Message examplePhrases = Message('Example Phrases', 'Frases de Ejemplo');
Message editorialNotes = Message('Editorial Notes', 'Notas Editoriales');
Message related = Message('Related', 'Relacionado');

// Localization for the help menu.
Message giveFeedback = Message('give feedback', 'dar opinion');
Message aboutThisApp = Message('about this app', 'acerca de esta aplicación');

// Localization for getting feedback.
_CapMessage feedback = _CapMessage('feedback', 'comentarios');
_CapMessage feedbackType = _CapMessage('feedback type', 'tipo de comentarios');
_CapMessage submit = _CapMessage('submit', 'enviar');
Message opensEmail = Message(
    '(opens your email app)', '(abre tu aplicación de correo electrónico)');

_CapMessage translationError =
    _CapMessage('translation error', 'error de traducción');
_CapMessage bugReport = _CapMessage('bug report', 'informe de error');
_CapMessage featureRequest =
    _CapMessage('feature request', 'solicitud de función');
_CapMessage other = _CapMessage('other', 'otro');

// Parts of speech
Message adjective = Message('adjective', 'adjetivo');
Message adverb = Message('adverb', 'adverbio');
Message conjunction = Message('conjunction', 'conjunción');
Message degree = Message('degree', 'grado');
Message feminineNoun = Message('feminine noun', 'nombre femenino');
Message femininePluralNoun =
    Message('feminine plural noun', 'nombre femenino plural');
Message femininePluralNounParen =
    Message('feminine (plural) noun', 'nombre femenino (plural)');
Message infinitive = Message('infinitive', 'infinitivo');
Message interjection = Message('interjection', 'interjección');
Message masculineNoun = Message('masculine noun', 'nombre masculino');
Message masculineFeminineNoun =
    Message('masculine/feminine noun', 'nombre masculino/femenino');
Message masculinePluralNoun =
    Message('masculine plural noun', 'nombre masculino plural');
Message masculinePluralNounParen =
    Message('masculine (plural) noun', 'nombre masculino (plural)');
Message noun = Message('noun', 'nombre');
Message pluralNoun = Message('plural noun', 'nombre plural');
Message pluralNounParen = Message('(plural) noun', 'nombre (plural)');
Message prefix = Message('prefix', 'prefijo');
Message preposition = Message('preposition', 'preposición');
Message verb = Message('verb', 'verbo');
Message intransitiveVerb = Message('intransitive verb', 'verbo intransitivo');
Message reflexiveVerb = Message('reflexive verb', 'verbo reflexivo');
Message transitiveVerb = Message('transitive verb', 'verbo transitivo');
Message phrase = Message('phrase', 'frase');
Message blank = Message('', '');

Message adjectivePhrase = Message('adjective phrase', 'frase adjectival');
Message adverbPhrase = Message('adverb phrase', 'frase adverbial');
Message degreePhrase = Message('degree phrase', 'frase de grado');
Message nounPhrase = Message('noun phrase', 'frase nominal');
Message pluralNounPhrase = Message('plural noun phrase', 'frase nominal');
Message prepositionPhrase =
    Message('prepositional phrase', 'frase preposicional');
Message verbPhrase = Message('verb phrase', 'frase verbal');
Message feminineNounPhrase =
    Message('feminine noun phrase', 'frase nominal femenina');
Message femininePluralNounPhrase =
    Message('feminine plural noun phrase', 'frase nominal femenina');
Message masculineFeminineNounPhrase = Message(
    'masculine/feminine noun phrase', 'frase nominal masculina/femenina');
Message masculineNounPhrase =
    Message('masculine noun phase', 'frase nominal masculina');
Message masculinePluralNounPhrase =
    Message('masculine plural phrase', 'frase nominal masculina');
Message masculinePluralNounPhraseParen =
    Message('masculine (plural) phrase', 'frase nominal masculina');

// Misc.
_CapMessage loading = _CapMessage('loading', 'cargando');

Message audioPlaybackTimeoutMsg = Message(
  'Audio playback timed out, check internet connection.',
  'Se agotó el tiempo de reproducción de audio, verifique la conexión a '
      'Internet.',
);
Message dissmiss = Message('Dismiss', 'despide');

class Message {
  Message(this.en, this.es);

  String getFor(bool isSpanish) {
    return isSpanish ? es : en;
  }

  final String en;
  final String es;
}

class _CapMessage extends Message {
  _CapMessage(String english, String spanish, [Message? cap])
      : cap = cap ??
            Message(
              english.capitalizeFirst,
              spanish.capitalizeFirst,
            ),
        super(english, spanish);

  final Message cap;
}
