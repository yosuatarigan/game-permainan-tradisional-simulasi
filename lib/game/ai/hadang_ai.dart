// File: lib/game/ai/hadang_ai.dart
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:game_permainan_tradisional_simulasi/models/game_state.dart';
import '../components/player.dart';
import '../components/hadang_field.dart';
import '../../utils/game_constants.dart';

class HadangAI {
  static HadangAI? _instance;
  static HadangAI get instance => _instance ??= HadangAI._();
  HadangAI._();

  final Random _random = Random();
  late String _difficultyLevel;
  late Map<String, dynamic> _difficultySettings;

  void initialize(String difficulty) {
    _difficultyLevel = difficulty;
    _difficultySettings = GameDifficulty.difficultyLevels[difficulty] ?? 
                         GameDifficulty.difficultyLevels['normal']!;
  }

  // Main AI decision maker
  AIDecision makeDecision(HadangPlayer player, HadangGameState gameState, 
                         List<HadangPlayer> teammates, List<HadangPlayer> opponents) {
    if (player.currentRole == PlayerRole.guard) {
      return _makeGuardDecision(player, gameState, opponents);
    } else {
      return _makeAttackerDecision(player, gameState, teammates, opponents);
    }
  }

  AIDecision _makeGuardDecision(HadangPlayer player, HadangGameState gameState, 
                               List<HadangPlayer> attackers) {
    final reactionTime = _difficultySettings['guardReactionTime'] as double;
    
    // Find closest attacker threat
    final threat = _findClosestThreat(player, attackers);
    if (threat == null) {
      return AIDecision(
        action: AIAction.wait,
        targetPosition: player.position,
        confidence: 0.5,
      );
    }

    // Calculate interception point
    final interceptPoint = _calculateInterceptionPoint(player, threat);
    
    // Determine action based on threat level and AI capability
    final threatLevel = _assessThreatLevel(player, threat);
    final confidence = _calculateConfidence(threatLevel, reactionTime);

    if (threatLevel > 0.7 && _random.nextDouble() < confidence) {
      return AIDecision(
        action: AIAction.intercept,
        targetPosition: interceptPoint,
        confidence: confidence,
        targetPlayer: threat,
      );
    } else if (threatLevel > 0.3) {
      return AIDecision(
        action: AIAction.track,
        targetPosition: _getOptimalGuardPosition(player, threat),
        confidence: confidence * 0.8,
        targetPlayer: threat,
      );
    }

    return AIDecision(
      action: AIAction.patrol,
      targetPosition: _getPatrolPosition(player),
      confidence: 0.6,
    );
  }

  AIDecision _makeAttackerDecision(HadangPlayer player, HadangGameState gameState,
                                  List<HadangPlayer> teammates, List<HadangPlayer> guards) {
    final strategicThinking = _difficultySettings['strategicThinking'] as double;
    final speed = _difficultySettings['attackerSpeed'] as double;

    // Analyze field situation
    final fieldAnalysis = _analyzeField(player, guards);
    final bestPath = _findBestPath(player, guards, strategicThinking);
    
    if (bestPath.isEmpty) {
      return AIDecision(
        action: AIAction.wait,
        targetPosition: player.position,
        confidence: 0.3,
      );
    }

    // Determine movement strategy
    final nextPosition = bestPath.first;
    final riskLevel = _calculateRiskLevel(player, nextPosition, guards);
    
    if (riskLevel < 0.3 || _random.nextDouble() < strategicThinking) {
      return AIDecision(
        action: AIAction.advance,
        targetPosition: nextPosition,
        confidence: (1.0 - riskLevel) * speed,
        path: bestPath,
      );
    } else if (riskLevel > 0.7) {
      // Look for teammate coordination opportunity
      final coordinationMove = _findCoordinationOpportunity(player, teammates, guards);
      if (coordinationMove != null) {
        return coordinationMove;
      }
      
      return AIDecision(
        action: AIAction.retreat,
        targetPosition: _getSafePosition(player, guards),
        confidence: 0.7,
      );
    }

    return AIDecision(
      action: AIAction.wait,
      targetPosition: player.position,
      confidence: 0.5,
    );
  }

