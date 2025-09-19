import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configure TTS settings
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.8); // Slightly slower for clarity
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      
      // Set voice (optional - will use system default if not available)
      var voices = await _flutterTts.getVoices;
      if (voices.isNotEmpty) {
        // Try to find a clear English voice
        var englishVoices = voices.where((voice) => 
          voice["locale"].toString().startsWith("en")).toList();
        if (englishVoices.isNotEmpty) {
          await _flutterTts.setVoice(englishVoices.first);
        }
      }

      _isInitialized = true;
    } catch (e) {
      print('TTS initialization failed: $e');
    }
  }

  Future<void> speakLetter(String letter) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Stop any ongoing speech
      await _flutterTts.stop();
      
      // Speak the letter
      await _flutterTts.speak(letter);
    } catch (e) {
      print('Failed to speak letter: $e');
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  void dispose() {
    _flutterTts.stop();
  }
}