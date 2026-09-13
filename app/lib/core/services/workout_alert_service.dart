import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

abstract final class WorkoutAlertService {
  static AudioPlayer? _player;

  /// Emite una vibración física y sonido de campana deportiva al terminar el descanso
  static Future<void> notifyRestCompleted() async {
    // 1. Vibración de hardware real
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(
          pattern: [0, 450, 150, 450],
          intensities: [0, 255, 0, 255],
        );
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (_) {
      try {
        await HapticFeedback.heavyImpact();
      } catch (_) {}
    }

    // 2. Chime de campana de temporizador limpio y deportivo
    try {
      _player ??= AudioPlayer();
      await _player!.stop();
      await _player!.play(AssetSource('audio/timer_end.wav'));
    } catch (_) {
      // Silencioso en entornos de test o sin hardware de audio
    }
  }
}
