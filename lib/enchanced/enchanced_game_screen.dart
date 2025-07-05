// File: lib/screens/enhanced_game_screen.dart (Official Hadang Rules)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_permainan_tradisional_simulasi/enchanced/enchandec_hadang_game.dart';
import '../game/enhanced_hadang_game.dart';
import '../utils/game_constants.dart';

class EnhancedGameScreen extends StatefulWidget {
  const EnhancedGameScreen({super.key});

  @override
  State<EnhancedGameScreen> createState() => _EnhancedGameScreenState();
}

class _EnhancedGameScreenState extends State<EnhancedGameScreen> with TickerProviderStateMixin {
  late EnhancedHadangGame game;
  late AnimationController _scoreAnimationController;
  late AnimationController _teamSwitchAnimationController;
  
  bool isPaused = false;
  Map<String, dynamic> gameStats = {};

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _initializeAnimations();
    _startStatsUpdater();
  }

  void _initializeGame() {
    try {
      game = EnhancedHadangGame();
      print('EnhancedGameScreen: Game initialized successfully');
    } catch (e) {
      print('EnhancedGameScreen: Error creating game: $e');
    }
  }

  void _initializeAnimations() {
    _scoreAnimationController = AnimationController(
      duration: GameConstants.scoreEffectDuration,
      vsync: this,
    );
    
    _teamSwitchAnimationController = AnimationController(
      duration: GameConstants.switchEffectDuration,
      vsync: this,
    );
  }

  void _startStatsUpdater() {
    // Update game stats every second
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) {
        setState(() {
          gameStats = game.getGameStatistics();
        });
      }
    });
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    _teamSwitchAnimationController.dispose();
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
      title: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sports_soccer,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'HADANG',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const Text(
            'Permainan Tradisional Indonesia',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
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
          icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
          onPressed: _togglePause,
          color: Colors.white,
          tooltip: isPaused ? GameTexts.resumeButton : GameTexts.pauseButton,
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
            _buildGameInfoPanel(),
            _buildGameCanvas(),
            _buildControlPanel(),
            _buildStatsPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameInfoPanel() {
    return Container(
      margin: const EdgeInsets.all(GameConstants.uiElementSpacing),
      padding: const EdgeInsets.all(GameConstants.uiElementSpacing),
      decoration: BoxDecoration(
        color: GameColors.cardBackground,
        borderRadius: BorderRadius.circular(GameConstants.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Score and Time Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildScoreCard(
                GameTexts.teamRed, 
                game.scoreTeamA, 
                GameColors.teamAColor
              ),
              _buildTimeCard(),
              _buildScoreCard(
                GameTexts.teamBlue, 
                game.scoreTeamB, 
                GameColors.teamBColor
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Team Roles Row
          _buildTeamRolesDisplay(),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String teamName, int score, Color color) {
    return Column(
      children: [
        Text(
          teamName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedBuilder(
          animation: _scoreAnimationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_scoreAnimationController.value * 0.1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeCard() {
    return Column(
      children: [
        Text(
          GameTexts.timeLabel,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: GameColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isPaused 
                ? GameColors.warningColor.withOpacity(0.1)
                : GameColors.textSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPaused 
                  ? GameColors.warningColor.withOpacity(0.3)
                  : GameColors.textSecondary.withOpacity(0.3)
            ),
          ),
          child: Text(
            game.gameTime.toGameTime(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isPaused ? GameColors.warningColor : GameColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamRolesDisplay() {
    return AnimatedBuilder(
      animation: _teamSwitchAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_teamSwitchAnimationController.value * 0.05),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: GameColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GameColors.primaryGreen.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shield,
                      color: GameColors.teamAColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Penjaga: ${gameStats['guardingTeam'] ?? 'Tim Merah'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: Colors.grey.shade300,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.run_circle,
                      color: GameColors.teamBColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Penyerang: ${gameStats['attackingTeam'] ?? 'Tim Biru'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
        margin: const EdgeInsets.symmetric(horizontal: GameConstants.uiElementSpacing),
        decoration: BoxDecoration(
          color: GameColors.cardBackground,
          borderRadius: BorderRadius.circular(GameConstants.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(GameConstants.cardRadius),
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
          game.moveClosestAttacker(details.localPosition);
        } catch (e) {
          print('Error handling tap: $e');
        }
      },
      child: game.widget,
    );
  }

  Widget _buildGameOverlay() {
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          game.currentPhase,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      margin: const EdgeInsets.all(GameConstants.uiElementSpacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            GameTexts.restartButton,
            Icons.refresh,
            GameColors.warningColor,
            _restartGame,
          ),
          _buildControlButton(
            isPaused ? GameTexts.resumeButton : GameTexts.pauseButton,
            isPaused ? Icons.play_arrow : Icons.pause,
            GameColors.infoColor,
            _togglePause,
          ),
          _buildControlButton(
            GameTexts.switchButton,
            Icons.swap_horiz,
            GameColors.secondaryGreen,
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
        height: GameConstants.buttonHeight,
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
              borderRadius: BorderRadius.circular(GameConstants.cardRadius),
            ),
            elevation: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: GameConstants.uiElementSpacing),
      // margin: const EdgeInsets.only(bottom: GameConstants.uiElementSpacing),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GameColors.cardBackground,
        borderRadius: BorderRadius.circular(GameConstants.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4.0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Sentuhan',
            '${gameStats['totalTouches'] ?? 0}',
            Icons.touch_app,
            GameColors.warningColor,
          ),
          _buildStatItem(
            'Pergantian',
            '${gameStats['teamSwitches'] ?? 0}',
            Icons.swap_horiz,
            GameColors.infoColor,
          ),
          _buildStatItem(
            'Progress',
            '${gameStats['attackerProgress'] ?? 0}/5',
            Icons.flag,
            GameColors.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // Game Control Methods
  void _restartGame() {
    if (GameSettings.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
    
    try {
      game.restartGame();
      isPaused = false;
      setState(() {});
      
      _showGameMessage(GameTexts.gameStarted);
    } catch (e) {
      print('Error restarting game: $e');
    }
  }

  void _togglePause() {
    if (GameSettings.hapticEnabled) {
      HapticFeedback.lightImpact();
    }
    
    try {
      game.pauseResumeGame();
      isPaused = !isPaused;
      setState(() {});
      
      _showGameMessage(isPaused ? 'Game Paused' : 'Game Resumed');
    } catch (e) {
      print('Error toggling pause: $e');
      isPaused = !isPaused;
      setState(() {});
    }
  }

  void _switchTeams() {
    if (GameSettings.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
    
    try {
      game.switchTeams();
      
      _teamSwitchAnimationController.forward().then((_) {
        _teamSwitchAnimationController.reset();
      });
      
      _showGameMessage(GameTexts.teamSwitched);
    } catch (e) {
      print('Error switching teams: $e');
    }
  }

  void _showGameMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: GameColors.primaryGreen,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameConstants.cardRadius),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Game event handlers
  void _onScoreAwarded(String teamName, int newScore) {
    _scoreAnimationController.forward().then((_) {
      _scoreAnimationController.reset();
    });
    
    _showGameMessage('🎯 ${GameTexts.scoreAwarded} $teamName: $newScore');
  }

  void _onTeamSwitched(String guardingTeam, String attackingTeam) {
    _teamSwitchAnimationController.forward().then((_) {
      _teamSwitchAnimationController.reset();
    });
    
    _showGameMessage('🔄 Tim berganti! Penjaga: $guardingTeam');
  }

  void _onGamePhaseChanged(String newPhase) {
    String message;
    String emoji;
    
    switch (newPhase) {
      case 'firstHalf':
        message = GameTexts.gameStarted;
        emoji = '🏁';
        break;
      case 'halfTime':
        message = GameTexts.halfTimeReached;
        emoji = '⏸️';
        break;
      case 'secondHalf':
        message = GameTexts.secondHalfStarted;
        emoji = '▶️';
        break;
      case 'finished':
        message = GameTexts.gameEnded;
        emoji = '🏆';
        break;
      default:
        message = 'Phase: $newPhase';
        emoji = 'ℹ️';
    }
    
    _showGameMessage('$emoji $message');
  }
}