  HadangPlayer? _findClosestThreat(HadangPlayer guard, List<HadangPlayer> attackers) {
    if (attackers.isEmpty) return null;

    HadangPlayer? closestThreat;
    double minThreatScore = double.infinity;

    for (final attacker in attackers) {
      final distance = guard.position.distanceTo(attacker.position);
      final speed = attacker.isMoving ? 1.5 : 1.0;
      final direction = _getAttackerDirection(attacker);
      
      // Calculate threat score (lower = more threatening)
      final threatScore = distance / speed / direction;
      
      if (threatScore < minThreatScore) {
        minThreatScore = threatScore;
        closestThreat = attacker;
      }
    }

    return closestThreat;
  }

  double _getAttackerDirection(HadangPlayer attacker) {
    // Check if attacker is moving towards guard's line
    // Return value between 0.5 (moving away) and 2.0 (moving directly towards)
    if (!attacker.isMoving) return 1.0;
    
    // Simplified direction calculation
    return 1.5; // Assume moderate threat direction
  }

  Vector2 _calculateInterceptionPoint(HadangPlayer guard, HadangPlayer attacker) {
    if (guard.assignedLine == null) return guard.position;
    
    final line = guard.assignedLine!;
    
    // Predict attacker's next position
    final prediction = _predictPlayerPosition(attacker, 0.5); // 0.5 second ahead
    
    // Find closest point on guard's line to predicted position
    return line.getClosestPointOnLine(prediction);
  }

  Vector2 _predictPlayerPosition(HadangPlayer player, double timeAhead) {
    if (!player.isMoving) return player.position;
    
    // Simple linear prediction
    final velocity = Vector2(0, 100); // Simplified velocity
    return player.position + (velocity * timeAhead);
  }

  double _assessThreatLevel(HadangPlayer guard, HadangPlayer attacker) {
    final distance = guard.position.distanceTo(attacker.position);
    final maxThreatDistance = 150.0;
    
    if (distance > maxThreatDistance) return 0.0;
    
    final proximityThreat = 1.0 - (distance / maxThreatDistance);
    final speedThreat = attacker.isMoving ? 1.0 : 0.5;
    
    return (proximityThreat * 0.7 + speedThreat * 0.3).clamp(0.0, 1.0);
  }

  double _calculateConfidence(double threatLevel, double reactionTime) {
    return (threatLevel * reactionTime).clamp(0.1, 1.0);
  }

  Vector2 _getOptimalGuardPosition(HadangPlayer guard, HadangPlayer threat) {
    if (guard.assignedLine == null) return guard.position;
    
    final line = guard.assignedLine!;
    final threatPosition = threat.position;
    
    // Position guard slightly ahead of threat's path
    final anticipationOffset = threat.isMoving ? 20.0 : 0.0;
    final targetY = threatPosition.y + anticipationOffset;
    
    return line.getClosestPointOnLine(Vector2(threatPosition.x, targetY));
  }

  Vector2 _getPatrolPosition(HadangPlayer guard) {
    if (guard.assignedLine == null) return guard.position;
    
    final line = guard.assignedLine!;
    final patrolRange = 60.0;
    
    // Move randomly within patrol range
    final centerPoint = line.center;
    final offset = (_random.nextDouble() - 0.5) * patrolRange;
    
    if (line.lineType == GuardLineType.horizontal) {
      return Vector2(centerPoint.x + offset, centerPoint.y);
    } else {
      return Vector2(centerPoint.x, centerPoint.y + offset);
    }
  }

  Map<String, dynamic> _analyzeField(HadangPlayer attacker, List<HadangPlayer> guards) {
    final analysis = <String, dynamic>{};
    
    // Count guards in each section
    final guardDensity = <int, int>{};
    for (final guard in guards) {
      // Simplified field analysis
      final section = _getFieldSection(guard.position);
      guardDensity[section] = (guardDensity[section] ?? 0) + 1;
    }
    
    analysis['guardDensity'] = guardDensity;
    analysis['safestSection'] = _findSafestSection(guardDensity);
    analysis['totalGuards'] = guards.length;
    
    return analysis;
  }

