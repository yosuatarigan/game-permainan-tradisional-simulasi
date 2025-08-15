// File: lib/game/widgets/game_field.dart
import 'package:flutter/material.dart';
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
    return Container(
      width: fieldSize.width,
      height: fieldSize.height,
      decoration: const BoxDecoration(
        color: GameColors.fieldBackground,
      ),
      child: CustomPaint(
        painter: FieldPainter(),
        child: Stack(
          children: [
            // Render all players
            ...players.map((player) => PlayerWidget(
              key: ValueKey(player.id),
              player: player,
              onTap: () => onPlayerTouch(player),
            )),
          ],
        ),
      ),
    );
  }
}

class FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final centerLinePaint = Paint()
      ..color = Colors.yellow.shade700
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    // Draw field border
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );

    // Draw 6 sections (3x2 grid)
    final sectionWidth = size.width / 3;
    final sectionHeight = size.height / 2;

    // Vertical lines
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(i * sectionWidth, 0),
        Offset(i * sectionWidth, size.height),
        paint,
      );
    }

    // Horizontal center line (Garis Sodor)
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerLinePaint,
    );

    // Draw section labels (optional)
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Add "GARIS SODOR" label
    textPainter.text = TextSpan(
      text: 'SODOR',
      style: TextStyle(
        color: Colors.yellow.shade700,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(10, size.height / 2 - 20),
    );
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
    return Positioned(
      left: player.position.dx - 15, // Center the player
      top: player.position.dy - 15,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: player.isPlayerControlled ? Colors.white : Colors.transparent,
              width: player.isPlayerControlled ? 2 : 0,
            ),
            boxShadow: [
              if (player.isMoving)
                BoxShadow(
                  color: player.team == 'red' 
                      ? GameColors.teamAColor.withOpacity(0.5)
                      : GameColors.teamBColor.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              children: [
                // Player image
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: player.team == 'red' 
                        ? GameColors.teamAColor 
                        : GameColors.teamBColor,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    player.imagePath,
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if image not found
                      return Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: player.team == 'red' 
                              ? GameColors.teamAColor 
                              : GameColors.teamBColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${player.id + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Player number overlay
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
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

                // Role indicator
                if (player.isPlayerControlled)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
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