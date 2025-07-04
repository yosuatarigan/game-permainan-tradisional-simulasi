
// File: lib/services/statistics_service.dart
import 'package:game_permainan_tradisional_simulasi/services/achievement_service.dart';

import 'local_storage_service.dart';

class StatisticsService {
  static StatisticsService? _instance;
  static StatisticsService get instance => _instance ??= StatisticsService._();
  StatisticsService._();

  final _storage = LocalStorageService.instance;

  void recordGameResult({
    required bool won,
    required int finalScore,
    required Duration gameDuration,
    required int touchCount,
    double? fastestCrossing,
  }) {
    // Update basic stats
    _storage.gamesPlayed += 1;
    if (won) _storage.gamesWon += 1;
    
    _storage.totalScore += finalScore;
    if (finalScore > _storage.bestScore) {
      _storage.bestScore = finalScore;
    }
    
    _storage.totalPlayTime += gameDuration.inSeconds;

    // Add to game history
    _storage.addGameToHistory({
      'date': DateTime.now().toIso8601String(),
      'score': finalScore.toString(),
      'duration': gameDuration.inMinutes.toString(),
      'winner': won ? 'Player' : 'AI',
    });

    // Check achievements
    AchievementService.instance.checkAchievements({
      'won': won,
      'touchCount': touchCount,
      'fastestCrossing': fastestCrossing,
    });
  }

  Map<String, dynamic> getStatistics() {
    final gamesPlayed = _storage.gamesPlayed;
    final gamesWon = _storage.gamesWon;
    
    return {
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'winRate': gamesPlayed > 0 ? (gamesWon / gamesPlayed * 100) : 0.0,
      'totalScore': _storage.totalScore,
      'bestScore': _storage.bestScore,
      'averageScore': gamesPlayed > 0 ? (_storage.totalScore / gamesPlayed) : 0.0,
      'totalPlayTime': Duration(seconds: _storage.totalPlayTime),
      'averageGameTime': gamesPlayed > 0 
          ? Duration(seconds: _storage.totalPlayTime ~/ gamesPlayed)
          : Duration.zero,
      'achievementProgress': AchievementService.instance.getAchievementProgress(),
      'achievementPoints': AchievementService.instance.getTotalAchievementPoints(),
    };
  }

  List<Map<String, String>> getRecentGames({int limit = 10}) {
    final history = _storage.getParsedGameHistory();
    return history.take(limit).toList();
  }
}