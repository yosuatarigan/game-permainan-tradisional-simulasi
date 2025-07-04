// File: lib/services/local_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/game_constants.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  static LocalStorageService get instance => _instance ??= LocalStorageService._();
  LocalStorageService._();

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  // GAME SETTINGS
  bool get soundEnabled => _prefs.getBool('sound_enabled') ?? GameSettings.soundEnabled;
  set soundEnabled(bool value) => _prefs.setBool('sound_enabled', value);

  bool get musicEnabled => _prefs.getBool('music_enabled') ?? GameSettings.musicEnabled;
  set musicEnabled(bool value) => _prefs.setBool('music_enabled', value);

  bool get hapticEnabled => _prefs.getBool('haptic_enabled') ?? GameSettings.hapticEnabled;
  set hapticEnabled(bool value) => _prefs.setBool('haptic_enabled', value);

  double get soundVolume => _prefs.getDouble('sound_volume') ?? GameSettings.soundVolume;
  set soundVolume(double value) => _prefs.setDouble('sound_volume', value);

  double get musicVolume => _prefs.getDouble('music_volume') ?? GameSettings.musicVolume;
  set musicVolume(double value) => _prefs.setDouble('music_volume', value);

  String get difficulty => _prefs.getString('difficulty') ?? GameSettings.defaultDifficulty;
  set difficulty(String value) => _prefs.setString('difficulty', value);

  bool get showMovementTrails => _prefs.getBool('show_movement_trails') ?? GameSettings.showMovementTrails;
  set showMovementTrails(bool value) => _prefs.setBool('show_movement_trails', value);

  bool get showRuleHints => _prefs.getBool('show_rule_hints') ?? GameSettings.showRuleHints;
  set showRuleHints(bool value) => _prefs.setBool('show_rule_hints', value);

  bool get tutorialCompleted => _prefs.getBool('tutorial_completed') ?? false;
  set tutorialCompleted(bool value) => _prefs.setBool('tutorial_completed', value);

  // STATISTICS
  int get gamesPlayed => _prefs.getInt('games_played') ?? 0;
  set gamesPlayed(int value) => _prefs.setInt('games_played', value);

  int get gamesWon => _prefs.getInt('games_won') ?? 0;
  set gamesWon(int value) => _prefs.setInt('games_won', value);

  int get totalScore => _prefs.getInt('total_score') ?? 0;
  set totalScore(int value) => _prefs.setInt('total_score', value);

  int get bestScore => _prefs.getInt('best_score') ?? 0;
  set bestScore(int value) => _prefs.setInt('best_score', value);

  int get totalPlayTime => _prefs.getInt('total_play_time') ?? 0; // in seconds
  set totalPlayTime(int value) => _prefs.setInt('total_play_time', value);

  // ACHIEVEMENTS
  List<String> get unlockedAchievements => _prefs.getStringList('unlocked_achievements') ?? [];
  
  void unlockAchievement(String achievementId) {
    final achievements = unlockedAchievements;
    if (!achievements.contains(achievementId)) {
      achievements.add(achievementId);
      _prefs.setStringList('unlocked_achievements', achievements);
    }
  }

  bool isAchievementUnlocked(String achievementId) {
    return unlockedAchievements.contains(achievementId);
  }

  // PLAYER PREFERENCES
  String get preferredTeamColor => _prefs.getString('preferred_team_color') ?? 'red';
  set preferredTeamColor(String value) => _prefs.setString('preferred_team_color', value);

  String get playerName => _prefs.getString('player_name') ?? 'Pemain';
  set playerName(String value) => _prefs.setString('player_name', value);

  // GAME HISTORY (Simple local history)
  List<String> get gameHistory => _prefs.getStringList('game_history') ?? [];
  
  void addGameToHistory(Map<String, dynamic> gameData) {
    final history = gameHistory;
    final gameString = '${gameData['date']},${gameData['score']},${gameData['duration']},${gameData['winner']}';
    history.insert(0, gameString); // Add to beginning
    
    // Keep only last 50 games
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }
    
    _prefs.setStringList('game_history', history);
  }

  List<Map<String, String>> getParsedGameHistory() {
    return gameHistory.map((gameString) {
      final parts = gameString.split(',');
      if (parts.length >= 4) {
        return {
          'date': parts[0],
          'score': parts[1],
          'duration': parts[2],
          'winner': parts[3],
        };
      }
      return <String, String>{};
    }).where((game) => game.isNotEmpty).toList();
  }

  // RESET METHODS
  Future<void> resetSettings() async {
    await _prefs.remove('sound_enabled');
    await _prefs.remove('music_enabled');
    await _prefs.remove('haptic_enabled');
    await _prefs.remove('sound_volume');
    await _prefs.remove('music_volume');
    await _prefs.remove('difficulty');
    await _prefs.remove('show_movement_trails');
    await _prefs.remove('show_rule_hints');
  }

  Future<void> resetStatistics() async {
    await _prefs.remove('games_played');
    await _prefs.remove('games_won');
    await _prefs.remove('total_score');
    await _prefs.remove('best_score');
    await _prefs.remove('total_play_time');
    await _prefs.remove('game_history');
  }

  Future<void> resetAchievements() async {
    await _prefs.remove('unlocked_achievements');
  }

  Future<void> resetAll() async {
    await _prefs.clear();
  }
}

