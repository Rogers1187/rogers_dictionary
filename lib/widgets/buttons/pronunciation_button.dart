import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rogers_dictionary/clients/text_to_speech.dart';
import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/models/translation_mode.dart';
import 'package:rogers_dictionary/util/color_utils.dart';
import 'package:rogers_dictionary/util/dictionary_progress_indicator.dart';
import 'package:rogers_dictionary/widgets/adaptive_material/adaptive_icon_button.dart';
import 'package:rogers_dictionary/widgets/adaptive_material/adaptive_material.dart';
import 'package:rogers_dictionary/widgets/on_error_stream_builder.dart';

class PronunciationButton extends StatelessWidget {
  PronunciationButton({
    Key? key,
    required this.text,
    required this.mode,
  }) : super(key: key);

  final String text;
  final TranslationMode mode;

  final ValueNotifier<Stream<PlaybackInfo>?> _currPlaybackStream =
      ValueNotifier(null);
  final GlobalKey _buttonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Stream<PlaybackInfo>?>(
      valueListenable: _currPlaybackStream,
      builder: (context, playbackStream, _) {
        late final Widget currButton;
        if (playbackStream == null) {
          currButton =
              _PlayButton(text, mode, _currPlaybackStream, key: _buttonKey);
        } else {
          currButton = _PlayingButton(text, mode, _size, playbackStream, () {
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              _currPlaybackStream.value = null;
            });
          });
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 20),
          child: currButton,
        );
      },
    );
  }

  double get _size =>
      (_buttonKey.currentContext!.findRenderObject() as RenderBox).size.height;
}

class _PlayButton extends StatelessWidget {
  const _PlayButton(
    this.text,
    this.mode,
    this._currPlaybackStream, {
    Key? key,
  }) : super(key: key);

  final String text;
  final TranslationMode mode;
  final ValueNotifier<Stream<PlaybackInfo>?> _currPlaybackStream;

  @override
  Widget build(BuildContext context) {
    return AdaptiveIconButton(
      visualDensity: VisualDensity.compact,
      onPressed: () {
        _currPlaybackStream.value =
            DictionaryApp.textToSpeech.playAudio(text, mode);
        DictionaryApp.analytics.logEvent(
          name: 'play_audio',
          parameters: {
            'text': text,
            'mode': mode.toString().split('.').last,
          },
        );
      },
      icon: const Icon(Icons.volume_up),
    );
  }
}

class _PlayingButton extends StatelessWidget {
  const _PlayingButton(
    this.text,
    this.mode,
    this.size,
    this._playbackStream,
    this._onDone, {
    Key? key,
  }) : super(key: key);

  final String text;
  final TranslationMode mode;
  final double size;
  final Stream<PlaybackInfo> _playbackStream;
  final VoidCallback _onDone;

  @override
  Widget build(BuildContext context) {
    return LoggingStreamBuilder<PlaybackInfo>(
      stream: _playbackStream,
      builder: (context, snap) {
        if (snap.hasError) {
          String message = snap.error.toString();
          if (snap.error is TimeoutException) {
            message = i18n.audioPlaybackTimeoutMsg.get(context);
          }
          DictionaryApp.snackBarNotifier.showErrorMessage(
            message: message,
            extraText: snap.error.toString()
          );
          _onDone();
        }
        if (snap.connectionState == ConnectionState.done) {
          _onDone();
        }
        if (snap.data == null) {
          return _LoadingIndicator(size);
        }
        final PlaybackInfo info = snap.data!;
        // Currently playing.
        return ProgressGradient(
          child: _StopButton(
            _onDone,
            text,
            mode,
          ),
          style: IndicatorStyle.circular,
          progress: info.position.inMilliseconds / info.duration.inMilliseconds,
        );
      },
    );
  }
}

class _StopButton extends StatelessWidget {
  const _StopButton(
    this._onDone,
    this.text,
    this.mode, {
    Key? key,
  }) : super(key: key);

  final VoidCallback _onDone;
  final String text;
  final TranslationMode mode;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: () {
        _onDone();
        DictionaryApp.textToSpeech.stopIfPlaying(text, mode);
      },
      icon: const Icon(Icons.stop),
      color: AdaptiveMaterial.secondaryOnColorOf(context)!
          .bake(Theme.of(context).cardColor),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator(this.size, {Key? key}) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        height: size,
        width: size,
        padding: const EdgeInsets.all(12),
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: AdaptiveMaterial.secondaryOnColorOf(context)!,
        ),
      ),
    );
  }
}
