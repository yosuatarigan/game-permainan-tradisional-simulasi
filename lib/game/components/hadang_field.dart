// File: lib/game/components/hadang_field.dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class HadangField extends Component {
  // Field dimensions (sesuai aturan resmi: 15m x 9m)
  static const double fieldRealWidth = 15.0;  // 15 meter
  static const double fieldRealHeight = 9.0;  // 9 meter
  static const double lineWidth = 0.05;       // 5 cm
  static const int sectionsCount = 6;
  
  // Calculated field dimensions for screen
  late double fieldWidth;
  late double fieldHeight;
  late double sectionWidth;
  late double sectionHeight;
  late Rect fieldRect;
  
  // Field lines
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
    // Calculate field size to fit screen with padding
    final gameSize = (parent as PositionComponent?)?.size ?? Vector2(800, 600);
    final padding = 60.0;
    
    // Maintain aspect ratio of 15:9
    final availableWidth = gameSize.x - (padding * 2);
    final availableHeight = gameSize.y - (padding * 2);
    
    final aspectRatio = fieldRealWidth / fieldRealHeight;
    
    if (availableWidth / aspectRatio <= availableHeight) {
      fieldWidth = availableWidth;
      fieldHeight = fieldWidth / aspectRatio;
    } else {
      fieldHeight = availableHeight;
      fieldWidth = fieldHeight * aspectRatio;
    }
    
    // Each section: 4.5m x 5m -> 3 sections horizontal (4.5m each), 2 vertical (5m each)
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
  }
  
  void _drawFieldBackground(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.green.shade100
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(fieldRect, paint);
    
    // Add field texture/pattern
    _drawGrassPattern(canvas);
  }
  
  void _drawGrassPattern(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.green.shade50
      ..style = PaintingStyle.fill;
    
    // Draw alternating rectangles for grass pattern
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
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    
    canvas.drawRect(fieldRect, paint);
  }
  
  void _drawSectionLines(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
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
    // Draw horizontal guard lines
    final horizontalPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    for (final line in horizontalLines) {
      canvas.drawLine(
        Offset(line.start.x, line.start.y),
        Offset(line.end.x, line.end.y),
        horizontalPaint,
      );
      
      // Draw guard position indicators
      _drawGuardPositionMarker(canvas, line);
    }
    
    // Draw center guard line (sodor)
    final centerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    
    canvas.drawLine(
      Offset(centerLine.start.x, centerLine.start.y),
      Offset(centerLine.end.x, centerLine.end.y),
      centerPaint,
    );
    
    _drawGuardPositionMarker(canvas, centerLine);
  }
  
  void _drawGuardPositionMarker(Canvas canvas, GuardLine line) {
    final paint = Paint()
      ..color = line.lineType == GuardLineType.horizontal ? Colors.red : Colors.blue
      ..style = PaintingStyle.fill;
    
    if (line.lineType == GuardLineType.horizontal) {
      // Draw circle at center of horizontal line
      final center = Vector2(
        (line.start.x + line.end.x) / 2,
        line.start.y,
      );
      canvas.drawCircle(Offset(center.x, center.y), 8, paint);
    } else {
      // Draw circle at center of vertical line
      final center = Vector2(
        line.start.x,
        (line.start.y + line.end.y) / 2,
      );
      canvas.drawCircle(Offset(center.x, center.y), 8, paint);
    }
  }
  
  void _drawFieldMarkings(Canvas canvas) {
    final textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    
    // Draw section labels
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 2; j++) {
        final sectionNumber = (j * 3) + i + 1;
        final position = Vector2(
          fieldRect.left + (i * sectionWidth) + (sectionWidth / 2),
          fieldRect.top + (j * sectionHeight) + (sectionHeight / 2),
        );
        
        textPaint.render(
          canvas,
          '$sectionNumber',
          position,
          anchor: Anchor.center,
        );
      }
    }
    
    // Draw start and finish markers
    _drawStartFinishMarkers(canvas);
  }
  
  void _drawStartFinishMarkers(Canvas canvas) {
    final startPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    
    final finishPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    final textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
    
    // Start area (top)
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
    
    // Finish area (bottom)
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
  
  // Helper methods for game logic
  bool isPointInField(Vector2 point) {
    return fieldRect.contains(Offset(point.x, point.y));
  }
  
  bool isPointOnSideLine(Vector2 point, {double tolerance = 10.0}) {
    return (point.x <= fieldRect.left + tolerance || 
            point.x >= fieldRect.right - tolerance) &&
           point.y >= fieldRect.top && 
           point.y <= fieldRect.bottom;
  }
  
  int getSectionAtPoint(Vector2 point) {
    if (!isPointInField(point)) return -1;
    
    final relativeX = point.x - fieldRect.left;
    final relativeY = point.y - fieldRect.top;
    
    final sectionX = (relativeX / sectionWidth).floor();
    final sectionY = (relativeY / sectionHeight).floor();
    
    return sectionY * 3 + sectionX + 1;
  }
  
  Vector2 getSectionCenter(int sectionNumber) {
    if (sectionNumber < 1 || sectionNumber > 6) {
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
  
  bool isPointOnLine(Vector2 point, {double tolerance = 15.0}) {
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
}

enum GuardLineType {
  horizontal,
  vertical
}