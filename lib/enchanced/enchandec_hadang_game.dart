// File: lib/game/enhanced_hadang_game.dart (Complete & Accurate to Real Rules)
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../utils/game_constants.dart';

class EnhancedHadangGame extends FlameGame with HasCollisionDetection {
  // Game State
  final HadangGameState gameState = HadangGameState();
  
  // Field components (menggunakan aturan resmi)
  late RectangleComponent fieldBackground;
  final List<RectangleComponent> fieldSections = [];
  final List<RectangleComponent> horizontalGuardLines = [];
  late RectangleComponent sodorGuardLine; // Garis tengah vertical
  
  // Player components (sesuai aturan: 5 pemain per tim)
  final List<CircleComponent> teamAPlayers = []; // Tim penjaga
  final List<CircleComponent> teamBPlayers = []; // Tim penyerang
  final List<PlayerRole> teamARoles = [];
  final List<PlayerRole> teamBRoles = [];
  final List<Vector2> teamAPositions = [];
  final List<Vector2> teamBPositions = [];
  
  // Game mechanics
  PlayerTeam guardingTeam = PlayerTeam.teamA; // Start dengan Team A sebagai penjaga
  PlayerTeam attackingTeam = PlayerTeam.teamB; // Team B sebagai penyerang
  final List<bool> attackerProgress = []; // Track progress setiap attacker
  
  // UI Components
  late TextComponent scoreDisplay;
  late TextComponent timeDisplay;
  late TextComponent phaseDisplay;
  late TextComponent teamRoleDisplay;
  
  // Game statistics
  int _totalTouches = 0;
  int _teamSwitches = 0;
  DateTime? _gameStartTime;
  
  // Public getters
  int get scoreTeamA => gameState.scoreTeamA;
  int get scoreTeamB => gameState.scoreTeamB;
  Duration get gameTime => gameState.gameTime;
  String get currentPhase => gameState.getCurrentPhaseDisplay();
  bool get isPaused => gameState.isPaused;
  String get guardingTeamName => guardingTeam == PlayerTeam.teamA ? 'Tim Merah' : 'Tim Biru';
  String get attackingTeamName => attackingTeam == PlayerTeam.teamA ? 'Tim Merah' : 'Tim Biru';
  
  // Widget getter
  Widget get widget => GameWidget(game: this);

  @override
  Future<void> onLoad() async {
    print('EnhancedHadangGame: Loading with official rules...');
    
    try {
      // Reset game state
      gameState.resetGame();
      
      // Setup camera
      camera.viewfinder.visibleGameSize = size;
      
      // Create official field layout
      await _createOfficialField();
      
      // Create teams (5 players each)
      await _createTeams();
      
      // Setup initial positions
      _setupInitialPositions();
      
      // Setup UI
      await _setupUI();
      
      // Start game
      _startGame();
      
      print('EnhancedHadangGame: Loaded successfully with official Hadang rules');
      
    } catch (e) {
      print('Error loading enhanced game: $e');
      gameState.resetGame();
    }
  }

