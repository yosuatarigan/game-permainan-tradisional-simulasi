
// File: lib/services/achievement_service.dart
import '../utils/game_constants.dart';
import 'local_storage_service.dart';

class AchievementService {
  static AchievementService? _instance;
  static AchievementService get instance => _instance ??= AchievementService._();
  AchievementService._();

  final _storage = LocalStorageService.instance;

  void checkAchievements(Map<String, dynamic> gameData) {
    _checkFirstWin(gameData);
    _checkPerfectGame(gameData);
    _checkSpeedster(gameData);
    _checkDefender(gameData);
    _checkStrategist(gameData);
    _checkMarathon();
  }

  void _checkFirstWin(Map<String, dynamic> gameData) {
    if (gameData['won'] == true && !_storage.isAchievementUnlocked(GameAchievements.firstWin)) {
      _unlockAchievement(GameAchievements.firstWin);
    }
  }

  void _checkPerfectGame(Map<String, dynamic> gameData) {
    if (gameData['won'] == true && 
        gameData['touchCount'] == 0 && 
        !_storage.isAchievementUnlocked(GameAchievements.perfectGame)) {
      _unlockAchievement(GameAchievements.perfectGame);
    }
  }

  void _checkSpeedster(Map<String, dynamic> gameData) {
    if (gameData['fastestCrossing'] != null && 
        gameData['fastestCrossing'] <= 10 && 
        !_storage.isAchievementUnlocked(GameAchievements.speedster)) {
      _unlockAchievement(GameAchievements.speedster);
    }
  }

  void _checkDefender(Map<String, dynamic> gameData) {
    if (gameData['touchCount'] != null && 
        gameData['touchCount'] >= 5 && 
        !_storage.isAchievementUnlocked(GameAchievements.defender)) {
      _unlockAchievement(GameAchievements.defender);
    }
  }

  void _checkStrategist(Map<String, dynamic> gameData) {
    if (gameData['won'] == true && 
        _storage.difficulty == 'expert' && 
        !_storage.isAchievementUnlocked(GameAchievements.strategist)) {
      _unlockAchievement(GameAchievements.strategist);
    }
  }

  void _checkMarathon() {
    if (_storage.gamesPlayed >= 50 && 
        !_storage.isAchievementUnlocked(GameAchievements.marathon)) {
      _unlockAchievement(GameAchievements.marathon);
    }
  }

  void _unlockAchievement(String achievementId) {
    _storage.unlockAchievement(achievementId);
    
    // You can add notification/popup logic here
    print('🏆 Achievement Unlocked: ${GameAchievements.achievements[achievementId]?['name']}');
  }

  List<Map<String, dynamic>> getUnlockedAchievements() {
    final unlockedIds = _storage.unlockedAchievements;
    return unlockedIds.map((id) {
      final achievement = GameAchievements.achievements[id];
      if (achievement != null) {
        return {
          'id': id,
          ...achievement,
        };
      }
      return null;
    }).whereType<Map<String, dynamic>>().toList();
  }

  List<Map<String, dynamic>> getAllAchievements() {
    return GameAchievements.achievements.entries.map((entry) {
      return {
        'id': entry.key,
        'unlocked': _storage.isAchievementUnlocked(entry.key),
        ...entry.value,
      };
    }).toList();
  }

  int getTotalAchievementPoints() {
    final unlockedIds = _storage.unlockedAchievements;
    return unlockedIds.fold(0, (total, id) {
      final achievement = GameAchievements.achievements[id];
      return total + (achievement?['points'] as int? ?? 0);
    });
  }

  double getAchievementProgress() {
    final totalAchievements = GameAchievements.achievements.length;
    final unlockedCount = _storage.unlockedAchievements.length;
    return unlockedCount / totalAchievements;
  }
}