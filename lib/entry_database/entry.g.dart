// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entry _$EntryFromJson(Map<String, dynamic> json) {
  return Entry(
    json['url_encoded_headword'] as String,
    json['headword'] as String,
    json['entry_id'] as int,
    json['run_on_parent'] as String,
    json['run_on_text'] as String,
    (json['run_ons'] as List)?.map((e) => e as String)?.toList(),
    json['abbreviation'] as String,
    json['naming_standard'] as String,
    json['alternate_headword'] as String,
    json['alternate_headword_abbreviation'] as String,
    json['alternate_headword_naming_standard'] as String,
    (json['translations'] as List)
        ?.map((e) =>
            e == null ? null : Translation.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$EntryToJson(Entry instance) => <String, dynamic>{
      'url_encoded_headword': instance.urlEncodedHeadword,
      'headword': instance.headword,
      'entry_id': instance.entryId,
      'run_on_parent': instance.runOnParent,
      'run_on_text': instance.runOnText,
      'run_ons': instance.runOns,
      'abbreviation': instance.abbreviation,
      'naming_standard': instance.namingStandard,
      'alternate_headword': instance.alternateHeadword,
      'alternate_headword_abbreviation': instance.alternateHeadwordAbbreviation,
      'alternate_headword_naming_standard':
          instance.alternateHeadwordNamingStandard,
      'translations': instance.translations?.map((e) => e?.toJson())?.toList(),
    };

Translation _$TranslationFromJson(Map<String, dynamic> json) {
  return Translation(
    json['meaning_id'] as String,
    json['part_of_speech'] as String,
    json['translation'] as String,
    json['should_be_key_phrase'] as bool,
    json['translation_feminine_indicator'] as String,
    json['gender_and_plural'] as String,
    json['example_phrase'] as String,
    json['editorial_note'] as String,
  );
}

Map<String, dynamic> _$TranslationToJson(Translation instance) =>
    <String, dynamic>{
      'meaning_id': instance.meaningId,
      'part_of_speech': instance.partOfSpeech,
      'translation': instance.translation,
      'should_be_key_phrase': instance.shouldBeKeyPhrase,
      'translation_feminine_indicator': instance.translationFeminineIndicator,
      'gender_and_plural': instance.genderAndPlural,
      'example_phrase': instance.examplePhrase,
      'editorial_note': instance.editorialNote,
    };
