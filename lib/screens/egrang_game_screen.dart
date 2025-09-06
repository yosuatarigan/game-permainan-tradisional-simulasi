import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

class EgrangRaceScreen extends StatefulWidget {
  @override
  _EgrangRaceScreenState createState() => _EgrangRaceScreenState();
}

class _EgrangRaceScreenState extends State<EgrangRaceScreen> {
  // Player position
  double playerX = 100.0;
  double playerY = 0.0; // 0 = ground, negative = jumping
  bool isJumping = false;
  
  // Game state
  double progress = 0.0;
  List<Obstacle> obstacles = [];
  Timer? gameTimer;
  final double finishDistance = 1000.0;
  bool isGameWon = false;
  
  // Movement state
  bool movingLeft = false;
  bool movingRight = false;
  double moveSpeed = 4.0;
  
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    startGame();
  }

  void startGame() {
    obstacles.clear();
    for (int i = 0; i < 15; i++) {
      obstacles.add(Obstacle(
        x: 200.0 + (i * 80.0) + Random().nextDouble() * 40,
        type: _getRandomObstacleType(),
      ));
    }
    
    gameTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      updateGame();
    });
  }

  ObstacleType _getRandomObstacleType() {
    List<ObstacleType> types = [
      ObstacleType.rock,
      ObstacleType.log,
      ObstacleType.hole,
      ObstacleType.puddle,
    ];
    return types[Random().nextInt(types.length)];
  }

  void updateGame() {
    if (isGameWon) return;
    
    setState(() {
      // Manual movement
      if (movingLeft && playerX > 50) {
        playerX -= moveSpeed;
      }
      if (movingRight && playerX < finishDistance + 100) {
        playerX += moveSpeed;
      }
      
      // Update progress
      progress = (playerX / finishDistance).clamp(0.0, 1.0);
      
      // Handle jumping
      if (isJumping) {
        playerY -= 4;
        if (playerY <= -60) {
          isJumping = false;
        }
      } else if (playerY < 0) {
        playerY += 5;
        if (playerY >= 0) {
          playerY = 0;
        }
      }
      
      // Check if reached finish line
      if (playerX >= finishDistance) {
        winGame();
      }
    });
  }

  void startMovingLeft() {
    movingLeft = true;
  }

  void stopMovingLeft() {
    movingLeft = false;
  }

  void startMovingRight() {
    movingRight = true;
  }

  void stopMovingRight() {
    movingRight = false;
  }

  void jump() {
    if (!isJumping && playerY >= 0) {
      setState(() {
        isJumping = true;
      });
    }
  }

  void winGame() {
    isGameWon = true;
    gameTimer?.cancel();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Selamat! 🎉',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'Kamu berhasil mencapai garis finish!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Permainan egrang yang luar biasa!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text('Kembali'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  resetGame();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text('Main Lagi'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      playerX = 100.0;
      playerY = 0.0;
      isJumping = false;
      progress = 0.0;
      isGameWon = false;
      movingLeft = false;
      movingRight = false;
      obstacles.clear();
    });
    startGame();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double cameraOffset = (playerX - screenWidth / 3).clamp(0.0, double.infinity);
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFF98FB98),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Game World
            ClipRect(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    // Clouds (fixed position, tidak ikut camera)
                    ...List.generate(25, (i) => 
                      Positioned(
                        top: 20 + (i % 4) * 30 + Random().nextDouble() * 20,
                        left: (i * 80.0) - cameraOffset * 0.3, // Parallax effect
                        child: _buildCloud(),
                      ),
                    ),
                    
                    // Ground dan Track (ikut camera movement)
                    Positioned(
                      bottom: 0,
                      left: -cameraOffset,
                      child: Container(
                        width: finishDistance + screenWidth + 500,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF228B22), Color(0xFF8B4513)],
                          ),
                        ),
                      ),
                    ),
                    
                    // Track
                    Positioned(
                      bottom: 80,
                      left: -cameraOffset,
                      child: Container(
                        width: finishDistance + screenWidth + 500,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(0xFFDEB887),
                          border: Border.symmetric(
                            horizontal: BorderSide(color: Colors.brown, width: 2),
                          ),
                        ),
                      ),
                    ),
                    
                    // Obstacles
                    ...obstacles.map((obstacle) => 
                      Positioned(
                        bottom: _getObstacleBottomPosition(obstacle.type),
                        left: obstacle.x - cameraOffset,
                        child: _buildObstacleWidget(obstacle.type),
                      ),
                    ).toList(),
                    
                    // Player
                    Positioned(
                      bottom: 120 - playerY,
                      left: playerX - cameraOffset - 25,
                      child: Container(
                        width: 50,
                        height: 80,
                        child: CustomPaint(
                          painter: EgrangPlayerPainter(),
                        ),
                      ),
                    ),
                    
                    // Finish line
                    Positioned(
                      bottom: 120,
                      left: finishDistance - cameraOffset,
                      child: Container(
                        width: 8,
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red, Colors.white, Colors.red, Colors.white],
                            stops: [0.0, 0.25, 0.5, 0.75],
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'FINISH',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // UI overlay
            _buildUI(),
            
            // Controls
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildCloud() {
    return Container(
      width: 50 + Random().nextDouble() * 30,
      height: 25 + Random().nextDouble() * 15,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  double _getObstacleBottomPosition(ObstacleType type) {
    switch (type) {
      case ObstacleType.rock:
        return 120;
      case ObstacleType.log:
        return 120;
      case ObstacleType.hole:
        return 120;
      case ObstacleType.puddle:
        return 80;
    }
  }

  Widget _buildObstacleWidget(ObstacleType type) {
    switch (type) {
      case ObstacleType.rock:
        return Container(
          width: 30,
          height: 25,
          decoration: BoxDecoration(
            color: Color(0xFF696969),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 1)),
            ],
          ),
        );
      case ObstacleType.log:
        return Container(
          width: 40,
          height: 15,
          decoration: BoxDecoration(
            color: Color(0xFF8B4513),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 1)),
            ],
          ),
        );
      case ObstacleType.hole:
        return Container(
          width: 35,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: Colors.brown, width: 2),
          ),
        );
      case ObstacleType.puddle:
        return Container(
          width: 45,
          height: 8,
          decoration: BoxDecoration(
            color: Color(0xFF4169E1).withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
        );
    }
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'EGRANG RACE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.black54),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress: ${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.green, Colors.yellow, Colors.red],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 20,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Kontrol kiri-kanan
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  // Tombol Kiri
                  GestureDetector(
                    onTapDown: (_) => startMovingLeft(),
                    onTapUp: (_) => stopMovingLeft(),
                    onTapCancel: () => stopMovingLeft(),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: movingLeft ? Colors.blue[300] : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_left,
                        size: 35,
                        color: movingLeft ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  // Tombol Kanan
                  GestureDetector(
                    onTapDown: (_) => startMovingRight(),
                    onTapUp: (_) => stopMovingRight(),
                    onTapCancel: () => stopMovingRight(),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: movingRight ? Colors.blue[300] : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_right,
                        size: 35,
                        color: movingRight ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Tombol Lompat
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: jump,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isJumping ? Colors.orange[300] : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.keyboard_arrow_up,
                        size: 35,
                        color: isJumping ? Colors.white : Colors.grey[700],
                      ),
                      Text(
                        'LOMPAT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isJumping ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Obstacle {
  double x;
  ObstacleType type;
  Obstacle({required this.x, required this.type});
}

enum ObstacleType { rock, log, hole, puddle }

class EgrangPlayerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Egrang sticks
    paint.color = Color(0xFFDEB887);
    paint.strokeWidth = 5;
    paint.strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(15, 30), Offset(12, 80), paint);
    canvas.drawLine(Offset(35, 30), Offset(38, 80), paint);
    
    // Body
    paint.color = Color(0xFFFF6B6B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(18, 12, 14, 18),
        Radius.circular(3),
      ),
      paint,
    );
    
    // Head
    paint.color = Color(0xFFFFDBB5);
    canvas.drawCircle(Offset(25, 8), 6, paint);
    
    // Hair
    paint.color = Color(0xFF4A4A4A);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(25, 8), radius: 6),
      -pi, pi, false, paint,
    );
    
    // Arms
    paint.color = Color(0xFFFFDBB5);
    paint.strokeWidth = 3;
    canvas.drawLine(Offset(15, 16), Offset(10, 28), paint);
    canvas.drawLine(Offset(35, 16), Offset(40, 28), paint);
    
    // Legs
    paint.color = Color(0xFF4169E1);
    paint.strokeWidth = 4;
    canvas.drawLine(Offset(20, 30), Offset(15, 45), paint);
    canvas.drawLine(Offset(30, 30), Offset(35, 45), paint);
    
    // Foot platforms
    paint.color = Color(0xFF8B4513);
    canvas.drawRect(Rect.fromLTWH(8, 40, 12, 3), paint);
    canvas.drawRect(Rect.fromLTWH(30, 40, 12, 3), paint);
    
    // Shoes
    paint.color = Color(0xFF000000);
    canvas.drawOval(Rect.fromLTWH(10, 38, 8, 5), paint);
    canvas.drawOval(Rect.fromLTWH(32, 38, 8, 5), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}