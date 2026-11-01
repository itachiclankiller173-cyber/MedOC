import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  Future<String> recognizeText(InputImage image) async {
    final RecognizedText recognizedText = await _textRecognizer.processImage(
      image,
    );

    return recognizedText.text;
  }

  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}
