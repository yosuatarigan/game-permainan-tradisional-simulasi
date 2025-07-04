// File: lib/game/models/game_state.dart
import 'package:flutter/foundation.dart';

enum GamePhase {
  setup,
  firstHalf,
  halfTime,
  secondHalf,
  finished
}

enum PlayerTeam {
  teamA,
  teamB
}

enum PlayerRole {
  guard,
  attacker
}

class HadangGameState extends ChangeNotifier {
  // Game timing (sesuai aturan resmi: 2x15 menit)
  static const Duration halfDuration = Duration(minutes: 15);
  static const Duration halfTimeDuration = Duration(minutes: 5);
  static const Duration noMovementTimeout = Duration(minutes: 2);
  
  // Game state
  GamePhase _currentPhase = GamePhase.setup;
  Duration _gameTime = Duration.zero;
  Duration _phaseTime = Duration.zero;
  bool _isPaused = false;
  
  // Scores
  int _scoreTeamA = 0;
  int _scoreTeamB = 0;
  
  // Team roles
  PlayerTeam _attackingTeam = PlayerTeam.teamB; // Team B starts attacking
  PlayerTeam _guardingTeam = PlayerTeam.teamA;  // Team A starts guarding
  
  // Game rules tracking
  Duration _noMovementTimer = Duration.zero;
  bool _hasMovementInCurrentPhase = false;
  
  // Substitution tracking (max 3 per team per game)
  int _teamASubstitutions = 0;
  int _teamBSubstitutions = 0;
  static const int maxSubstitutions = 3;

  // Getters
  GamePhase get currentPhase => _currentPhase;
  Duration get gameTime => _gameTime;
  Duration get phaseTime => _phaseTime;
  bool get isPaused => _isPaused;
  int get scoreTeamA => _scoreTeamA;
  int get scoreTeamB => _scoreTeamB;
  PlayerTeam get attackingTeam => _attackingTeam;
  PlayerTeam get guardingTeam => _guardingTeam;
  Duration get noMovementTimer => _noMovementTimer;
  
  // Game control methods
  void startGame() {
    _currentPhase = GamePhase.firstHalf;
    _gameTime = Duration.zero;
    _phaseTime = Duration.zero;
    _isPaused = false;
    notifyListeners();
  }
  
  void updateTime(double deltaTime) {
    if (_isPaused || !isGameActive()) return;
    
    final dt = Duration(milliseconds: (deltaTime * 1000).round());
    
    _gameTime += dt;
    _phaseTime += dt;
    
    // Update no-movement timer if no movement detected
    if (!_hasMovementInCurrentPhase) {
      _noMovementTimer += dt;
      
      // Check 2-minute rule
      if (_noMovementTimer >= noMovementTimeout) {
        _handleNoMovementTimeout();
      }
    }
    
    notifyListeners();
  }
  
  void resetMovementTimer() {
    _hasMovementInCurrentPhase = true;
    _noMovementTimer = Duration.zero;
  }
  
  void _handleNoMovementTimeout() {
    // Force team switch due to 2-minute rule
    switchAttackingTeam();
    _noMovementTimer = Duration.zero;
    _hasMovementInCurrentPhase = false;
  }
  
  bool shouldSwitchHalf() {
    return (_currentPhase == GamePhase.firstHalf && _phaseTime >= halfDuration) ||
           (_currentPhase == GamePhase.halfTime && _phaseTime >= halfTimeDuration);
  }
  
  void switchHalf() {
    switch (_currentPhase) {
      case GamePhase.firstHalf:
        _currentPhase = GamePhase.halfTime;
        _phaseTime = Duration.zero;
        break;
      case GamePhase.halfTime:
        _currentPhase = GamePhase.secondHalf;
        _phaseTime = Duration.zero;
        // Teams switch sides for second half
        _switchTeamSides();
        break;
      default:
        break;
    }
    notifyListeners();
  }
  
  void _switchTeamSides() {
    // Swap attacking and guarding teams for second half
    final temp = _attackingTeam;
    _attackingTeam = _guardingTeam;
    _guardingTeam = temp;
  }
  
  bool shouldEndGame() {
    return _currentPhase == GamePhase.secondHalf && _phaseTime >= halfDuration;
  }
  
  void endGame() {
    _currentPhase = GamePhase.finished;
    _isPaused = true;
    notifyListeners();
  }
  
  bool isGameActive() {
    return _currentPhase == GamePhase.firstHalf || _currentPhase == GamePhase.secondHalf;
  }
  
