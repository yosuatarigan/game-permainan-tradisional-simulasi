// File: lib/multiplayer/improved_multiplayer_hadang_game.dart
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/game_constants.dart';

class ImprovedMultiplayerHadangGame extends FlameGame {
  // Game state
  int redScore = 0;
  int blueScore = 0;
  int currentRound = 1;
  bool gameActive = true;
  bool gamePaused = false;
  
  // Game dimensions
  late Vector2 fieldPosition;
  late Vector2 fieldSize;
  
  // Players - Simple and reliable
  final List<GamePlayer> redPlayers = [];
  final List<GamePlayer> bluePlayers = [];
  
  // Selection
  GamePlayer? selectedRedPlayer;
  GamePlayer? selectedBluePlayer;
  
  // Game components
  late RectangleComponent fieldBackground;
  late RectangleComponent sodorLine;
  late TextComponent scoreDisplay;
  
  // Movement restrictions
  static const double maxMovementDistance = 120.0;
  
  // Public getters
  int get scoreTeamRed => redScore;
  int get scoreTeamBlue => blueScore;
  Widget get widget => GameWidget(game: this);

  @override
  Future<void> onLoad() async {
    print('🎮 STARTING HADANG GAME...');
    
    try {
      // Wait for proper initialization
      await Future.delayed(const Duration(milliseconds: 100));
      
      print('✅ Game size: ${size.x.toInt()} x ${size.y.toInt()}');
      
      // Create field
      await _createGameField();
      
      // Create players
      await _createGamePlayers();
      
      // Position players
      _positionAllPlayers();
      
      // Add UI
      await _addGameUI();
      
      print('✅ GAME READY!');
      
    } catch (e) {
      print('❌ ERROR: $e');
    }
  }

  Future<void> _createGameField() async {
    print('🏟️ Creating field...');
    
    // Field dimensions - fullscreen
    fieldSize = Vector2(size.x * 0.9, size.y * 0.75);
    fieldPosition = Vector2(
      (size.x - fieldSize.x) / 2,
      size.y * 0.15,
    );
    
    // Field background
    fieldBackground = RectangleComponent(
      size: fieldSize,
      position: fieldPosition,
      paint: Paint()..color = Colors.green[200]!,
    );
    await add(fieldBackground);
    
    // Create 6 sections
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
          paint: Paint()..color = (row + col) % 2 == 0 ? Colors.green[100]! : Colors.green[50]!,
        );
        await add(section);
        
