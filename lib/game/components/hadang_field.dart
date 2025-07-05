// File: lib/game/components/hadang_field.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../utils/game_constants.dart';

class HadangField extends Component {
  // Calculated field dimensions for screen (menggunakan spesifikasi resmi)
  late double fieldWidth;
  late double fieldHeight;
  late double sectionWidth;
  late double sectionHeight;
  late Rect fieldRect;
  
  // Field lines (sesuai aturan resmi Hadang)
  final List<GuardLine> horizontalLines = [];
  late GuardLine centerLine;
  final List<Vector2> fieldCorners = [];
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _calculateFieldDimensions();
    _createFieldLines();
  }
  
  void _calculateFieldDimensions() {
    // Calculate field size menggunakan konstanta resmi (15m x 9m)
    final gameSize = (parent as PositionComponent?)?.size ?? Vector2(800, 600);
    
    // Maintain aspect ratio sesuai aturan resmi: 15:9
    final aspectRatio = GameConstants.fieldRealWidth / GameConstants.fieldRealHeight;
    final availableWidth = gameSize.x - (GameConstants.fieldPadding * 2);
    final availableHeight = gameSize.y - (GameConstants.fieldPadding * 2);
    
    if (availableWidth / aspectRatio <= availableHeight) {
      fieldWidth = availableWidth;
      fieldHeight = fieldWidth / aspectRatio;
    } else {
      fieldHeight = availableHeight;
      fieldWidth = fieldHeight * aspectRatio;
    }
    
    // Setiap section: 4.5m x 5m -> 3 kolom (4.5m each), 2 baris (5m each)
    sectionWidth = fieldWidth / 3;  // 3 kolom
    sectionHeight = fieldHeight / 2; // 2 baris
    
    // Center the field
    final fieldX = (gameSize.x - fieldWidth) / 2;
    final fieldY = (gameSize.y - fieldHeight) / 2;
    
    fieldRect = Rect.fromLTWH(fieldX, fieldY, fieldWidth, fieldHeight);
    
    // Store field corners
    fieldCorners.clear();
    fieldCorners.addAll([
      Vector2(fieldRect.left, fieldRect.top),     // Top-left
      Vector2(fieldRect.right, fieldRect.top),    // Top-right
      Vector2(fieldRect.right, fieldRect.bottom), // Bottom-right
      Vector2(fieldRect.left, fieldRect.bottom),  // Bottom-left
    ]);
  }
  
  void _createFieldLines() {
    horizontalLines.clear();
    
    // Create 4 horizontal guard lines (sesuai aturan: 4 penjaga horizontal + 1 tengah)
    for (int i = 1; i <= 4; i++) {
      final y = fieldRect.top + (i * sectionHeight / 2);
      final line = GuardLine(
        start: Vector2(fieldRect.left, y),
        end: Vector2(fieldRect.right, y),
        lineType: GuardLineType.horizontal,
        lineIndex: i - 1,
      );
      horizontalLines.add(line);
    }
    
    // Create center vertical guard line (sodor line)
    centerLine = GuardLine(
      start: Vector2(fieldRect.center.dx, fieldRect.top),
      end: Vector2(fieldRect.center.dx, fieldRect.bottom),
      lineType: GuardLineType.vertical,
      lineIndex: 0,
    );
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    _drawFieldBackground(canvas);
    _drawFieldBorder(canvas);
    _drawSectionLines(canvas);
    _drawGuardLines(canvas);
    _drawFieldMarkings(canvas);
    _drawStartFinishAreas(canvas);
  }
  
  void _drawFieldBackground(Canvas canvas) {
    final paint = Paint()
      ..color = GameColors.fieldBackground
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(fieldRect, paint);
    
    // Add alternating pattern untuk visual appeal
    _drawAlternatingPattern(canvas);
  }
  
  void _drawAlternatingPattern(Canvas canvas) {
    final paint = Paint()
      ..color = GameColors.fieldAlternate
      ..style = PaintingStyle.fill;
    
    // Draw alternating rectangles (pola catur)
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 2; j++) {
        if ((i + j) % 2 == 0) {
          final rect = Rect.fromLTWH(
            fieldRect.left + (i * sectionWidth),
            fieldRect.top + (j * sectionHeight),
            sectionWidth,
            sectionHeight,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }
  }
  
  void _drawFieldBorder(Canvas canvas) {
    final paint = Paint()
      ..color = GameColors.fieldBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    
    canvas.drawRect(fieldRect, paint);
    
    // Draw corner markers
    _drawCornerMarkers(canvas);
  }
  
  void _drawCornerMarkers(Canvas canvas) {
    final paint = Paint()
      ..color = GameColors.fieldBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    const markerSize = 15.0;
    
    for (final corner in fieldCorners) {
      // Draw L-shaped corner markers
      canvas.drawLine(
        Offset(corner.x - markerSize, corner.y),
        Offset(corner.x + markerSize, corner.y),
        paint,
      );
      canvas.drawLine(
        Offset(corner.x, corner.y - markerSize),
        Offset(corner.x, corner.y + markerSize),
        paint,
      );
    }
  }
  
  void _drawSectionLines(Canvas canvas) {
    final paint = Paint()
      ..color = GameColors.fieldBorder.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Vertical section dividers
    for (int i = 1; i < 3; i++) {
      final x = fieldRect.left + (i * sectionWidth);
      canvas.drawLine(
        Offset(x, fieldRect.top),
        Offset(x, fieldRect.bottom),
        paint,
      );
    }
    
    // Horizontal section divider (center line)
    canvas.drawLine(
      Offset(fieldRect.left, fieldRect.center.dy),
      Offset(fieldRect.right, fieldRect.center.dy),
      paint,
    );
  }
  
  void _drawGuardLines(Canvas canvas) {
    // Draw horizontal guard lines (penjaga horizontal)
    final horizontalPaint = Paint()
      ..color = GameColors.guardLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    
    for (final line in horizontalLines) {
      canvas.drawLine(
        Offset(line.start.x, line.start.y),
        Offset(line.end.x, line.end.y),
        horizontalPaint,
      );
      
      // Draw guard position indicators
      _drawGuardPositionMarker(canvas, line);
    }
    
    // Draw center guard line (sodor) dengan warna berbeda
    final centerPaint = Paint()
      ..color = GameColors.centerLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    
    canvas.drawLine(
      Offset(centerLine.start.x, centerLine.start.y),
      Offset(centerLine.end.x, centerLine.end.y),
      centerPaint,
    );
    
    _drawGuardPositionMarker(canvas, centerLine);
  }
  
  void _drawGuardPositionMarker(Canvas canvas, GuardLine line) {
    final isHorizontal = line.lineType == GuardLineType.horizontal;
    final paint = Paint()
      ..color = isHorizontal ? GameColors.guardLine : GameColors.centerLine
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    if (isHorizontal) {
      // Draw circle at center of horizontal line
      final center = Vector2(
        (line.start.x + line.end.x) / 2,
        line.start.y,
      );
      canvas.drawCircle(Offset(center.x, center.y), 10, paint);
      canvas.drawCircle(Offset(center.x, center.y), 10, strokePaint);
    } else {
      // Draw circle at center of vertical line (sodor)
      final center = Vector2(
        line.start.x,
        (line.start.y + line.end.y) / 2,
      );
      canvas.drawCircle(Offset(center.x, center.y), 12, paint);
      canvas.drawCircle(Offset(center.x, center.y), 12, strokePaint);
      
      // Draw special sodor marker (diamond shape)
      _drawSodorMarker(canvas, center);
    }
  }
  
  void _drawSodorMarker(Canvas canvas, Vector2 center) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final path = Path();
    const size = 6.0;
    
    path.moveTo(center.x, center.y - size);
    path.lineTo(center.x + size, center.y);
    path.lineTo(center.x, center.y + size);
    path.lineTo(center.x - size, center.y);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  void _drawFieldMarkings(Canvas canvas) {
    final textPaint = TextPaint(
      style: TextStyle(
        color: GameColors.fieldBorder,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            offset: const Offset(1, 1),
            blurRadius: 2,
            color: Colors.black.withOpacity(0.3),
          ),
        ],
      ),
    );
    
    // Draw section numbers (1-6)
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 2; j++) {
        final sectionNumber = (j * 3) + i + 1;
        final position = Vector2(
          fieldRect.left + (i * sectionWidth) + (sectionWidth / 2),
          fieldRect.top + (j * sectionHeight) + (sectionHeight / 2),
        );
        
        // Draw section background circle
        final bgPaint = Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(Offset(position.x, position.y), 18, bgPaint);
        
        textPaint.render(
          canvas,
          '$sectionNumber',
          position,
          anchor: Anchor.center,
        );
      }
    }
    
    // Draw field title
    _drawFieldTitle(canvas);
  }
  
  void _drawFieldTitle(Canvas canvas) {
    final titlePaint = TextPaint(
      style: TextStyle(
        color: GameColors.primaryGreen,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            offset: const Offset(2, 2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.3),
          ),
        ],
      ),
    );
    
    titlePaint.render(
      canvas,
      GameTexts.appTitle.toUpperCase(),
      Vector2(fieldRect.center.dx, fieldRect.top - 30),
      anchor: Anchor.center,
    );
  }
  
  void _drawStartFinishAreas(Canvas canvas) {
    final startPaint = Paint()
      ..color = GameColors.successColor
      ..style = PaintingStyle.fill;
    
    final finishPaint = Paint()
      ..color = GameColors.errorColor
      ..style = PaintingStyle.fill;
    
    final textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    
    // Start area (top) - tempat attacker mulai
    final startRect = Rect.fromLTWH(
      fieldRect.left,
      fieldRect.top - 25,
      fieldRect.width,
      20,
    );
    canvas.drawRect(startRect, startPaint);
    textPaint.render(
      canvas,
      'START',
      Vector2(fieldRect.center.dx, fieldRect.top - 15),
      anchor: Anchor.center,
    );
    
    // Finish area (bottom) - tempat attacker selesai
    final finishRect = Rect.fromLTWH(
      fieldRect.left,
      fieldRect.bottom + 5,
      fieldRect.width,
      20,
    );
    canvas.drawRect(finishRect, finishPaint);
    textPaint.render(
      canvas,
      'FINISH',
      Vector2(fieldRect.center.dx, fieldRect.bottom + 15),
      anchor: Anchor.center,
    );
  }
  
  // Helper methods untuk game logic
  bool isPointInField(Vector2 point) {
    return fieldRect.contains(Offset(point.x, point.y));
  }
  
  bool isPointOnSideLine(Vector2 point, {double tolerance = GameConstants.guardLineTolerrance}) {
    return (point.x <= fieldRect.left + tolerance || 
            point.x >= fieldRect.right - tolerance) &&
           point.y >= fieldRect.top && 
           point.y <= fieldRect.bottom;
  }
  
  bool isPointInStartArea(Vector2 point) {
    return point.y <= fieldRect.top && 
           point.x >= fieldRect.left && 
           point.x <= fieldRect.right;
  }
  
  bool isPointInFinishArea(Vector2 point) {
    return point.y >= fieldRect.bottom && 
           point.x >= fieldRect.left && 
           point.x <= fieldRect.right;
  }
  
  int getSectionAtPoint(Vector2 point) {
    if (!isPointInField(point)) return -1;
    
    final relativeX = point.x - fieldRect.left;
    final relativeY = point.y - fieldRect.top;
    
    final sectionX = (relativeX / sectionWidth).floor().clamp(0, 2);
    final sectionY = (relativeY / sectionHeight).floor().clamp(0, 1);
    
    return sectionY * 3 + sectionX + 1;
  }
  
  Vector2 getSectionCenter(int sectionNumber) {
    if (sectionNumber < 1 || sectionNumber > GameConstants.sectionsCount) {
      return Vector2.zero();
    }
    
    final sectionIndex = sectionNumber - 1;
    final sectionX = sectionIndex % 3;
    final sectionY = sectionIndex ~/ 3;
    
    return Vector2(
      fieldRect.left + (sectionX * sectionWidth) + (sectionWidth / 2),
      fieldRect.top + (sectionY * sectionHeight) + (sectionHeight / 2),
    );
  }
  
  // Get random position dalam section tertentu
  Vector2 getRandomPositionInSection(int sectionNumber) {
    if (sectionNumber < 1 || sectionNumber > GameConstants.sectionsCount) {
      return Vector2.zero();
    }
    
    final sectionIndex = sectionNumber - 1;
    final sectionX = sectionIndex % 3;
    final sectionY = sectionIndex ~/ 3;
    
    final random = math.Random();
    return Vector2(
      fieldRect.left + (sectionX * sectionWidth) + (random.nextDouble() * sectionWidth),
      fieldRect.top + (sectionY * sectionHeight) + (random.nextDouble() * sectionHeight),
    );
  }
  
  // Mendapatkan jarak terdekat ke guard line
  double getDistanceToNearestGuardLine(Vector2 point) {
    double minDistance = double.infinity;
    
    for (final line in horizontalLines) {
      final distance = (point.y - line.start.y).abs();
      minDistance = math.min(minDistance, distance);
    }
    
    // Check center line
    final centerDistance = (point.x - centerLine.start.x).abs();
    minDistance = math.min(minDistance, centerDistance);
    
    return minDistance;
  }
  
  // Check apakah point dekat dengan guard line
  bool isNearGuardLine(Vector2 point, {double tolerance = GameConstants.touchDetectionRadius}) {
    return getDistanceToNearestGuardLine(point) <= tolerance;
  }
}

