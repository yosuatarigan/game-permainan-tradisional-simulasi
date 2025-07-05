// File: lib/models/game_state.dart
import 'package:flutter/foundation.dart';
import '../utils/game_constants.dart';

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
  // Game state menggunakan konstanta resmi
  GamePhase _currentPhase = GamePhase.setup;
  Duration _gameTime = Duration.zero;
  Duration _phaseTime = Duration.zero;
  bool _isPaused = false;
  
  // Scores
  int _scoreTeamA = 0;
  int _scoreTeamB = 0;
  
  // Team roles (sesuai aturan resmi)
  PlayerTeam _attackingTeam = PlayerTeam.teamB; // Team B starts attacking
  PlayerTeam _guardingTeam = PlayerTeam.teamA;  // Team A starts guarding
  
  // Game rules tracking (aturan 2 menit)
  Duration _noMovementTimer = Duration.zero;
  bool _hasMovementInCurrentPhase = false;
  
  // Substitution tracking (max 3 per team per game)
  int _teamASubstitutions = 0;
  int _teamBSubstitutions = 0;
  
  // Game statistics
  int _teamAScores = 0;
  int _teamBScores = 0;
  int _totalTouches = 0;
  DateTime? _gameStartTime;

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
  int get teamASubstitutions => _teamASubstitutions;
  int get teamBSubstitutions => _teamBSubstitutions;
  
  // Game control methods
  void startGame() {
    _currentPhase = GamePhase.firstHalf;
    _gameTime = Duration.zero;
    _phaseTime = Duration.zero;
    _isPaused = false;
    _gameStartTime = DateTime.now();
    notifyListeners();
  }
  
  void updateTime(double deltaTime) {
    if (_isPaused || !isGameActive()) return;
    
    final dt = Duration(milliseconds: (deltaTime * 1000).round());
    
    _gameTime += dt;
    _phaseTime += dt;
    
    // Update no-movement timer jika tidak ada gerakan
    if (!_hasMovementInCurrentPhase) {
      _noMovementTimer += dt;
      
      // Check aturan 2 menit
      if (_noMovementTimer >= GameConstants.noMovementTimeout) {
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
    // Force team switch karena aturan 2 menit
    switchAttackingTeam();
    _noMovementTimer = Duration.zero;
    _hasMovementInCurrentPhase = false;
    print('2-minute rule activated: Teams switched due to no movement');
  }
  
  bool shouldSwitchHalf() {
    return (_currentPhase == GamePhase.firstHalf && _phaseTime >= GameConstants.halfDuration) ||
           (_currentPhase == GamePhase.halfTime && _phaseTime >= GameConstants.halfTimeDuration);
  }
  
  void switchHalf() {
    switch (_currentPhase) {
      case GamePhase.firstHalf:
        _currentPhase = GamePhase.halfTime;
        _phaseTime = Duration.zero;
        print('Switching to half time');
        break;
      case GamePhase.halfTime:
        _currentPhase = GamePhase.secondHalf;
        _phaseTime = Duration.zero;
        // Teams switch sides untuk babak kedua
        _switchTeamSides();
        print('Starting second half');
        break;
      default:
        break;
    }
    notifyListeners();
  }
  
  void _switchTeamSides() {
    // Swap attacking dan guarding teams untuk babak kedua
    final temp = _attackingTeam;
    _attackingTeam = _guardingTeam;
    _guardingTeam = temp;
    print('Teams switched sides for second half');
  }
  
  bool shouldEndGame() {
    return _currentPhase == GamePhase.secondHalf && _phaseTime >= GameConstants.halfDuration;
  }
  
  void endGame() {
    _currentPhase = GamePhase.finished;
    _isPaused = true;
    
    // Log final game statistics
    _logFinalStatistics();
    notifyListeners();
  }
  
  void _logFinalStatistics() {
    if (_gameStartTime != null) {
      final totalDuration = DateTime.now().difference(_gameStartTime!);
      print('=== GAME STATISTICS ===');
      print('Total Duration: ${totalDuration.toGameTime()}');
      print('Final Score: $_scoreTeamA - $_scoreTeamB');
      print('Team A Substitutions: $_teamASubstitutions/${GameConstants.maxSubstitutionsPerTeam}');
      print('Team B Substitutions: $_teamBSubstitutions/${GameConstants.maxSubstitutionsPerTeam}');
      print('Total Touches: $_totalTouches');
      print('Winner: ${getWinner()?.name ?? 'Draw'}');
      print('======================');
    }
  }
  
  bool isGameActive() {
    return _currentPhase == GamePhase.firstHalf || _currentPhase == GamePhase.secondHalf;
  }
  
  // Scoring methods
  void addScore(PlayerTeam team, [int points = 1]) {
    if (team == PlayerTeam.teamA) {
      _scoreTeamA += points;
      _teamAScores++;
    } else {
      _scoreTeamB += points;
      _teamBScores++;
    }
    
    print('Score added for ${team.name}: ${getScore(team)} points');
    notifyListeners();
  }
  
  int getScore(PlayerTeam team) {
    return team == PlayerTeam.teamA ? _scoreTeamA : _scoreTeamB;
  }
  
  // Team switching (ketika attacker tersentuh)
  void switchAttackingTeam() {
    final temp = _attackingTeam;
    _attackingTeam = _guardingTeam;
    _guardingTeam = temp;
    
    // Reset movement tracking
    _hasMovementInCurrentPhase = false;
    _noMovementTimer = Duration.zero;
    
    print('Teams switched: ${_attackingTeam.name} now attacking');
    notifyListeners();
  }
  
  // Pause/Resume
  void togglePause() {
    _isPaused = !_isPaused;
    print('Game ${_isPaused ? 'paused' : 'resumed'}');
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
    _teamAScores = 0;
    _teamBScores = 0;
    _totalTouches = 0;
    _gameStartTime = null;
    
    print('Game reset to initial state');
    notifyListeners();
  }
  
  // Substitution methods (sesuai aturan resmi)
  bool canSubstitute(PlayerTeam team) {
    final substitutions = team == PlayerTeam.teamA ? _teamASubstitutions : _teamBSubstitutions;
    return substitutions < GameConstants.maxSubstitutionsPerTeam && 
           (_isPaused || _currentPhase == GamePhase.halfTime);
  }
  
  void makeSubstitution(PlayerTeam team) {
    if (!canSubstitute(team)) {
      print('Cannot make substitution for ${team.name}: ${_getSubstitutionReason(team)}');
      return;
    }
    
    if (team == PlayerTeam.teamA) {
      _teamASubstitutions++;
    } else {
      _teamBSubstitutions++;
    }
    
    final remaining = GameConstants.maxSubstitutionsPerTeam - 
                     (team == PlayerTeam.teamA ? _teamASubstitutions : _teamBSubstitutions);
    
    print('Substitution made for ${team.name}. Remaining: $remaining');
    notifyListeners();
  }
  
  String _getSubstitutionReason(PlayerTeam team) {
    final substitutions = team == PlayerTeam.teamA ? _teamASubstitutions : _teamBSubstitutions;
    
    if (substitutions >= GameConstants.maxSubstitutionsPerTeam) {
      return 'Maximum substitutions reached';
    }
    
    if (!_isPaused && _currentPhase != GamePhase.halfTime) {
      return 'Game must be paused or at half-time';
    }
    
    return 'Unknown reason';
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
  
  // Statistics dan analytics
  double getGameProgressPercentage() {
    if (!isGameActive()) return 0.0;
    
    return (_gameTime.inMilliseconds / GameConstants.gameDuration.inMilliseconds).clamp(0.0, 1.0);
  }
  
  String getFormattedGameTime() {
    return _gameTime.toGameTime();
  }
  
  String getFormattedPhaseTime() {
    return _phaseTime.toGameTime();
  }
  
  String getCurrentPhaseDisplay() {
    switch (_currentPhase) {
      case GamePhase.setup:
        return GameTexts.phaseSetup;
      case GamePhase.firstHalf:
        return GameTexts.phaseFirstHalf;
      case GamePhase.halfTime:
        return GameTexts.phaseHalfTime;
      case GamePhase.secondHalf:
        return GameTexts.phaseSecondHalf;
      case GamePhase.finished:
        return GameTexts.phaseFinished;
    }
  }
  
  Duration getRemainingTime() {
    switch (_currentPhase) {
      case GamePhase.firstHalf:
      case GamePhase.secondHalf:
        return GameConstants.halfDuration - _phaseTime;
      case GamePhase.halfTime:
        return GameConstants.halfTimeDuration - _phaseTime;
      default:
        return Duration.zero;
    }
  }
  
  String getFormattedRemainingTime() {
    return getRemainingTime().toGameTime();
  }
  
  // Rule validation helpers
  bool isValidMove(PlayerTeam team, PlayerRole role) {
    // Attackers hanya bisa bergerak jika tim mereka yang menyerang
    if (role == PlayerRole.attacker) {
      return team == _attackingTeam;
    }
    
    // Guards selalu bisa bergerak dalam area yang ditentukan
    return team == _guardingTeam;
  }
  
  bool isTimeoutPending() {
    return _noMovementTimer >= GameConstants.noMovementTimeout;
  }
  
  double getMovementTimeoutProgress() {
    return (_noMovementTimer.inMilliseconds / GameConstants.noMovementTimeout.inMilliseconds)
        .clamp(0.0, 1.0);
  }
  
  // Touch tracking
  void recordTouch() {
    _totalTouches++;
  }
  
  Map<String, dynamic> getGameSummary() {
    return {
      'phase': getCurrentPhaseDisplay(),
      'gameTime': getFormattedGameTime(),
      'phaseTime': getFormattedPhaseTime(),
      'remainingTime': getFormattedRemainingTime(),
      'scoreTeamA': _scoreTeamA,
      'scoreTeamB': _scoreTeamB,
      'attackingTeam': _attackingTeam.name,
      'guardingTeam': _guardingTeam.name,
      'isPaused': _isPaused,
      'winner': getWinner()?.name,
      'isDraw': isDraw(),
      'progress': getGameProgressPercentage(),
      'substitutionsA': '$_teamASubstitutions/${GameConstants.maxSubstitutionsPerTeam}',
      'substitutionsB': '$_teamBSubstitutions/${GameConstants.maxSubstitutionsPerTeam}',
      'totalTouches': _totalTouches,
      'timeoutProgress': getMovementTimeoutProgress(),
      'canSubstituteA': canSubstitute(PlayerTeam.teamA),
      'canSubstituteB': canSubstitute(PlayerTeam.teamB),
    };
  }
  
  // Performance analytics
  Map<String, dynamic> getPerformanceStats() {
    final totalTime = _gameTime.inSeconds;
    final scoreRate = totalTime > 0 ? (_scoreTeamA + _scoreTeamB) / (totalTime / 60.0) : 0.0;
    
    return {
      'averageScorePerMinute': scoreRate.toStringAsFixed(2),
      'touchesPerMinute': totalTime > 0 ? (_totalTouches / (totalTime / 60.0)).toStringAsFixed(2) : '0',
      'teamAEfficiency': _teamAScores > 0 ? (_scoreTeamA / _teamAScores).toStringAsFixed(2) : '0',
      'teamBEfficiency': _teamBScores > 0 ? (_scoreTeamB / _teamBScores).toStringAsFixed(2) : '0',
      'gameIntensity': _totalTouches > 10 ? 'High' : _totalTouches > 5 ? 'Medium' : 'Low',
    };
  }
}