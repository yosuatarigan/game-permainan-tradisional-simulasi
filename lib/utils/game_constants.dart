// File: lib/utils/game_constants.dart
import 'package:flutter/material.dart';

class GameConstants {
  // OFFICIAL GAME RULES (Sesuai dokumen resmi)
  static const Duration gameDuration = Duration(minutes: 30); // 2 x 15 menit
  static const Duration halfDuration = Duration(minutes: 15);
  static const Duration halfTimeDuration = Duration(minutes: 5);
  static const Duration noMovementTimeout = Duration(minutes: 2);
  
  // FIELD SPECIFICATIONS (Aturan resmi: 15m x 9m)
  static const double fieldRealWidth = 15.0;   // meter
  static const double fieldRealHeight = 9.0;   // meter
  static const double lineWidth = 0.05;        // 5 cm
  static const int sectionsCount = 6;          // 6 petak
  static const double sectionRealWidth = 4.5;  // meter
  static const double sectionRealHeight = 5.0; // meter
  
  // TEAM CONFIGURATION
  static const int playersPerTeam = 5;         // 5 pemain aktif
  static const int substitutePlayersPerTeam = 3; // 3 cadangan
  static const int maxSubstitutionsPerTeam = 3;  // Max 3 pergantian
  static const int totalPlayersPerTeam = 8;    // Total 8 pemain (1-8)
  
  // PLAYER SPECIFICATIONS
  static const double playerRadius = 15.0;
  static const double playerMovementSpeed = 200.0;
  static const double guardLineTolerrance = 20.0;
  static const double touchDetectionRadius = 25.0;
  
  // VISUAL SETTINGS
  static const double fieldPadding = 60.0;
  static const double uiElementSpacing = 16.0;
  static const double buttonHeight = 48.0;
  static const double cardRadius = 12.0;
  
  // ANIMATION SETTINGS
  static const Duration playerMovementDuration = Duration(milliseconds: 300);
  static const Duration scoreEffectDuration = Duration(milliseconds: 500);
  static const Duration touchEffectDuration = Duration(milliseconds: 200);
  static const Duration uiTransitionDuration = Duration(milliseconds: 250);
}

class GameColors {
  // TEAM COLORS
  static const Color teamAColor = Colors.red;
  static const Color teamBColor = Colors.blue;
  static const Color teamALight = Color(0xFFFFCDD2);
  static const Color teamBLight = Color(0xFFBBDEFB);
  
  // FIELD COLORS
  static const Color fieldBackground = Color(0xFFE8F5E8);
  static const Color fieldAlternate = Color(0xFFF1F8E9);
  static const Color fieldBorder = Colors.white;
  static const Color guardLine = Colors.red;
  static const Color centerLine = Colors.blue;
  
  // UI COLORS
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color secondaryGreen = Color(0xFF81C784);
  static const Color backgroundColor = Color(0xFFF1F8E9);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2E7D32);
  static const Color textSecondary = Color(0xFF66BB6A);
  
  // STATUS COLORS
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);
}

class GameTexts {
  // MENU TEXTS
  static const String appTitle = 'Hadang';
  static const String appSubtitle = 'Permainan Tradisional Indonesia';
  static const String playButton = 'Mulai Bermain';
  static const String settingsButton = 'Pengaturan';
  static const String aboutButton = 'Tentang';
  static const String exitButton = 'Keluar';
  
  // GAME TEXTS
  static const String teamRed = 'Tim Merah';
  static const String teamBlue = 'Tim Biru';
  static const String timeLabel = 'Waktu';
  static const String scoreLabel = 'Skor';
  static const String phaseLabel = 'Fase';
  
  // GAME PHASES
  static const String phaseSetup = 'Persiapan';
  static const String phaseFirstHalf = 'Babak 1';
  static const String phaseHalfTime = 'Istirahat';
  static const String phaseSecondHalf = 'Babak 2';
  static const String phaseFinished = 'Selesai';
  
  // CONTROLS
  static const String pauseButton = 'Jeda';
  static const String resumeButton = 'Lanjut';
  static const String restartButton = 'Ulang';
  static const String switchButton = 'Tukar';
  
  // GAME EVENTS
  static const String gameStarted = 'Permainan dimulai!';
  static const String halfTimeReached = 'Waktu istirahat!';
  static const String secondHalfStarted = 'Babak kedua dimulai!';
  static const String gameEnded = 'Permainan selesai!';
  static const String teamSwitched = 'Tim bertukar posisi!';
  static const String playerTouched = 'Pemain tersentuh!';
  static const String scoreAwarded = 'Poin diraih!';
  
  // RULES TEXTS
  static const String ruleGuardStayOnLine = 'Penjaga harus tetap di garis';
  static const String ruleAttackerNoSideline = 'Penyerang tidak boleh keluar garis samping';
  static const String ruleForwardMovement = 'Penyerang harus bergerak maju';
  static const String ruleTouchWithOpenHand = 'Sentuh dengan telapak tangan terbuka';
  static const String rule2MinuteTimeout = 'Batas waktu 2 menit tanpa gerakan';
}

