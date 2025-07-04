// File: lib/game/hadang_game.dart
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_permainan_tradisional_simulasi/models/game_state.dart';
import 'components/hadang_field.dart';
import 'components/player.dart';

class HadangGame extends FlameGame  {
  // Game State
  late HadangGameState gameState;
  late HadangField field;
  
  // Components
  final List<HadangPlayer> teamAPlayers = [];
  final List<HadangPlayer> teamBPlayers = [];
  
  // UI Components
  late TextComponent scoreDisplay;
  late TextComponent timeDisplay;
  late TextComponent gamePhaseDisplay;
  
  // Public getters for UI
  int get scoreTeamA => gameState.scoreTeamA;
  int get scoreTeamB => gameState.scoreTeamB;
  String get currentPhase => gameState.currentPhase.toString();
  bool get isPaused => gameState.isPaused;
  
  // Widget property for UI integration
  Widget get widget => GameWidget(game: this);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Initialize game state
    gameState = HadangGameState();
    
    // Setup camera untuk responsive design
    camera.viewfinder.visibleGameSize = size;
    
    // Create field (lapangan)
    field = HadangField();
    await add(field);
    
    // Create players
    await _createPlayers();
    
    // Setup UI components
    await _setupUI();
    
    // Start game
    _startGame();
  }

  Future<void> _createPlayers() async {
    // Team A (Red) - Starting as Guards
    for (int i = 0; i < 5; i++) {
      final player = HadangPlayer(
        playerId: i + 1,
        team: PlayerTeam.teamA,
        initialRole: PlayerRole.guard,
        playerColor: Colors.red,
      );
      teamAPlayers.add(player);
      await add(player);
    }
    
    // Team B (Blue) - Starting as Attackers  
    for (int i = 0; i < 5; i++) {
      final player = HadangPlayer(
        playerId: i + 1,
        team: PlayerTeam.teamB,
        initialRole: PlayerRole.attacker,
        playerColor: Colors.blue,
      );
      teamBPlayers.add(player);
      await add(player);
    }
    
    // Set initial positions
    _setInitialPositions();
  }

  void _setInitialPositions() {
    final fieldCenter = field.fieldRect.center;
    final fieldWidth = field.fieldRect.width;
    final fieldHeight = field.fieldRect.height;
    
    // Position guards on their lines (Team A)
    for (int i = 0; i < 4; i++) {
      final guardLine = field.horizontalLines[i];
      teamAPlayers[i].setPosition(Vector2(
        guardLine.start.x + (guardLine.end.x - guardLine.start.x) / 2,
        guardLine.start.y,
      ));
      teamAPlayers[i].assignToLine(guardLine);
    }
    
    // Position center guard (sodor)
    teamAPlayers[4].setPosition(Vector2(
      fieldCenter.dx,
      fieldCenter.dy,
    ));
    teamAPlayers[4].assignToLine(field.centerLine);
    
    // Position attackers at starting line (Team B)
    for (int i = 0; i < 5; i++) {
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
        ),
      ),
    );
    await add(gamePhaseDisplay);
  }

  void _startGame() {
    gameState.startGame();
    _updateUI();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!gameState.isPaused && gameState.isGameActive()) {
      gameState.updateTime(dt);
      _checkGameRules();
      _updateUI();
    }
  }

  void _checkGameRules() {
    // Check for touches/collisions
    _checkPlayerCollisions();
    
    // Check scoring conditions
    _checkScoring();
    
    // Check timeout conditions
    _checkTimeouts();
    
    // Check game end conditions
    if (gameState.shouldEndGame()) {
      _endGame();
    }
  }

  void _checkPlayerCollisions() {
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
  }

  void _handlePlayerTouch(HadangPlayer guard, HadangPlayer attacker) {
    // Vibrate feedback
    HapticFeedback.mediumImpact();
    
    // Switch teams
    switchTeams();
    
    // Log event
    print('${guard.team.name} guard touched ${attacker.team.name} attacker!');
  }

  void _checkScoring() {
    final attackers = _getActiveAttackers();
    
    for (final attacker in attackers) {
      if (attacker.hasScored() && !attacker.scoreProcessed) {
        _awardScore(attacker.team);
        attacker.markScoreProcessed();
      }
    }
  }

  void _awardScore(PlayerTeam team) {
    gameState.addScore(team);
    HapticFeedback.lightImpact();
    print('Score! ${team.name} - ${gameState.getScore(team)}');
  }

  void _checkTimeouts() {
    // Check 2-minute rule for no movement
    // Check half-time
    if (gameState.shouldSwitchHalf()) {
      _switchHalf();
    }
  }

  void _switchHalf() {
    gameState.switchHalf();
    _setInitialPositions();
    print('Half time! Switching sides...');
  }

  void _endGame() {
    gameState.endGame();
    print('Game Over! Final Score - Team A: ${gameState.scoreTeamA}, Team B: ${gameState.scoreTeamB}');
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
    gamePhaseDisplay.text = 'Fase: ${gameState.currentPhase.name}';
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
    for (final player in [...teamAPlayers, ...teamBPlayers]) {
      player.reset();
    }
    _updateUI();
  }

  void pauseResumeGame() {
    gameState.togglePause();
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
  }

  @override
  bool onTapDown(TapDownInfo info) {
    final tapPosition = info.eventPosition.global;
    
    // Find closest attacker to move
    final attackers = _getActiveAttackers();
    if (attackers.isNotEmpty) {
      final closestAttacker = _findClosestPlayer(attackers, tapPosition);
      if (closestAttacker != null) {
        closestAttacker.moveTowards(tapPosition);
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
}