  int _getFieldSection(Vector2 position) {
    // Simplified field section calculation (1-6)
    return 1; // Placeholder
  }

  int _findSafestSection(Map<int, int> guardDensity) {
    int safestSection = 1;
    int minGuards = 999;
    
    for (int section = 1; section <= 6; section++) {
      final guardCount = guardDensity[section] ?? 0;
      if (guardCount < minGuards) {
        minGuards = guardCount;
        safestSection = section;
      }
    }
    
    return safestSection;
  }

  List<Vector2> _findBestPath(HadangPlayer attacker, List<HadangPlayer> guards, 
                             double strategicThinking) {
    final paths = _generatePossiblePaths(attacker);
    
    if (paths.isEmpty) return [];
    
    // Score each path
    double bestScore = -1;
    List<Vector2> bestPath = [];
    
    for (final path in paths) {
      final score = _scorePath(path, guards, strategicThinking);
      if (score > bestScore) {
        bestScore = score;
        bestPath = path;
      }
    }
    
    return bestPath;
  }

  List<List<Vector2>> _generatePossiblePaths(HadangPlayer attacker) {
    final paths = <List<Vector2>>[];
    final currentPos = attacker.position;
    
    // Generate 3 basic paths: left, center, right
    for (int i = 0; i < 3; i++) {
      final path = <Vector2>[];
      final xOffset = (i - 1) * 60.0; // -60, 0, +60
      
      // Create simple forward path with lateral movement
      for (int step = 1; step <= 3; step++) {
        path.add(Vector2(
          currentPos.x + xOffset,
          currentPos.y + (step * 80.0),
        ));
      }
      
      paths.add(path);
    }
    
    return paths;
  }

  double _scorePath(List<Vector2> path, List<HadangPlayer> guards, double strategicThinking) {
    double score = 1.0;
    
    for (final position in path) {
      final risk = _calculateRiskLevel(null, position, guards);
      score *= (1.0 - risk);
    }
    
    // Bonus for reaching goal
    final lastPosition = path.isNotEmpty ? path.last : Vector2.zero();
    if (_isNearGoal(lastPosition)) {
      score *= 2.0;
    }
    
    return score * strategicThinking;
  }

  double _calculateRiskLevel(HadangPlayer? attacker, Vector2 position, 
                           List<HadangPlayer> guards) {
    double maxRisk = 0.0;
    
    for (final guard in guards) {
      final distance = guard.position.distanceTo(position);
      final guardReach = 40.0; // Guard's effective reach
      
      if (distance < guardReach) {
        final risk = 1.0 - (distance / guardReach);
        maxRisk = max(maxRisk, risk);
      }
    }
    
    return maxRisk.clamp(0.0, 1.0);
  }

  bool _isNearGoal(Vector2 position) {
    // Check if position is near the goal line
    return position.y > 400; // Simplified goal check
  }

  AIDecision? _findCoordinationOpportunity(HadangPlayer attacker, 
                                          List<HadangPlayer> teammates,
                                          List<HadangPlayer> guards) {
    // Look for distraction opportunities
    for (final teammate in teammates) {
      if (teammate != attacker && teammate.isMoving) {
        // If teammate is drawing attention, create opportunity
        final distractionPoint = _findDistractionOpportunity(attacker, teammate, guards);
        if (distractionPoint != null) {
          return AIDecision(
            action: AIAction.coordinate,
            targetPosition: distractionPoint,
            confidence: 0.8,
            coordinationTarget: teammate,
          );
        }
      }
    }
    
    return null;
  }

