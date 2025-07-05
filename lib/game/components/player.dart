// File: lib/game/components/player.dart
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../utils/game_constants.dart';
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
  
  // Movement tracking (untuk aturan game)
  final List<Vector2> _movementHistory = [];
  bool _hasMovedThisPhase = false;
  bool _scoreProcessed = false;
  DateTime? _lastMoveTime;
  
  // Animation and visual
  late Paint _playerPaint;
  late Paint _shadowPaint;
  late Paint _outlinePaint;
  late Paint _teamColorPaint;
  bool _isSelected = false;
  bool _isMoving = false;
  double _animationScale = 1.0;
  
  // Performance tracking
  int _touchesMade = 0;
  int _scoresMade = 0;
  double _totalDistanceMoved = 0.0;

  HadangPlayer({
    required this.playerId,
    required this.team,
    required PlayerRole initialRole,
    required this.playerColor,
  }) : _currentRole = initialRole {
    radius = GameConstants.playerRadius;
    anchor = Anchor.center;
    
    // Setup collision dengan radius yang tepat
    add(CircleHitbox(radius: radius));
    
    _initializePaints();
  }
  
  void _initializePaints() {
    // Main player color
    _playerPaint = Paint()
      ..color = playerColor
      ..style = PaintingStyle.fill;
    
    // Team color untuk secondary elements
    _teamColorPaint = Paint()
      ..color = team == PlayerTeam.teamA ? GameColors.teamALight : GameColors.teamBLight
      ..style = PaintingStyle.fill;
    
    // Shadow
    _shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    // Outline berdasarkan role
    _outlinePaint = Paint()
      ..color = _getOutlineColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
  }
  
  Color _getOutlineColor() {
    if (_currentRole == PlayerRole.guard) {
      return Colors.white;
    } else {
      return Colors.yellow;
    }
  }
  
  // Getters
  PlayerRole get currentRole => _currentRole;
  bool get hasMovedThisPhase => _hasMovedThisPhase;
  bool get scoreProcessed => _scoreProcessed;
  bool get isMoving => _isMoving;
  int get touchesMade => _touchesMade;
  int get scoresMade => _scoresMade;
  double get totalDistanceMoved => _totalDistanceMoved;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _lastValidPosition = position.clone();
    _lastMoveTime = DateTime.now();
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (_targetPosition != null) {
      _moveTowardsTarget(dt);
    }
    
    _updateMovementHistory();
    _validatePosition();
    _updateAnimations(dt);
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
    
    final velocity = direction.normalized() * GameConstants.playerMovementSpeed * dt;
    final newPosition = position + velocity;
    
    if (_isValidMove(newPosition)) {
      final moveDistance = position.distanceTo(newPosition);
      position = newPosition;
      _lastValidPosition = position.clone();
      _hasMovedThisPhase = true;
      _isMoving = true;
      _lastMoveTime = DateTime.now();
      _totalDistanceMoved += moveDistance;
    } else {
      _targetPosition = null;
      _isMoving = false;
    }
  }
  
  void _onReachedTarget() {
    _addMovementToHistory(position);
    _checkScoring();
    
    // Check achievement untuk movement
    if (_totalDistanceMoved > 500) {
      print('Player ${team.name}$playerId: Marathon runner!');
    }
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
    
    // Guards harus tetap di garis yang ditugaskan
    return _assignedLine!.isPointOnLine(newPosition);
  }
  
  bool _isValidAttackerMove(Vector2 newPosition, HadangField field) {
    // Check basic field boundaries
    if (!field.isPointInField(newPosition)) {
      // Allow overflow untuk start/finish areas
      if (field.isPointInStartArea(newPosition) || field.isPointInFinishArea(newPosition)) {
        return true;
      }
      return false;
    }
    
    // Check side line rule - attackers tidak boleh keluar garis samping
    if (field.isPointOnSideLine(newPosition)) {
      return false;
    }
    
    // Check forward movement rule - tidak boleh mundur setelah maju
    return _isForwardMovement(newPosition, field);
  }
  
  bool _isForwardMovement(Vector2 newPosition, HadangField field) {
    if (_movementHistory.isEmpty) return true;
    
    final lastPosition = _movementHistory.last;
    final fieldCenterY = (field.fieldRect.top + field.fieldRect.bottom) / 2;
    
    // Untuk attackers bergerak dari start ke finish (top ke bottom)
    if (lastPosition.y < fieldCenterY) {
      // Di bagian atas, harus bergerak maju (down) atau menyamping
      return newPosition.y >= lastPosition.y - 10; // Small tolerance
    } else {
      // Di bagian bawah, bisa bergerak kemanapun (returning)
      return true;
    }
  }
  
  void _addMovementToHistory(Vector2 position) {
    _movementHistory.add(position.clone());
    
    // Keep only recent history untuk performance
    if (_movementHistory.length > 20) {
      _movementHistory.removeAt(0);
    }
  }
  
  void _updateMovementHistory() {
    // Update history secara periodik
    if (_isMoving) {
      final now = DateTime.now();
      if (_lastMoveTime != null && now.difference(_lastMoveTime!).inMilliseconds > 500) {
        _addMovementToHistory(position);
        _lastMoveTime = now;
      }
    }
  }
  
  void _validatePosition() {
    final field = parent?.children.whereType<HadangField>().firstOrNull;
    if (field == null) return;
    
    if (!_isValidMove(position)) {
      // Revert ke posisi valid terakhir
      position = _lastValidPosition.clone();
      _targetPosition = null;
      _isMoving = false;
    }
  }
  
  void _updateAnimations(double dt) {
    // Scale animation saat bergerak
    final targetScale = _isMoving ? 1.1 : (_isSelected ? 1.05 : 1.0);
    _animationScale = _lerp(_animationScale, targetScale, dt * 5.0);
    
    scale = Vector2.all(_animationScale);
  }
  
  double _lerp(double a, double b, double t) {
    return a + (b - a) * t.clamp(0.0, 1.0);
  }
  
  void _checkScoring() {
    if (_currentRole != PlayerRole.attacker) return;
    if (_scoreProcessed) return;
    
    final field = parent?.children.whereType<HadangField>().firstOrNull;
    if (field == null) return;
    
    // Check jika mencapai finish line
    if (field.isPointInFinishArea(position)) {
      _scoreProcessed = true;
      _scoresMade++;
      return;
    }
    
    // Check jika kembali ke start line setelah melewati finish
    if (field.isPointInStartArea(position) && _movementHistory.isNotEmpty) {
      final hasReachedFinish = _movementHistory.any((pos) => 
          field.isPointInFinishArea(pos));
      
      if (hasReachedFinish) {
        _scoreProcessed = true;
        _scoresMade++;
      }
    }
  }
  
  bool hasScored() {
    return _scoreProcessed;
  }
  
  void markScoreProcessed() {
    _scoreProcessed = true;
  }
  
  // Touch detection untuk guards
  bool canTouch(HadangPlayer attacker) {
    if (_currentRole != PlayerRole.guard) return false;
    if (attacker._currentRole != PlayerRole.attacker) return false;
    if (_assignedLine == null) return false;
    
    // Check jika guard ada di garis mereka
    if (!_assignedLine!.isPointOnLine(position)) {
      return false;
    }
    
    // Check jika attacker dalam jangkauan sentuhan
    return _isAttackerInTouchableArea(attacker);
  }
  
  bool _isAttackerInTouchableArea(HadangPlayer attacker) {
    if (_assignedLine == null) return false;
    
    final distance = position.distanceTo(attacker.position);
    
    if (distance > GameConstants.touchDetectionRadius) {
      return false;
    }
    
    if (_assignedLine!.lineType == GuardLineType.horizontal) {
      // Horizontal guard bisa menyentuh attackers yang melewati garis mereka
      return (attacker.position.y - _assignedLine!.start.y).abs() < GameConstants.touchDetectionRadius;
    } else {
      // Vertical guard (sodor) bisa menyentuh di area tengah
      return (attacker.position.x - _assignedLine!.start.x).abs() < GameConstants.touchDetectionRadius;
    }
  }
  
  bool isCollidingWith(HadangPlayer other) {
    final distance = position.distanceTo(other.position);
    return distance < (radius + other.radius);
  }
  
  // Movement control
  void moveTowards(Vector2 target) {
    if (_currentRole == PlayerRole.guard && _assignedLine != null) {
      // Guards bergerak sepanjang garis yang ditugaskan
      _targetPosition = _assignedLine!.getClosestPointOnLine(target);
    } else if (_currentRole == PlayerRole.attacker) {
      // Attackers bergerak bebas (dengan validasi)
      _targetPosition = target.clone();
    }
    
    _isSelected = true;
    
    // Auto-deselect setelah beberapa detik
    Future.delayed(GameConstants.uiTransitionDuration, () {
      _isSelected = false;
    });
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
    
    // Add switch effect
    add(
      ScaleEffect.by(
        Vector2.all(1.3),
        EffectController(
          duration: GameConstants.touchEffectDuration.inMilliseconds / 1000.0,
          reverseDuration: GameConstants.touchEffectDuration.inMilliseconds / 1000.0,
        ),
      ),
    );
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
    _lastMoveTime = DateTime.now();
  }
  
  void reset() {
    _resetForNewRole();
    _isSelected = false;
    _touchesMade = 0;
    _scoresMade = 0;
    _totalDistanceMoved = 0.0;
    _animationScale = 1.0;
    scale = Vector2.all(1.0);
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
    final shadowOffset = Offset(3, 3);
    canvas.drawCircle(shadowOffset, radius * _animationScale, _shadowPaint);
    
    // Draw team color background (larger circle)
    canvas.drawCircle(Offset.zero, radius * _animationScale * 1.1, _teamColorPaint);
    
    // Draw player body
    canvas.drawCircle(Offset.zero, radius * _animationScale, _playerPaint);
    
    // Draw outline berdasarkan status
    if (_isSelected || _isMoving || _currentRole == PlayerRole.guard) {
      _outlinePaint.strokeWidth = _isSelected ? 4.0 : 3.0;
      _outlinePaint.color = _getOutlineColor();
      canvas.drawCircle(Offset.zero, radius * _animationScale, _outlinePaint);
    }
    
    // Draw player elements
    _drawPlayerNumber(canvas);
    _drawRoleIndicator(canvas);
    
    // Draw movement trail untuk attackers
    if (GameSettings.showMovementTrails && _isMoving && _currentRole == PlayerRole.attacker) {
      _drawMovementTrail(canvas);
    }
    
    // Draw performance indicators
    if (_touchesMade > 0 || _scoresMade > 0) {
      _drawPerformanceIndicators(canvas);
    }
  }
  
  void _drawPlayerNumber(Canvas canvas) {
    final textPaint = TextPaint(
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            offset: const Offset(1, 1),
            blurRadius: 2,
            color: Colors.black.withOpacity(0.8),
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
    
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    if (_currentRole == PlayerRole.guard) {
      // Draw shield icon untuk guards
      indicatorPaint.color = Colors.orange;
      
      final shieldPath = Path();
      final centerX = radius - 8;
      final centerY = -radius + 8;
      
      shieldPath.moveTo(centerX, centerY - 6);
      shieldPath.lineTo(centerX - 4, centerY);
      shieldPath.lineTo(centerX, centerY + 6);
      shieldPath.lineTo(centerX + 4, centerY);
      shieldPath.close();
      
      canvas.drawPath(shieldPath, indicatorPaint);
      canvas.drawPath(shieldPath, strokePaint);
    } else {
      // Draw arrow icon untuk attackers
      indicatorPaint.color = Colors.lightGreen;
      
      final arrowPath = Path();
      final centerX = radius - 8;
      final centerY = -radius + 8;
      
      arrowPath.moveTo(centerX - 3, centerY + 3);
      arrowPath.lineTo(centerX + 3, centerY);
      arrowPath.lineTo(centerX - 3, centerY - 3);
      arrowPath.moveTo(centerX + 3, centerY);
      arrowPath.lineTo(centerX - 1, centerY);
      
      canvas.drawPath(arrowPath, Paint()
        ..color = Colors.lightGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0);
    }
  }
  
  void _drawMovementTrail(Canvas canvas) {
    if (_movementHistory.length < 2) return;
    
    final trailPaint = Paint()
      ..color = playerColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    
    final path = Path();
    bool firstPoint = true;
    
    for (final historyPoint in _movementHistory) {
      final localPoint = historyPoint - position;
      
      if (firstPoint) {
        path.moveTo(localPoint.x, localPoint.y);
        firstPoint = false;
      } else {
        path.lineTo(localPoint.x, localPoint.y);
      }
    }
    
    canvas.drawPath(path, trailPaint);
  }
  
  void _drawPerformanceIndicators(Canvas canvas) {
    if (_touchesMade > 0) {
      // Draw touch count untuk guards
      final touchPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(-radius + 5, radius - 5),
        6,
        touchPaint,
      );
      
      final textPaint = TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      );
      
      textPaint.render(
        canvas,
        '$_touchesMade',
        Vector2(-radius + 5, radius - 5),
        anchor: Anchor.center,
      );
    }
    
    if (_scoresMade > 0) {
      // Draw score count untuk attackers
      final scorePaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(radius - 5, radius - 5),
        6,
        scorePaint,
      );
      
      final textPaint = TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      );
      
      textPaint.render(
        canvas,
        '$_scoresMade',
        Vector2(radius - 5, radius - 5),
        anchor: Anchor.center,
      );
    }
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
    _touchesMade++;
    
    // Create touch effect
    add(
      ScaleEffect.by(
        Vector2.all(1.4),
        EffectController(
          duration: GameConstants.touchEffectDuration.inMilliseconds / 1000.0,
          reverseDuration: GameConstants.touchEffectDuration.inMilliseconds / 1000.0,
        ),
      ),
    );
    
    // Add color flash effect
    add(
      ColorEffect(
        Colors.yellow,
        EffectController(
          duration: GameConstants.touchEffectDuration.inMilliseconds / 1000.0,
        ),
      ),
    );
    
    print('Guard ${team.name}$playerId touched attacker ${attacker.team.name}${attacker.playerId} (Total touches: $_touchesMade)');
  }
  
  // Performance analytics
  Map<String, dynamic> getPlayerStats() {
    final playTime = _lastMoveTime != null 
        ? DateTime.now().difference(_lastMoveTime!).inMinutes 
        : 0;
    
    return {
      'playerId': playerId,
      'team': team.name,
      'role': _currentRole.name,
      'touchesMade': _touchesMade,
      'scoresMade': _scoresMade,
      'totalDistance': _totalDistanceMoved.toStringAsFixed(1),
      'playTime': playTime,
      'efficiency': _calculateEfficiency(),
    };
  }
  
  double _calculateEfficiency() {
    if (_currentRole == PlayerRole.guard) {
      return _touchesMade > 0 ? _touchesMade / (_totalDistanceMoved / 100) : 0.0;
    } else {
      return _scoresMade > 0 ? _scoresMade / (_totalDistanceMoved / 200) : 0.0;
    }
  }
}