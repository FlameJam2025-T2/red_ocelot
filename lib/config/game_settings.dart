import 'package:red_ocelot/config/world_parameters.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HighScore {
  final Duration time;
  final int score;
  final DateTime dateTime;

  HighScore(this.time, this.score, {DateTime? dateTime})
    : dateTime = dateTime ?? DateTime.now();
  @override
  String toString() {
    return 'HighScore{time: $time, score: $score}';
  }
}

extension HighScoreList on List<HighScore> {
  /// Sorts the list of high scores by score (higher is better)
  /// + time (lower is better).
  void sortByScore() {
    sort((a, b) {
      if (a.score != b.score) {
        return b.score.compareTo(a.score);
      } else {
        return a.time.compareTo(b.time);
      }
    });
  }

  /// Sorts the list of high scores in ascending order based on the time.
  void sortByTime() {
    sort((a, b) => a.time.compareTo(b.time));
  }

  List<String> toPreferencesStringList() {
    return map(
      (e) => '${e.time.inMilliseconds},${e.score},${e.dateTime}',
    ).toList();
  }

  static List<HighScore> fromPreferencesStringList(List<String> scores) {
    return scores.map((e) {
      final parts = e.split(',');
      final time = Duration(milliseconds: int.parse(parts[0]));
      final score = int.parse(parts[1]);
      final dateTime = DateTime.parse(parts[2]);
      return HighScore(time, score, dateTime: dateTime);
    }).toList();
  }

  /// Adds a new high score to the list in scoring order.
  /// If [addIfLower] is true, the new score will be added even if it is lower
  /// than the lowest score in the list.
  void addHighScore(
    HighScore newScore,
    int maxLength, {
    bool addIfLower = false,
  }) {
    if (addIfLower || isEmpty || newScore.score > last.score) {
      add(newScore);
      sortByScore();
      if (length > maxLength) {
        removeRange(maxLength, length);
      }
    }
  }

  /// Clears the list of high scores.
  void clearHighScores() {
    clear();
  }
}

//// [defaultSettings] contains the definitive list of game settings, and
/// the default values for each setting.
const Map<String, dynamic> defaultSettings = {
  'soundEnabled': true,
  'soundVolume': 1.0,
  'musicEnabled': true,
  'musicVolume': 1.0,
  'vibrationEnabled': true,
  'vibrationStrength': 1.0,
  'highScores': <HighScore>[],
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
  static final Map<String, Object> cache = {};
  late final SharedPreferencesWithCache _prefs;

  static final GameSettings _instance = GameSettings._internal();
  factory GameSettings() {
    return _instance;
  }

  GameSettings._internal();

  static Future<void> init() async {
    _instance._prefs = await SharedPreferencesWithCache.create(
      cache: cache,
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
  }

  /// Sound setting
  Future<bool> get soundEnabled async =>
      _prefs.getBool('soundEnabled') ?? defaultSettings['soundEnabled'];
  Future<void> setSoundEnabled(bool value) async {
    _prefs.setBool('soundEnabled', value);
  }

  /// Sound volume setting
  /// This value is between 0.0 and 1.0
  /// Default is 1.0
  Future<double> get soundVolume async =>
      _prefs.getDouble('soundVolume') ?? defaultSettings['soundVolume'];
  Future<void> setSoundVolume(double value) async {
    _prefs.setDouble('soundVolume', value);
  }

  /// Music setting
  Future<bool> get musicEnabled async =>
      _prefs.getBool('musicEnabled') ?? defaultSettings['musicEnabled'];
  Future<void> setMusicEnabled(bool value) async {
    _prefs.setBool('musicEnabled', value);
  }

  /// Music volume setting
  /// This value is between 0.0 and 1.0
  /// Default is 1.0
  Future<double> get musicVolume async =>
      _prefs.getDouble('musicVolume') ?? defaultSettings['musicVolume'];
  Future<void> setMusicVolume(double value) async {
    _prefs.setDouble('musicVolume', value);
  }

  /// Vibration setting
  Future<bool> get vibrationEnabled async =>
      _prefs.getBool('vibrationEnabled') ?? defaultSettings['vibrationEnabled'];
  Future<void> setVibrationEnabled(bool value) async {
    _prefs.setBool('vibrationEnabled', value);
  }

  /// Vibration strength setting
  /// This value is between 0.0 and 1.0
  /// Default is 1.0
  Future<double> get vibrationStrength async =>
      _prefs.getDouble('vibrationStrength') ??
      defaultSettings['vibrationStrength'];
  Future<void> setVibrationStrength(double value) async {
    _prefs.setDouble('vibrationStrength', value);
  }

  /// High scores setting
  /// This is a list of HighScore objects
  /// Default is an empty list
  Future<List<HighScore>> get highScores async {
    final List<String> scores = _prefs.getStringList('highScores') ?? [];
    return HighScoreList.fromPreferencesStringList(scores);
  }

  Future<void> setHighScores(List<HighScore> scores) async {
    final List<String> scoresString =
        HighScoreList(scores).toPreferencesStringList();
    _prefs.setStringList('highScores', scoresString);
  }

  Future<void> addHighScore(HighScore newScore) async {
    final List<HighScore> scores = await highScores;
    scores.addHighScore(newScore, highScoreCount);
    await setHighScores(scores);
  }

  Future<void> clearHighScores() async {
    final List<HighScore> scores = await highScores;
    scores.clearHighScores();
    await setHighScores(scores);
  }

  Future<void> resetSettings() async {
    final prefs = await _prefs;
    for (final key in defaultSettings.keys) {
      if (key == 'highScores') {
        prefs.remove(key);
      } else {
        prefs.setString(key, defaultSettings[key].toString());
      }
    }
  }
}
