// File: lib/game/multiplayer_hadang_game.dart (2-Player Real Game)
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../utils/game_constants.dart';

class MultiplayerHadangGame extends FlameGame with HasCollisionDetection {
  // Game State
  final HadangGameState gameState = HadangGameState();
  
  // Field components
  late RectangleComponent fieldBackground;
  final List<RectangleComponent> fieldSections = [];
  final List<RectangleComponent> guardLines = [];
  
  // Players - 2 tim dengan role yang jelas
  final List<CircleComponent> redTeamPlayers = []; // Player 1 - Tim Merah
  final List<CircleComponent> blueTeamPlayers = []; // Player 2 - Tim Biru
  
  // Game mechanics - simple dan fun
  bool redTeamIsGuarding = true; // Red start as guards, Blue as attackers
  late Vector2 fieldPosition;
  late Vector2 fieldSize;
  
  // Player selection untuk controls
  CircleComponent? selectedPlayer;
  Color selectionColor = Colors.yellow;
  
  // Game data
  int redScore = 0;
  int blueScore = 0;
  int round = 1;
  bool gameActive = true;
  
  // UI Components
  late TextComponent scoreDisplay;
  late TextComponent roundDisplay;
  late TextComponent instructionDisplay;
  
  // Public getters untuk UI
  int get scoreTeamRed => redScore;
  int get scoreTeamBlue => blueScore;
  int get currentRound => round;
  bool get isGameActive => gameActive;
  String get currentAttacker => redTeamIsGuarding ? 'BIRU' : 'MERAH';
  String get currentGuard => redTeamIsGuarding ? 'MERAH' : 'BIRU';
  
  Widget get widget => GameWidget(game: this);

  @override
  Future<void> onLoad() async {
    print('MultiplayerHadangGame: Creating 2-player game...');
    
    try {
      // Setup camera
      camera.viewfinder.visibleGameSize = size;
      
      // Create playable field
      await _createPlayableField();
      
      // Create 2 teams
      await _createTwoTeams();
      
      // Setup starting positions
      _setupGamePositions();
      
      // Create UI
      await _setupGameUI();
      
      print('MultiplayerHadangGame: Ready for 2 players!');
      
    } catch (e) {
      print('Error creating multiplayer game: $e');
    }
  }

  Future<void> _createPlayableField() async {
    // Calculate field size untuk mobile screen
    final gameSize = size;
    final padding = 60.0;
    
    fieldSize = Vector2(
      gameSize.x - (padding * 2),
      (gameSize.y - 200) * 0.7, // Leave space for UI
    );
    
    fieldPosition = Vector2(
      (gameSize.x - fieldSize.x) / 2,
      80 + padding,
    );
    
    // Main field background
    fieldBackground = RectangleComponent(
      size: fieldSize,
      position: fieldPosition,
      paint: Paint()..color = GameColors.fieldBackground,
    );
    await add(fieldBackground);
    
    // Create field border
    final border = RectangleComponent(
      size: fieldSize,
      position: fieldPosition,
      paint: Paint()
        ..color = GameColors.fieldBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0,
    );
    await add(border);
    
    // Create sections (6 petak)
    final sectionWidth = fieldSize.x / 3;
    final sectionHeight = fieldSize.y / 2;
    
    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < 3; col++) {
        final section = RectangleComponent(
          size: Vector2(sectionWidth, sectionHeight),
          position: Vector2(
            fieldPosition.x + (col * sectionWidth),
            fieldPosition.y + (row * sectionHeight),
          ),
          paint: Paint()
            ..color = (row + col) % 2 == 0 
                ? GameColors.fieldAlternate 
                : GameColors.fieldBackground
            ..style = PaintingStyle.fill,
        );
        
        final sectionBorder = RectangleComponent(
          size: Vector2(sectionWidth, sectionHeight),
          position: Vector2(
            fieldPosition.x + (col * sectionWidth),
            fieldPosition.y + (row * sectionHeight),
          ),
          paint: Paint()
            ..color = Colors.white.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
        
        fieldSections.add(section);
        await add(section);
        await add(sectionBorder);
      }
    }
    
    // Create guard lines (4 horizontal + 1 center vertical)
    // 4 horizontal lines
    for (int i = 1; i <= 4; i++) {
      final lineY = fieldPosition.y + (i * sectionHeight / 2);
      final guardLine = RectangleComponent(
        size: Vector2(fieldSize.x, 3),
        position: Vector2(fieldPosition.x, lineY - 1.5),
        paint: Paint()..color = GameColors.guardLine,
      );
      guardLines.add(guardLine);
      await add(guardLine);
    }
    
