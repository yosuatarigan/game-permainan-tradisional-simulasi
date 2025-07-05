// File: lib/game/hadang_game.dart (Fixed Initialization)
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../utils/game_constants.dart';
import 'components/hadang_field.dart';
import 'components/player.dart';

class HadangGame extends FlameGame with HasCollisionDetection {
  // Game State - Initialize immediately
  late HadangGameState gameState = HadangGameState();
  HadangField? field;
  
  // Loading state
  bool _isLoaded = false;
  
  // Components
  final List<HadangPlayer> teamAPlayers = [];
  final List<HadangPlayer> teamBPlayers = [];
  
  // UI Components
  TextComponent? scoreDisplay;
  TextComponent? timeDisplay;
  TextComponent? gamePhaseDisplay;
  TextComponent? gameEventsDisplay;
  
  // Game Statistics
  int _totalTouches = 0;
  int _teamASwitches = 0;
  int _teamBSwitches = 0;
  DateTime? _gameStartTime;
  
  // Public getters for UI with safe defaults
  int get scoreTeamA => _isLoaded ? gameState.scoreTeamA : 0;
  int get scoreTeamB => _isLoaded ? gameState.scoreTeamB : 0;
  String get currentPhase => _isLoaded ? gameState.getCurrentPhaseDisplay() : GameTexts.phaseSetup;
  bool get isPaused => _isLoaded ? gameState.isPaused : false;
  Duration get gameTime => _isLoaded ? gameState.gameTime : Duration.zero;
  bool get isLoaded => _isLoaded;
  
