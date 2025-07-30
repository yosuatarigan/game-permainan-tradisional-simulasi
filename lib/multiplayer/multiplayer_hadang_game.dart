// File: lib/multiplayer/improved_multiplayer_hadang_game.dart
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/game_constants.dart';

class ImprovedMultiplayerHadangGame extends FlameGame
    with HasCollisionDetection {
  // Game dimensions dan layout
  late Vector2 fieldPosition;
  late Vector2 fieldSize;
  late double sectionWidth;
  late double sectionHeight;

  // Field components dengan layout yang benar
  late RectangleComponent fieldBackground;
  final List<RectangleComponent> fieldSections = [];
  late RectangleComponent sodorLine;

  // Players - 3 vs 3 untuk active gameplay
  final List<PlayerComponent> teamRed = []; // Player 1
  final List<PlayerComponent> teamBlue = []; // Player 2

  // Game state - ACTIVE MODE (no turn-based)
  int redScore = 0;
  int blueScore = 0;
  int currentRound = 1;
  bool gameActive = true;
  bool gamePaused = false;

  // Player controls
  PlayerComponent? selectedRedPlayer;
  PlayerComponent? selectedBluePlayer;

  // UI Components
  late TextComponent scoreText;
  late TextComponent statusText;
  late TextComponent instructionText;

  // Public getters
  int get scoreTeamRed => redScore;
  int get scoreTeamBlue => blueScore;
  Widget get widget => GameWidget(game: this);

  @override
  Future<void> onLoad() async {
    print('🎮 Loading Multiplayer Hadang Game...');

    try {
      // Setup camera
      camera.viewfinder.visibleGameSize = size;

      // Create proper hadang field layout
      await _createProperHadangField();

      // Create teams (3v3 optimal)
      await _createOptimalTeams();

      // Position players immediately for ACTIVE gameplay
      _setupActiveGameplay();

      // Setup game UI
      await _setupGameUI();

      // Add debug info
      await _addDebugInfo();

      print('✅ Hadang game ready!');
      print('🔍 Field: ${fieldSize.x.toInt()}x${fieldSize.y.toInt()}');
      print('👥 Players: ${teamRed.length} red, ${teamBlue.length} blue');
    } catch (e) {
      print('❌ Error creating game: $e');
    }
  }

  Future<void> _createProperHadangField() async {
    // Calculate optimal field size
    final gameWidth = size.x;
    final gameHeight = size.y;

    fieldSize = Vector2(
      gameWidth * 0.8, // 80% of screen width
      gameHeight * 0.5, // 50% of screen height
    );

    fieldPosition = Vector2(
      (gameWidth - fieldSize.x) / 2,
      gameHeight * 0.25, // Position di tengah vertikal
    );

    // Calculate section dimensions (3x2 grid)
    sectionWidth = fieldSize.x / 3;
    sectionHeight = fieldSize.y / 2;

    // Create main field background
    fieldBackground = RectangleComponent(
      size: fieldSize,
      position: fieldPosition,
      paint: Paint()..color = Colors.green[100]!,
    );
    await add(fieldBackground);

    // Create 6 sections (3 kolom x 2 baris)
    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < 3; col++) {
        final section = RectangleComponent(
          size: Vector2(sectionWidth, sectionHeight),
          position: Vector2(
            fieldPosition.x + (col * sectionWidth),
            fieldPosition.y + (row * sectionHeight),
          ),
          paint: Paint()..color = Colors.green[50]!,
        );
        fieldSections.add(section);
        await add(section);
      }
    }

    // Create boundary lines (4 tepi + 2 pembagi vertikal)
    // Top boundary
    await add(
      RectangleComponent(
        size: Vector2(fieldSize.x, 4),
        position: fieldPosition,
        paint: Paint()..color = Colors.black,
      ),
    );

    // Bottom boundary
    await add(
      RectangleComponent(
        size: Vector2(fieldSize.x, 4),
        position: Vector2(fieldPosition.x, fieldPosition.y + fieldSize.y - 4),
        paint: Paint()..color = Colors.black,
      ),
    );

    // Left boundary
    await add(
      RectangleComponent(
        size: Vector2(4, fieldSize.y),
        position: fieldPosition,
        paint: Paint()..color = Colors.black,
      ),
    );

    // Right boundary
    await add(
      RectangleComponent(
        size: Vector2(4, fieldSize.y),
        position: Vector2(fieldPosition.x + fieldSize.x - 4, fieldPosition.y),
        paint: Paint()..color = Colors.black,
      ),
    );

    // Vertical dividers (2 garis pembagi kolom)
    for (int col = 1; col <= 2; col++) {
      await add(
        RectangleComponent(
          size: Vector2(4, fieldSize.y),
          position: Vector2(
            fieldPosition.x + (col * sectionWidth) - 2,
            fieldPosition.y,
          ),
          paint: Paint()..color = Colors.black,
        ),
      );
    }

    // GARIS SODOR - satu-satunya garis horizontal di dalam lapangan
    sodorLine = RectangleComponent(
      size: Vector2(fieldSize.x, 6),
      position: Vector2(
        fieldPosition.x,
        fieldPosition.y + (fieldSize.y / 2) - 3,
      ),
      paint: Paint()..color = Colors.yellow[700]!,
    );
    await add(sodorLine);

    // Add sodor label
    await add(
      TextComponent(
        text: 'GARIS SODOR',
        position: Vector2(
          fieldPosition.x + 20,
          fieldPosition.y + (fieldSize.y / 2) - 25,
        ),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    print('Proper Hadang field created');
  }

  Future<void> _createOptimalTeams() async {
    // Create Team Red (Player 1) - 3 players
    teamRed.clear();
    for (int i = 0; i < 3; i++) {
      final player = PlayerComponent(
        teamColor: Colors.red[600]!,
        playerNumber: i + 1,
        isRed: true,
      );
      teamRed.add(player);
      await add(player);
    }

    // Create Team Blue (Player 2) - 3 players
    teamBlue.clear();
    for (int i = 0; i < 3; i++) {
      final player = PlayerComponent(
        teamColor: Colors.blue[600]!,
        playerNumber: i + 1,
        isRed: false,
      );
      teamBlue.add(player);
      await add(player);
    }

    print('Teams created: 3v3 optimal setup');
  }

  Future<void> _setupGameUI() async {
    // Score display
    scoreText = TextComponent(
      text: 'PLAYER 1: 0  vs  PLAYER 2: 0',
      position: Vector2(size.x / 2, 40),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
    );
    await add(scoreText);

    // Status display
    statusText = TextComponent(
      text: 'ROUND 1 - MERAH JAGA',
      position: Vector2(size.x / 2, 65),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      anchor: Anchor.center,
    );
    await add(statusText);

    // Instruction display
    instructionText = TextComponent(
      text: 'TAP PEMAIN → TAP TUJUAN → HINDARI PENJAGA',
      position: Vector2(size.x / 2, fieldPosition.y + fieldSize.y + 30),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.lightGreen,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      anchor: Anchor.center,
    );
    await add(instructionText);
  }

  Future<void> _addDebugInfo() async {
    // Add debug text to show game status
    await add(
      TextComponent(
        text: 'DEBUG: Players loaded successfully',
        position: Vector2(10, 10),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.yellow,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _setupActiveGameplay() {
    print('🎯 Setting up ACTIVE gameplay - both teams play simultaneously');

    // Red team starts at top (targeting bottom)
    for (int i = 0; i < teamRed.length; i++) {
      teamRed[i].position = Vector2(
        fieldPosition.x + 60 + (i * (fieldSize.x - 120) / (teamRed.length - 1)),
        fieldPosition.y - 60, // Above field
      );
      teamRed[i].setAsGuard(false); // All players are attackers in active mode
      teamRed[i].resetProgress();
      print(
        '🔴 Red player ${i + 1} positioned at ${teamRed[i].position.x.toInt()}, ${teamRed[i].position.y.toInt()}',
      );
    }

    // Blue team starts at bottom (targeting top)
    for (int i = 0; i < teamBlue.length; i++) {
      teamBlue[i].position = Vector2(
        fieldPosition.x +
            60 +
            (i * (fieldSize.x - 120) / (teamBlue.length - 1)),
        fieldPosition.y + fieldSize.y + 60, // Below field
      );
      teamBlue[i].setAsGuard(false); // All players are attackers in active mode
      teamBlue[i].resetProgress();
      print(
        '🔵 Blue player ${i + 1} positioned at ${teamBlue[i].position.x.toInt()}, ${teamBlue[i].position.y.toInt()}',
      );
    }

    // Clear selections
    _clearAllSelections();

    print('✅ Active gameplay setup complete');
  }

  void _positionGuards(List<PlayerComponent> guards) {
    // Guard positions: 2 horizontal guards + 1 sodor guard

    // Top horizontal guard
    guards[0].position = Vector2(
      fieldPosition.x + (fieldSize.x / 2),
      fieldPosition.y + 20,
    );
    guards[0].setAsGuard(true);
    guards[0].assignGuardLine('horizontal_top');

    // Bottom horizontal guard
    guards[1].position = Vector2(
      fieldPosition.x + (fieldSize.x / 2),
      fieldPosition.y + fieldSize.y - 20,
    );
    guards[1].setAsGuard(true);
    guards[1].assignGuardLine('horizontal_bottom');

    // Sodor guard (center vertical)
    guards[2].position = Vector2(
      fieldPosition.x + (fieldSize.x / 2),
      fieldPosition.y + (fieldSize.y / 2),
    );
    guards[2].setAsGuard(true);
    guards[2].assignGuardLine('sodor_vertical');
  }

  void _positionAttackers(List<PlayerComponent> attackers) {
    // Position attackers at start area (above field)
    final startY = fieldPosition.y - 40;
    final spacing = fieldSize.x / 4;

    for (int i = 0; i < attackers.length; i++) {
      attackers[i].position = Vector2(
        fieldPosition.x + spacing + (i * spacing),
        startY,
      );
      attackers[i].setAsGuard(false);
      attackers[i].resetProgress();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameActive && !gamePaused) {
      _checkActiveCollisions();
      _checkActiveScoring();
      _updateGameUI();
    }
  }

  void _checkActiveCollisions() {
    // Check collisions between red and blue players
    for (final redPlayer in teamRed) {
      for (final bluePlayer in teamBlue) {
        if (redPlayer.position.distanceTo(bluePlayer.position) < 45) {
          _handleActiveCollision(redPlayer, bluePlayer);
          return;
        }
      }
    }
  }

  void _handleActiveCollision(
    PlayerComponent redPlayer,
    PlayerComponent bluePlayer,
  ) {
    if (GameSettings.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }

    print('💥 COLLISION! Red vs Blue players');

    // Reset both players to their starting positions
    redPlayer.position = Vector2(fieldPosition.x + 60, fieldPosition.y - 60);
    redPlayer.resetProgress();

    bluePlayer.position = Vector2(
      fieldPosition.x + 60,
      fieldPosition.y + fieldSize.y + 60,
    );
    bluePlayer.resetProgress();

    // Clear selections
    _clearAllSelections();
  }

  void _checkActiveScoring() {
    // Check red team scoring (reaching bottom)
    for (final redPlayer in teamRed) {
      if (redPlayer.position.y >= fieldPosition.y + fieldSize.y + 40) {
        _awardActiveScore(true, redPlayer);
        return;
      }
    }

    // Check blue team scoring (reaching top)
    for (final bluePlayer in teamBlue) {
      if (bluePlayer.position.y <= fieldPosition.y - 40) {
        _awardActiveScore(false, bluePlayer);
        return;
      }
    }
  }

  void _awardActiveScore(bool redScored, PlayerComponent scorer) {
    if (GameSettings.hapticEnabled) {
      HapticFeedback.lightImpact();
    }

    if (redScored) {
      redScore++;
      print('🔴 RED SCORES! Total: $redScore');
      // Reset the scorer to start
      scorer.position = Vector2(fieldPosition.x + 60, fieldPosition.y - 60);
    } else {
      blueScore++;
      print('🔵 BLUE SCORES! Total: $blueScore');
      // Reset the scorer to start
      scorer.position = Vector2(
        fieldPosition.x + 60,
        fieldPosition.y + fieldSize.y + 60,
      );
    }

    scorer.resetProgress();
    _clearAllSelections();
  }

  void _updateGameUI() {
    scoreText.text = 'PLAYER 1: $redScore  vs  PLAYER 2: $blueScore';
    statusText.text = 'ROUND $currentRound - ACTIVE GAMEPLAY';
    instructionText.text = 'KEDUA TIM BERMAIN BERSAMAAN - CAPAI SISI SEBERANG!';
  }

  // Touch handling untuk 2-player controls - ACTIVE MODE
  void handlePlayerTap(Offset tapPosition) {
    if (!gameActive || gamePaused) return;

    final tapVector = Vector2(tapPosition.dx, tapPosition.dy);
    final isLeftSide = tapPosition.dx < size.x / 2;

    if (isLeftSide) {
      // Player 1 control (Red team)
      _handlePlayer1Control(tapVector);
    } else {
      // Player 2 control (Blue team)
      _handlePlayer2Control(tapVector);
    }
  }

  void _handlePlayer1Control(Vector2 tapPosition) {
    // Check if tapping on red player
    for (final player in teamRed) {
      if (player.position.distanceTo(tapPosition) < 35) {
        _selectPlayer(player, true);
        return;
      }
    }

    // Move selected red player
    if (selectedRedPlayer != null) {
      _movePlayer(selectedRedPlayer!, tapPosition);
    }
  }

  void _handlePlayer2Control(Vector2 tapPosition) {
    // Check if tapping on blue player
    for (final player in teamBlue) {
      if (player.position.distanceTo(tapPosition) < 35) {
        _selectPlayer(player, false);
        return;
      }
    }

    // Move selected blue player
    if (selectedBluePlayer != null) {
      _movePlayer(selectedBluePlayer!, tapPosition);
    }
  }

  void _selectPlayer(PlayerComponent player, bool isRedPlayer) {
    if (isRedPlayer) {
      selectedRedPlayer?.clearSelection();
      selectedRedPlayer = player;
    } else {
      selectedBluePlayer?.clearSelection();
      selectedBluePlayer = player;
    }

    player.showSelection();
    print(
      'Player selected: ${player.isRed ? 'Red' : 'Blue'} #${player.playerNumber}',
    );
  }

  void _movePlayer(PlayerComponent player, Vector2 newPosition) {
    // Basic boundary check - allow movement in expanded area
    if (newPosition.x >= 20 &&
        newPosition.x <= size.x - 20 &&
        newPosition.y >= 20 &&
        newPosition.y <= size.y - 20) {
      player.moveTo(newPosition);
      print(
        '${player.isRed ? 'Red' : 'Blue'} player moved to ${newPosition.x.toInt()}, ${newPosition.y.toInt()}',
      );
    }
  }

  // Public control methods - ACTIVE MODE
  void restartGame() {
    redScore = 0;
    blueScore = 0;
    currentRound = 1;
    gameActive = true;
    gamePaused = false;

    _setupActiveGameplay();
    print('🔄 Game restarted - Active mode');
  }

  void pauseGame() {
    gamePaused = !gamePaused;
    print('⏸️ Game ${gamePaused ? 'paused' : 'resumed'}');
  }

  void switchTeams() {
    // In active mode, just reset positions
    _setupActiveGameplay();
    currentRound++;
    print('🔄 Teams reset - Round $currentRound');
  }

  void _clearAllSelections() {
    selectedRedPlayer?.clearSelection();
    selectedBluePlayer?.clearSelection();
    selectedRedPlayer = null;
    selectedBluePlayer = null;
  }

  Map<String, dynamic> getGameStats() {
    return {
      'redScore': redScore,
      'blueScore': blueScore,
      'round': currentRound,
      'attackingTeam': 'Both', // Both teams attack in active mode
      'guardingTeam': 'None', // No guards in active mode
      'isActive': gameActive,
      'isPaused': gamePaused,
    };
  }
}

// Player Component untuk ACTIVE gameplay - simplified
class PlayerComponent extends CircleComponent {
  final Color teamColor;
  final int playerNumber;
  final bool isRed;

  bool _isSelected = false;
  bool _hasScored = false;

  PlayerComponent({
    required this.teamColor,
    required this.playerNumber,
    required this.isRed,
  }) : super(radius: 18, paint: Paint()..color = teamColor);

  @override
  Future<void> onLoad() async {
    // Add white outline for visibility
    add(
      CircleComponent(
        radius: 20,
        paint:
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
      ),
    );

    // Add player number
    add(
      TextComponent(
        text: '$playerNumber',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
      ),
    );

    print('✅ Player ${isRed ? 'Red' : 'Blue'} #$playerNumber loaded');
  }

  // Simplified methods for active gameplay
  void setAsGuard(bool guard) {
    // In active mode, no guards - all players are active
  }

  void assignGuardLine(String lineType) {
    // Not used in active mode
  }

  void updateGuardMovement(Vector2 fieldPos, Vector2 fieldSize) {
    // Not used in active mode
  }

  bool checkCollision(PlayerComponent other) {
    return position.distanceTo(other.position) < 40;
  }

  bool isInField(Vector2 fieldPos, Vector2 fieldSize) {
    return position.x >= fieldPos.x - 50 &&
        position.x <= fieldPos.x + fieldSize.x + 50 &&
        position.y >= fieldPos.y - 50 &&
        position.y <= fieldPos.y + fieldSize.y + 50;
  }

  bool checkScoring(Vector2 fieldPos, Vector2 fieldSize) {
    // Simplified scoring for active mode
    if (isRed) {
      // Red team scores by reaching bottom
      return position.y >= fieldPos.y + fieldSize.y + 30;
    } else {
      // Blue team scores by reaching top
      return position.y <= fieldPos.y - 30;
    }
  }

  void resetProgress() {
    _hasScored = false;
  }

  bool canMoveTo(Vector2 newPos, Vector2 fieldPos, Vector2 fieldSize) {
    // Allow free movement in active mode
    return true;
  }

  void moveTo(Vector2 newPosition) {
    position = newPosition;
  }

  void showSelection() {
    if (!_isSelected) {
      _isSelected = true;
      add(
        CircleComponent(
          radius: 25,
          paint:
              Paint()
                ..color = Colors.yellow
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3,
        ),
      );
    }
  }

  void clearSelection() {
    if (_isSelected) {
      _isSelected = false;
      // Remove selection highlight (last child)
      if (children.isNotEmpty) {
        children.last.removeFromParent();
      }
    }
  }
}