  // Scoring methods
  void addScore(PlayerTeam team, [int points = 1]) {
    if (team == PlayerTeam.teamA) {
      _scoreTeamA += points;
    } else {
      _scoreTeamB += points;
    }
    notifyListeners();
  }
  
  int getScore(PlayerTeam team) {
    return team == PlayerTeam.teamA ? _scoreTeamA : _scoreTeamB;
  }
  
  // Team switching (when attacker is touched)
  void switchAttackingTeam() {
    final temp = _attackingTeam;
    _attackingTeam = _guardingTeam;
    _guardingTeam = temp;
    
    // Reset movement tracking
    _hasMovementInCurrentPhase = false;
    _noMovementTimer = Duration.zero;
    
    notifyListeners();
  }
  
  // Pause/Resume
  void togglePause() {
    _isPaused = !_isPaused;
    notifyListeners();
  }
  
  void pause() {
    _isPaused = true;
    notifyListeners();
  }
  
  void resume() {
    _isPaused = false;
    notifyListeners();
  }
  
  // Reset game
  void resetGame() {
    _currentPhase = GamePhase.setup;
    _gameTime = Duration.zero;
    _phaseTime = Duration.zero;
    _isPaused = false;
    _scoreTeamA = 0;
    _scoreTeamB = 0;
    _attackingTeam = PlayerTeam.teamB;
    _guardingTeam = PlayerTeam.teamA;
    _noMovementTimer = Duration.zero;
    _hasMovementInCurrentPhase = false;
    _teamASubstitutions = 0;
    _teamBSubstitutions = 0;
    notifyListeners();
  }
  
  // Substitution methods
  bool canSubstitute(PlayerTeam team) {
    final substitutions = team == PlayerTeam.teamA ? _teamASubstitutions : _teamBSubstitutions;
    return substitutions < maxSubstitutions && (_isPaused || _currentPhase == GamePhase.halfTime);
  }
  
  void makeSubstitution(PlayerTeam team) {
    if (!canSubstitute(team)) return;
    
    if (team == PlayerTeam.teamA) {
      _teamASubstitutions++;
    } else {
      _teamBSubstitutions++;
    }
    notifyListeners();
  }
  
  // Game result methods
  PlayerTeam? getWinner() {
    if (_currentPhase != GamePhase.finished) return null;
    
    if (_scoreTeamA > _scoreTeamB) {
      return PlayerTeam.teamA;
    } else if (_scoreTeamB > _scoreTeamA) {
      return PlayerTeam.teamB;
    }
    return null; // Draw
  }
  
  bool isDraw() {
    return _currentPhase == GamePhase.finished && _scoreTeamA == _scoreTeamB;
  }
  
  // Statistics
  double getGameProgressPercentage() {
    if (!isGameActive()) return 0.0;
    
    final totalGameTime = halfDuration * 2;
    return (_gameTime.inMilliseconds / totalGameTime.inMilliseconds).clamp(0.0, 1.0);
  }
  
  String getFormattedGameTime() {
    final minutes = _gameTime.inMinutes;
    final seconds = _gameTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  String getFormattedPhaseTime() {
    final minutes = _phaseTime.inMinutes;
    final seconds = _phaseTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  String getCurrentPhaseDisplay() {
    switch (_currentPhase) {
      case GamePhase.setup:
        return 'Persiapan';
      case GamePhase.firstHalf:
        return 'Babak 1';
      case GamePhase.halfTime:
        return 'Istirahat';
      case GamePhase.secondHalf:
        return 'Babak 2';
      case GamePhase.finished:
        return 'Selesai';
    }
  }
  
  // Rule validation helpers
  bool isValidMove(PlayerTeam team, PlayerRole role) {
    // Attackers can only move if it's their team's turn to attack
    if (role == PlayerRole.attacker) {
      return team == _attackingTeam;
    }
    
    // Guards can always move within their designated areas
    return team == _guardingTeam;
  }
  
  Map<String, dynamic> getGameSummary() {
    return {
      'phase': getCurrentPhaseDisplay(),
      'gameTime': getFormattedGameTime(),
      'phaseTime': getFormattedPhaseTime(),
      'scoreTeamA': _scoreTeamA,
      'scoreTeamB': _scoreTeamB,
      'attackingTeam': _attackingTeam.name,
      'isPaused': _isPaused,
      'winner': getWinner()?.name,
      'isDraw': isDraw(),
      'progress': getGameProgressPercentage(),
    };
  }
}