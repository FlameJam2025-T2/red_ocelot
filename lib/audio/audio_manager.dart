// AudioManager singleton
import 'package:flutter_soloud/flutter_soloud.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  late final SoundHandle bgmHandle;
  late final SoundHandle sfxHandle;
  late final SoundHandle musicHandle;
  static final SoLoud soloud = SoLoud.instance;

  /// for web, this should only be called after user interaction.
  Future<void> init() async {
    await soloud.init();

    final bgmSource = await soloud.loadAsset('assets/audio/spaceW0rp.mp3');
    bgmHandle = await soloud.play(
      bgmSource,
      volume: 0.25,
      looping: true,
      paused: true,
    );
    final sfxSource = await soloud.loadAsset('assets/audio/thrust3.mp3');
    sfxHandle = await soloud.play(
      sfxSource,
      volume: 0.3,
      looping: false,
      paused: true,
    );
  }

  void playBGM() {
    soloud.setPause(bgmHandle, false);
  }

  void stopBGM() {
    soloud.setPause(bgmHandle, true);
  }
}
