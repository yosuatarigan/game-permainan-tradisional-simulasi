// File: lib/game/widgets/game_field.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../../utils/game_constants.dart';
import '../game_logic.dart';

class GameField extends StatelessWidget {
  final List<Player> players;
  final Size fieldSize;
  final Function(Player) onPlayerTouch;

  const GameField({
    super.key,
    required this.players,
    required this.fieldSize,
    required this.onPlayerTouch,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use full available space
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        
        return Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            color: GameColors.fieldBackground,
          ),
          child: CustomPaint(
            painter: FieldPainter(),
            child: Stack(
              children: [
                // Render all players with scaling to full screen
                ...players.map((player) {
                  // Scale player positions to fit actual screen size
                  final scaledPosition = Offset(
                    (player.position.dx / fieldSize.width) * width,
                    (player.position.dy / fieldSize.height) * height,
                  );
                  
                  return PlayerWidget(
                    key: ValueKey(player.id),
                    player: Player(
                      id: player.id,
                      team: player.team,
                      role: player.role,
                      position: scaledPosition,
                      isPlayerControlled: player.isPlayerControlled,
                      isMoving: player.isMoving,
                    ),
                    onTap: () => onPlayerTouch(player),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fieldPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final centerLinePaint = Paint()
      ..color = Colors.yellow.shade700
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    final boundaryPaint = Paint()
      ..color = Colors.red.shade700
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final goalAreaPaint = Paint()
      ..color = Colors.green.shade600
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Draw field background with subtle gradient
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          GameColors.fieldBackground,
          GameColors.fieldBackground.withOpacity(0.8),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Draw field border (thick)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      fieldPaint,
    );

    // Draw 6 sections (3x2 grid) with clearer lines
    final sectionWidth = size.width / 3;
    final sectionHeight = size.height / 2;

    // Vertical lines
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(i * sectionWidth, 0),
        Offset(i * sectionWidth, size.height),
        fieldPaint,
      );
    }

    // Horizontal center line (Garis Sodor) - THICK
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerLinePaint,
    );

    // Draw goal areas (top and bottom)
    final goalHeight = size.height * 0.15;
    
    // Top goal area (where attackers need to reach) - with fill
    final topGoalRect = Rect.fromLTWH(0, 0, size.width, goalHeight);
    canvas.drawRect(
      topGoalRect,
      Paint()..color = Colors.green.withOpacity(0.2),
    );
    canvas.drawRect(topGoalRect, goalAreaPaint..style = PaintingStyle.stroke);
    
    // Bottom starting area - with fill
    final bottomStartRect = Rect.fromLTWH(0, size.height - goalHeight, size.width, goalHeight);
    canvas.drawRect(
      bottomStartRect,
      Paint()..color = Colors.red.withOpacity(0.2),
    );
    canvas.drawRect(bottomStartRect, boundaryPaint..style = PaintingStyle.stroke);

    // Draw section numbers for clarity (adaptive size)
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final sectionNumberSize = (size.width * 0.08).clamp(16.0, 32.0);
    
    
    
    // Add "GARIS SODOR" label with better styling (adaptive size)
    final labelSize = (size.width * 0.025).clamp(10.0, 16.0);
    textPainter.text = TextSpan(
      text: 'GARIS SODOR',
      style: TextStyle(
        color: Colors.yellow.shade700,
        fontSize: labelSize,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.width * 0.02, size.height / 2 - (labelSize * 1.5)),
    );

    // Add goal labels (adaptive size)
    final goalLabelSize = (size.width * 0.02).clamp(8.0, 14.0);
    
    textPainter.text = TextSpan(
      text: '⚽ AREA TUJUAN',
      style: TextStyle(
        color: Colors.green.shade700,
        fontSize: goalLabelSize,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.02, size.height * 0.02));

    textPainter.text = TextSpan(
      text: '🏁 AREA START',
      style: TextStyle(
        color: Colors.red.shade700,
        fontSize: goalLabelSize,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.02, size.height - goalHeight + (goalLabelSize * 0.5)));
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Color color, double strokeWidth) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw arrow line
    canvas.drawLine(start, end, paint);

    // Draw arrowhead
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final arrowLength = strokeWidth * 5;
    final arrowAngle = 0.5;

    final arrowX1 = end.dx - arrowLength * cos(atan2(dy, dx) - arrowAngle);
    final arrowY1 = end.dy - arrowLength * sin(atan2(dy, dx) - arrowAngle);
    final arrowX2 = end.dx - arrowLength * cos(atan2(dy, dx) + arrowAngle);
    final arrowY2 = end.dy - arrowLength * sin(atan2(dy, dx) + arrowAngle);

    canvas.drawLine(end, Offset(arrowX1, arrowY1), paint);
    canvas.drawLine(end, Offset(arrowX2, arrowY2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PlayerWidget extends StatelessWidget {
  final Player player;
  final VoidCallback onTap;

  const PlayerWidget({
    super.key,
    required this.player,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAttacker = player.role == 'attacker';
    final controlColor = player.team == 'red' ? GameColors.teamAColor : GameColors.teamBColor;
    
    return Positioned(
      left: player.position.dx - 18, // Slightly larger for better visibility
      top: player.position.dy - 18,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Control indicator - thick white border for controlled players
            border: Border.all(
              color: player.isPlayerControlled ? Colors.white : Colors.transparent,
              width: player.isPlayerControlled ? 3 : 0,
            ),
            // Role indicator - different shadow for attackers vs guards
            boxShadow: [
              if (player.isMoving)
                BoxShadow(
                  color: controlColor.withOpacity(0.6),
                  blurRadius: player.isPlayerControlled ? 12 : 6,
                  offset: const Offset(0, 2),
                ),
              // Role shadow
              BoxShadow(
                color: isAttacker ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              children: [
                // Player image with role-based background
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: controlColor,
                    shape: BoxShape.circle,
                    // Role-based pattern
                    border: Border.all(
                      color: isAttacker ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Image.asset(
                    player.imagePath,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Enhanced fallback with role colors
                      return Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              controlColor,
                              controlColor.withOpacity(0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${player.id + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Player number overlay (bottom-right)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        '${(player.id % 5) + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // Control indicator (top-left)
                if (player.isPlayerControlled)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: controlColor, width: 1),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.control_camera,
                          color: controlColor,
                          size: 8,
                        ),
                      ),
                    ),
                  ),

                // Role indicator (top-right)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isAttacker ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Center(
                      child: Icon(
                        isAttacker ? Icons.arrow_upward : Icons.block,
                        color: Colors.white,
                        size: 6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}