import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> playNotificationSound() async {
    try {
      // We use a low-latency player for short notification sounds.
      // 'audio1.mp3' is chosen as the default notification sound.
      await _player.play(AssetSource('audio/audio1.mp3'), mode: PlayerMode.lowLatency);
    } catch (e) {
      print("Error playing notification sound: $e");
    }
  }

  // Optional: Add methods for other sounds if needed, e.g., playErrorSound()
}
