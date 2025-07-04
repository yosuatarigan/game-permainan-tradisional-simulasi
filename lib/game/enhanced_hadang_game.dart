// File: lib/game/enhanced_hadang_game.dart
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_permainan_tradisional_simulasi/models/game_state.dart';
import 'components/hadang_field.dart';
import 'components/player.dart';
import 'ai/hadang_ai.dart';
import '../services/audio_service.dart';
import '../services/local_storage_service.dart';
import '../services/statistics_service.dart';
import '../utils/game_constants.dart';

class EnhancedHadangGame extends FlameGame with HasTappables, HasCollisionDetection {
  // Core game components
  late HadangGameState gameState;
  late HadangField field;
  late HadangAI aiController;
  
  // Services
  final _audio = AudioService.instance;
  final _storage = LocalStorageService.instance;
  final _statistics = StatisticsService.instance;
  
  // Players
  final List<HadangPlayer> teamAPlayers = [];
  final List<HadangPlayer> teamBPlayers = [];
  
  // UI Components
  late TextComponent scoreDisplay;
  late TextComponent timeDisplay;
  late TextComponent gamePhaseDisplay;
  late TextComponent hintDisplay;
  
  // Game state tracking
  bool _isInitialized = false;
  bool _gameStarted = false;
  Duration _gameStartTime = Duration.zero;
  int _touchCount = 0;
  double? _fastestCrossing;
  
  // AI settings
  bool _aiEnabled = true;
  String _aiDifficulty = 'normal';
  
  // Visual settings
  bool _showMovementTrails = true;
  bool _showRuleHints = true;
  