class GameSounds {
  // SOUND FILE PATHS
  static const String soundPlayerMove = 'audio/player_move.mp3';
  static const String soundPlayerTouch = 'audio/player_touch.mp3';
  static const String soundScore = 'audio/score.mp3';
  static const String soundWhistle = 'audio/whistle.mp3';
  static const String soundHalfTime = 'audio/half_time.mp3';
  static const String soundGameEnd = 'audio/game_end.mp3';
  static const String soundTeamSwitch = 'audio/team_switch.mp3';
  
  // BACKGROUND MUSIC
  static const String musicGameplay = 'audio/gameplay_music.mp3';
  static const String musicMenu = 'audio/menu_music.mp3';
}

class GameDifficulty {
  // AI DIFFICULTY LEVELS
  static const Map<String, Map<String, dynamic>> difficultyLevels = {
    'easy': {
      'name': 'Mudah',
      'guardReactionTime': 0.8,
      'attackerSpeed': 0.6,
      'strategicThinking': 0.4,
    },
    'normal': {
      'name': 'Normal',
      'guardReactionTime': 0.6,
      'attackerSpeed': 0.8,
      'strategicThinking': 0.6,
    },
    'hard': {
      'name': 'Sulit',
      'guardReactionTime': 0.4,
      'attackerSpeed': 1.0,
      'strategicThinking': 0.8,
    },
    'expert': {
      'name': 'Ahli',
      'guardReactionTime': 0.2,
      'attackerSpeed': 1.2,
      'strategicThinking': 1.0,
    },
  };
}

class GameSettings {
  // DEFAULT SETTINGS
  static const bool soundEnabled = true;
  static const bool musicEnabled = true;
  static const bool hapticEnabled = true;
  static const bool tutorialEnabled = true;
  static const double soundVolume = 0.8;
  static const double musicVolume = 0.6;
  static const String defaultDifficulty = 'normal';
  static const bool showMovementTrails = true;
  static const bool showRuleHints = true;
  
  // PERFORMANCE SETTINGS
  static const int targetFPS = 60;
  static const bool enableParticleEffects = true;
  static const bool enableShadows = true;
  static const bool enableAntiAliasing = true;
}

class GameAnalytics {
  // ANALYTICS EVENTS
  static const String eventGameStarted = 'game_started';
  static const String eventGameEnded = 'game_ended';
  static const String eventPlayerTouched = 'player_touched';
  static const String eventScoreAwarded = 'score_awarded';
  static const String eventTeamSwitched = 'team_switched';
  static const String eventDifficultyChanged = 'difficulty_changed';
  static const String eventSettingsChanged = 'settings_changed';
  
  // ANALYTICS PARAMETERS
  static const String paramGameDuration = 'game_duration';
  static const String paramFinalScore = 'final_score';
  static const String paramWinningTeam = 'winning_team';
  static const String paramTotalTouches = 'total_touches';
  static const String paramDifficulty = 'difficulty';
}

class GameAchievements {
  // ACHIEVEMENT IDS
  static const String firstWin = 'first_win';
  static const String perfectGame = 'perfect_game';
  static const String speedster = 'speedster';
  static const String defender = 'defender';
  static const String strategist = 'strategist';
  static const String marathon = 'marathon';
  static const String culturalAmbassador = 'cultural_ambassador';
  
  // ACHIEVEMENT DATA
  static const Map<String, Map<String, dynamic>> achievements = {
    firstWin: {
      'name': 'Kemenangan Pertama',
      'description': 'Menangkan permainan pertama Anda',
      'icon': '🏆',
      'points': 100,
    },
    perfectGame: {
      'name': 'Permainan Sempurna',
      'description': 'Menang tanpa pemain tersentuh',
      'icon': '⭐',
      'points': 500,
    },
    speedster: {
      'name': 'Pelari Cepat',
      'description': 'Selesaikan crossing dalam 10 detik',
      'icon': '⚡',
      'points': 200,
    },
    defender: {
      'name': 'Penjaga Tangguh',
      'description': 'Sentuh 5 penyerang dalam satu permainan',
      'icon': '🛡️',
      'points': 300,
    },
    strategist: {
      'name': 'Ahli Strategi',
      'description': 'Menang di tingkat kesulitan Ahli',
      'icon': '🧠',
      'points': 1000,
    },
    marathon: {
      'name': 'Atlet Marathon',
      'description': 'Mainkan 50 permainan',
      'icon': '🏃',
      'points': 750,
    },
    culturalAmbassador: {
      'name': 'Duta Budaya',
      'description': 'Selesaikan tutorial sejarah Hadang',
      'icon': '🎭',
      'points': 150,
    },
  };
}

// Extension methods untuk utility
extension DurationExtension on Duration {
  String toGameTime() {
    final minutes = inMinutes;
    final seconds = inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

extension ColorExtension on Color {
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
  
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}