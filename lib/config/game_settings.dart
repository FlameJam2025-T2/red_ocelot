import 'package:shared_preferences/shared_preferences.dart';

//// [defaultSettings] contains the definitive list of game settings, and
/// the default values for each setting.
const Map<String, dynamic> defaultSettings = {
  'soundEnabled': true,
  'soundVolume': 1.0,
  'musicEnabled': true,
  'musicVolume': 1.0,
  'vibrationEnabled': true,
  'vibrationStrength': 1.0,
};

/// This (singleton) class is used to manage the game settings.
/// It uses the shared_preferences package to store and retrieve settings.
///
/// The settings include (for now):
/// - soundEnabled: A boolean value indicating whether sound is enabled or disabled.
/// - soundVolume: A double value indicating the volume level of the sound.
/// - musicEnabled: A boolean value indicating whether music is enabled or disabled.
/// - musicVolume: A double value indicating the volume level of the music.
/// - vibrationEnabled: A boolean value indicating whether vibration is enabled or
///   disabled.
/// - vibrationStrength: A double value indicating the strength of the
///   vibration.
class GameSettings {
  final Future<SharedPreferencesWithCache> _prefs;
  static final GameSettings _instance = GameSettings._internal();
  factory GameSettings() {
    return _instance;
  }

  GameSettings._internal()
    : _prefs = SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(),
      );

  /// Sound setting
  Future<bool> get soundEnabled async =>
      (await _prefs).getBool('soundEnabled') ?? defaultSettings['soundEnabled'];
  Future<void> setSoundEnabled(bool value) async {
    (await _prefs).setBool('soundEnabled', value);
  }

  /// Sound volume setting
  /// This value is between 0.0 and 1.0
  /// Default is 1.0
  Future<double> get soundVolume async =>
      (await _prefs).getDouble('soundVolume') ?? defaultSettings['soundVolume'];
  Future<void> setSoundVolume(double value) async {
    (await _prefs).setDouble('soundVolume', value);
  }

  /// Music setting
  Future<bool> get musicEnabled async =>
      (await _prefs).getBool('musicEnabled') ?? defaultSettings['musicEnabled'];
  Future<void> setMusicEnabled(bool value) async {
    (await _prefs).setBool('musicEnabled', value);
  }

  /// Music volume setting
  /// This value is between 0.0 and 1.0
  /// Default is 1.0
  Future<double> get musicVolume async =>
      (await _prefs).getDouble('musicVolume') ?? defaultSettings['musicVolume'];
  Future<void> setMusicVolume(double value) async {
    (await _prefs).setDouble('musicVolume', value);
  }

  /// Vibration setting
  Future<bool> get vibrationEnabled async =>
      (await _prefs).getBool('vibrationEnabled') ??
      defaultSettings['vibrationEnabled'];
  Future<void> setVibrationEnabled(bool value) async {
    (await _prefs).setBool('vibrationEnabled', value);
  }

  /// Vibration strength setting
  /// This value is between 0.0 and 1.0
  /// Default is 1.0
  Future<double> get vibrationStrength async =>
      (await _prefs).getDouble('vibrationStrength') ??
      defaultSettings['vibrationStrength'];
  Future<void> setVibrationStrength(double value) async {
    (await _prefs).setDouble('vibrationStrength', value);
  }
}
