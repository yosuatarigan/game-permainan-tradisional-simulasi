// File: lib/game/components/player.dart
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:game_permainan_tradisional_simulasi/models/game_state.dart';
import 'hadang_field.dart';

class HadangPlayer extends CircleComponent with HasCollisionDetection, CollisionCallbacks {
  final int playerId;
  final PlayerTeam team;
  final Color playerColor;
  
  // Player state
  PlayerRole _currentRole;
  GuardLine? _assignedLine;
  Vector2? _targetPosition;
  Vector2 _lastValidPosition = Vector2.zero();
  
  // Movement tracking
  final List<Vector2> _movementHistory = [];
  bool _hasMovedThisPhase = false;
  bool _scoreProcessed = false;
  
  // Animation and visual
  late Paint _playerPaint;
  late Paint _shadowPaint;
  late Paint _outlinePaint;
  bool _isSelected = false;
  bool _isMoving = false;
  
  // Movement constraints
  static const double playerRadius = 15.0;
  static const double movementSpeed = 200.0;
  static const double guardLineTolerrance = 20.0;

  HadangPlayer({
    required this.playerId,
    required this.team,
    required PlayerRole initialRole,
    required this.playerColor,
  }) : _currentRole = initialRole {
    radius = playerRadius;
    anchor = Anchor.center;
    
    // Setup collision
    add(CircleHitbox(radius: radius));
    
    _initializePaints();
  }
  
  void _initializePaints() {
    _playerPaint = Paint()
      ..color = playerColor
      ..style = PaintingStyle.fill;
    
    _shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    _outlinePaint = Paint()
      ..color = _currentRole == PlayerRole.guard ? Colors.white : Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
  }
  
  PlayerRole get currentRole => _currentRole;
  bool get hasMovedThisPhase => _hasMovedThisPhase;
  bool get scoreProcessed => _scoreProcessed;
  bool get isMoving => _isMoving;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _lastValidPosition = position.clone();
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (_targetPosition != null) {
      _moveTowardsTarget(dt);
    }
    