        // Section borders
        final border = RectangleComponent(
          size: Vector2(sectionWidth, sectionHeight),
          position: Vector2(
            fieldPosition.x + (col * sectionWidth),
            fieldPosition.y + (row * sectionHeight),
          ),
          paint: Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
        await add(border);
      }
    }
    
    // Field border
    final outerBorder = RectangleComponent(
      size: fieldSize,
      position: fieldPosition,
      paint: Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );
    await add(outerBorder);
    
    // Vertical dividers
    for (int i = 1; i <= 2; i++) {
      final divider = RectangleComponent(
        size: Vector2(6, fieldSize.y),
        position: Vector2(
          fieldPosition.x + (i * sectionWidth) - 3,
          fieldPosition.y,
        ),
        paint: Paint()..color = Colors.black,
      );
      await add(divider);
    }
    
    // SODOR line
    sodorLine = RectangleComponent(
      size: Vector2(fieldSize.x, 8),
      position: Vector2(
        fieldPosition.x,
        fieldPosition.y + (fieldSize.y / 2) - 4,
      ),
      paint: Paint()..color = Colors.orange[600]!,
    );
    await add(sodorLine);
    
    // Goal zones
    await _createGoalZones();
    
    print('✅ Field created');
  }

  Future<void> _createGoalZones() async {
    // Red goal (bottom)
    final redGoal = RectangleComponent(
      size: Vector2(fieldSize.x, 40),
      position: Vector2(fieldPosition.x, fieldPosition.y + fieldSize.y + 10),
      paint: Paint()..color = Colors.red.withOpacity(0.3),
    );
    await add(redGoal);
    
    await add(TextComponent(
      text: '🏁 RED GOAL ZONE',
      position: Vector2(size.x / 2, fieldPosition.y + fieldSize.y + 30),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
    ));
    
    // Blue goal (top)
    final blueGoal = RectangleComponent(
      size: Vector2(fieldSize.x, 40),
      position: Vector2(fieldPosition.x, fieldPosition.y - 50),
      paint: Paint()..color = Colors.blue.withOpacity(0.3),
    );
    await add(blueGoal);
    
    await add(TextComponent(
      text: '🏁 BLUE GOAL ZONE',
      position: Vector2(size.x / 2, fieldPosition.y - 30),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
    ));
  }

  Future<void> _createGamePlayers() async {
    print('👥 Creating players...');
    
    // Clear existing
    redPlayers.clear();
    bluePlayers.clear();
    
    // Create red team
    for (int i = 0; i < 3; i++) {
      final player = GamePlayer(
        playerNumber: i + 1,
        isRed: true,
        assetPath: 'red.png',
      );
      
      redPlayers.add(player);
      await add(player);
      print('🔴 Added red player ${i + 1}');
    }
    
    // Create blue team
    for (int i = 0; i < 3; i++) {
      final player = GamePlayer(
        playerNumber: i + 1,
        isRed: false,
        assetPath: 'assets/blue.png',
      );
      
      bluePlayers.add(player);
      await add(player);
      print('🔵 Added blue player ${i + 1}');
    }
    
    print('✅ Players created: ${redPlayers.length + bluePlayers.length} total');
  }

  void _positionAllPlayers() {
    print('📍 Positioning players...');
    
    // Red team at top
    for (int i = 0; i < redPlayers.length; i++) {
      final x = fieldPosition.x + 100 + (i * (fieldSize.x - 200) / 2);
      final y = fieldPosition.y - 100;
      
      redPlayers[i].position = Vector2(x, y);
      redPlayers[i].startPosition = Vector2(x, y);
      print('🔴 Red ${i + 1} positioned at ${x.toInt()}, ${y.toInt()}');
    }
    
    // Blue team at bottom
    for (int i = 0; i < bluePlayers.length; i++) {
      final x = fieldPosition.x + 100 + (i * (fieldSize.x - 200) / 2);
      final y = fieldPosition.y + fieldSize.y + 100;
      
      bluePlayers[i].position = Vector2(x, y);
      bluePlayers[i].startPosition = Vector2(x, y);
      print('🔵 Blue ${i + 1} positioned at ${x.toInt()}, ${y.toInt()}');
    }
    
    print('✅ All players positioned');
  }

  Future<void> _addGameUI() async {
    scoreDisplay = TextComponent(
      text: 'RED: 0  -  BLUE: 0',
      position: Vector2(size.x / 2, 40),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black),
          ],
        ),
      ),
      anchor: Anchor.center,
    );
    await add(scoreDisplay);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (gameActive && !gamePaused) {
      _checkCollisions();
      _checkScoring();
      _updateUI();
    }
  }

  void _checkCollisions() {
    for (final redPlayer in redPlayers) {
      for (final bluePlayer in bluePlayers) {
        if (redPlayer.position.distanceTo(bluePlayer.position) < 70) {
          _handleCollision(redPlayer, bluePlayer);
          return;
        }
      }
    }
  }

  void _handleCollision(GamePlayer red, GamePlayer blue) {
    if (GameSettings.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
    
    print('💥 COLLISION! Players reset');
    
    red.resetToStart();
    blue.resetToStart();
    
    _clearSelections();
  }

  void _checkScoring() {
    // Check red scoring (reaching blue goal - top)
    for (final redPlayer in redPlayers) {
      if (redPlayer.position.y <= fieldPosition.y - 40) {
        _awardScore(true, redPlayer);
        return;
      }
    }
    
    // Check blue scoring (reaching red goal - bottom)
    for (final bluePlayer in bluePlayers) {
      if (bluePlayer.position.y >= fieldPosition.y + fieldSize.y + 40) {
        _awardScore(false, bluePlayer);
        return;
      }
    }
  }

  void _awardScore(bool redScored, GamePlayer scorer) {
    if (GameSettings.hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    
    if (redScored) {
      redScore++;
      print('🔴 RED SCORES! Total: $redScore');
    } else {
      blueScore++;
      print('🔵 BLUE SCORES! Total: $blueScore');
    }
    
    scorer.resetToStart();
    _clearSelections();
  }

  void _updateUI() {
    scoreDisplay.text = 'RED: $redScore  -  BLUE: $blueScore';
  }

  // Touch handling
  void handlePlayerTap(Offset tapPosition) {
    if (!gameActive || gamePaused) return;
    
    final tapVector = Vector2(tapPosition.dx, tapPosition.dy);
    final isLeftSide = tapPosition.dx < size.x / 2;
    
    print('👆 TAP at ${tapVector.x.toInt()}, ${tapVector.y.toInt()}');
    
    if (isLeftSide) {
      _handleRedControl(tapVector);
    } else {
      _handleBlueControl(tapVector);
    }
  }

  void _handleRedControl(Vector2 tapPosition) {
    // Check player selection
    for (final player in redPlayers) {
      if (player.position.distanceTo(tapPosition) < 60) {
        _selectRedPlayer(player);
        return;
      }
    }
    
    // Move selected player
    if (selectedRedPlayer != null) {
      _movePlayerWithLimits(selectedRedPlayer!, tapPosition);
    }
  }

  void _handleBlueControl(Vector2 tapPosition) {
    // Check player selection
    for (final player in bluePlayers) {
      if (player.position.distanceTo(tapPosition) < 60) {
        _selectBluePlayer(player);
        return;
      }
    }
    
    // Move selected player
    if (selectedBluePlayer != null) {
      _movePlayerWithLimits(selectedBluePlayer!, tapPosition);
    }
  }

  void _movePlayerWithLimits(GamePlayer player, Vector2 targetPosition) {
    final distance = player.position.distanceTo(targetPosition);
    
    if (distance < 20) return; // Too small movement
    
    // Limit movement distance
    Vector2 finalPosition;
    if (distance > maxMovementDistance) {
      final direction = (targetPosition - player.position).normalized();
      finalPosition = player.position + (direction * maxMovementDistance);
    } else {
      finalPosition = targetPosition;
    }
    
    // Boundary check
    if (finalPosition.x < 60 || finalPosition.x > size.x - 60 ||
        finalPosition.y < 60 || finalPosition.y > size.y - 60) {
      return;
    }
    
    player.position = finalPosition;
    print('${player.isRed ? '🔴' : '🔵'} Player moved');
  }

  void _selectRedPlayer(GamePlayer player) {
    selectedRedPlayer?.clearSelection();
    selectedRedPlayer = player;
    player.showSelection();
    print('🔴 Selected red player ${player.playerNumber}');
  }

  void _selectBluePlayer(GamePlayer player) {
    selectedBluePlayer?.clearSelection();
    selectedBluePlayer = player;
    player.showSelection();
    print('🔵 Selected blue player ${player.playerNumber}');
  }

  void _clearSelections() {
    selectedRedPlayer?.clearSelection();
    selectedBluePlayer?.clearSelection();
    selectedRedPlayer = null;
    selectedBluePlayer = null;
  }

  // Control methods
  void restartGame() {
    redScore = 0;
    blueScore = 0;
    gameActive = true;
    gamePaused = false;
    
    _positionAllPlayers();
    _clearSelections();
    
    print('🔄 Game restarted');
  }

  void pauseGame() {
    gamePaused = !gamePaused;
    print('⏸️ Game ${gamePaused ? 'paused' : 'resumed'}');
  }

  void switchTeams() {
    _positionAllPlayers();
    _clearSelections();
    print('🔄 Teams reset');
  }

  Map<String, dynamic> getGameStats() {
    return {
      'redScore': redScore,
      'blueScore': blueScore,
      'round': currentRound,
      'isActive': gameActive,
      'isPaused': gamePaused,
    };
  }
}

// Simple, Reliable Player Component
class GamePlayer extends PositionComponent {
  final int playerNumber;
  final bool isRed;
  final String assetPath;
  
  bool _isSelected = false;
  Vector2 startPosition = Vector2.zero();
  
  late SpriteComponent _sprite;
  late RectangleComponent _fallback;
  late CircleComponent _selectionRing;
  late TextComponent _numberText;
  
  GamePlayer({
    required this.playerNumber,
    required this.isRed,
    required this.assetPath,
  }) : super(
    size: Vector2(60, 60),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    print('🎯 Loading ${isRed ? 'Red' : 'Blue'} player #$playerNumber...');
    
    // Try to load sprite, fallback to rectangle
    try {
      _sprite = SpriteComponent(
        sprite: await Sprite.load(assetPath),
        size: Vector2(60, 60),
      );
      add(_sprite);
      print('✅ Loaded sprite: $assetPath');
    } catch (e) {
      print('⚠️ Using fallback for $assetPath');
      _fallback = RectangleComponent(
        size: Vector2(60, 60),
        paint: Paint()..color = isRed ? Colors.red[600]! : Colors.blue[600]!,
      );
      add(_fallback);
    }
    
    // White border for visibility
    final border = RectangleComponent(
      size: Vector2(64, 64),
      position: Vector2(-2, -2),
      paint: Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    add(border);
    
    // Player number
    _numberText = TextComponent(
      text: '$playerNumber',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(30, 30),
    );
    add(_numberText);
    
    // Selection ring
    _selectionRing = CircleComponent(
      radius: 40,
      paint: Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    _selectionRing.position = Vector2(30, 30);
    
    print('✅ ${isRed ? 'Red' : 'Blue'} player #$playerNumber ready');
  }

  void resetToStart() {
    position = startPosition;
  }

  void showSelection() {
    if (!_isSelected) {
      _isSelected = true;
      add(_selectionRing);
    }
  }

  void clearSelection() {
    if (_isSelected) {
      _isSelected = false;
      remove(_selectionRing);
    }
  }
}