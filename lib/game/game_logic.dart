// File: lib/game/game_logic.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class Player {
  final int id;
  final String team; // 'red' or 'blue'
  String role; // 'guard' or 'attacker' - made mutable
  final bool isPlayerControlled;
  Offset position;
  Offset targetPosition;
  bool isMoving;

  Player({
    required this.id,
    required this.team,
    required this.role,
    required this.position,
    this.isPlayerControlled = false,
    this.isMoving = false,
  }) : targetPosition = position;

  String get imagePath => 'assets/${team}.png';
}

class HadangGameLogic extends ChangeNotifier {
  // Game State
  bool isPaused = false;
  int scoreRed = 0;
  int scoreBlue = 0;
  String currentPhase = 'Babak 1';
  Duration timeRemaining = const Duration(minutes: 15);
  
  // Field & Players
  final Size fieldSize = const Size(350, 250);
  final List<Player> players = [];
  
  // Controlled Players
  Player? player1; // Player controlled by joystick 1
  Player? player2; // Player controlled by joystick 2
  
  // Game Timer
  Timer? _gameTimer;
  Timer? _aiTimer;
  
  // Game Settings
  final double playerRadius = 15.0;
  final double playerSpeed = 2.0;
  final double touchDistance = 25.0;

  HadangGameLogic() {
    _initializePlayers();
  }

  void _initializePlayers() {
    players.clear();
    
    // Red Team (Guards) - positioned on horizontal lines
    for (int i = 0; i < 5; i++) {
      players.add(Player(
        id: i,
        team: 'red',
        role: 'guard',
        position: Offset(70 + (i * 60), 125), // Middle horizontal line
        isPlayerControlled: i == 0, // First red player is controlled
      ));
    }
    
    // Blue Team (Attackers) - positioned at bottom
    for (int i = 0; i < 5; i++) {
      players.add(Player(
        id: i + 5,
        team: 'blue',
        role: 'attacker',
        position: Offset(70 + (i * 60), 200), // Bottom area
        isPlayerControlled: i == 0, // First blue player is controlled
      ));
    }
    
    // Set controlled players
    player1 = players.firstWhere((p) => p.team == 'red' && p.isPlayerControlled);
    player2 = players.firstWhere((p) => p.team == 'blue' && p.isPlayerControlled);
  }