  Future<void> _createOfficialField() async {
    // Calculate field dimensions (15m x 9m scaled to screen)
    final gameSize = size;
    final aspectRatio = GameConstants.fieldRealWidth / GameConstants.fieldRealHeight; // 15:9
    
    final availableWidth = gameSize.x - 120; // Padding for UI
    final availableHeight = gameSize.y - 200; // Padding for UI
    
    double fieldWidth, fieldHeight;
    if (availableWidth / aspectRatio <= availableHeight) {
      fieldWidth = availableWidth;
      fieldHeight = fieldWidth / aspectRatio;
    } else {
      fieldHeight = availableHeight;
      fieldWidth = fieldHeight * aspectRatio;
    }
    
    final fieldX = (gameSize.x - fieldWidth) / 2;
    final fieldY = (gameSize.y - fieldHeight) / 2 + 50; // Space for UI
    
    // Create main field background
    fieldBackground = RectangleComponent(
      size: Vector2(fieldWidth, fieldHeight),
      position: Vector2(fieldX, fieldY),
      paint: Paint()..color = GameColors.fieldBackground,
    );
    await add(fieldBackground);
    
    // Create 6 field sections (3 columns x 2 rows)
    final sectionWidth = fieldWidth / 3;
    final sectionHeight = fieldHeight / 2;
    
    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < 3; col++) {
        final section = RectangleComponent(
          size: Vector2(sectionWidth, sectionHeight),
          position: Vector2(
            fieldX + (col * sectionWidth),
            fieldY + (row * sectionHeight),
          ),
          paint: Paint()
            ..color = (row + col) % 2 == 0 
                ? GameColors.fieldAlternate 
                : GameColors.fieldBackground
            ..style = PaintingStyle.fill,
        );
        
        // Add border
        final border = RectangleComponent(
          size: Vector2(sectionWidth, sectionHeight),
          position: Vector2(
            fieldX + (col * sectionWidth),
            fieldY + (row * sectionHeight),
          ),
          paint: Paint()
            ..color = GameColors.fieldBorder
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
        
        fieldSections.add(section);
        await add(section);
        await add(border);
        
        // Add section number
        final sectionNumber = (row * 3) + col + 1;
        final numberText = TextComponent(
          text: '$sectionNumber',
          position: Vector2(
            fieldX + (col * sectionWidth) + (sectionWidth / 2),
            fieldY + (row * sectionHeight) + (sectionHeight / 2),
          ),
          textRenderer: TextPaint(
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          anchor: Anchor.center,
        );
        await add(numberText);
      }
    }
    
    // Create horizontal guard lines (4 lines for horizontal guards)
    for (int i = 1; i <= 4; i++) {
      final lineY = fieldY + (i * sectionHeight / 2);
      final guardLine = RectangleComponent(
        size: Vector2(fieldWidth, 3),
        position: Vector2(fieldX, lineY - 1.5),
        paint: Paint()..color = GameColors.guardLine,
      );
      horizontalGuardLines.add(guardLine);
      await add(guardLine);
    }
    
    // Create sodor guard line (vertical center line)
    sodorGuardLine = RectangleComponent(
      size: Vector2(3, fieldHeight),
      position: Vector2(fieldX + (fieldWidth / 2) - 1.5, fieldY),
      paint: Paint()..color = GameColors.centerLine,
    );
    await add(sodorGuardLine);
    
    print('Official Hadang field created: ${fieldWidth.toInt()}x${fieldHeight.toInt()}');
  }

  Future<void> _createTeams() async {
    // Initialize progress tracking
    attackerProgress.clear();
    for (int i = 0; i < 5; i++) {
      attackerProgress.add(false);
    }
    
    // Team A (Start as Guards) - Red
    teamAPlayers.clear();
    teamARoles.clear();
    teamAPositions.clear();
    
    for (int i = 0; i < 5; i++) {
      final player = CircleComponent(
        radius: GameConstants.playerRadius,
        paint: Paint()..color = GameColors.teamAColor,
      );
      
      // Add player number
      final numberText = TextComponent(
        text: '${i + 1}',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
      );
      player.add(numberText);
      
      teamAPlayers.add(player);
      teamARoles.add(PlayerRole.guard);
      teamAPositions.add(Vector2.zero());
      await add(player);
    }
    
    // Team B (Start as Attackers) - Blue
    teamBPlayers.clear();
    teamBRoles.clear();
    teamBPositions.clear();
    
    for (int i = 0; i < 5; i++) {
      final player = CircleComponent(
        radius: GameConstants.playerRadius,
        paint: Paint()..color = GameColors.teamBColor,
      );
      
      // Add player number
      final numberText = TextComponent(
        text: '${i + 1}',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
      );
      player.add(numberText);
      
      teamBPlayers.add(player);
      teamBRoles.add(PlayerRole.attacker);
      teamBPositions.add(Vector2.zero());
      await add(player);
    }
    
    print('Teams created: 5 guards (Red) + 5 attackers (Blue)');
  }

