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
  double jumpVelocity = 0.0; // Untuk physics yang lebih natural
  
  // Animation variables
  double stepAnimation = 0.0;
  double stepSpeed = 0.12;
  bool isMoving = false;
  
  // Game state
  double progress = 0.0;
  List<Obstacle> obstacles = [];
  Timer? gameTimer;
  final double finishDistance = 4000.0;
  bool isGameWon = false;
  
  // Movement state - speed dinaikkan
  bool movingLeft = false;
  bool movingRight = false;
  double moveSpeed = 6.0; // Dinaikkan dari 4.0 ke 6.0
  
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
    // Spacing diperbesar dan variasi lebih baik
    for (int i = 0; i < 50; i++) {
      obstacles.add(Obstacle(
        x: 300.0 + (i * 85.0) + Random().nextDouble() * 30, // Spacing lebih besar
        type: _getRandomObstacleType(),
      ));
    }
    
    gameTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      updateGame();
    });
  }

  ObstacleType _getRandomObstacleType() {
    // Balancing: lebih sedikit obstacle berbahaya di awal
    List<ObstacleType> types = [
      ObstacleType.log,         // Mudah - bisa injak
      ObstacleType.puddle,      // Mudah - hanya melambat
      ObstacleType.rock,        // Medium - harus lompat
      ObstacleType.hole,        // Medium - harus lompat
      ObstacleType.mudPit,      // Medium - melambat banyak
      ObstacleType.narrowBridge, // Medium - melambat
      ObstacleType.spike,       // Hard - harus lompat tinggi
      ObstacleType.platform,    // Hard - harus lompat tinggi
      ObstacleType.lowBarrier,  // Medium - timing
      ObstacleType.ramp,        // Easy - naik turun
    ];
    return types[Random().nextInt(types.length)];
  }

  void updateGame() {
    if (isGameWon) return;
    
    setState(() {
      double newPlayerX = playerX;
      isMoving = false;
      
      double currentMoveSpeed = _getCurrentMoveSpeed();
      
      // Movement dengan collision yang lebih akurat
      if (movingLeft && playerX > 50) {
        newPlayerX = playerX - currentMoveSpeed;
        if (!_checkObstacleCollision(newPlayerX)) {
          playerX = newPlayerX;
          isMoving = true;
        }
      }
      if (movingRight && playerX < finishDistance + 200) {
        newPlayerX = playerX + currentMoveSpeed;
        if (!_checkObstacleCollision(newPlayerX)) {
          playerX = newPlayerX;
          isMoving = true;
        }
      }
      
      // Step animation
      if (isMoving && !isJumping && playerY >= 0) {
        stepAnimation += stepSpeed;
        if (stepAnimation >= 2 * pi) {
          stepAnimation = 0;
        }
      }
      
      progress = (playerX / finishDistance).clamp(0.0, 1.0);
      
      // Improved jumping physics
      if (isJumping) {
        playerY += jumpVelocity;
        jumpVelocity += 0.8; // Gravity
        
        if (playerY >= 0) {
          playerY = 0;
          jumpVelocity = 0;
          isJumping = false;
        }
      }
      
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
        jumpVelocity = -12.0; // Jump strength dinaikkan dari 4 ke 12
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
      jumpVelocity = 0.0;
      progress = 0.0;
      isGameWon = false;
      movingLeft = false;
      movingRight = false;
      stepAnimation = 0.0;
      isMoving = false;
      obstacles.clear();
    });
    startGame();
  }

  double _getCurrentMoveSpeed() {
    double currentSpeed = moveSpeed;
    
    for (Obstacle obstacle in obstacles) {
      double distance = (obstacle.x - playerX).abs();
      
      if (distance < 25) { // Reduced from 30 to 25
        switch (obstacle.type) {
          case ObstacleType.puddle:
            currentSpeed *= 0.8; // Less penalty: 20% slower instead of 30%
            break;
          case ObstacleType.mudPit:
            currentSpeed *= 0.6; // Less penalty: 40% slower instead of 60%
            break;
          case ObstacleType.narrowBridge:
            currentSpeed *= 0.7; // Less penalty: 30% slower instead of 40%
            break;
          default:
            break;
        }
      }
    }
    
    return currentSpeed;
  }

  // Collision detection yang lebih akurat dan permisif
  bool _checkObstacleCollision(double newPlayerX) {
    if (isJumping && playerY < -30) { // Lebih mudah melewati saat jump tinggi
      return _checkHighObstacleCollision(newPlayerX);
    }
    
    for (Obstacle obstacle in obstacles) {
      double obstacleLeft = obstacle.x - _getObstacleWidth(obstacle.type) / 2;
      double obstacleRight = obstacle.x + _getObstacleWidth(obstacle.type) / 2;
      
      // Hitbox player diperkecil: dari 25 ke 18
      double playerLeft = newPlayerX - 18;
      double playerRight = newPlayerX + 18;
      
      if (playerRight > obstacleLeft && playerLeft < obstacleRight) {
        switch (obstacle.type) {
          case ObstacleType.rock:
          case ObstacleType.spike:
          case ObstacleType.lowBarrier:
          case ObstacleType.hole:
            // Hanya blok jika tidak jump cukup tinggi
            return !(isJumping && playerY < -20);
          case ObstacleType.platform:
            // Platform hanya blok jika tidak jump sangat tinggi  
            return !(isJumping && playerY < -40);
          case ObstacleType.log:
          case ObstacleType.puddle:
          case ObstacleType.mudPit:
          case ObstacleType.ramp:
          case ObstacleType.narrowBridge:
            return false; // Selalu bisa lewat
        }
      }
    }
    return false;
  }

  bool _checkHighObstacleCollision(double newPlayerX) {
    for (Obstacle obstacle in obstacles) {
      if (_isHighObstacle(obstacle.type)) {
        double obstacleLeft = obstacle.x - _getObstacleWidth(obstacle.type) / 2;
        double obstacleRight = obstacle.x + _getObstacleWidth(obstacle.type) / 2;
        double playerLeft = newPlayerX - 18; // Diperkecil dari 25
        double playerRight = newPlayerX + 18;
        
        if (playerRight > obstacleLeft && playerLeft < obstacleRight) {
          return playerY > -50; // Hanya blok jika tidak jump sangat tinggi
        }
      }
    }
    return false;
  }

  bool _isHighObstacle(ObstacleType type) {
    return type == ObstacleType.platform;
  }

  // Width obstacle diperkecil untuk lebih mudah dilewati
  double _getObstacleWidth(ObstacleType type) {
    switch (type) {
      case ObstacleType.rock: 
        return 28; // Diperkecil dari 36
      case ObstacleType.log: 
        return 32; // Diperkecil dari 40
      case ObstacleType.hole: 
        return 30; // Diperkecil dari 35
      case ObstacleType.puddle: 
        return 35; // Diperkecil dari 45
      case ObstacleType.spike: 
        return 25; // Diperkecil dari 30
      case ObstacleType.platform: 
        return 50; // Diperkecil dari 60
      case ObstacleType.lowBarrier: 
        return 40; // Diperkecil dari 50
      case ObstacleType.mudPit: 
        return 55; // Diperkecil dari 70
      case ObstacleType.ramp: 
        return 65; // Diperkecil dari 80
      case ObstacleType.narrowBridge: 
        return 20; // Diperkecil dari 25
    }
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
              Color(0xFF87CEEB),
              Color(0xFFB0E0E6),
              Color(0xFF98FB98),
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
                    
                    // Obstacles dengan visual feedback yang lebih jelas
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
                      child: Transform.scale(
                        scaleX: movingLeft ? -1 : 1,
                        child: Container(
                          width: 50,
                          height: 80,
                          child: CustomPaint(
                            painter: EgrangPlayerPainter(
                              stepAnimation: stepAnimation,
                              isMoving: isMoving,
                            ),
                          ),
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

  List<Widget> _buildBackgroundElements(double cameraOffset) {
    List<Widget> elements = [];
    
    // Matahari dengan glow effect
    elements.add(
      Positioned(
        top: 40,
        left: 300 - cameraOffset * 0.05,
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

    // Awan cantik
    for (int i = 0; i < 15; i++) {
      elements.add(
        Positioned(
          top: 30 + (i % 3) * 25,
          left: (i * 180.0) - cameraOffset * 0.1,
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
          left: (i * 150.0) - cameraOffset * 0.2,
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
          left: (i * 100.0) - cameraOffset * 0.15,
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

    // Pohon-pohon
    double screenWidth = MediaQuery.of(context).size.width;
    double viewStart = cameraOffset - 200;
    double viewEnd = cameraOffset + screenWidth + 200;
    
    for (int i = 0; i < 50; i++) {
      double treeX = i * 100.0 + (i % 3) * 30;
      
      if (treeX >= viewStart && treeX <= viewEnd) {
        elements.add(
          Positioned(
            bottom: 160,
            left: treeX - cameraOffset,
            child: _buildTree(i % 4),
          ),
        );
      }
    }

    // Pohon background (parallax lambat)
    for (int i = 0; i < 30; i++) {
      double treeX = i * 150.0;
      if (treeX >= viewStart && treeX <= viewEnd) {
        elements.add(
          Positioned(
            bottom: 180,
            left: treeX - cameraOffset * 0.3,
            child: Transform.scale(
              scale: 0.6,
              child: Opacity(
                opacity: 0.4,
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
          left: (i * 250.0) - cameraOffset * 0.3,
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
      case ObstacleType.spike:
      case ObstacleType.lowBarrier:
      case ObstacleType.narrowBridge:
        return 120;
      case ObstacleType.puddle:
      case ObstacleType.mudPit:
        return 80;
      case ObstacleType.platform:
        return 140;
      case ObstacleType.ramp:
        return 100;
    }
  }

  Widget _buildObstacleWidget(ObstacleType type) {
    switch (type) {
      case ObstacleType.rock:
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF808080), Color(0xFF404040)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.red.withOpacity(0.6), width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(1, 1)),
            ],
          ),
          child: Center(
            child: Icon(Icons.warning, size: 14, color: Colors.red),
          ),
        );
        
      case ObstacleType.log:
        return Container(
          width: 32, height: 12,
          decoration: BoxDecoration(
            color: Color(0xFF8B4513),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.green.withOpacity(0.5), width: 1),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 1))],
          ),
        );
        
      case ObstacleType.hole:
        return Container(
          width: 30, height: 18,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.red.withOpacity(0.7), width: 2),
          ),
          child: Center(
            child: Icon(Icons.keyboard_arrow_down, size: 12, color: Colors.red),
          ),
        );
        
      case ObstacleType.puddle:
        return Container(
          width: 35, height: 6,
          decoration: BoxDecoration(
            color: Color(0xFF4169E1).withOpacity(0.7),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.blue.withOpacity(0.5), width: 1),
          ),
        );
        
      case ObstacleType.spike:
        return Container(
          width: 25,
          height: 22,
          child: CustomPaint(
            painter: SpikePainter(),
          ),
        );
        
      case ObstacleType.platform:
        return Container(
          width: 50,
          height: 18,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF654321), Color(0xFF8B4513)],
            ),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.orange.withOpacity(0.7), width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black54, blurRadius: 3, offset: Offset(0, 1)),
            ],
          ),
          child: Center(
            child: Icon(Icons.keyboard_arrow_up, size: 10, color: Colors.orange),
          ),
        );
        
      case ObstacleType.lowBarrier:
        return Container(
          width: 40,
          height: 16,
          decoration: BoxDecoration(
            color: Color(0xFF696969),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.yellow, width: 1),
          ),
          child: Center(
            child: Icon(Icons.keyboard_arrow_down, size: 8, color: Colors.yellow),
          ),
        );
        
      case ObstacleType.mudPit:
        return Container(
          width: 55,
          height: 10,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF654321), Color(0xFF8B4513), Color(0xFF654321)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.brown.withOpacity(0.5), width: 1),
          ),
        );
        
      case ObstacleType.ramp:
        return Container(
          width: 65,
          height: 25,
          child: CustomPaint(
            painter: RampPainter(),
          ),
        );
        
      case ObstacleType.narrowBridge:
        return Container(
          width: 20,
          height: 35,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF8B4513), Color(0xFF654321)],
            ),
            border: Border.all(color: Colors.orange.withOpacity(0.6), width: 1),
          ),
        );
        
      default:
        return Container(
          width: 30, 
          height: 15, 
          color: Colors.grey,
          child: Center(
            child: Text('?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
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
                        '🟥 Merah: Lompat! | 🟦 Biru: Aman lewat | 🟨 Kuning: Hati-hati',
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

// Obstacle, Enum, dan Custom Painter classes tetap sama seperti aslinya
class Obstacle {
  final double x;
  final ObstacleType type;
  
  Obstacle({required this.x, required this.type});
}

enum ObstacleType { 
  rock, log, hole, puddle, spike, platform, lowBarrier, mudPit, ramp, narrowBridge,
}

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

class SpikePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF696969)
      ..style = PaintingStyle.fill;
    
    final spikePath = Path();
    spikePath.moveTo(0, size.height);
    
    for (int i = 0; i < 3; i++) {
      double x = (size.width / 3) * i;
      spikePath.lineTo(x + size.width / 6, 0);
      spikePath.lineTo(x + size.width / 3, size.height);
    }
    spikePath.close();
    
    canvas.drawPath(spikePath, paint);
    
    final highlightPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(spikePath, highlightPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RampPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF8B4513)
      ..style = PaintingStyle.fill;
    
    final rampPath = Path();
    rampPath.moveTo(0, size.height);
    rampPath.lineTo(size.width, size.height * 0.3);
    rampPath.lineTo(size.width, size.height);
    rampPath.close();
    
    canvas.drawPath(rampPath, paint);
    
    final linePaint = Paint()
      ..color = Color(0xFF654321)
      ..strokeWidth = 1;
    
    for (int i = 1; i < 4; i++) {
      double y = size.height - (size.height * 0.15 * i);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width * (1 - 0.15 * i), y * 0.6),
        linePaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EgrangPlayerPainter extends CustomPainter {
  final double stepAnimation;
  final bool isMoving;
  
  EgrangPlayerPainter({
    required this.stepAnimation,
    required this.isMoving,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    double leftFootY = 45;
    double rightFootY = 45;
    double leftStickBottomY = 80;
    double rightStickBottomY = 80;
    double bodyBounce = 0;
    
    double leftFootX = 18;
    double rightFootX = 32;
    double leftStickX = 15;
    double rightStickX = 35;
    
    bool leftInFront = false;
    bool rightInFront = false;
    
    if (isMoving) {
      double leftStep = sin(stepAnimation);
      double rightStep = sin(stepAnimation + pi);
      
      if (leftStep > 0) {
        leftFootY = 45 - (leftStep * 20);
        leftStickBottomY = 80 - (leftStep * 20);
        leftFootX = 18 + (leftStep * 8);
        leftStickX = 15 + (leftStep * 8);
        leftInFront = true;
      }
      
      if (rightStep > 0) {
        rightFootY = 45 - (rightStep * 20);
        rightStickBottomY = 80 - (rightStep * 20);
        rightFootX = 32 - (rightStep * 8);
        rightStickX = 35 - (rightStep * 8);
        rightInFront = true;
      }
      
      bodyBounce = -(sin(stepAnimation * 2).abs()) * 2;
    }
    
    // Drawing logic sama seperti aslinya, tapi dengan perubahan ukuran yang minor
    paint.color = Color(0xFFDEB887);
    paint.strokeWidth = 5;
    paint.strokeCap = StrokeCap.round;
    
    if (!leftInFront) {
      canvas.drawLine(
        Offset(leftFootX, 30 + bodyBounce), 
        Offset(leftStickX, leftStickBottomY), 
        paint
      );
    }
    
    if (!rightInFront) {
      canvas.drawLine(
        Offset(rightFootX, 30 + bodyBounce), 
        Offset(rightStickX, rightStickBottomY), 
        paint
      );
    }
    
    // Body
    paint.color = Color(0xFFFF6B6B);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, 12 + bodyBounce, 10, 18),
        Radius.circular(3),
      ),
      paint,
    );
    
    // Head
    paint.color = Color(0xFFFFDBB5);
    canvas.drawOval(
      Rect.fromLTWH(22, 5 + bodyBounce, 12, 10),
      paint
    );
    
    // Hair
    paint.color = Color(0xFF4A4A4A);
    final hairPath = Path();
    hairPath.moveTo(22, 8 + bodyBounce);
    hairPath.quadraticBezierTo(20, 5 + bodyBounce, 22, 2 + bodyBounce);
    hairPath.quadraticBezierTo(28, 1 + bodyBounce, 32, 4 + bodyBounce);
    hairPath.quadraticBezierTo(30, 7 + bodyBounce, 28, 8 + bodyBounce);
    canvas.drawPath(hairPath, paint);
    
    // Eyes
    paint.color = Colors.black;
    canvas.drawCircle(Offset(29, 8 + bodyBounce), 1.5, paint);
    
    // Nose
    paint.color = Color(0xFFFFB3B3);
    canvas.drawCircle(Offset(34, 10 + bodyBounce), 1, paint);
    
    // Arms
    paint.color = Color(0xFFFFDBB5);
    paint.strokeWidth = 3;
    paint.strokeCap = StrokeCap.round;
    
    double armSwing = isMoving ? sin(stepAnimation) * 3 : 0;
    
    canvas.drawLine(
      Offset(22, 16 + bodyBounce), 
      Offset(15 + armSwing, 25), 
      paint
    );
    
    canvas.drawLine(
      Offset(28, 16 + bodyBounce), 
      Offset(38 - armSwing, 25), 
      paint
    );
    
    // Legs
    paint.color = Color(0xFF4169E1);
    paint.strokeWidth = 4;
    
    if (!leftInFront) {
      canvas.drawLine(
        Offset(22, 30 + bodyBounce), 
        Offset(leftFootX, leftFootY), 
        paint
      );
    }
    
    if (!rightInFront) {
      canvas.drawLine(
        Offset(28, 30 + bodyBounce), 
        Offset(rightFootX, rightFootY), 
        paint
      );
    }
    
    // Platforms - back first
    paint.color = Color(0xFF8B4513);
    
    if (!leftInFront) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(leftStickX - 3, leftFootY - 5, 12, 3),
          Radius.circular(1),
        ),
        paint
      );
    }
    
    if (!rightInFront) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rightStickX - 3, rightFootY - 5, 12, 3),
          Radius.circular(1),
        ),
        paint
      );
    }
    
    // Shoes - back first
    paint.color = Color(0xFF000000);
    
    if (!leftInFront) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(leftStickX - 5, leftFootY - 7, 10, 4),
          Radius.circular(2),
        ),
        paint
      );
    }
    
    if (!rightInFront) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rightStickX - 5, rightFootY - 7, 10, 4),
          Radius.circular(2),
        ),
        paint
      );
    }
    
    // Front elements
    paint.color = Color(0xFFDEB887);
    paint.strokeWidth = 5;
    paint.strokeCap = StrokeCap.round;
    
    if (leftInFront) {
      canvas.drawLine(
        Offset(leftFootX, 30 + bodyBounce), 
        Offset(leftStickX, leftStickBottomY), 
        paint
      );
    }
    
    if (rightInFront) {
      canvas.drawLine(
        Offset(rightFootX, 30 + bodyBounce), 
        Offset(rightStickX, rightStickBottomY), 
        paint
      );
    }
    
    paint.color = Color(0xFF4169E1);
    paint.strokeWidth = 4;
    
    if (leftInFront) {
      canvas.drawLine(
        Offset(22, 30 + bodyBounce), 
        Offset(leftFootX, leftFootY), 
        paint
      );
    }
    
    if (rightInFront) {
      canvas.drawLine(
        Offset(28, 30 + bodyBounce), 
        Offset(rightFootX, rightFootY), 
        paint
      );
    }
    
    paint.color = Color(0xFF8B4513);
    
    if (leftInFront) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(leftStickX - 3, leftFootY - 5, 12, 3),
          Radius.circular(1),
        ),
        paint
      );
    }
    
    if (rightInFront) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rightStickX - 3, rightFootY - 5, 12, 3),
          Radius.circular(1),
        ),
        paint
      );
    }
    
    paint.color = Color(0xFF000000);
    
    if (leftInFront) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(leftStickX - 5, leftFootY - 7, 10, 4),
          Radius.circular(2),
        ),
        paint
      );
    }
    
    if (rightInFront) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rightStickX - 5, rightFootY - 7, 10, 4),
          Radius.circular(2),
        ),
        paint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is EgrangPlayerPainter && 
           (oldDelegate.stepAnimation != stepAnimation || 
            oldDelegate.isMoving != isMoving);
  }
}