    // 1 center vertical line (sodor)
    final centerLine = RectangleComponent(
      size: Vector2(3, fieldSize.y),
      position: Vector2(fieldPosition.x + (fieldSize.x / 2) - 1.5, fieldPosition.y),
      paint: Paint()..color = GameColors.centerLine,
    );
    guardLines.add(centerLine);
    await add(centerLine);
    
    print('Playable field created: ${fieldSize.x.toInt()}x${fieldSize.y.toInt()}');
  }

  Future<void> _createTwoTeams() async {
    // Team Merah (Red) - 5 players
    redTeamPlayers.clear();
    for (int i = 0; i < 5; i++) {
      final player = CircleComponent(
        radius: 18,
        paint: Paint()..color = GameColors.teamAColor,
      );
      
      // Add player outline untuk visibility
      final outline = CircleComponent(
        radius: 20,
        paint: Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
      player.add(outline);
      
      // Add player number
      final numberText = TextComponent(
        text: '${i + 1}',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
      );
      player.add(numberText);
      
      redTeamPlayers.add(player);
      await add(player);
    }
    
    // Team Biru (Blue) - 5 players  
    blueTeamPlayers.clear();
    for (int i = 0; i < 5; i++) {
      final player = CircleComponent(
        radius: 18,
        paint: Paint()..color = GameColors.teamBColor,
      );
      
      // Add player outline
      final outline = CircleComponent(
        radius: 20,
        paint: Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
      player.add(outline);
      
      // Add player number
      final numberText = TextComponent(
        text: '${i + 1}',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
      );
      player.add(numberText);
      
      blueTeamPlayers.add(player);
      await add(player);
    }
    
    print('Two teams created: 5 Red + 5 Blue players');
  }

  void _setupGamePositions() {
    if (redTeamIsGuarding) {
      // Red team as guards (4 horizontal + 1 sodor)
      _positionGuards(redTeamPlayers);
      _positionAttackers(blueTeamPlayers);
    } else {
      // Blue team as guards
      _positionGuards(blueTeamPlayers);
      _positionAttackers(redTeamPlayers);
    }
  }

  void _positionGuards(List<CircleComponent> guards) {
    final sectionHeight = fieldSize.y / 2;
    
    // Position 4 horizontal guards
    for (int i = 0; i < 4; i++) {
      final lineY = fieldPosition.y + ((i + 1) * sectionHeight / 2);
      guards[i].position = Vector2(
        fieldPosition.x + (fieldSize.x / 2),
        lineY,
      );
    }
    
    // Position 1 sodor guard (center)
    guards[4].position = Vector2(
      fieldPosition.x + (fieldSize.x / 2),
      fieldPosition.y + (fieldSize.y / 2),
    );
  }

  void _positionAttackers(List<CircleComponent> attackers) {
    // Position attackers at start line
    final startY = fieldPosition.y - 40;
    final spacing = (fieldSize.x - 80) / 4;
    
    for (int i = 0; i < 5; i++) {
      attackers[i].position = Vector2(
        fieldPosition.x + 40 + (i * spacing),
        startY,
      );
    }
  }

  Future<void> _setupGameUI() async {
    // Score display
    scoreDisplay = TextComponent(
      text: 'MERAH: 0  vs  BIRU: 0',
      position: Vector2(size.x / 2, 30),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
    );
    await add(scoreDisplay);
    
    // Round display
    roundDisplay = TextComponent(
      text: 'ROUND 1',
      position: Vector2(size.x / 2, 55),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      anchor: Anchor.center,
    );
    await add(roundDisplay);
    
    // Instruction display
    instructionDisplay = TextComponent(
      text: 'TIM BIRU MENYERANG - TAP PEMAIN UNTUK PINDAH',
      position: Vector2(size.x / 2, fieldPosition.y + fieldSize.y + 30),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.lightGreen,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      anchor: Anchor.center,
    );
    await add(instructionDisplay);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (gameActive) {
      _checkCollisions();
      _checkScoring();
      _updateUI();
    }
  }

  void _checkCollisions() {
    final attackers = redTeamIsGuarding ? blueTeamPlayers : redTeamPlayers;
    final guards = redTeamIsGuarding ? redTeamPlayers : blueTeamPlayers;
    
    for (final attacker in attackers) {
      for (final guard in guards) {
        final distance = attacker.position.distanceTo(guard.position);
        
        if (distance < 40) { // Collision detected
          _handleTouch(guard, attacker);
          return;
        }
      }
    }
  }

  void _handleTouch(CircleComponent guard, CircleComponent attacker) {
    if (GameSettings.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
    
    // Switch teams
    redTeamIsGuarding = !redTeamIsGuarding;
    round++;
    
    // Reset positions
    _setupGamePositions();
    
    // Clear selection
    selectedPlayer = null;
    
    print('TOUCH! Teams switched - Round $round');
  }

  void _checkScoring() {
    final attackers = redTeamIsGuarding ? blueTeamPlayers : redTeamPlayers;
    final finishLine = fieldPosition.y + fieldSize.y + 20;
    
    for (final attacker in attackers) {
      if (attacker.position.y >= finishLine) {
        _awardScore();
        return;
      }
    }
  }

  void _awardScore() {
    if (GameSettings.hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    
    if (redTeamIsGuarding) {
      blueScore++; // Blue scored
      print('SCORE! Blue team scored');
    } else {
      redScore++; // Red scored  
      print('SCORE! Red team scored');
    }
    
    // Switch teams after scoring
    redTeamIsGuarding = !redTeamIsGuarding;
    round++;
    
    // Reset positions
    _setupGamePositions();
    
    // Clear selection
    selectedPlayer = null;
  }

  void _updateUI() {
    scoreDisplay.text = 'MERAH: $redScore  vs  BIRU: $blueScore';
    roundDisplay.text = 'ROUND $round';
    
    final attackingTeam = redTeamIsGuarding ? 'BIRU' : 'MERAH';
    instructionDisplay.text = 'TIM $attackingTeam MENYERANG - TAP PEMAIN UNTUK PINDAH';
  }

  // Tap handling untuk 2-player controls
  void handlePlayerTap(Offset tapPosition) {
    final tapVector = Vector2(tapPosition.dx, tapPosition.dy);
    final attackers = redTeamIsGuarding ? blueTeamPlayers : redTeamPlayers;
    
    // First, check if tapping on an attacker to select
    for (final attacker in attackers) {
      final distance = attacker.position.distanceTo(tapVector);
      
      if (distance < 30) {
        // Select this player
        _selectPlayer(attacker);
        return;
      }
    }
    
    // If we have a selected player, move them
    if (selectedPlayer != null) {
      _moveSelectedPlayer(tapVector);
    }
  }

  void _selectPlayer(CircleComponent player) {
    // Clear previous selection
    if (selectedPlayer != null) {
      _clearPlayerSelection(selectedPlayer!);
    }
    
    // Select new player
    selectedPlayer = player;
    _highlightSelectedPlayer(player);
    
    print('Player selected for movement');
  }

  void _highlightSelectedPlayer(CircleComponent player) {
    // Add selection highlight
    final highlight = CircleComponent(
      radius: 25,
      paint: Paint()
        ..color = selectionColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );
    player.add(highlight);
  }

  void _clearPlayerSelection(CircleComponent player) {
    // Remove highlight (simple approach: remove last child if it's highlight)
    if (player.children.isNotEmpty) {
      final lastChild = player.children.last;
      if (lastChild is CircleComponent) {
        player.remove(lastChild);
      }
    }
  }

  void _moveSelectedPlayer(Vector2 newPosition) {
    if (selectedPlayer == null) return;
    
    // Validate move (basic validation)
    if (_isValidMove(selectedPlayer!, newPosition)) {
      selectedPlayer!.position = newPosition;
      print('Player moved to ${newPosition.x.toInt()}, ${newPosition.y.toInt()}');
    }
  }

  bool _isValidMove(CircleComponent player, Vector2 newPosition) {
    // Basic boundary check
    if (newPosition.x < fieldPosition.x || 
        newPosition.x > fieldPosition.x + fieldSize.x ||
        newPosition.y < fieldPosition.y - 60 ||
        newPosition.y > fieldPosition.y + fieldSize.y + 60) {
      return false;
    }
    
    return true;
  }

  // Public control methods
  void restartGame() {
    redScore = 0;
    blueScore = 0;
    round = 1;
    redTeamIsGuarding = true;
    gameActive = true;
    selectedPlayer = null;
    
    _setupGamePositions();
    
    print('Game restarted - Red guards, Blue attacks');
  }

  void pauseGame() {
    gameActive = !gameActive;
    print('Game ${gameActive ? 'resumed' : 'paused'}');
  }

  void switchTeams() {
    redTeamIsGuarding = !redTeamIsGuarding;
    round++;
    _setupGamePositions();
    selectedPlayer = null;
    
    print('Manual team switch - Round $round');
  }

  Map<String, dynamic> getGameStats() {
    return {
      'redScore': redScore,
      'blueScore': blueScore,
      'round': round,
      'attackingTeam': redTeamIsGuarding ? 'Blue' : 'Red',
      'guardingTeam': redTeamIsGuarding ? 'Red' : 'Blue',
      'isActive': gameActive,
    };
  }
}