  void _setupInitialPositions() {
    final fieldRect = fieldBackground;
    final fieldWidth = fieldRect.size.x;
    final fieldHeight = fieldRect.size.y;
    final fieldX = fieldRect.position.x;
    final fieldY = fieldRect.position.y;
    
    // Position guards (Team A) - 4 horizontal + 1 sodor
    if (guardingTeam == PlayerTeam.teamA) {
      // 4 horizontal guards
      for (int i = 0; i < 4; i++) {
        final lineY = fieldY + ((i + 1) * fieldHeight / 4);
        final posX = fieldX + (fieldWidth / 2);
        
        teamAPlayers[i].position = Vector2(posX, lineY);
        teamAPositions[i] = Vector2(posX, lineY);
      }
      
      // 1 sodor guard (center vertical)
      teamAPlayers[4].position = Vector2(fieldX + (fieldWidth / 2), fieldY + (fieldHeight / 2));
      teamAPositions[4] = Vector2(fieldX + (fieldWidth / 2), fieldY + (fieldHeight / 2));
      
      // Position attackers (Team B) - at start line
      for (int i = 0; i < 5; i++) {
        final posX = fieldX + 50 + (i * (fieldWidth - 100) / 4);
        teamBPlayers[i].position = Vector2(posX, fieldY - 30);
        teamBPositions[i] = Vector2(posX, fieldY - 30);
      }
    } else {
      // Swap roles
      for (int i = 0; i < 4; i++) {
        final lineY = fieldY + ((i + 1) * fieldHeight / 4);
        final posX = fieldX + (fieldWidth / 2);
        
        teamBPlayers[i].position = Vector2(posX, lineY);
        teamBPositions[i] = Vector2(posX, lineY);
      }
      
      teamBPlayers[4].position = Vector2(fieldX + (fieldWidth / 2), fieldY + (fieldHeight / 2));
      teamBPositions[4] = Vector2(fieldX + (fieldWidth / 2), fieldY + (fieldHeight / 2));
      
      for (int i = 0; i < 5; i++) {
        final posX = fieldX + 50 + (i * (fieldWidth - 100) / 4);
        teamAPlayers[i].position = Vector2(posX, fieldY - 30);
        teamAPositions[i] = Vector2(posX, fieldY - 30);
      }
    }
    
    print('Initial positions set: ${guardingTeamName} as guards, ${attackingTeamName} as attackers');
  }