    _updateMovementHistory();
    _validatePosition();
  }
  
  void _moveTowardsTarget(double dt) {
    if (_targetPosition == null) return;
    
    final direction = _targetPosition! - position;
    final distance = direction.length;
    
    if (distance < 5.0) {
      position = _targetPosition!;
      _targetPosition = null;
      _isMoving = false;
      _onReachedTarget();
      return;
    }
    
    final velocity = direction.normalized() * movementSpeed * dt;
    final newPosition = position + velocity;
    
    if (_isValidMove(newPosition)) {
      position = newPosition;
      _lastValidPosition = position.clone();
      _hasMovedThisPhase = true;
      _isMoving = true;
    } else {
      _targetPosition = null;
      _isMoving = false;
    }
  }
  
  void _onReachedTarget() {
    _addMovementToHistory(position);
    _checkScoring();
  }
  
  bool _isValidMove(Vector2 newPosition) {
    final field = parent?.children.whereType<HadangField>().firstOrNull;
    if (field == null) return false;
    
    if (_currentRole == PlayerRole.guard) {
      return _isValidGuardMove(newPosition, field);
    } else {
      return _isValidAttackerMove(newPosition, field);
    }
  }
  
  bool _isValidGuardMove(Vector2 newPosition, HadangField field) {
    if (_assignedLine == null) return false;
    
    // Guards must stay on their assigned line
    return _assignedLine!.isPointOnLine(newPosition); // Removed the second argument
  }
  
  bool _isValidAttackerMove(Vector2 newPosition, HadangField field) {
    // Check basic field boundaries
    if (!field.isPointInField(newPosition)) {
      // Allow slight overflow for start/finish areas
      if (newPosition.y < field.fieldRect.top - 30 || 
          newPosition.y > field.fieldRect.bottom + 30) {
        return true; // Start/finish areas
      }
      return false;
    }
    
    // Check side line rule - attackers cannot go outside side lines
    if (field.isPointOnSideLine(newPosition)) {
      return false;
    }
    
    // Check forward movement rule - cannot move backward once advanced
    return _isForwardMovement(newPosition, field);
  }
  
  bool _isForwardMovement(Vector2 newPosition, HadangField field) {
    if (_movementHistory.isEmpty) return true;
    
    final lastPosition = _movementHistory.last;
    
    // For attackers moving from start to finish (top to bottom)
    if (lastPosition.y < (field.fieldRect.top + field.fieldRect.bottom) / 2) {
      // In top half, must move forward (down) or sideways
      return newPosition.y >= lastPosition.y - 10; // Small tolerance
    } else {
      // In bottom half, can move anywhere (returning)
      return true;
    }
  }
  
  void _addMovementToHistory(Vector2 position) {
    _movementHistory.add(position.clone());
    
    // Keep only recent history
    if (_movementHistory.length > 10) {
      _movementHistory.removeAt(0);
    }
  }
  
  void _updateMovementHistory() {
    // Update history periodically even during movement
    int updateCounter = 0;
    updateCounter++;
    
    if (updateCounter % 30 == 0) { // Every ~0.5 seconds
      _addMovementToHistory(position);
    }
  }
  
  void _validatePosition() {
    final field = parent?.children.whereType<HadangField>().firstOrNull;
    if (field == null) return;
    
    if (!_isValidMove(position)) {
      // Revert to last valid position
      position = _lastValidPosition.clone();
      _targetPosition = null;
      _isMoving = false;
    }
  }
  
  void _checkScoring() {
    if (_currentRole != PlayerRole.attacker) return;
    if (_scoreProcessed) return;
    
    final field = parent?.children.whereType<HadangField>().firstOrNull;
    if (field == null) return;
    
    // Check if reached finish line
    if (position.y >= field.fieldRect.bottom + 10) {
      _scoreProcessed = true;
    }
    
    // Check if returned to start line
    if (position.y <= field.fieldRect.top - 10 && _movementHistory.isNotEmpty) {
      final hasReachedFinish = _movementHistory.any((pos) => pos.y >= field.fieldRect.bottom);
      if (hasReachedFinish) {
        _scoreProcessed = true;
      }
    }
  }
  
  bool hasScored() {
    return _scoreProcessed;
  }
  
  void markScoreProcessed() {
    _scoreProcessed = true;
  }
  
  // Touch detection for guards
  bool canTouch(HadangPlayer attacker) {
    if (_currentRole != PlayerRole.guard) return false;
    if (attacker._currentRole != PlayerRole.attacker) return false;
    if (_assignedLine == null) return false;
    
    // Check if guard is on their line
    if (!_assignedLine!.isPointOnLine(position)) { // Removed the second argument
      return false;
    }
    
    // Check if attacker is in touchable area
    return _isAttackerInTouchableArea(attacker);
  }
  
  bool _isAttackerInTouchableArea(HadangPlayer attacker) {
    if (_assignedLine == null) return false;
    
    if (_assignedLine!.lineType == GuardLineType.horizontal) {
      // Horizontal guard can touch attackers crossing their line
      return (attacker.position.y - _assignedLine!.start.y).abs() < 30;
    } else {
      // Vertical guard (sodor) can touch in center area
      return (attacker.position.x - _assignedLine!.start.x).abs() < 30;
    }
  }
  
  bool isCollidingWith(HadangPlayer other) {
    final distance = position.distanceTo(other.position);
    return distance < (radius + other.radius);
  }
  
  // Movement control
  void moveTowards(Vector2 target) {
    if (_currentRole == PlayerRole.guard && _assignedLine != null) {
      // Guards move along their assigned line
      _targetPosition = _assignedLine!.getClosestPointOnLine(target);
    } else if (_currentRole == PlayerRole.attacker) {
      // Attackers move freely (with validation)
      _targetPosition = target.clone();
    }
  }
  
  void setPosition(Vector2 newPosition) {
    position = newPosition;
    _lastValidPosition = newPosition.clone();
    _addMovementToHistory(newPosition);
  }
  
  // Role and line assignment
  void switchRole() {
    _currentRole = _currentRole == PlayerRole.guard 
        ? PlayerRole.attacker 
        : PlayerRole.guard;
    
    _initializePaints();
    _resetForNewRole();
  }
  
  void assignToLine(GuardLine line) {
    _assignedLine = line;
  }
  
  void _resetForNewRole() {
    _targetPosition = null;
    _isMoving = false;
    _hasMovedThisPhase = false;
    _scoreProcessed = false;
    _movementHistory.clear();
  }
  
  void reset() {
    _resetForNewRole();
    _isSelected = false;
  }
  
  void select() {
    _isSelected = true;
  }
  
  void deselect() {
    _isSelected = false;
  }
  
  @override
  void render(Canvas canvas) {
    // Draw shadow
    final shadowOffset = Offset(2, 2);
    canvas.drawCircle(shadowOffset, radius, _shadowPaint);
    
    // Draw player body
    canvas.drawCircle(Offset.zero, radius, _playerPaint);
    
    // Draw outline
    if (_isSelected || _isMoving) {
      _outlinePaint.strokeWidth = _isSelected ? 3.0 : 2.0;
      canvas.drawCircle(Offset.zero, radius, _outlinePaint);
    }
    
    // Draw player number
    _drawPlayerNumber(canvas);
    
    // Draw role indicator
    _drawRoleIndicator(canvas);
    
    // Draw movement trail
    if (_isMoving && _currentRole == PlayerRole.attacker) {
      _drawMovementTrail(canvas);
    }
  }
  
  void _drawPlayerNumber(Canvas canvas) {
    final textPaint = TextPaint(
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            offset: const Offset(1, 1),
            blurRadius: 2,
            color: Colors.black.withOpacity(0.7),
          ),
        ],
      ),
    );
    
    textPaint.render(
      canvas,
      '$playerId',
      Vector2.zero(),
      anchor: Anchor.center,
    );
  }
  
  void _drawRoleIndicator(Canvas canvas) {
    final indicatorPaint = Paint()
      ..style = PaintingStyle.fill;
    
    if (_currentRole == PlayerRole.guard) {
      // Draw shield icon for guards
      indicatorPaint.color = Colors.white;
      final shieldRect = Rect.fromCircle(
        center: Offset(radius - 5, -radius + 5),
        radius: 4,
      );
      canvas.drawRect(shieldRect, indicatorPaint);
    } else {
      // Draw arrow icon for attackers
      indicatorPaint.color = Colors.yellow;
      final arrowPath = Path();
      arrowPath.moveTo(radius - 8, -radius + 5);
      arrowPath.lineTo(radius - 2, -radius + 5);
      arrowPath.lineTo(radius - 5, -radius + 2);
      arrowPath.close();
      canvas.drawPath(arrowPath, indicatorPaint);
    }
  }
  
  void _drawMovementTrail(Canvas canvas) {
    if (_movementHistory.length < 2) return;
    
    final trailPaint = Paint()
      ..color = playerColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    final path = Path();
    path.moveTo(
      _movementHistory.first.x - position.x,
      _movementHistory.first.y - position.y,
    );
    
    for (int i = 1; i < _movementHistory.length; i++) {
      path.lineTo(
        _movementHistory[i].x - position.x,
        _movementHistory[i].y - position.y,
      );
    }
    
    canvas.drawPath(path, trailPaint);
  }
  
  @override
  bool onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is HadangPlayer) {
      // Handle player collision
      if (_currentRole == PlayerRole.guard && other._currentRole == PlayerRole.attacker) {
        if (canTouch(other)) {
          _handleTouch(other);
        }
      }
    }
    return true;
  }
  
  void _handleTouch(HadangPlayer attacker) {
    // Create touch effect
    add(
      ScaleEffect.by(
        Vector2.all(1.2),
        EffectController(duration: 0.2, reverseDuration: 0.2),
      ),
    );
    
    // Signal game for team switch
    print('Guard ${team.name}$playerId touched attacker ${attacker.team.name}${attacker.playerId}');
  }
}