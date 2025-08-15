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
  final Size fieldSize = const Size(400, 300); // Increased from 350x250
  final List<Player> players = [];
  
  // Controlled Players
  Player? player1; // Player controlled by joystick 1
  Player? player2; // Player controlled by joystick 2
  
  // Game Timer
  Timer? _gameTimer;
  Timer? _aiTimer;
  
  // Score callback for dialog
  Function(String team, int newScore)? onScoreCallback;
  
  // Game Settings
  final double playerRadius = 15.0;
  final double playerSpeed = 1.5; // Reduced for smoother movement
  final double touchDistance = 25.0;
  final double aiMoveChance = 0.005; // Much slower AI (0.5% chance per frame)

  // Role and objective tracking
  String get player1Role => player1?.role.toUpperCase() ?? 'UNKNOWN';
  String get player2Role => player2?.role.toUpperCase() ?? 'UNKNOWN';
  
  String get gameObjective {
    if (timeRemaining <= Duration.zero) {
      return _getWinnerText();
    }
    return 'PENYERANG: Capai area atas! | PENJAGA: Halangi lawan!';
  }

  String _getWinnerText() {
    if (scoreRed > scoreBlue) {
      return '🏆 TIM MERAH MENANG! $scoreRed - $scoreBlue';
    } else if (scoreBlue > scoreRed) {
      return '🏆 TIM BIRU MENANG! $scoreBlue - $scoreRed';
    } else {
      return '🤝 PERMAINAN SERI! $scoreRed - $scoreBlue';
    }
  }

  HadangGameLogic() {
    _initializePlayers();
  }

  void _initializePlayers() {
    players.clear();
    
    // Red Team (Guards) - positioned on horizontal lines (adjusted for bigger field)
    for (int i = 0; i < 5; i++) {
      players.add(Player(
        id: i,
        team: 'red',
        role: 'guard',
        position: Offset(80 + (i * 60), 150), // Adjusted spacing for bigger field
        isPlayerControlled: i == 0, // First red player is controlled
      ));
    }
    
    // Blue Team (Attackers) - positioned at bottom (adjusted for bigger field)
    for (int i = 0; i < 5; i++) {
      players.add(Player(
        id: i + 5,
        team: 'blue',
        role: 'attacker',
        position: Offset(80 + (i * 60), 250), // Adjusted for bigger field
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
        // Simplified and predictable AI behavior
        if (player.role == 'guard') {
          // Guards patrol slowly left-right on their line
          if (random.nextDouble() < aiMoveChance) {
            double newX = player.position.dx + (random.nextBool() ? 20 : -20);
            // Keep guards within field bounds with padding
            newX = newX.clamp(playerRadius + 10, fieldSize.width - playerRadius - 10);
            player.targetPosition = Offset(newX, player.position.dy);
          }
        } else {
          // Attackers move forward very slowly and predictably
          if (random.nextDouble() < aiMoveChance * 0.5) { // Even slower for attackers
            double newY = player.position.dy - 5; // Smaller steps
            // Don't let attackers move too far up automatically - adjusted for bigger field
            newY = newY.clamp(100.0, fieldSize.height - playerRadius - 10);
            player.targetPosition = Offset(player.position.dx, newY);
          }
        }
        
        // Apply movement boundaries and smooth movement
        _movePlayerToTargetWithBounds(player);
      }
    }
  }

  void _movePlayerToTargetWithBounds(Player player) {
    final dx = player.targetPosition.dx - player.position.dx;
    final dy = player.targetPosition.dy - player.position.dy;
    final distance = sqrt(dx * dx + dy * dy);
    
    if (distance > 0.5) {
      final moveX = (dx / distance) * playerSpeed;
      final moveY = (dy / distance) * playerSpeed;
      
      // Apply movement bounds based on role
      Offset newPosition = Offset(
        player.position.dx + moveX,
        player.position.dy + moveY,
      );
      
      // Enforce role-based movement constraints
      newPosition = _enforceMovementRules(player, newPosition);
      
      player.position = newPosition;
      player.isMoving = true;
    } else {
      player.isMoving = false;
    }
  }

  Offset _enforceMovementRules(Player player, Offset newPosition) {
    // Keep within field bounds
    double clampedX = newPosition.dx.clamp(playerRadius, fieldSize.width - playerRadius);
    double clampedY = newPosition.dy.clamp(playerRadius, fieldSize.height - playerRadius);
    
    // Role-specific constraints
    if (player.role == 'guard') {
      // Guards can only move left-right on their horizontal line (with some tolerance)
      clampedY = player.position.dy; // Lock Y position for guards
    } else if (player.role == 'attacker') {
      // Attackers can't move backward (except when manually controlled)
      if (!player.isPlayerControlled && clampedY > player.position.dy) {
        clampedY = player.position.dy; // Prevent moving backward
      }
    }
    
    return Offset(clampedX, clampedY);
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
      
      // Check if attacker reached the top (scored) - adjusted for bigger field
      if (attacker.position.dy < 45) { // Adjusted scoring threshold
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
      onScoreCallback?.call('red', scoreRed);
    } else {
      scoreBlue++;
      onScoreCallback?.call('blue', scoreBlue);
    }
  }

  void _resetPlayerPosition(Player player) {
    if (player.role == 'attacker') {
      player.position = Offset(player.position.dx, fieldSize.height - 50); // Adjusted for bigger field
    }
    player.targetPosition = player.position;
  }

  void _switchTeamRoles() {
    // Simple team switch - swap roles (adjusted for bigger field)
    for (final player in players) {
      if (player.role == 'guard') {
        player.role = 'attacker';
        player.position = Offset(player.position.dx, fieldSize.height - 50); // Adjusted
      } else {
        player.role = 'guard';
        player.position = Offset(player.position.dx, fieldSize.height / 2); // Center line
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

  // Player Controls with boundary enforcement
  void movePlayer1(Offset direction) {
    if (isPaused || player1 == null) return;
    
    final moveDistance = playerSpeed * 4; // Faster for manual control
    final newPosition = Offset(
      player1!.position.dx + direction.dx * moveDistance,
      player1!.position.dy + direction.dy * moveDistance,
    );
    
    // Apply movement rules and boundaries
    final constrainedPosition = _enforceMovementRules(player1!, newPosition);
    
    player1!.position = constrainedPosition;
    player1!.targetPosition = constrainedPosition;
    player1!.isMoving = direction.distance > 0.1;
  }

  void movePlayer2(Offset direction) {
    if (isPaused || player2 == null) return;
    
    final moveDistance = playerSpeed * 4; // Faster for manual control
    final newPosition = Offset(
      player2!.position.dx + direction.dx * moveDistance,
      player2!.position.dy + direction.dy * moveDistance,
    );
    
    // Apply movement rules and boundaries
    final constrainedPosition = _enforceMovementRules(player2!, newPosition);
    
    player2!.position = constrainedPosition;
    player2!.targetPosition = constrainedPosition;
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