  Future<void> _setupUI() async {
    // Score display
    scoreDisplay = TextComponent(
      text: 'Merah: 0 - Biru: 0',
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
      text: 'Waktu: 15:00',
      position: Vector2(20, 45),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
    await add(timeDisplay);
    
    // Phase display
    phaseDisplay = TextComponent(
      text: 'Fase: Babak 1',
      position: Vector2(20, 70),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    await add(phaseDisplay);
    
    // Team role display
    teamRoleDisplay = TextComponent(
      text: 'Penjaga: ${guardingTeamName} | Penyerang: ${attackingTeamName}',
      position: Vector2(20, 95),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.lightGreen,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
    await add(teamRoleDisplay);
  }

  void _startGame() {
    gameState.startGame();
    _gameStartTime = DateTime.now();
    _updateUI();
    print('Enhanced Hadang game started with official rules');
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
    _checkCollisions();
    _checkAttackerProgress();
    _checkBoundaryViolations();
    _checkTimeouts();
    
    if (gameState.shouldEndGame()) {
      _endGame();
    }
  }

  void _checkCollisions() {
    final attackers = attackingTeam == PlayerTeam.teamA ? teamAPlayers : teamBPlayers;
    final guards = guardingTeam == PlayerTeam.teamA ? teamAPlayers : teamBPlayers;
    
    for (int i = 0; i < attackers.length; i++) {
      final attacker = attackers[i];
      
      for (int j = 0; j < guards.length; j++) {
        final guard = guards[j];
        final distance = attacker.position.distanceTo(guard.position);
        
        if (distance < (GameConstants.playerRadius * 2) + 5) {
          _handleTouch(guard, attacker, j);
          return; // Exit after first touch
        }
      }
    }
  }

  void _handleTouch(CircleComponent guard, CircleComponent attacker, int guardIndex) {
    if (GameSettings.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
    
    _totalTouches++;
    _teamSwitches++;
    
    // Switch team roles
    final temp = guardingTeam;
    guardingTeam = attackingTeam;
    attackingTeam = temp;
    
    // Reset positions
    _setupInitialPositions();
    
    // Reset progress
    for (int i = 0; i < attackerProgress.length; i++) {
      attackerProgress[i] = false;
    }
    
    // Reset movement timer
    gameState.resetMovementTimer();
    
    print('Touch! Guard ${guardIndex + 1} touched attacker. Teams switched!');
    print('New setup: ${guardingTeamName} guards, ${attackingTeamName} attacks');
  }

  void _checkAttackerProgress() {
    final fieldRect = fieldBackground;
    final fieldY = fieldRect.position.y;
    final fieldHeight = fieldRect.size.y;
    final finishLine = fieldY + fieldHeight;
    
    final attackers = attackingTeam == PlayerTeam.teamA ? teamAPlayers : teamBPlayers;
    
    for (int i = 0; i < attackers.length; i++) {
      final attacker = attackers[i];
      
      // Check if reached finish line
      if (attacker.position.y >= finishLine && !attackerProgress[i]) {
        attackerProgress[i] = true;
        print('Attacker ${i + 1} reached finish line!');
      }
      
      // Check if completed round trip (back to start)
      if (attackerProgress[i] && attacker.position.y <= fieldY - 20) {
        _awardScore(attackingTeam, i + 1);
        attackerProgress[i] = false; // Reset for next attempt
      }
    }
  }

  void _awardScore(PlayerTeam team, int playerNumber) {
    gameState.addScore(team);
    
    if (GameSettings.hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    
    final teamName = team == PlayerTeam.teamA ? 'Tim Merah' : 'Tim Biru';
    print('SCORE! $teamName Player $playerNumber completed round trip!');
  }

  void _checkBoundaryViolations() {
    final fieldRect = fieldBackground;
    final fieldX = fieldRect.position.x;
    final fieldWidth = fieldRect.size.x;
    
    final attackers = attackingTeam == PlayerTeam.teamA ? teamAPlayers : teamBPlayers;
    
    for (int i = 0; i < attackers.length; i++) {
      final attacker = attackers[i];
      
      // Check side boundary violations
      if (attacker.position.x < fieldX || attacker.position.x > fieldX + fieldWidth) {
        print('Boundary violation! Attacker ${i + 1} went outside side lines');
        _handleBoundaryViolation();
        return;
      }
    }
  }

  void _handleBoundaryViolation() {
    // Switch teams due to rule violation
    final temp = guardingTeam;
    guardingTeam = attackingTeam;
    attackingTeam = temp;
    
    _setupInitialPositions();
    
    for (int i = 0; i < attackerProgress.length; i++) {
      attackerProgress[i] = false;
    }
    
    print('Rule violation! Teams switched due to boundary exit');
  }

  void _checkTimeouts() {
    if (gameState.shouldSwitchHalf()) {
      _switchHalf();
    }
  }

  void _switchHalf() {
    gameState.switchHalf();
    _setupInitialPositions();
    print('Half time! Continuing with current team setup');
  }

  void _endGame() {
    gameState.endGame();
    print('Game Over! Final Score - Merah: ${gameState.scoreTeamA}, Biru: ${gameState.scoreTeamB}');
  }

  void _updateUI() {
    scoreDisplay.text = 'Merah: ${gameState.scoreTeamA} - Biru: ${gameState.scoreTeamB}';
    timeDisplay.text = 'Waktu: ${gameState.gameTime.toGameTime()}';
    phaseDisplay.text = 'Fase: ${gameState.getCurrentPhaseDisplay()}';
    teamRoleDisplay.text = 'Penjaga: ${guardingTeamName} | Penyerang: ${attackingTeamName}';
  }

  // Public control methods
  void restartGame() {
    gameState.resetGame();
    guardingTeam = PlayerTeam.teamA;
    attackingTeam = PlayerTeam.teamB;
    _setupInitialPositions();
    
    for (int i = 0; i < attackerProgress.length; i++) {
      attackerProgress[i] = false;
    }
    
    _totalTouches = 0;
    _teamSwitches = 0;
    _gameStartTime = DateTime.now();
    
    _updateUI();
    print('Game restarted with official rules');
  }

  void pauseResumeGame() {
    gameState.togglePause();
    print('Game ${gameState.isPaused ? 'paused' : 'resumed'}');
  }

  void switchTeams() {
    final temp = guardingTeam;
    guardingTeam = attackingTeam;
    attackingTeam = temp;
    
    _setupInitialPositions();
    
    for (int i = 0; i < attackerProgress.length; i++) {
      attackerProgress[i] = false;
    }
    
    print('Manual team switch: ${guardingTeamName} now guards, ${attackingTeamName} now attacks');
  }

  void moveClosestAttacker(Offset tapPosition) {
    final tapVector = Vector2(tapPosition.dx, tapPosition.dy);
    final attackers = attackingTeam == PlayerTeam.teamA ? teamAPlayers : teamBPlayers;
    
    if (attackers.isEmpty) return;
    
    // Find closest attacker
    CircleComponent? closest;
    double minDistance = double.infinity;
    
    for (final attacker in attackers) {
      final distance = attacker.position.distanceTo(tapVector);
      if (distance < minDistance) {
        minDistance = distance;
        closest = attacker;
      }
    }
    
    if (closest != null && _isValidAttackerMove(closest, tapVector)) {
      closest.position = tapVector;
      gameState.resetMovementTimer();
      print('Attacker moved to ${tapVector.x.toInt()}, ${tapVector.y.toInt()}');
    }
  }

  bool _isValidAttackerMove(CircleComponent attacker, Vector2 newPosition) {
    final fieldRect = fieldBackground;
    final fieldX = fieldRect.position.x;
    final fieldY = fieldRect.position.y;
    final fieldWidth = fieldRect.size.x;
    final fieldHeight = fieldRect.size.y;
    
    // Check if within field boundaries (allowing start/finish areas)
    if (newPosition.x < fieldX || newPosition.x > fieldX + fieldWidth) {
      return false; // Side boundary violation
    }
    
    // Allow movement in start area (above field) and finish area (below field)
    if (newPosition.y < fieldY - 50 || newPosition.y > fieldY + fieldHeight + 50) {
      return false; // Too far out
    }
    
    // Check forward movement rule (simplified)
    final currentY = attacker.position.y;
    if (newPosition.y < currentY - 20 && currentY > fieldY) {
      return false; // Can't move backward significantly once in field
    }
    
    return true;
  }

  Map<String, dynamic> getGameStatistics() {
    return {
      'gameTime': gameState.gameTime.toGameTime(),
      'phase': gameState.getCurrentPhaseDisplay(),
      'scoreTeamA': gameState.scoreTeamA,
      'scoreTeamB': gameState.scoreTeamB,
      'guardingTeam': guardingTeamName,
      'attackingTeam': attackingTeamName,
      'totalTouches': _totalTouches,
      'teamSwitches': _teamSwitches,
      'attackerProgress': attackerProgress.where((p) => p).length,
      'isPaused': gameState.isPaused,
    };
  }
}