// File: lib/game/hadang_game.dart (Fixed Loading)
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../utils/game_constants.dart';
import 'components/hadang_field.dart';
import 'components/player.dart';

class HadangGame extends FlameGame with HasCollisionDetection {
  // Game State - Initialize immediately with default state
  final HadangGameState gameState = HadangGameState();
  HadangField? field;
  
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
  
  // Public getters for UI - Always safe to access
  int get scoreTeamA => gameState.scoreTeamA;
  int get scoreTeamB => gameState.scoreTeamB;
  String get currentPhase => gameState.getCurrentPhaseDisplay();
  bool get isPaused => gameState.isPaused;
  Duration get gameTime => gameState.gameTime;
  
  // Simple widget property
  Widget get widget => GameWidget(game: this);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    try {
      print('Starting HadangGame initialization...');
      
      // Reset game state to ensure clean start
      gameState.resetGame();
      
      // Setup camera
      camera.viewfinder.visibleGameSize = size;
      
      // Create field first
      await _createField();
      
      // Create players
      await _createPlayers();
      
      // Setup basic UI
      await _setupBasicUI();
      
      // Start game
      _startGame();
      
      print('HadangGame initialization completed');
      
    } catch (e) {
      print('Error in onLoad: $e');
      // Even if there's an error, ensure basic state is available
      gameState.resetGame();
    }
  }

  Future<void> _createField() async {
    try {
      field = HadangField();
      await add(field!);
      print('Field created successfully');
    } catch (e) {
      print('Error creating field: $e');
      // Create a minimal field fallback
      field = HadangField();
      add(field!);
    }
  }

  Future<void> _createPlayers() async {
    try {
      // Clear existing players
      teamAPlayers.clear();
      teamBPlayers.clear();
      
      // Team A (Red) - Guards
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
      
      // Team B (Blue) - Attackers  
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
      
      print('Players created: ${teamAPlayers.length} + ${teamBPlayers.length}');
      
      // Set positions after field is ready
      _setInitialPositions();
      
    } catch (e) {
      print('Error creating players: $e');
    }
  }

  void _setInitialPositions() {
    try {
      if (field == null) {
        print('Field not ready, using default positions');
        // Use default positions if field not ready
        _setDefaultPositions();
        return;
      }
      
      final fieldCenter = field!.fieldRect.center;
      
      // Position guards (Team A)
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
      
      // Position center guard (sodor)
      if (teamAPlayers.length > 4) {
        teamAPlayers[4].setPosition(Vector2(
          fieldCenter.dx,
          fieldCenter.dy,
        ));
        teamAPlayers[4].assignToLine(field!.centerLine);
      }
      
      // Position attackers (Team B)
      for (int i = 0; i < teamBPlayers.length; i++) {
        teamBPlayers[i].setPosition(Vector2(
          field!.fieldRect.left + 50 + (i * 60),
          field!.fieldRect.top - 30,
        ));
      }
      
      print('Positions set successfully');
    } catch (e) {
      print('Error setting positions: $e');
      _setDefaultPositions();
    }
  }

  void _setDefaultPositions() {
    // Fallback positions if field not ready
    for (int i = 0; i < teamAPlayers.length; i++) {
      teamAPlayers[i].setPosition(Vector2(100 + (i * 50), 200));
    }
    
    for (int i = 0; i < teamBPlayers.length; i++) {
      teamBPlayers[i].setPosition(Vector2(100 + (i * 50), 100));
    }
  }

  Future<void> _setupBasicUI() async {
    try {
      // Score display
      scoreDisplay = TextComponent(
        text: '${GameTexts.teamRed}: 0 - ${GameTexts.teamBlue}: 0',
        position: Vector2(20, 20),
        textRenderer: TextPaint(
          style: TextStyle(
            color: Colors.white,
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
      await add(scoreDisplay!);
      
      // Time display
      timeDisplay = TextComponent(
        text: '${GameTexts.timeLabel}: 15:00',
        position: Vector2(20, 45),
        textRenderer: TextPaint(
          style: TextStyle(
            color: Colors.white,
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
      await add(timeDisplay!);
      
      // Game phase display
      gamePhaseDisplay = TextComponent(
        text: '${GameTexts.phaseLabel}: ${GameTexts.phaseSetup}',
        position: Vector2(20, 70),
        textRenderer: TextPaint(
          style: TextStyle(
            color: Colors.yellow,
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
      
      print('UI components created');
    } catch (e) {
      print('Error setting up UI: $e');
    }
  }

  void _startGame() {
    try {
      gameState.startGame();
      _gameStartTime = DateTime.now();
      _updateUI();
      print('Game started successfully');
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
      print('Error in update: $e');
    }
  }

  void _checkGameRules() {
    try {
      _checkPlayerCollisions();
      _checkScoring();
      _checkTimeouts();
      
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
      if (GameSettings.hapticEnabled) {
        HapticFeedback.mediumImpact();
      }
      
      _totalTouches++;
      switchTeams();
      gameState.resetMovementTimer();
      
      print('Touch: ${guard.team.name}${guard.playerId} → ${attacker.team.name}${attacker.playerId}');
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
      
      print('Score awarded to ${team.name}');
    } catch (e) {
      print('Error awarding score: $e');
    }
  }

  void _checkTimeouts() {
    try {
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
      print('Half switched');
    } catch (e) {
      print('Error switching half: $e');
    }
  }

  void _endGame() {
    try {
      gameState.endGame();
      print('Game ended');
    } catch (e) {
      print('Error ending game: $e');
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
      scoreDisplay?.text = '${GameTexts.teamRed}: ${gameState.scoreTeamA} - ${GameTexts.teamBlue}: ${gameState.scoreTeamB}';
      timeDisplay?.text = '${GameTexts.timeLabel}: ${gameState.gameTime.toGameTime()}';
      gamePhaseDisplay?.text = '${GameTexts.phaseLabel}: ${gameState.getCurrentPhaseDisplay()}';
    } catch (e) {
      print('Error updating UI: $e');
    }
  }

  // Public methods for UI controls
  void restartGame() {
    try {
      gameState.resetGame();
      _setInitialPositions();
      
      _totalTouches = 0;
      _teamASwitches = 0;
      _teamBSwitches = 0;
      _gameStartTime = DateTime.now();
      
      for (final player in [...teamAPlayers, ...teamBPlayers]) {
        player.reset();
      }
      
      _updateUI();
      print('Game restarted');
    } catch (e) {
      print('Error restarting game: $e');
    }
  }

  void pauseResumeGame() {
    try {
      gameState.togglePause();
      print('Game ${gameState.isPaused ? 'paused' : 'resumed'}');
    } catch (e) {
      print('Error pausing/resuming game: $e');
    }
  }

  void switchTeams() {
    try {
      if (gameState.attackingTeam == PlayerTeam.teamA) {
        _teamASwitches++;
      } else {
        _teamBSwitches++;
      }
      
      for (final player in teamAPlayers) {
        player.switchRole();
      }
      for (final player in teamBPlayers) {
        player.switchRole();
      }
      
      _setInitialPositions();
      gameState.switchAttackingTeam();
      
      print('Teams switched');
    } catch (e) {
      print('Error switching teams: $e');
    }
  }

  void moveClosestAttacker(Offset tapPosition) {
    try {
      final tapVector = Vector2(tapPosition.dx, tapPosition.dy);
      final attackers = _getActiveAttackers();
      
      if (attackers.isNotEmpty) {
        final closestAttacker = _findClosestPlayer(attackers, tapVector);
        if (closestAttacker != null) {
          closestAttacker.moveTowards(tapVector);
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
        if (distance < minDistance && distance < 200) {
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
      print('Substitution: Player $playerOut → Player $playerIn');
    }
  }
}