  Vector2? _findDistractionOpportunity(HadangPlayer attacker, HadangPlayer distractingTeammate,
                                      List<HadangPlayer> guards) {
    // Check if guards are focused on teammate
    int guardsDistracted = 0;
    for (final guard in guards) {
      final distanceToTeammate = guard.position.distanceTo(distractingTeammate.position);
      final distanceToAttacker = guard.position.distanceTo(attacker.position);
      
      if (distanceToTeammate < distanceToAttacker) {
        guardsDistracted++;
      }
    }
    
    if (guardsDistracted >= guards.length / 2) {
      // More than half guards distracted, find opening
      return _findOpeningPosition(attacker, guards);
    }
    
    return null;
  }

  Vector2 _findOpeningPosition(HadangPlayer attacker, List<HadangPlayer> guards) {
    // Find position with least guard coverage
    final testPositions = _generateTestPositions(attacker.position);
    
    Vector2 bestPosition = attacker.position;
    double lowestRisk = 1.0;
    
    for (final pos in testPositions) {
      final risk = _calculateRiskLevel(attacker, pos, guards);
      if (risk < lowestRisk) {
        lowestRisk = risk;
        bestPosition = pos;
      }
    }
    
    return bestPosition;
  }

  List<Vector2> _generateTestPositions(Vector2 currentPosition) {
    final positions = <Vector2>[];
    final radius = 80.0;
    
    for (int angle = 0; angle < 360; angle += 45) {
      final radians = angle * (pi / 180);
      final x = currentPosition.x + cos(radians) * radius;
      final y = currentPosition.y + sin(radians) * radius;
      positions.add(Vector2(x, y));
    }
    
    return positions;
  }

  Vector2 _getSafePosition(HadangPlayer attacker, List<HadangPlayer> guards) {
    // Find position with maximum distance from all guards
    final testPositions = _generateTestPositions(attacker.position);
    
    Vector2 safestPosition = attacker.position;
    double maxMinDistance = 0.0;
    
    for (final pos in testPositions) {
      double minDistanceToGuards = double.infinity;
      
      for (final guard in guards) {
        final distance = guard.position.distanceTo(pos);
        minDistanceToGuards = min(minDistanceToGuards, distance);
      }
      
      if (minDistanceToGuards > maxMinDistance) {
        maxMinDistance = minDistanceToGuards;
        safestPosition = pos;
      }
    }
    
    return safestPosition;
  }
}

// AI Decision data structure
class AIDecision {
  final AIAction action;
  final Vector2 targetPosition;
  final double confidence;
  final HadangPlayer? targetPlayer;
  final HadangPlayer? coordinationTarget;
  final List<Vector2>? path;

  AIDecision({
    required this.action,
    required this.targetPosition,
    required this.confidence,
    this.targetPlayer,
    this.coordinationTarget,
    this.path,
  });
}

enum AIAction {
  wait,
  patrol,
  track,
  intercept,
  advance,
  retreat,
  coordinate,
}

// AI Behavior Patterns
class AIBehaviorPattern {
  final String name;
  final double aggressiveness;
  final double cautiousness;
  final double teamwork;
  final double adaptability;

  const AIBehaviorPattern({
    required this.name,
    required this.aggressiveness,
    required this.cautiousness,
    required this.teamwork,
    required this.adaptability,
  });

  static const defensive = AIBehaviorPattern(
    name: 'Defensive',
    aggressiveness: 0.3,
    cautiousness: 0.9,
    teamwork: 0.7,
    adaptability: 0.5,
  );

  static const balanced = AIBehaviorPattern(
    name: 'Balanced',
    aggressiveness: 0.6,
    cautiousness: 0.6,
    teamwork: 0.6,
    adaptability: 0.6,
  );

  static const aggressive = AIBehaviorPattern(
    name: 'Aggressive',
    aggressiveness: 0.9,
    cautiousness: 0.3,
    teamwork: 0.5,
    adaptability: 0.7,
  );

  static const tactical = AIBehaviorPattern(
    name: 'Tactical',
    aggressiveness: 0.5,
    cautiousness: 0.7,
    teamwork: 0.9,
    adaptability: 0.8,
  );
}