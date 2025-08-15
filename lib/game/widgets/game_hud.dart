// File: lib/game/widgets/game_hud.dart
import 'package:flutter/material.dart';
import '../../utils/game_constants.dart';

class GameHUD extends StatelessWidget {
  final int scoreRed;
  final int scoreBlue;
  final Duration timeRemaining;
  final String currentPhase;
  final bool isPaused;

  const GameHUD({
    super.key,
    required this.scoreRed,
    required this.scoreBlue,
    required this.timeRemaining,
    required this.currentPhase,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          // Red Team Score
          Expanded(
            child: _buildTeamScore(
              'TIM MERAH',
              scoreRed,
              GameColors.teamAColor,
              Icons.person,
            ),
          ),

          // Center Info (Timer & Phase)
          Expanded(
            flex: 2,
            child: _buildCenterInfo(),
          ),

          // Blue Team Score
          Expanded(
            child: _buildTeamScore(
              'TIM BIRU',
              scoreBlue,
              GameColors.teamBColor,
              Icons.person,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScore(String teamName, int score, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              teamName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            '$score',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCenterInfo() {
    return Column(
      children: [
        // Game Phase
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _getPhaseColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getPhaseColor().withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getPhaseIcon(),
                color: _getPhaseColor(),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                currentPhase,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getPhaseColor(),
                ),
              ),
              if (isPaused) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.pause_circle_filled,
                  color: GameColors.warningColor,
                  size: 14,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Timer Display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: GameColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GameColors.primaryGreen.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer,
                color: GameColors.primaryGreen,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(timeRemaining),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: GameColors.primaryGreen,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // Time Progress Bar
        Container(
          width: 120,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _getTimeProgress(),
            child: Container(
              decoration: BoxDecoration(
                color: _getTimeProgressColor(),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getPhaseColor() {
    switch (currentPhase) {
      case 'Babak 1':
        return GameColors.successColor;
      case 'Istirahat':
        return GameColors.warningColor;
      case 'Babak 2':
        return GameColors.infoColor;
      case 'Selesai':
        return GameColors.errorColor;
      default:
        return GameColors.primaryGreen;
    }
  }

  IconData _getPhaseIcon() {
    switch (currentPhase) {
      case 'Babak 1':
        return Icons.play_arrow;
      case 'Istirahat':
        return Icons.coffee;
      case 'Babak 2':
        return Icons.sports_soccer;
      case 'Selesai':
        return Icons.flag;
      default:
        return Icons.sports;
    }
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double _getTimeProgress() {
    const totalTime = Duration(minutes: 15);
    final elapsed = totalTime - timeRemaining;
    return elapsed.inMilliseconds / totalTime.inMilliseconds;
  }

  Color _getTimeProgressColor() {
    final progress = _getTimeProgress();
    if (progress > 0.8) {
      return GameColors.errorColor;
    } else if (progress > 0.6) {
      return GameColors.warningColor;
    } else {
      return GameColors.successColor;
    }
  }
}