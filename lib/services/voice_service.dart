import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'language_service.dart';

class VoiceService {
  final SpeechToText speech = SpeechToText();
  final FlutterTts tts = FlutterTts();

  String _languageCode = "en-IN";

  Future<bool> initialize() async {
    _languageCode = await LanguageService.getLanguage();

    final available = await speech.initialize();

    if (available) {
      final locales = await speech.locales();

      final languageExists = locales.any(
        (locale) =>
            locale.localeId.toLowerCase() == _languageCode.toLowerCase(),
      );

      if (!languageExists) {
        _languageCode = "en-IN";
      }
    }

    return available;
  }

  Future<void> changeLanguage(String languageCode) async {
    _languageCode = languageCode;

    await LanguageService.saveLanguage(languageCode);

    await tts.setLanguage(_languageCode);
  }

  Future<void> startListening(
    Function(String) onResult, {
    String? languageCode,
  }) async {
    final code = languageCode ?? _languageCode;

    await speech.listen(
      localeId: code,
      onResult: (result) {
        onResult(result.recognizedWords);
      },
    );
  }

  Future<void> stopListening() async {
    await speech.stop();
  }

  Future<void> speak(String text, {String? languageCode}) async {
    final code = languageCode ?? _languageCode;

    await tts.setLanguage(code);
    await tts.setSpeechRate(0.42);
    await tts.setPitch(1.0);

    await tts.stop();
    await tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await tts.stop();
  }

  String get languageCode => _languageCode;
}
