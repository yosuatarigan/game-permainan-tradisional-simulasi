// File: lib/screens/multiplayer_game_screen.dart (2-Player Real Game)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_permainan_tradisional_simulasi/multiplayer/multiplayer_hadang_game.dart';
import '../utils/game_constants.dart';

class MultiplayerGameScreen extends StatefulWidget {
  const MultiplayerGameScreen({super.key});

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> with TickerProviderStateMixin {
  late MultiplayerHadangGame game;
  late AnimationController _scoreAnimationController;
  
  Map<String, dynamic> gameStats = {};
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _initializeAnimations();
    _startStatsUpdater();
  }

  void _initializeGame() {
    try {
      game = MultiplayerHadangGame();
      print('MultiplayerGameScreen: Game ready for 2 players');
    } catch (e) {
      print('Error creating multiplayer game: $e');
    }
  }

  void _initializeAnimations() {
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  void _startStatsUpdater() {
    // Update stats every 500ms untuk responsive UI
    Stream.periodic(const Duration(milliseconds: 500)).listen((_) {
      if (mounted) {
        setState(() {
          gameStats = game.getGameStats();
        });
      }
    });
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.backgroundColor,
      appBar: _buildAppBar(),
      body: _buildGameBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sports,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'HADANG',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const Text(
                '2 Players',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: GameColors.primaryGreen,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      actions: [
        IconButton(
          icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
          onPressed: _togglePause,
          color: Colors.white,
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
            GameColors.backgroundColor,
            GameColors.fieldBackground,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildScoreBoard(),
            _buildGameCanvas(),
            _buildControlPanel(),
            _buildGameInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main score display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPlayerScore(
                'PLAYER 1',
                'TIM MERAH',
                game.scoreTeamRed,
                GameColors.teamAColor,
                gameStats['guardingTeam'] == 'Red' ? 'PENJAGA' : 'PENYERANG',
              ),
              Container(
                width: 2,
                height: 60,
                color: Colors.grey.shade300,
              ),
              _buildPlayerScore(
                'PLAYER 2', 
                'TIM BIRU',
                game.scoreTeamBlue,
                GameColors.teamBColor,
                gameStats['guardingTeam'] == 'Blue' ? 'PENJAGA' : 'PENYERANG',
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Round info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: GameColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'ROUND ${game.currentRound}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: GameColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerScore(String player, String team, int score, Color color, String role) {
    return AnimatedBuilder(
      animation: _scoreAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_scoreAnimationController.value * 0.05),
          child: Column(
            children: [
              Text(
                player,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              Text(
                team,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                role,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: role == 'PENYERANG' ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameCanvas() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              _buildGameWidget(),
              _buildGameOverlay(),
            ],
          ),
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
          }
        } catch (e) {
          print('Error handling player tap: $e');
        }
      },
      child: game.widget,
    );
  }

  Widget _buildGameOverlay() {
    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Current turn indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: gameStats['attackingTeam'] == 'Red' 
                  ? GameColors.teamAColor.withOpacity(0.9)
                  : GameColors.teamBColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${gameStats['attackingTeam'] ?? 'BIRU'} MENYERANG',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Pause indicator
          if (isPaused)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'PAUSED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            'RESTART',
            Icons.refresh,
            GameColors.warningColor,
            _restartGame,
          ),
          _buildControlButton(
            isPaused ? 'RESUME' : 'PAUSE',
            isPaused ? Icons.play_arrow : Icons.pause,
            GameColors.infoColor,
            _togglePause,
          ),
          _buildControlButton(
            'SWITCH',
            Icons.swap_horiz,
            GameColors.successColor,
            _switchTeams,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 48,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildGameInstructions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GameColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: GameColors.primaryGreen.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: GameColors.primaryGreen,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'CARA BERMAIN:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '1. TAP pemain penyerang untuk pilih  •  2. TAP area untuk pindah  •  3. Hindari penjaga  •  4. Capai garis finish untuk SKOR!',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Game control methods
  void _restartGame() {
    if (GameSettings.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
    
    try {
      game.restartGame();
      isPaused = false;
      setState(() {});
      
      _showGameMessage('🏁 Game dimulai ulang!');
    } catch (e) {
      print('Error restarting game: $e');
    }
  }

  void _togglePause() {
    if (GameSettings.hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    
    try {
      game.pauseGame();
      isPaused = !isPaused;
      setState(() {});
      
      _showGameMessage(isPaused ? '⏸️ Game dipause' : '▶️ Game dilanjutkan');
    } catch (e) {
      print('Error toggling pause: $e');
    }
  }

  void _switchTeams() {
    if (GameSettings.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
    
    try {
      game.switchTeams();
      
      _scoreAnimationController.forward().then((_) {
        _scoreAnimationController.reset();
      });
      
      _showGameMessage('🔄 Tim berganti peran!');
    } catch (e) {
      print('Error switching teams: $e');
    }
  }

  void _showGameMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: GameColors.primaryGreen,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _onScoreUpdate() {
    _scoreAnimationController.forward().then((_) {
      _scoreAnimationController.reset();
    });
    
    final winner = game.scoreTeamRed > game.scoreTeamBlue ? 'MERAH' : 'BIRU';
    _showGameMessage('🎯 GOAL! Tim $winner mencetak poin!');
  }
}