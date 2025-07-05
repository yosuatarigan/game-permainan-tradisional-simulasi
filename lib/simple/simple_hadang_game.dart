// File: lib/game/simple_hadang_game.dart (Ultra Simple - Fixed Widget)
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../utils/game_constants.dart';

class SimpleHadangGame extends FlameGame {
  // Simple game state
  final HadangGameState gameState = HadangGameState();
  
  // Simple components
  late RectangleComponent field;
  final List<CircleComponent> players = [];
  
  // Game data
  int teamAScore = 0;
  int teamBScore = 0;
  bool isPaused = false;
  
  // Public getters
  int get scoreTeamA => teamAScore;
  int get scoreTeamB => teamBScore;
  Duration get gameTime => gameState.gameTime;
  String get currentPhase => 'Playing';
  
  // Widget getter untuk UI integration
  Widget get widget => GameWidget(game: this);

  @override
  Future<void> onLoad() async {
    print('SimpleHadangGame: Starting load...');
    
    // Create simple field
    field = RectangleComponent(
      size: Vector2(300, 200),
      position: Vector2(50, 100),
      paint: Paint()..color = GameColors.fieldBackground,
    );
    add(field);
    
    // Create simple players
    for (int i = 0; i < 10; i++) {
      final player = CircleComponent(
        radius: 15,
        position: Vector2(100 + (i * 30), 150),
        paint: Paint()..color = i < 5 ? GameColors.teamAColor : GameColors.teamBColor,
      );
      players.add(player);
      add(player);
    }
    
    // Create simple UI
    final scoreText = TextComponent(
      text: 'Red: 0 - Blue: 0',
      position: Vector2(20, 20),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(scoreText);
    
    print('SimpleHadangGame: Load completed!');
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isPaused) {
      gameState.updateTime(dt);
    }
  }

  // Simple methods
  void restartGame() {
    teamAScore = 0;
    teamBScore = 0;
    gameState.resetGame();
    print('Game restarted');
  }

  void pauseResumeGame() {
    isPaused = !isPaused;
    gameState.togglePause();
    print('Game ${isPaused ? 'paused' : 'resumed'}');
  }

  void switchTeams() {
    // Simple team switch
    print('Teams switched');
  }

  void moveClosestAttacker(Offset tapPosition) {
    print('Tap at: ${tapPosition.dx}, ${tapPosition.dy}');
    
    // Simple player movement
    if (players.isNotEmpty) {
      final player = players.first;
      player.position = Vector2(tapPosition.dx, tapPosition.dy);
    }
  }
}