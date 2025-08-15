// File: lib/game/hadang_game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/game_constants.dart';
import 'widgets/game_field.dart';
import 'widgets/game_hud.dart';
import 'widgets/joystick_widget.dart';
import 'game_logic.dart';

class HadangGameScreen extends StatefulWidget {
  const HadangGameScreen({super.key});

  @override
  State<HadangGameScreen> createState() => _HadangGameScreenState();
}

class _HadangGameScreenState extends State<HadangGameScreen> 
    with TickerProviderStateMixin {
  
  late HadangGameLogic gameLogic;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    gameLogic = HadangGameLogic();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _startGame();
  }

  @override
  void dispose() {
    _animationController.dispose();
    gameLogic.dispose();
    super.dispose();
  }

  void _startGame() {
    gameLogic.startGame();
    gameLogic.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _onPlayer1Move(Offset direction) {
    gameLogic.movePlayer1(direction);
    HapticFeedback.lightImpact();
  }

  void _onPlayer2Move(Offset direction) {
    gameLogic.movePlayer2(direction);
    HapticFeedback.lightImpact();
  }

  void _pauseGame() {
    gameLogic.togglePause();
    HapticFeedback.mediumImpact();
  }

  void _resetGame() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Game'),
        content: const Text('Mulai permainan baru?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              gameLogic.resetGame();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Hadang Game'),
        backgroundColor: GameColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _pauseGame,
            icon: Icon(gameLogic.isPaused ? Icons.play_arrow : Icons.pause),
          ),
          IconButton(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Game HUD - Score & Timer
          GameHUD(
            scoreRed: gameLogic.scoreRed,
            scoreBlue: gameLogic.scoreBlue,
            timeRemaining: gameLogic.timeRemaining,
            currentPhase: gameLogic.currentPhase,
            isPaused: gameLogic.isPaused,
            player1Role: gameLogic.player1Role,
            player2Role: gameLogic.player2Role,
            gameObjective: gameLogic.gameObjective,
          ),

          // Game Field - Main Playing Area
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GameField(
                  players: gameLogic.players,
                  fieldSize: gameLogic.fieldSize,
                  onPlayerTouch: gameLogic.onPlayerTouch,
                ),
              ),
            ),
          ),

          // Control Area - Dual Joysticks
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Player 1 Joystick (Left)
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Player 1',
                          style: TextStyle(
                            color: GameColors.teamAColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: JoystickWidget(
                            onMove: _onPlayer1Move,
                            color: GameColors.teamAColor,
                            isEnabled: !gameLogic.isPaused,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center Divider
                  Container(
                    width: 2,
                    height: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: GameColors.textSecondary,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),

                  // Player 2 Joystick (Right)
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Player 2',
                          style: TextStyle(
                            color: GameColors.teamBColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: JoystickWidget(
                            onMove: _onPlayer2Move,
                            color: GameColors.teamBColor,
                            isEnabled: !gameLogic.isPaused,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Game Status Info
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              gameLogic.gameStatusText,
              style: TextStyle(
                fontSize: 12,
                color: GameColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}