  // Simple widget property
  Widget get widget => GameWidget(game: this);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    try {
      print('Starting HadangGame initialization...');
      
      // gameState already initialized, just reset it
      gameState.resetGame();
      
      // Setup camera untuk responsive design
      camera.viewfinder.visibleGameSize = size;
      
      // Create field (lapangan) dengan spesifikasi resmi
      field = HadangField();
      await add(field!);
      
      // Create players sesuai aturan resmi (5 pemain per tim)
      await _createPlayers();
      
      // Setup UI components
      await _setupUI();
      
      // Mark as loaded
      _isLoaded = true;
      
      // Start game
      _startGame();
      
      // Track game start time
      _gameStartTime = DateTime.now();
      
      print('HadangGame initialization completed successfully');
      
    } catch (e) {
      print('Error loading game: $e');
      // Ensure basic state even if loading fails
      _isLoaded = true;
    }
  }

  Future<void> _createPlayers() async {
    try {
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
      
      // Set initial positions
      _setInitialPositions();
    } catch (e) {
      print('Error creating players: $e');
    }
  }

  void _setInitialPositions() {
    try {
      if (field == null) {
        print('Field not initialized yet, skipping position setup');
        return;
      }
      
      final fieldCenter = field!.fieldRect.center;
      
      // Position guards on their lines (Team A)
      // 4 horizontal guards + 1 center guard (sodor)
      if (field!.horizontalLines.length >= 4) {
        for (int i = 0; i < 4 && i < teamAPlayers.length; i++) {
          final guardLine = field!.horizontalLines[i];
          teamAPlayers[i].setPosition(Vector2(
            guardLine.start.x + (guardLine.end.x - guardLine.start.x) / 2,
            guardLine.start.y,
          ));
          teamAPlayers[i].assignToLine(guardLine);
        }
      }
      
      // Position center guard (sodor) - player ke-5
      if (teamAPlayers.length > 4) {
        teamAPlayers[4].setPosition(Vector2(
          fieldCenter.dx,
          fieldCenter.dy,
        ));
        teamAPlayers[4].assignToLine(field!.centerLine);
      }
      
      // Position attackers at starting line (Team B)
      for (int i = 0; i < teamBPlayers.length; i++) {
        teamBPlayers[i].setPosition(Vector2(
          field!.fieldRect.left + 50 + (i * 60),
          field!.fieldRect.top - 30,
        ));
      }
    } catch (e) {
      print('Error setting initial positions: $e');
    }
  }

  Future<void> _setupUI() async {
    try {
      // Score display
      scoreDisplay = TextComponent(
        text: '${GameTexts.teamRed}: ${gameState.scoreTeamA} - ${GameTexts.teamBlue}: ${gameState.scoreTeamB}',
        position: Vector2(20, 20),
        textRenderer: TextPaint(
          style: TextStyle(
            color: GameColors.cardBackground,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 2,
                color: Colors.black.withOpacity(0.7),
              ),
            ],
          ),
        ),
      );
      if (scoreDisplay != null) {
        await add(scoreDisplay!);
      }
      
      // Time display
      timeDisplay = TextComponent(
        text: '${GameTexts.timeLabel}: ${gameState.gameTime.toGameTime()}',
        position: Vector2(20, 45),
        textRenderer: TextPaint(
          style: TextStyle(
            color: GameColors.cardBackground,
            fontSize: 16,
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 2,
                color: Colors.black.withOpacity(0.7),
              ),
            ],
          ),
        ),
      );
      if (timeDisplay != null) {
        await add(timeDisplay!);
      }
      
      // Game phase display
      gamePhaseDisplay = TextComponent(
        text: '${GameTexts.phaseLabel}: ${gameState.getCurrentPhaseDisplay()}',
        position: Vector2(20, 70),
        textRenderer: TextPaint(
          style: TextStyle(
            color: GameColors.warningColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 2,
                color: Colors.black.withOpacity(0.7),
              ),
            ],
          ),
        ),
      );
      await add(gamePhaseDisplay!);
      
      // Game events display
      gameEventsDisplay = TextComponent(
        text: '',
        position: Vector2(20, 95),
        textRenderer: TextPaint(
          style: TextStyle(
            color: GameColors.successColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 2,
                color: Colors.black.withOpacity(0.7),
              ),
            ],
          ),
        ),
      );
      if (gameEventsDisplay != null) {
        await add(gameEventsDisplay!);
      }
      
    } catch (e) {
      print('Error setting up UI: $e');
    }
  }

  void _startGame() {
    try {
      gameState.startGame();
      _updateUI();
      _showGameEvent(GameTexts.gameStarted);
    } catch (e) {
      print('Error starting game: $e');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    try {
      if (!gameState.isPaused && gameState.isGameActive()) {
        gameState.updateTime(dt);
        _checkGameRules();
        _updateUI();
      }
    } catch (e) {
      print('Error updating game: $e');
    }
  }

  void _checkGameRules() {
    try {
      // Check for touches/collisions
      _checkPlayerCollisions();
      
      // Check scoring conditions
      _checkScoring();
      
      // Check timeout conditions (2-minute rule)
      _checkTimeouts();
      
      // Check game end conditions
      if (gameState.shouldEndGame()) {
        _endGame();
      }
    } catch (e) {
      print('Error checking game rules: $e');
    }
  }

  void _checkPlayerCollisions() {
    try {
      final attackers = _getActiveAttackers();
      final guards = _getActiveGuards();
      
      for (final attacker in attackers) {
        for (final guard in guards) {
          if (attacker.isCollidingWith(guard) && guard.canTouch(attacker)) {
            _handlePlayerTouch(guard, attacker);
            break;
          }
        }
      }
    } catch (e) {
      print('Error checking collisions: $e');
    }
  }

  void _handlePlayerTouch(HadangPlayer guard, HadangPlayer attacker) {
    try {
      // Haptic feedback
      if (GameSettings.hapticEnabled) {
        HapticFeedback.mediumImpact();
      }
      
      // Track statistics
      _totalTouches++;
      
      // Show touch event
      _showGameEvent(GameTexts.playerTouched);
      
      // Switch teams
      switchTeams();
      
      // Reset movement timer
      gameState.resetMovementTimer();
      
      print('${guard.team.name} guard ${guard.playerId} touched ${attacker.team.name} attacker ${attacker.playerId}!');
      
    } catch (e) {
      print('Error handling touch: $e');
    }
  }

  void _checkScoring() {
    try {
      final attackers = _getActiveAttackers();
      
      for (final attacker in attackers) {
        if (attacker.hasScored() && !attacker.scoreProcessed) {
          _awardScore(attacker.team);
          attacker.markScoreProcessed();
        }
      }
    } catch (e) {
      print('Error checking scoring: $e');
    }
  }

  void _awardScore(PlayerTeam team) {
    try {
      gameState.addScore(team);
      
      if (GameSettings.hapticEnabled) {
        HapticFeedback.lightImpact();
      }
      
      final teamName = team == PlayerTeam.teamA ? GameTexts.teamRed : GameTexts.teamBlue;
      _showGameEvent('${GameTexts.scoreAwarded} $teamName!');
      
      print('Score! ${team.name} - ${gameState.getScore(team)}');
    } catch (e) {
      print('Error awarding score: $e');
    }
  }

  void _checkTimeouts() {
    try {
      // Check 2-minute no movement rule
      if (gameState.noMovementTimer >= GameConstants.noMovementTimeout) {
        _showGameEvent('Timeout! ${GameTexts.teamSwitched}');
        switchTeams();
      }
      
      // Check half-time
      if (gameState.shouldSwitchHalf()) {
        _switchHalf();
      }
    } catch (e) {
      print('Error checking timeouts: $e');
    }
  }

  void _switchHalf() {
    try {
      gameState.switchHalf();
      _setInitialPositions();
      
      String message;
      switch (gameState.currentPhase) {
        case GamePhase.halfTime:
          message = GameTexts.halfTimeReached;
          break;
        case GamePhase.secondHalf:
          message = GameTexts.secondHalfStarted;
          break;
        default:
          message = 'Half switched';
      }
      
      _showGameEvent(message);
      print('Half time! Switching sides...');
    } catch (e) {
      print('Error switching half: $e');
    }
  }

  void _endGame() {
    try {
      gameState.endGame();
      _showGameEvent(GameTexts.gameEnded);
      
      // Log final statistics
      final winner = gameState.getWinner();
      final finalScore = 'Final Score - ${GameTexts.teamRed}: ${gameState.scoreTeamA}, ${GameTexts.teamBlue}: ${gameState.scoreTeamB}';
      
      print(finalScore);
      if (winner != null) {
        final winnerName = winner == PlayerTeam.teamA ? GameTexts.teamRed : GameTexts.teamBlue;
        print('Winner: $winnerName');
      } else {
        print('Game ended in a draw!');
      }
      
      _logGameAnalytics();
    } catch (e) {
      print('Error ending game: $e');
    }
  }

  void _logGameAnalytics() {
    if (_gameStartTime != null) {
      final gameDuration = DateTime.now().difference(_gameStartTime!);
      
      print('Game Analytics:');
      print('- Duration: ${gameDuration.toGameTime()}');
      print('- Total Touches: $_totalTouches');
      print('- Team A Switches: $_teamASwitches');
      print('- Team B Switches: $_teamBSwitches');
      print('- Final Score: ${gameState.scoreTeamA}-${gameState.scoreTeamB}');
    }
  }

  List<HadangPlayer> _getActiveAttackers() {
    try {
      return [...teamAPlayers, ...teamBPlayers]
          .where((p) => p.currentRole == PlayerRole.attacker)
          .toList();
    } catch (e) {
      print('Error getting attackers: $e');
      return [];
    }
  }

  List<HadangPlayer> _getActiveGuards() {
    try {
      return [...teamAPlayers, ...teamBPlayers]
          .where((p) => p.currentRole == PlayerRole.guard)
          .toList();
    } catch (e) {
      print('Error getting guards: $e');
      return [];
    }
  }

  void _updateUI() {
    try {
      if (!_isLoaded) return;
      
      scoreDisplay?.let((display) {
        display.text = '${GameTexts.teamRed}: ${gameState.scoreTeamA} - ${GameTexts.teamBlue}: ${gameState.scoreTeamB}';
      });
      
      timeDisplay?.let((display) {
        display.text = '${GameTexts.timeLabel}: ${gameState.gameTime.toGameTime()}';
      });
      
      gamePhaseDisplay?.let((display) {
        display.text = '${GameTexts.phaseLabel}: ${gameState.getCurrentPhaseDisplay()}';
      });
    } catch (e) {
      print('Error updating UI: $e');
    }
  }

  void _showGameEvent(String event) {
    try {
      gameEventsDisplay?.let((display) {
        display.text = event;
        
        // Auto-clear event after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (gameEventsDisplay != null) {
            display.text = '';
          }
        });
      });
    } catch (e) {
      print('Error showing game event: $e');
    }
  }

  // Public methods for UI controls
  void restartGame() {
    try {
      gameState.resetGame();
      _setInitialPositions();
      
      // Reset statistics
      _totalTouches = 0;
      _teamASwitches = 0;
      _teamBSwitches = 0;
      _gameStartTime = DateTime.now();
      
      // Reset all players
      for (final player in [...teamAPlayers, ...teamBPlayers]) {
        player.reset();
      }
      
      _updateUI();
      _showGameEvent(GameTexts.gameStarted);
    } catch (e) {
      print('Error restarting game: $e');
    }
  }

  void pauseResumeGame() {
    try {
      gameState.togglePause();
      
      final message = gameState.isPaused ? 'Game Paused' : 'Game Resumed';
      _showGameEvent(message);
    } catch (e) {
      print('Error pausing/resuming game: $e');
    }
  }

  void switchTeams() {
    try {
      // Track team switches
      if (gameState.attackingTeam == PlayerTeam.teamA) {
        _teamASwitches++;
      } else {
        _teamBSwitches++;
      }
      
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
      
      _showGameEvent(GameTexts.teamSwitched);
    } catch (e) {
      print('Error switching teams: $e');
    }
  }

  // Manual player movement (akan dipanggil dari UI)
  void moveClosestAttacker(Offset tapPosition) {
    try {
      if (!_isLoaded) {
        print('Game not loaded yet, ignoring tap');
        return;
      }
      
      final tapVector = Vector2(tapPosition.dx, tapPosition.dy);
      
      // Find closest attacker to move
      final attackers = _getActiveAttackers();
      if (attackers.isNotEmpty) {
        final closestAttacker = _findClosestPlayer(attackers, tapVector);
        if (closestAttacker != null) {
          closestAttacker.moveTowards(tapVector);
          
          // Reset movement timer when player moves
          gameState.resetMovementTimer();
        }
      }
    } catch (e) {
      print('Error moving attacker: $e');
    }
  }

  HadangPlayer? _findClosestPlayer(List<HadangPlayer> players, Vector2 position) {
    try {
      if (players.isEmpty) return null;
      
      HadangPlayer? closest;
      double minDistance = double.infinity;
      
      for (final player in players) {
        final distance = player.position.distanceTo(position);
        if (distance < minDistance && distance < GameConstants.touchDetectionRadius * 3) {
          minDistance = distance;
          closest = player;
        }
      }
      
      return closest;
    } catch (e) {
      print('Error finding closest player: $e');
      return null;
    }
  }

  // Additional game features
  Map<String, dynamic> getGameStatistics() {
    return {
      'gameTime': gameState.gameTime.toGameTime(),
      'phase': gameState.getCurrentPhaseDisplay(),
      'scoreTeamA': gameState.scoreTeamA,
      'scoreTeamB': gameState.scoreTeamB,
      'totalTouches': _totalTouches,
      'teamASwitches': _teamASwitches,
      'teamBSwitches': _teamBSwitches,
      'attackingTeam': gameState.attackingTeam.name,
      'isPaused': gameState.isPaused,
    };
  }

  bool canMakeSubstitution(PlayerTeam team) {
    return gameState.canSubstitute(team);
  }

  void makeSubstitution(PlayerTeam team, int playerOut, int playerIn) {
    if (canMakeSubstitution(team)) {
      gameState.makeSubstitution(team);
      _showGameEvent('Substitution: Player $playerOut → Player $playerIn');
    }
  }
}

// Extension for null safety
extension NullSafetyExtension<T> on T? {
  void let(Function(T) action) {
    if (this != null) {
      action(this!);
    }
  }
}