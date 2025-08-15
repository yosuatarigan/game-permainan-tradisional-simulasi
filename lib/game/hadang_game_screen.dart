// File: lib/game/hadang_game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_permainan_tradisional_simulasi/game/widgets/game_hud.dart';
import '../utils/game_constants.dart';
import 'widgets/game_field.dart';
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
  bool _showObjective = true;

  @override
  void initState() {
    super.initState();
    gameLogic = HadangGameLogic();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _startGame();

    // Auto-hide objective after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showObjective = false;
        });
      }
    });
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

    // Set score callback to show dialog
    gameLogic.onScoreCallback = _showScoreDialog;
  }

  void _showScoreDialog(String team, int newScore) {
    HapticFeedback.heavyImpact();

    final teamColor =
        team == 'red' ? GameColors.teamAColor : GameColors.teamBColor;
    final teamName = team == 'red' ? 'TIM MERAH' : 'TIM BIRU';
    final emoji = team == 'red' ? '🔴' : '🔵';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 600),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          teamColor.withOpacity(0.95),
                          teamColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: teamColor.withOpacity(0.6),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated trophy with team emoji
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.emoji_events,
                                color: teamColor,
                                size: 50,
                              ),
                              Positioned(
                                bottom: 15,
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Celebration text
                        Text(
                          '🎉 GOAL! 🎉',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 4,
                                color: Colors.black45,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          teamName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Score: $newScore',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Continue button
                        // ElevatedButton.icon(
                        //   onPressed: () {
                        //     if (mounted && Navigator.canPop(context)) {
                        //       Navigator.of(context).pop();
                        //     }
                        //   },
                        //   icon: const Icon(Icons.play_arrow),
                        //   label: const Text('Lanjutkan'),
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: Colors.white,
                        //     foregroundColor: teamColor,
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 24,
                        //       vertical: 12,
                        //     ),
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(25),
                        //     ),
                        //     elevation: 8,
                        //   ),
                        // ),

                        const SizedBox(height: 8),

                        Text(
                          'Auto close in 2 seconds',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
    );

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
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
      builder:
          (context) => AlertDialog(
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

  void _exitGame() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Keluar Permainan'),
            content: const Text(
              'Apakah Anda yakin ingin keluar? Progress akan hilang.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: GameColors.errorColor,
                ),
                child: const Text('Keluar'),
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
          IconButton(onPressed: _resetGame, icon: const Icon(Icons.refresh)),
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
            flex: 4,
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
                            fontSize: 12, // Smaller text
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: JoystickWidget(
                            onMove: _onPlayer1Move,
                            color: GameColors.teamAColor,
                            isEnabled: !gameLogic.isPaused,
                            size: 90, // Slightly smaller joystick
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center Divider
                  Container(
                    width: 2,
                    height: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
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
                            fontSize: 12, // Smaller text
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: JoystickWidget(
                            onMove: _onPlayer2Move,
                            color: GameColors.teamBColor,
                            isEnabled: !gameLogic.isPaused,
                            size: 90, // Slightly smaller joystick
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Game Status Info (Compact)
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //   child: Text(
            //     gameLogic.gameStatusText,
            //     style: TextStyle(
            //       fontSize: 11,
            //       color: GameColors.textSecondary,
            //       fontStyle: FontStyle.italic,
            //     ),
            //     textAlign: TextAlign.center,
            //   ),
          ),
        ],
      ),
    );
  }
}
