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
  final double finishDistance = 4000.0;
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
    for (int i = 0; i < 60; i++) {
      obstacles.add(Obstacle(
        x: 200.0 + (i * 70.0) + Random().nextDouble() * 50,
        type: _getRandomObstacleType(),
      ));
    }
    
    gameTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      updateGame();
    });
  }

  ObstacleType _getRandomObstacleType() {
    // Batu dipersedikit - hanya 1 dari 8 kemungkinan
    List<ObstacleType> types = [
      ObstacleType.rock,    // 1x batu
      ObstacleType.log,     // 2x log
      ObstacleType.log,
      ObstacleType.hole,    // 2x hole
      ObstacleType.hole,
      ObstacleType.puddle,  // 3x puddle
      ObstacleType.puddle,
      ObstacleType.puddle,
    ];
    return types[Random().nextInt(types.length)];
  }

  void updateGame() {
    if (isGameWon) return;
    
    setState(() {
      double newPlayerX = playerX;
      
      // Manual movement dengan collision detection
      if (movingLeft && playerX > 50) {
        newPlayerX = playerX - moveSpeed;
        if (!_checkRockCollision(newPlayerX)) {
          playerX = newPlayerX;
        }
      }
      if (movingRight && playerX < finishDistance + 200) {
        newPlayerX = playerX + moveSpeed;
        if (!_checkRockCollision(newPlayerX)) {
          playerX = newPlayerX;
        }
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

  // Collision detection - hanya untuk batu dan saat tidak jumping
  bool _checkRockCollision(double newPlayerX) {
    if (isJumping || playerY < -10) return false;
    
    for (Obstacle obstacle in obstacles) {
      if (obstacle.type == ObstacleType.rock) {
        double obstacleLeft = obstacle.x - 18;   // batu width 36/2
        double obstacleRight = obstacle.x + 18;
        double playerLeft = newPlayerX - 25;     // player width/2
        double playerRight = newPlayerX + 25;
        
        if (playerRight > obstacleLeft && playerLeft < obstacleRight) {
          return true; // Ada collision dengan batu
        }
      }
    }
    return false;
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
              'Lomba egrang 4000 meter yang luar biasa!',
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
              Color(0xFF87CEEB),  // Sky blue
              Color(0xFFB0E0E6),  // Light sky blue
              Color(0xFF98FB98),  // Pale green
            ],
          ),
        ),
        child: Stack(
          children: [
            ClipRect(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: [
                    // Background elements dengan parallax yang cantik
                    ..._buildBackgroundElements(cameraOffset),
                    
                    // Ground
                    Positioned(
                      bottom: 0,
                      left: -cameraOffset,
                      child: Container(
                        width: finishDistance + screenWidth + 1000,
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
                        width: finishDistance + screenWidth + 1000,
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
            
            _buildUI(),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  // Ganti method _buildBackgroundElements dengan yang ini
List<Widget> _buildBackgroundElements(double cameraOffset) {
  List<Widget> elements = [];
  
  // Matahari dengan glow effect
  elements.add(
    Positioned(
      top: 40,
      left: 300 - cameraOffset * 0.05, // Parallax sangat lambat
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.orange[300],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    ),
  );

  // Awan cantik yang tidak kedip-kedip
  for (int i = 0; i < 15; i++) {
    elements.add(
      Positioned(
        top: 30 + (i % 3) * 25,
        left: (i * 180.0) - cameraOffset * 0.1, // Parallax lambat
        child: Container(
          width: 80 + (i % 3) * 25,
          height: 40 + (i % 2) * 15,
          child: CustomPaint(
            painter: CloudPainter(),
          ),
        ),
      ),
    );
  }

  // Gunung berlapis
  for (int i = 0; i < 12; i++) {
    elements.add(
      Positioned(
        bottom: 160,
        left: (i * 150.0) - cameraOffset * 0.2, // Parallax medium
        child: Container(
          width: 180,
          height: 100 + (i % 3) * 20,
          child: CustomPaint(
            painter: MountainPainter(
              color: i % 2 == 0 ? Color(0xFF4A5D23) : Color(0xFF5D6B2F),
            ),
          ),
        ),
      ),
    );
  }

  // Bukit-bukit hijau
  for (int i = 0; i < 20; i++) {
    elements.add(
      Positioned(
        bottom: 200,
        left: (i * 100.0) - cameraOffset * 0.15, // Parallax medium-slow
        child: Container(
          width: 120,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFF7FB069).withOpacity(0.7),
            borderRadius: BorderRadius.only(
              topLeft: Radius.elliptical(60, 50),
              topRight: Radius.elliptical(60, 50),
            ),
          ),
        ),
      ),
    );
  }

  // Pohon-pohon STATIS (background jauh - tidak bergerak sama sekali)
  double screenWidth = MediaQuery.of(context).size.width;
  double viewStart = cameraOffset - 200; // Mulai render pohon 200px sebelum masuk screen
  double viewEnd = cameraOffset + screenWidth + 200; // Stop render 200px setelah keluar screen
  
  for (int i = 0; i < 50; i++) {
    double treeX = i * 100.0 + (i % 3) * 30; // Posisi pohon tetap
    
    // Hanya render pohon yang terlihat di screen (untuk performa)
    if (treeX >= viewStart && treeX <= viewEnd) {
      elements.add(
        Positioned(
          bottom: 160,
          left: treeX - cameraOffset, // Pohon bergerak dengan kamera (parallax 1:1)
          child: _buildTree(i % 4),
        ),
      );
    }
  }

  // Pohon background (parallax lambat untuk kedalaman)
  for (int i = 0; i < 30; i++) {
    double treeX = i * 150.0;
    if (treeX >= viewStart && treeX <= viewEnd) {
      elements.add(
        Positioned(
          bottom: 180,
          left: treeX - cameraOffset * 0.3, // Parallax lambat untuk background
          child: Transform.scale(
            scale: 0.6, // Lebih kecil untuk efek kedalaman
            child: Opacity(
              opacity: 0.4, // Transparan untuk efek background
              child: _buildTree((i + 2) % 4),
            ),
          ),
        ),
      );
    }
  }

  // Burung terbang
  for (int i = 0; i < 8; i++) {
    elements.add(
      Positioned(
        top: 50 + (i % 2) * 30,
        left: (i * 250.0) - cameraOffset * 0.3, // Parallax medium-fast
        child: Container(
          width: 25,
          height: 12,
          child: CustomPaint(
            painter: BirdPainter(),
          ),
        ),
      ),
    );
  }
  
  return elements;
}

  Widget _buildTree(int type) {
    switch (type) {
      case 0:
        return Container(
          width: 25, height: 50,
          child: CustomPaint(painter: PineTreePainter()),
        );
      case 1:
        return Container(
          width: 30, height: 45,
          child: CustomPaint(painter: RoundTreePainter()),
        );
      case 2:
        return Container(
          width: 20, height: 55,
          child: CustomPaint(painter: TallTreePainter()),
        );
      default:
        return Container(
          width: 28, height: 48,
          child: CustomPaint(painter: BushTreePainter()),
        );
    }
  }

  double _getObstacleBottomPosition(ObstacleType type) {
    switch (type) {
      case ObstacleType.rock:
      case ObstacleType.log:
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
          width: 36,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF808080), Color(0xFF404040)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.4), width: 3),
            boxShadow: [
              BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(2, 2)),
              BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, spreadRadius: 3),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.warning,
              size: 18,
              color: Colors.red[400],
            ),
          ),
        );
      case ObstacleType.log:
        return Container(
          width: 40, height: 15,
          decoration: BoxDecoration(
            color: Color(0xFF8B4513),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 1))],
          ),
        );
      case ObstacleType.hole:
        return Container(
          width: 35, height: 20,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: Colors.brown, width: 2),
          ),
        );
      case ObstacleType.puddle:
        return Container(
          width: 45, height: 8,
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
                  'EGRANG RACE - 4KM',
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
                        'Progress: ${(progress * 100).toInt()}% (${(playerX).toInt()}m / 4000m)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '⚠️ Lompati batu merah untuk lewat!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.yellow[300],
                          fontWeight: FontWeight.w500,
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
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTapDown: (_) => startMovingLeft(),
                    onTapUp: (_) => stopMovingLeft(),
                    onTapCancel: () => stopMovingLeft(),
                    child: Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(
                        color: movingLeft ? Colors.blue[300] : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
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
                  GestureDetector(
                    onTapDown: (_) => startMovingRight(),
                    onTapUp: (_) => stopMovingRight(),
                    onTapCancel: () => stopMovingRight(),
                    child: Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(
                        color: movingRight ? Colors.blue[300] : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
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
            
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: jump,
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: isJumping ? Colors.orange[300] : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
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

// Custom Painters untuk background yang cantik
class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(Rect.fromLTWH(0, size.height * 0.3, size.width * 0.4, size.height * 0.6), paint);
    canvas.drawOval(Rect.fromLTWH(size.width * 0.2, size.height * 0.1, size.width * 0.5, size.height * 0.7), paint);
    canvas.drawOval(Rect.fromLTWH(size.width * 0.4, size.height * 0.2, size.width * 0.45, size.height * 0.6), paint);
    canvas.drawOval(Rect.fromLTWH(size.width * 0.6, size.height * 0.4, size.width * 0.4, size.height * 0.5), paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MountainPainter extends CustomPainter {
  final Color color;
  MountainPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width * 0.2, size.height * 0.3);
    path.lineTo(size.width * 0.5, size.height * 0.1);
    path.lineTo(size.width * 0.8, size.height * 0.4);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PineTreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final trunkPaint = Paint()..color = Color(0xFF8B4513);
    final leafPaint = Paint()..color = Color(0xFF228B22);
    
    canvas.drawRect(Rect.fromLTWH(size.width * 0.4, size.height * 0.6, size.width * 0.2, size.height * 0.4), trunkPaint);
    
    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width * 0.1, size.height * 0.7);
    path.lineTo(size.width * 0.9, size.height * 0.7);
    path.close();
    canvas.drawPath(path, leafPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RoundTreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final trunkPaint = Paint()..color = Color(0xFF8B4513);
    final leafPaint = Paint()..color = Color(0xFF32CD32);
    
    canvas.drawRect(Rect.fromLTWH(size.width * 0.4, size.height * 0.6, size.width * 0.2, size.height * 0.4), trunkPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.35), size.width * 0.4, leafPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TallTreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final trunkPaint = Paint()..color = Color(0xFF8B4513);
    final leafPaint = Paint()..color = Color(0xFF228B22);
    
    canvas.drawRect(Rect.fromLTWH(size.width * 0.4, size.height * 0.5, size.width * 0.2, size.height * 0.5), trunkPaint);
    canvas.drawOval(Rect.fromLTWH(size.width * 0.2, 0, size.width * 0.6, size.height * 0.6), leafPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BushTreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final leafPaint = Paint()..color = Color(0xFF90EE90);
    
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.7), size.width * 0.25, leafPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.8), size.width * 0.3, leafPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.5), size.width * 0.35, leafPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BirdPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final path1 = Path();
    path1.moveTo(size.width * 0.2, size.height * 0.3);
    path1.lineTo(size.width * 0.5, size.height * 0.7);
    
    final path2 = Path();
    path2.moveTo(size.width * 0.8, size.height * 0.3);
    path2.lineTo(size.width * 0.5, size.height * 0.7);
    
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
    paint.strokeWidth = 1;
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