  void startGame() {
    isPaused = false;
    _startGameTimer();
    _startAITimer();
    notifyListeners();
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused && timeRemaining > Duration.zero) {
        timeRemaining = timeRemaining - const Duration(seconds: 1);
        
        // Check for half time
        if (timeRemaining == const Duration(minutes: 7, seconds: 30)) {
          currentPhase = 'Istirahat';
          _switchTeamSides();
        } else if (timeRemaining == const Duration(minutes: 7, seconds: 25)) {
          currentPhase = 'Babak 2';
        }
        
        // End game
        if (timeRemaining <= Duration.zero) {
          _endGame();
        }
        
        notifyListeners();
      }
    });
  }

  void _startAITimer() {
    _aiTimer?.cancel();
    _aiTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!isPaused) {
        _updateAIPlayers();
        _checkCollisions();
        notifyListeners();
      }
    });
  }

  void _updateAIPlayers() {
    final random = Random();
    
    for (final player in players) {
      if (!player.isPlayerControlled) {
        // Simple AI movement
        if (player.role == 'guard') {
          // Guards move left-right on their line
          if (random.nextDouble() < 0.02) { // 2% chance to change direction
            double newX = player.position.dx + (random.nextBool() ? 30 : -30);
            newX = newX.clamp(50.0, fieldSize.width - 50);
            player.targetPosition = Offset(newX, player.position.dy);
          }
        } else {
          // Attackers move toward goal slowly
          if (random.nextDouble() < 0.01) { // 1% chance to move up
            double newY = player.position.dy - 10;
            newY = newY.clamp(50.0, fieldSize.height - 50);
            player.targetPosition = Offset(player.position.dx, newY);
          }
        }
        
        // Smooth movement toward target
        _movePlayerToTarget(player);
      }
    }
  }

  void _movePlayerToTarget(Player player) {
    final dx = player.targetPosition.dx - player.position.dx;
    final dy = player.targetPosition.dy - player.position.dy;
    final distance = sqrt(dx * dx + dy * dy);
    
    if (distance > 1.0) {
      final moveX = (dx / distance) * playerSpeed;
      final moveY = (dy / distance) * playerSpeed;
      player.position = Offset(
        player.position.dx + moveX,
        player.position.dy + moveY,
      );
      player.isMoving = true;
    } else {
      player.isMoving = false;
    }
  }

  void _checkCollisions() {
    final attackers = players.where((p) => p.role == 'attacker').toList();
    final guards = players.where((p) => p.role == 'guard').toList();
    
    for (final attacker in attackers) {
      for (final guard in guards) {
        final distance = _getDistance(attacker.position, guard.position);
        if (distance < touchDistance) {
          _onPlayerTouched(attacker, guard);
          break;
        }
      }
      
      // Check if attacker reached the top (scored)
      if (attacker.position.dy < 50) {
        _onScore(attacker.team);
        _resetPlayerPosition(attacker);
      }
    }
  }

  double _getDistance(Offset pos1, Offset pos2) {
    final dx = pos1.dx - pos2.dx;
    final dy = pos1.dy - pos2.dy;
    return sqrt(dx * dx + dy * dy);
  }

  void _onPlayerTouched(Player attacker, Player guard) {
    // Switch teams
    _switchTeamRoles();
    _resetPlayerPosition(attacker);
  }

  void _onScore(String team) {
    if (team == 'red') {
      scoreRed++;
    } else {
      scoreBlue++;
    }
  }

  void _resetPlayerPosition(Player player) {
    if (player.role == 'attacker') {
      player.position = Offset(player.position.dx, fieldSize.height - 50);
    }
    player.targetPosition = player.position;
  }

  void _switchTeamRoles() {
    // Simple team switch - swap roles
    for (final player in players) {
      if (player.role == 'guard') {
        player.role = 'attacker';
        player.position = Offset(player.position.dx, fieldSize.height - 50);
      } else {
        player.role = 'guard';
        player.position = Offset(player.position.dx, fieldSize.height / 2);
      }
      player.targetPosition = player.position;
    }
  }

  void _switchTeamSides() {
    // Switch team sides for second half
    for (final player in players) {
      player.position = Offset(
        fieldSize.width - player.position.dx,
        fieldSize.height - player.position.dy,
      );
      player.targetPosition = player.position;
    }
  }

  void _endGame() {
    isPaused = true;
    _gameTimer?.cancel();
    _aiTimer?.cancel();
    currentPhase = 'Selesai';
  }

  // Player Controls
  void movePlayer1(Offset direction) {
    if (isPaused || player1 == null) return;
    
    final newPosition = Offset(
      (player1!.position.dx + direction.dx * playerSpeed * 3).clamp(
        playerRadius, fieldSize.width - playerRadius),
      (player1!.position.dy + direction.dy * playerSpeed * 3).clamp(
        playerRadius, fieldSize.height - playerRadius),
    );
    
    player1!.position = newPosition;
    player1!.targetPosition = newPosition;
    player1!.isMoving = direction.distance > 0.1;
  }

  void movePlayer2(Offset direction) {
    if (isPaused || player2 == null) return;
    
    final newPosition = Offset(
      (player2!.position.dx + direction.dx * playerSpeed * 3).clamp(
        playerRadius, fieldSize.width - playerRadius),
      (player2!.position.dy + direction.dy * playerSpeed * 3).clamp(
        playerRadius, fieldSize.height - playerRadius),
    );
    
    player2!.position = newPosition;
    player2!.targetPosition = newPosition;
    player2!.isMoving = direction.distance > 0.1;
  }

  void onPlayerTouch(Player player) {
    // Handle direct player touch if needed
  }

  // Game Controls
  void togglePause() {
    isPaused = !isPaused;
    notifyListeners();
  }

  void resetGame() {
    isPaused = false;
    scoreRed = 0;
    scoreBlue = 0;
    currentPhase = 'Babak 1';
    timeRemaining = const Duration(minutes: 15);
    _initializePlayers();
    startGame();
  }

  String get gameStatusText {
    if (isPaused) return 'Game Paused';
    if (timeRemaining <= Duration.zero) {
      final winner = scoreRed > scoreBlue ? 'Tim Merah' :
                    scoreBlue > scoreRed ? 'Tim Biru' : 'Seri';
      return 'Game Selesai - $winner Menang!';
    }
    return 'Kontrol pemain dengan joystick';
  }

  String get timeText {
    final minutes = timeRemaining.inMinutes;
    final seconds = timeRemaining.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _aiTimer?.cancel();
    super.dispose();
  }
}