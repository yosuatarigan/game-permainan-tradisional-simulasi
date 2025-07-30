// File: lib/screens/improved_multiplayer_game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_permainan_tradisional_simulasi/multiplayer/multiplayer_hadang_game.dart';

import '../utils/game_constants.dart';

class ImprovedMultiplayerGameScreen extends StatefulWidget {
  const ImprovedMultiplayerGameScreen({super.key});

  @override
  State<ImprovedMultiplayerGameScreen> createState() =>
      _ImprovedMultiplayerGameScreenState();
}

class _ImprovedMultiplayerGameScreenState
    extends State<ImprovedMultiplayerGameScreen>
    with TickerProviderStateMixin {
  late ImprovedMultiplayerHadangGame game;
  late AnimationController _scoreAnimationController;
  late AnimationController _pulseAnimationController;

  Map<String, dynamic> gameStats = {};
  bool isPaused = false;

  // Game timer
  int gameTimeSeconds = 0;
  bool timerRunning = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _initializeAnimations();
    _startStatsUpdater();
    _startGameTimer();
  }

  void _initializeGame() {
    try {
      game = ImprovedMultiplayerHadangGame();
      print('ImprovedMultiplayerGameScreen: Enhanced 2-player game ready');
    } catch (e) {
      print('Error creating improved game: $e');
    }
  }

  void _initializeAnimations() {
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _startStatsUpdater() {
    Stream.periodic(const Duration(milliseconds: 300)).listen((_) {
      if (mounted) {
        setState(() {
          gameStats = game.getGameStats();
        });
      }
    });
  }

  void _startGameTimer() {
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted && timerRunning && !isPaused) {
        setState(() {
          gameTimeSeconds++;
        });
      }
    });
    timerRunning = true;
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildGameAppBar(),
      body: _buildGameBody(),
    );
  }

  PreferredSizeWidget _buildGameAppBar() {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.sports_handball,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 6),
                const Text(
                  'HADANG',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '2 PLAYERS',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: GameColors.primaryGreen,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      actions: [
        IconButton(
          icon: Icon(
            isPaused ? Icons.play_arrow : Icons.pause,
            color: Colors.white,
          ),
          onPressed: _togglePause,
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _showRestartDialog,
        ),
      ],
    );
  }

  Widget _buildGameBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GameColors.primaryGreen,
            GameColors.fieldBackground,
            Colors.black,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildEnhancedScoreBoard(),
            _buildGameCanvas(),
            _buildTwoPlayerControlInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedScoreBoard() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Timer and round info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoChip(
                'ROUND',
                '${game.currentRound}',
                Colors.purple,
                Icons.loop,
              ),
              _buildInfoChip(
                'TIME',
                _formatTime(gameTimeSeconds),
                Colors.orange,
                Icons.timer,
              ),
              _buildInfoChip(
                'STATUS',
                gameStats['isPaused'] == true ? 'PAUSED' : 'PLAYING',
                gameStats['isPaused'] == true ? Colors.red : Colors.green,
                gameStats['isPaused'] == true ? Icons.pause : Icons.play_arrow,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Main score display
          Row(
            children: [
              // Player 1 Score
              Expanded(
                child: _buildEnhancedPlayerScore(
                  'PLAYER 1',
                  'TIM MERAH',
                  game.scoreTeamRed,
                  Colors.red[600]!,
                  'PENYERANG',
                  true, // Always active in active mode
                ),
              ),

              // VS Separator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      'VS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),

              // Player 2 Score
              Expanded(
                child: _buildEnhancedPlayerScore(
                  'PLAYER 2',
                  'TIM BIRU',
                  game.scoreTeamBlue,
                  Colors.blue[600]!,
                  'PENYERANG',
                  true, // Always active in active mode
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPlayerScore(
    String player,
    String team,
    int score,
    Color color,
    String role,
    bool isActive,
  ) {
    return AnimatedBuilder(
      animation: _scoreAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_scoreAnimationController.value * 0.1),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? color.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border:
                  isActive
                      ? Border.all(color: color.withOpacity(0.3), width: 2)
                      : null,
            ),
            child: Column(
              children: [
                Text(
                  player,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  team,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$score',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Colors
                            .green, // Always green for attackers in active mode
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameCanvas() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(children: [_buildGameWidget(), _buildGameOverlays()]),
        ),
      ),
    );
  }

  Widget _buildGameWidget() {
    return GestureDetector(
      onTapDown: (details) {
        try {
          if (!isPaused) {
            game.handlePlayerTap(details.localPosition);
            if (GameSettings.hapticEnabled) {
              HapticFeedback.selectionClick();
            }
          }
        } catch (e) {
          print('Error handling tap: $e');
        }
      },
      child: game.widget,
    );
  }

  Widget _buildGameOverlays() {
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Current turn indicator - Updated for active gameplay
          AnimatedBuilder(
            animation: _pulseAnimationController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(
                    0.8 + _pulseAnimationController.value * 0.2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sports_handball, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'KEDUA TIM AKTIF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Pause indicator
          if (isPaused)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.pause, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  const Text(
                    'PAUSED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTwoPlayerControlInstructions() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.yellow, size: 16),
              const SizedBox(width: 8),
              const Text(
                'KONTROL 2 PEMAIN:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              // Player 1 instructions
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.red, size: 14),
                          const SizedBox(width: 4),
                          const Text(
                            'PLAYER 1 (KIRI)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'TAP sisi KIRI layar untuk kontrol tim MERAH',
                        style: TextStyle(fontSize: 9, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // VS separator
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Player 2 instructions
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.blue, size: 14),
                          const SizedBox(width: 4),
                          const Text(
                            'PLAYER 2 (KANAN)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'TAP sisi KANAN layar untuk kontrol tim BIRU',
                        style: TextStyle(fontSize: 9, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Game instructions - Updated for active gameplay
          Text(
            '🎯 ACTIVE MODE: Kedua tim bermain bersamaan • Red ke bawah, Blue ke atas • Hindari collision = reset!',
            style: TextStyle(fontSize: 10, color: Colors.white60, height: 1.2),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _togglePause() {
    if (GameSettings.hapticEnabled) {
      HapticFeedback.lightImpact();
    }

    try {
      game.pauseGame();
      isPaused = !isPaused;
      timerRunning = !isPaused;
      setState(() {});

      _showGameMessage(isPaused ? '⏸️ Game dipause' : '▶️ Game dilanjutkan');
    } catch (e) {
      print('Error toggling pause: $e');
    }
  }

  void _showRestartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restart Game?'),
          content: const Text(
            'Apakah Anda yakin ingin memulai ulang permainan?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restartGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GameColors.primaryGreen,
              ),
              child: const Text('Restart'),
            ),
          ],
        );
      },
    );
  }

  void _restartGame() {
    if (GameSettings.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }

    try {
      game.restartGame();
      isPaused = false;
      gameTimeSeconds = 0;
      timerRunning = true;
      setState(() {});

      _showGameMessage('🏁 Game dimulai ulang!');
    } catch (e) {
      print('Error restarting game: $e');
    }
  }

  void _showGameMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.sports_handball, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: GameColors.primaryGreen,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
