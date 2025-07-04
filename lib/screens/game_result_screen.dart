
// File: lib/screens/game_result_screen.dart
import 'package:flutter/material.dart';
import '../utils/game_constants.dart';
import '../services/local_storage_service.dart';
import '../services/audio_service.dart';
import '../services/statistics_service.dart';
import '../services/achievement_service.dart';

class GameResultScreen extends StatefulWidget {
  final bool playerWon;
  final int playerScore;
  final int aiScore;
  final Duration gameDuration;
  final Map<String, dynamic> gameStats;

  const GameResultScreen({
    super.key,
    required this.playerWon,
    required this.playerScore,
    required this.aiScore,
    required this.gameDuration,
    required this.gameStats,
  });

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  final _storage = LocalStorageService.instance;
  final _audio = AudioService.instance;
  final _statistics = StatisticsService.instance;
  final _achievements = AchievementService.instance;
  
  List<Map<String, dynamic>> _newAchievements = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _recordGameResult();
    _playResultSound();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  void _recordGameResult() {
    _statistics.recordGameResult(
      won: widget.playerWon,
      finalScore: widget.playerScore,
      gameDuration: widget.gameDuration,
      touchCount: widget.gameStats['touchCount'] ?? 0,
      fastestCrossing: widget.gameStats['fastestCrossing'],
    );

    // Check for new achievements
    _checkNewAchievements();
  }

  void _checkNewAchievements() {
    final beforeAchievements = _achievements.getUnlockedAchievements().length;
    
    _achievements.checkAchievements({
      'won': widget.playerWon,
      'touchCount': widget.gameStats['touchCount'] ?? 0,
      'fastestCrossing': widget.gameStats['fastestCrossing'],
    });
    
    final afterAchievements = _achievements.getUnlockedAchievements().length;
    
    if (afterAchievements > beforeAchievements) {
      final allAchievements = _achievements.getUnlockedAchievements();
      _newAchievements = allAchievements.skip(beforeAchievements).toList();
    }
  }

  void _playResultSound() {
    if (widget.playerWon) {
      _audio.playGameEndSound();
    } else {
      _audio.playErrorSound();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.playerWon ? GameColors.successColor : GameColors.errorColor,
              GameColors.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Header with result
                    Expanded(
                      flex: 2,
                      child: _buildResultHeader(),
                    ),
                    
                    // Game statistics
                    Expanded(
                      flex: 3,
                      child: _buildStatistics(),
                    ),
                    
                    // New achievements
                    if (_newAchievements.isNotEmpty)
                      Expanded(
                        flex: 1,
                        child: _buildNewAchievements(),
                      ),
                    
                    // Action buttons
                    Expanded(
                      flex: 1,
                      child: _buildActionButtons(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: widget.playerWon ? GameColors.successColor : GameColors.errorColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (widget.playerWon ? GameColors.successColor : GameColors.errorColor)
                        .withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                widget.playerWon ? Icons.emoji_events : Icons.close,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            widget.playerWon ? 'Selamat!' : 'Permainan Selesai',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: widget.playerWon ? GameColors.successColor : GameColors.errorColor,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            widget.playerWon ? 'Anda Menang!' : 'Coba Lagi!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Score display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${widget.playerScore} - ${widget.aiScore}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: GameColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Statistik Permainan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: GameColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 20),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildStatRow('Durasi Permainan', _formatDuration(widget.gameDuration)),
                      _buildStatRow('Skor Anda', '${widget.playerScore}'),
                      _buildStatRow('Skor Lawan', '${widget.aiScore}'),
                      _buildStatRow('Total Sentuhan', '${widget.gameStats['touchCount'] ?? 0}'),
                      if (widget.gameStats['fastestCrossing'] != null)
                        _buildStatRow('Crossing Tercepat', '${widget.gameStats['fastestCrossing']!.toStringAsFixed(1)}s'),
                      _buildStatRow('Efisiensi', '${_calculateEfficiency().toStringAsFixed(1)}%'),
                      
                      const SizedBox(height: 16),
                      
                      _buildProgressStats(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: GameColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStats() {
    final totalGames = _storage.gamesPlayed;
    final winRate = totalGames > 0 ? (_storage.gamesWon / totalGames) : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Win Rate Keseluruhan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(winRate * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: GameColors.primaryGreen,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          LinearProgressIndicator(
            value: winRate,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(GameColors.primaryGreen),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Total: ${_storage.gamesWon} menang dari $totalGames permainan',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewAchievements() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        color: Colors.amber[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Achievement Baru!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Expanded(
                child: ListView.builder(
                  itemCount: _newAchievements.length,
                  itemBuilder: (context, index) {
                    final achievement = _newAchievements[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            achievement['icon'] ?? '🏆',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  achievement['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${achievement['points']} poin',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _playAgain,
              icon: const Icon(Icons.refresh),
              label: const Text('Main Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: GameColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _goToMenu,
              icon: const Icon(Icons.home),
              label: const Text('Menu Utama'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  double _calculateEfficiency() {
    final touchCount = widget.gameStats['touchCount'] ?? 0;
    if (touchCount == 0) return 100.0;
    
    final crossingAttempts = widget.playerScore + touchCount;
    return crossingAttempts > 0 ? (widget.playerScore / crossingAttempts) * 100 : 0.0;
  }

  void _playAgain() {
    _audio.playButtonClick();
    Navigator.pop(context, 'play_again');
  }

  void _goToMenu() {
    _audio.playButtonClick();
    Navigator.pop(context, 'menu');
  }
}