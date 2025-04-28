// AudioManager singleton
import 'package:flutter_soloud/flutter_soloud.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  late final SoundHandle bgmHandle;
  late final SoundHandle thrustHandle;
  late final SoundHandle laserHandle;
  // late final SoundHandle musicHandle;
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
    thrustHandle = await soloud.play(
      sfxSource,
      volume: 0.2,
      looping: true,
      paused: true,
    );

    final laserSource = await soloud.loadAsset('assets/audio/laser.mp3');

    laserHandle = await soloud.play(
      laserSource,
      volume: 0.15,
      looping: true,
      paused: true,
      loopingStartAt: Duration(milliseconds: 2620),
    );
  }

  void playBGM() {
    if (soloud.getPause(bgmHandle)) {
      soloud.setPause(bgmHandle, false);
    }
  }

  void stopBGM() {
    if (!soloud.getPause(bgmHandle)) {
      soloud.setPause(bgmHandle, true);
    }
  }

  void playThrust() {
    if (soloud.getPause(thrustHandle)) {
      soloud.setPause(thrustHandle, false);
    }
  }

  void stopThrust() {
    if (!soloud.getPause(thrustHandle)) {
      soloud.setPause(thrustHandle, true);
    }
  }

  void playLaser() {
    soloud.setPause(laserHandle, false);
  }

  void stopLaser() {
    if (!soloud.getPause(laserHandle)) {
      soloud.setPause(laserHandle, true);
    }
  }
}