  // Public getters for UI
  int get scoreTeamA => gameState.scoreTeamA;
  int get scoreTeamB => gameState.scoreTeamB;
  String get currentPhase => gameState.currentPhase.toString();
  bool get isPaused => gameState.isPaused;
  Widget get widget => GameWidget(game: this);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _initializeServices();
    await _setupGame();
  }

  Future<void> _initializeServices() async {
    await _audio.initialize();
    await _storage.initialize();
    
    // Load settings
    _aiDifficulty = _storage.difficulty;
    _showMovementTrails = _storage.showMovementTrails;
    _showRuleHints = _storage.showRuleHints;
    
    // Initialize AI
    aiController = HadangAI.instance;
    aiController.initialize(_aiDifficulty);
    
    _isInitialized = true;
  }

  Future<void> _setupGame() async {
    // Initialize game state
    gameState = HadangGameState();
    
    // Setup camera
    camera.viewfinder.visibleGameSize = size;
    
    // Create field
    field = HadangField();
    await add(field);
    
    // Create players
    await _createPlayers();
    
    // Setup UI
    await _setupUI();
    
    // Load audio
    await _preloadAudio();
    
    // Start background music
    await _audio.playGameplayMusic();
  }

  Future<void> _createPlayers() async {
    // Team A (Red) - Starting as Guards
    for (int i = 0; i < GameConstants.playersPerTeam; i++) {
      final player = HadangPlayer(
        playerId: i + 1,
        team: PlayerTeam.teamA,
        initialRole: PlayerRole.guard,
        playerColor: GameColors.teamAColor,
      );
      teamAPlayers.add(player);
      await add(player);
    }
    
    // Team B (Blue) - Starting as Attackers  
    for (int i = 0; i < GameConstants.playersPerTeam; i++) {
      final player = HadangPlayer(
        playerId: i + 1,
        team: PlayerTeam.teamB,
        initialRole: PlayerRole.attacker,
        playerColor: GameColors.teamBColor,
      );
      teamBPlayers.add(player);
      await add(player);
    }
    
    _setInitialPositions();
  }

  void _setInitialPositions() {
    final fieldCenter = field.fieldRect.center;
    
    // Position guards on their lines (Team A)
    for (int i = 0; i < 4; i++) {
      if (i < field.horizontalLines.length) {
        final guardLine = field.horizontalLines[i];
        teamAPlayers[i].setPosition(Vector2(
          guardLine.start.x + (guardLine.end.x - guardLine.start.x) / 2,
          guardLine.start.y,
        ));
        teamAPlayers[i].assignToLine(guardLine);
      }
    }
    
    // Position center guard (sodor)
    if (teamAPlayers.length > 4) {
      teamAPlayers[4].setPosition(Vector2(fieldCenter.x, fieldCenter.y));
      teamAPlayers[4].assignToLine(field.centerLine);
    }
    
    // Position attackers at starting line (Team B)
    for (int i = 0; i < teamBPlayers.length; i++) {
      teamBPlayers[i].setPosition(Vector2(
        field.fieldRect.left + 50 + (i * 60),
        field.fieldRect.top - 30,
      ));
    }
  }

  Future<void> _setupUI() async {
    // Score display
    scoreDisplay = TextComponent(
      text: 'Merah: ${gameState.scoreTeamA} - Biru: ${gameState.scoreTeamB}',
      position: Vector2(20, 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black),
          ],
        ),
      ),
    );
    await add(scoreDisplay);
    
    // Time display
    timeDisplay = TextComponent(
      text: 'Waktu: ${_formatTime(gameState.gameTime)}',
      position: Vector2(20, 45),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black),
          ],
        ),
      ),
    );
    await add(timeDisplay);
    
    // Game phase display
    gamePhaseDisplay = TextComponent(
      text: 'Fase: ${gameState.currentPhase.name}',
      position: Vector2(20, 70),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black),
          ],
        ),
      ),
    );
    await add(gamePhaseDisplay);
    
    // Hint display (if enabled)
    if (_showRuleHints) {
      hintDisplay = TextComponent(
        text: 'Tap pemain biru untuk memilih, tap area untuk bergerak',
        position: Vector2(20, size.y - 40),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            shadows: [
              Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black),
            ],
          ),
        ),
      );
      await add(hintDisplay);
    }
  }

  Future<void> _preloadAudio() async {
    final soundsToPreload = [
      GameSounds.soundPlayerMove,
      GameSounds.soundPlayerTouch,
      GameSounds.soundScore,
      GameSounds.soundWhistle,
    ];
    
    await _audio.preloadSounds(soundsToPreload);
  }

  void _startGame() {
    if (!_gameStarted) {
      gameState.startGame();
      _gameStarted = true;
      _gameStartTime = Duration.zero;
      _audio.playWhistleSound();
      _updateHint('Permainan dimulai! Selamat bermain!');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!_isInitialized) return;
    
    if (!_gameStarted) {
      _startGame();
      return;
    }
    
    if (!gameState.isPaused && gameState.isGameActive()) {
      gameState.updateTime(dt);
      _gameStartTime += Duration(milliseconds: (dt * 1000).round());
      
      _updateAI(dt);
      _checkGameRules();
      _updateUI();
      _updateHints();
      
      if (gameState.shouldEndGame()) {
        _endGame();
      }
    }
  }

  void _updateAI(double dt) {
    if (!_aiEnabled) return;
    
    // Update AI for current AI team
    final aiTeam = gameState.attackingTeam == PlayerTeam.teamA ? teamAPlayers : teamBPlayers;
    final humanTeam = gameState.attackingTeam == PlayerTeam.teamA ? teamBPlayers : teamAPlayers;
    
    for (final player in aiTeam) {
      if (player.currentRole == PlayerRole.guard) {
        // AI guards
        final decision = aiController.makeDecision(player, gameState, aiTeam, humanTeam);
        _executeAIDecision(player, decision);
      }
    }
  }

  void _executeAIDecision(HadangPlayer player, AIDecision decision) {
    switch (decision.action) {
      case AIAction.intercept:
      case AIAction.track:
      case AIAction.advance:
        player.moveTowards(decision.targetPosition);
        break;
        
      case AIAction.patrol:
        if (!player.isMoving) {
          player.moveTowards(decision.targetPosition);
        }
        break;
        
      case AIAction.wait:
      case AIAction.retreat:
      case AIAction.coordinate:
        // Implement specific behaviors
        break;
    }
  }

  void _checkGameRules() {
    _checkPlayerCollisions();
    _checkScoring();
    _checkTimeouts();
  }

  void _checkPlayerCollisions() {
    final attackers = _getActiveAttackers();
    final guards = _getActiveGuards();
    
    for (final attacker in attackers) {
      for (final guard in guards) {
        if (attacker.isCollidingWith(guard) && guard.canTouch(attacker)) {
          _handlePlayerTouch(guard, attacker);
          return; // Only handle one collision per frame
        }
      }
    }
  }

  void _handlePlayerTouch(HadangPlayer guard, HadangPlayer attacker) {
    _touchCount++;
    
    // Audio and haptic feedback
    _audio.playPlayerTouchSound();
    
    // Visual feedback
    _createTouchEffect(guard.position);
    
    // Switch teams
    switchTeams();
    
    // Update hint
    _updateHint('${guard.team.name} menyentuh ${attacker.team.name}! Tim bertukar peran.');
    
    print('Touch! ${guard.team.name} guard touched ${attacker.team.name} attacker!');
  }

  void _createTouchEffect(Vector2 position) {
    // Create visual effect at touch point
    // This could be implemented with particles or sprite animations
  }

  void _checkScoring() {
    final attackers = _getActiveAttackers();
    
    for (final attacker in attackers) {
      if (attacker.hasScored() && !attacker.scoreProcessed) {
        _awardScore(attacker.team);
        attacker.markScoreProcessed();
        
        // Track fastest crossing
        final crossingTime = _gameStartTime.inMilliseconds / 1000.0;
        if (_fastestCrossing == null || crossingTime < _fastestCrossing!) {
          _fastestCrossing = crossingTime;
        }
      }
    }
  }

  void _awardScore(PlayerTeam team) {
    gameState.addScore(team);
    
    // Audio and visual feedback
    _audio.playScoreSound();
    _createScoreEffect(team);
    
    // Update hint
    final teamName = team == PlayerTeam.teamA ? 'Tim Merah' : 'Tim Biru';
    _updateHint('$teamName mencetak poin! Skor: ${gameState.getScore(team)}');
    
    print('Score! ${team.name} - ${gameState.getScore(team)}');
  }

  void _createScoreEffect(PlayerTeam team) {
    // Create celebration effect
    // This could be implemented with particles or animations
  }

  void _checkTimeouts() {
    if (gameState.shouldSwitchHalf()) {
      _switchHalf();
    }
  }

  void _switchHalf() {
    gameState.switchHalf();
    _setInitialPositions();
    _audio.playHalfTimeSound();
    _updateHint('Istirahat selesai! Babak kedua dimulai.');
    print('Half time! Switching sides...');
  }

  void _endGame() {
    gameState.endGame();
    _audio.stopBackgroundMusic();
    _audio.playGameEndSound();
    
    // Show game result
    _showGameResult();
    
    print('Game Over! Final Score - Team A: ${gameState.scoreTeamA}, Team B: ${gameState.scoreTeamB}');
  }

  void _showGameResult() {
    // This would trigger showing the GameResultScreen
    // Implementation depends on the navigation structure
    final playerWon = gameState.scoreTeamB > gameState.scoreTeamA; // Assuming player is Team B
    final gameStats = {
      'touchCount': _touchCount,
      'fastestCrossing': _fastestCrossing,
    };
    
    // Could use a callback or event system to notify parent widget
    print('Show game result: Player ${playerWon ? 'won' : 'lost'}');
  }

  List<HadangPlayer> _getActiveAttackers() {
    return [...teamAPlayers, ...teamBPlayers]
        .where((p) => p.currentRole == PlayerRole.attacker)
        .toList();
  }

  List<HadangPlayer> _getActiveGuards() {
    return [...teamAPlayers, ...teamBPlayers]
        .where((p) => p.currentRole == PlayerRole.guard)
        .toList();
  }

  void _updateUI() {
    scoreDisplay.text = 'Merah: ${gameState.scoreTeamA} - Biru: ${gameState.scoreTeamB}';
    timeDisplay.text = 'Waktu: ${_formatTime(gameState.gameTime)}';
    gamePhaseDisplay.text = 'Fase: ${gameState.getCurrentPhaseDisplay()}';
  }

  void _updateHints() {
    if (!_showRuleHints || hintDisplay == null) return;
    
    // Update hints based on game state
    final attackingTeam = gameState.attackingTeam;
    if (attackingTeam == PlayerTeam.teamB) {
      // Player is attacking
      hintDisplay!.text = 'Pilih pemain biru dan gerakkan untuk mencetak poin!';
    } else {
      // Player is guarding (AI attacking)
      hintDisplay!.text = 'AI sedang menyerang. Perhatikan pergerakan mereka!';
    }
  }

  void _updateHint(String hint) {
    if (_showRuleHints && hintDisplay != null) {
      hintDisplay!.text = hint;
      
      // Auto-clear hint after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (hintDisplay != null) {
          _updateHints(); // Reset to default hint
        }
      });
    }
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Public methods for UI controls
  void restartGame() {
    gameState.resetGame();
    _setInitialPositions();
    _gameStarted = false;
    _touchCount = 0;
    _fastestCrossing = null;
    
    for (final player in [...teamAPlayers, ...teamBPlayers]) {
      player.reset();
    }
    
    _audio.playWhistleSound();
    _updateHint('Permainan direset. Siap untuk bermain lagi!');
    _updateUI();
  }

  void pauseResumeGame() {
    gameState.togglePause();
    
    if (gameState.isPaused) {
      _audio.pauseBackgroundMusic();
      _updateHint('Permainan dijeda.');
    } else {
      _audio.resumeBackgroundMusic();
      _updateHint('Permainan dilanjutkan.');
    }
  }

  void switchTeams() {
    // Switch roles
    for (final player in teamAPlayers) {
      player.switchRole();
    }
    for (final player in teamBPlayers) {
      player.switchRole();
    }
    
    // Reset positions
    _setInitialPositions();
    
    // Update game state
    gameState.switchAttackingTeam();
    
    // Audio feedback
    _audio.playTeamSwitchSound();
  }

  @override
  bool onTapDown(TapDownInfo info) {
    if (!_isInitialized || !_gameStarted) return false;
    
    final tapPosition = info.eventPosition.game;
    
    // Only allow human control for their team
    final humanTeam = gameState.attackingTeam == PlayerTeam.teamA ? teamAPlayers : teamBPlayers;
    final attackers = humanTeam.where((p) => p.currentRole == PlayerRole.attacker).toList();
    
    if (attackers.isNotEmpty) {
      final closestAttacker = _findClosestPlayer(attackers, tapPosition);
      if (closestAttacker != null) {
        closestAttacker.moveTowards(tapPosition);
        _audio.playPlayerMoveSound();
        gameState.resetMovementTimer(); // Reset the 2-minute rule timer
      }
    }
    
    return true;
  }

  HadangPlayer? _findClosestPlayer(List<HadangPlayer> players, Vector2 position) {
    if (players.isEmpty) return null;
    
    HadangPlayer? closest;
    double minDistance = double.infinity;
    
    for (final player in players) {
      final distance = player.position.distanceTo(position);
      if (distance < minDistance) {
        minDistance = distance;
        closest = player;
      }
    }
    
    return closest;
  }

  // Settings update methods
  void updateAIDifficulty(String difficulty) {
    _aiDifficulty = difficulty;
    aiController.initialize(difficulty);
    _updateHint('Tingkat kesulitan AI diubah ke ${GameDifficulty.difficultyLevels[difficulty]?['name']}');
  }

  void toggleAI(bool enabled) {
    _aiEnabled = enabled;
    _updateHint(enabled ? 'AI diaktifkan' : 'AI dinonaktifkan');
  }

  void updateVisualSettings() {
    _showMovementTrails = _storage.showMovementTrails;
    _showRuleHints = _storage.showRuleHints;
    
    // Update players' trail settings
    for (final player in [...teamAPlayers, ...teamBPlayers]) {
      // Update player visual settings
    }
    
    // Show/hide hint display
    if (_showRuleHints && hintDisplay == null) {
      // Re-add hint display
      _setupUI();
    } else if (!_showRuleHints && hintDisplay != null) {
      remove(hintDisplay!);
    }
  }

  void onAudioSettingsChanged() {
    _audio.onSettingsChanged();
  }

  // Game statistics for result screen
  Map<String, dynamic> getGameStatistics() {
    return {
      'touchCount': _touchCount,
      'fastestCrossing': _fastestCrossing,
      'gameTime': _gameStartTime,
      'playerScore': gameState.scoreTeamB, // Assuming player is Team B
      'aiScore': gameState.scoreTeamA,
      'playerWon': gameState.scoreTeamB > gameState.scoreTeamA,
    };
  }
}

// File: lib/game/game_manager.dart
import 'package:flutter/material.dart';
import 'enhanced_hadang_game.dart';
import '../screens/game_result_screen.dart';
import '../services/audio_service.dart';

class GameManager {
  static GameManager? _instance;
  static GameManager get instance => _instance ??= GameManager._();
  GameManager._();

  EnhancedHadangGame? _currentGame;
  BuildContext? _context;

  void initializeGame(BuildContext context) {
    _context = context;
    _currentGame = EnhancedHadangGame();
  }

  EnhancedHadangGame? get currentGame => _currentGame;

  void onGameEnded() {
    if (_currentGame == null || _context == null) return;

    final gameStats = _currentGame!.getGameStatistics();
    
    // Show game result screen
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) => GameResultScreen(
          playerWon: gameStats['playerWon'],
          playerScore: gameStats['playerScore'],
          aiScore: gameStats['aiScore'],
          gameDuration: gameStats['gameTime'],
          gameStats: gameStats,
        ),
      ),
    ).then((result) {
      if (result == 'play_again') {
        _currentGame?.restartGame();
      } else if (result == 'menu') {
        Navigator.pop(_context!);
      }
    });
  }

  void dispose() {
    _currentGame = null;
    _context = null;
  }
}