import 'dart:async';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService extends GetxService {
  final stt.SpeechToText _stt = stt.SpeechToText();
  final RxBool isAvailable = false.obs;
  final RxBool isListening = false.obs;

  Future<VoiceService> init() async {
    // Lazy init on first use
    return this;
  }

  /// Opens the mic, returns the final recognized text (or null on cancel/failure).
  Future<String?> listenOnce({Duration timeout = const Duration(seconds: 8)}) async {
    if (!await _ensureAvailable()) {
      return null;
    }
    final completer = Completer<String?>();
    String finalText = '';

    isListening.value = true;

    await _stt.listen(
      listenFor: timeout,
      pauseFor: const Duration(seconds: 2),
      partialResults: true,
      onResult: (res) {
        if (res.recognizedWords.isNotEmpty) {
          finalText = res.recognizedWords;
        }
        if (res.finalResult && !completer.isCompleted) {
          completer.complete(finalText);
        }
      },
      // onSoundLevelChange: (_, __) {}, // you can ignore
      cancelOnError: true,
      listenMode: stt.ListenMode.dictation,
    );

    // Safety timeout in case finalResult never fires
    Future.delayed(timeout + const Duration(seconds: 2), () {
      if (!completer.isCompleted) completer.complete(finalText.isEmpty ? null : finalText);
    });

    final result = await completer.future;
    await _stt.stop();
    isListening.value = false;
    return result?.trim().isEmpty == true ? null : result?.trim();
  }

  Future<bool> _ensureAvailable() async {
    if (!isAvailable.value) {
      final ok = await _stt.initialize(
        onError: (e) {},
        onStatus: (s) {},
      );
      isAvailable.value = ok;
    }
    return isAvailable.value;
  }
}