class GuardLine {
  final Vector2 start;
  final Vector2 end;
  final GuardLineType lineType;
  final int lineIndex;
  
  GuardLine({
    required this.start,
    required this.end,
    required this.lineType,
    required this.lineIndex,
  });
  
  double get length => start.distanceTo(end);
  
  Vector2 get center => Vector2(
    (start.x + end.x) / 2,
    (start.y + end.y) / 2,
  );
  
  bool isPointOnLine(Vector2 point, {double tolerance = GameConstants.guardLineTolerrance}) {
    if (lineType == GuardLineType.horizontal) {
      return (point.y - start.y).abs() <= tolerance &&
             point.x >= start.x && point.x <= end.x;
    } else {
      return (point.x - start.x).abs() <= tolerance &&
             point.y >= start.y && point.y <= end.y;
    }
  }
  
  Vector2 getClosestPointOnLine(Vector2 point) {
    if (lineType == GuardLineType.horizontal) {
      return Vector2(
        math.max(start.x, math.min(end.x, point.x)),
        start.y,
      );
    } else {
      return Vector2(
        start.x,
        math.max(start.y, math.min(end.y, point.y)),
      );
    }
  }
  
  bool canGuardReach(Vector2 guardPosition, Vector2 targetPosition) {
    final closestPoint = getClosestPointOnLine(targetPosition);
    final maxReach = GameConstants.touchDetectionRadius;
    
    return guardPosition.distanceTo(closestPoint) <= maxReach;
  }
  
  // Get direction vector untuk line ini
  Vector2 getDirection() {
    return (end - start).normalized();
  }
  
  // Get perpendicular vector (untuk collision detection)
  Vector2 getPerpendicular() {
    final dir = getDirection();
    return Vector2(-dir.y, dir.x);
  }
}

enum GuardLineType {
  horizontal,
  vertical
}