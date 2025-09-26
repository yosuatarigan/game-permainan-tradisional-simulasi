import 'package:flutter/material.dart';
import 'dart:math';

class GobakSodorGame extends StatefulWidget {
  const GobakSodorGame({super.key});

  @override
  State<GobakSodorGame> createState() => _GobakSodorGameState();
}

class _GobakSodorGameState extends State<GobakSodorGame>
    with TickerProviderStateMixin {
  late AnimationController _guardController;
  late AnimationController _gameController;
  late AnimationController _particleController;
  
  // Game state
  int currentPlayer = 1;
  int playersCompleted = 0;
  int playersFailed = 0;
  int totalScore = 0;
  bool gameStarted = false;
  bool gameOver = false;
  bool playerCaught = false;
  bool playerCompleted = false;
  String gameMessage = '';
  
  // Player position
  Offset playerPosition = const Offset(200, 460);
  Offset playerVelocity = Offset.zero;
  bool playerMoving = false;
  bool returningHome = false;
  bool hasReachedFinish = false;
  
  // Guards positions and directions
  List<Guard> guards = [];
  
  // Joystick - FIXED
  Offset joystickPosition = Offset.zero;
  Offset knobPosition = Offset.zero;
  bool joystickActive = false;
  final double joystickRadius = 60;
  final double knobRadius = 25;
  final GlobalKey joystickKey = GlobalKey();
  
  // Particles
  List<Particle> particles = [];
  List<Particle> trailParticles = [];
  
  // Game settings
  final double fieldWidth = 400;
  final double fieldHeight = 500;
  final double playerSize = 24;
  final double guardSize = 24;
  final double maxSpeed = 3.0;
  
  @override
  void initState() {
    super.initState();
    _initializeGame();
    
    // Initialize joystick position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        joystickPosition = Offset(joystickRadius + 20, joystickRadius + 20);
        knobPosition = joystickPosition;
      });
    });
  }
  
  void _initializeGame() {
    // Animation controllers
    _guardController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _gameController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 16), // 60 FPS
      vsync: this,
    )..repeat();
    
    // Listen to particle animation for game loop
    _particleController.addListener(_gameLoop);
    
    // Initialize guards dengan posisi yang lebih akurat
    guards = [
      Guard(1, const Offset(200, 100), true, 140, _guardController), // Horizontal guard 1
      Guard(2, const Offset(200, 180), true, 140, _guardController), // Horizontal guard 2
      Guard(3, const Offset(200, 260), true, 140, _guardController), // Horizontal guard 3
      Guard(4, const Offset(200, 340), true, 140, _guardController), // Horizontal guard 4
      Guard(5, const Offset(200, 220), false, 110, _guardController), // Vertical guard 5
    ];
  }
  
  void _gameLoop() {
    if (!gameStarted || gameOver || playerCaught || playerCompleted) return;
    
    setState(() {
      // Update player position with velocity
      if (joystickActive) {
        double newX = (playerPosition.dx + playerVelocity.dx)
            .clamp(30, fieldWidth - 30);
        double newY = (playerPosition.dy + playerVelocity.dy)
            .clamp(70, fieldHeight - 70);
        
        playerPosition = Offset(newX, newY);
        
        // Add trail particles when moving
        if (playerVelocity.distance > 0.5) {
          _addTrailParticle();
        }
        
        playerMoving = playerVelocity.distance > 0.5;
      } else {
        playerMoving = false;
      }
      
      // Check game state
      _checkGameState();
      _checkCollisions();
      
      // Update particles
      _updateParticles();
    });
  }
  
  void _checkGameState() {
    // Check if reached finish line (top area) - langsung selesai!
    if (!playerCompleted && playerPosition.dy <= 90) {
      _playerCompletedRound();
    }
  }
  
  void _startGame() {
    setState(() {
      gameStarted = true;
      gameOver = false;
      currentPlayer = 1;
      playersCompleted = 0;
      playersFailed = 0;
      totalScore = 0;
      playerPosition = const Offset(200, 460);
      playerCaught = false;
      playerCompleted = false;
      gameMessage = 'Pemain 1 - Capai Garis Finish!';
    });
  }
  
  // FIXED JOYSTICK METHODS
  void _handleJoystickStart(Offset globalPosition) {
    if (!gameStarted || gameOver || playerCaught || playerCompleted) return;
    
    final RenderBox? renderBox = joystickKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final localPosition = renderBox.globalToLocal(globalPosition);
      _updateJoystick(localPosition);
    }
  }
  
  void _handleJoystickUpdate(Offset globalPosition) {
    if (!gameStarted || gameOver || playerCaught || playerCompleted) return;
    
    final RenderBox? renderBox = joystickKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final localPosition = renderBox.globalToLocal(globalPosition);
      _updateJoystick(localPosition);
    }
  }
  
  void _updateJoystick(Offset localPosition) {
    final center = Offset(joystickRadius + 20, joystickRadius + 20);
    final delta = localPosition - center;
    final distance = delta.distance;
    
    setState(() {
      if (distance <= joystickRadius) {
        knobPosition = localPosition;
        joystickActive = distance > 8; // Dead zone
      } else {
        // Clamp to boundary
        final direction = delta / distance;
        knobPosition = center + direction * joystickRadius;
        joystickActive = true;
      }
      
      if (joystickActive) {
        final clampedDistance = distance.clamp(0.0, joystickRadius);
        final normalizedDistance = clampedDistance / joystickRadius;
        final direction = delta / (distance == 0 ? 1 : distance);
        
        playerVelocity = direction * maxSpeed * normalizedDistance;
      } else {
        playerVelocity = Offset.zero;
      }
    });
  }
  
  void _stopJoystick() {
    setState(() {
      knobPosition = Offset(joystickRadius + 20, joystickRadius + 20);
      joystickActive = false;
      playerVelocity = Offset.zero;
    });
  }
  
  // Particle Methods
  void _addTrailParticle() {
    if (trailParticles.length > 20) {
      trailParticles.removeAt(0);
    }
    
    trailParticles.add(Particle(
      position: playerPosition + Offset(
        (Random().nextDouble() - 0.5) * 10,
        (Random().nextDouble() - 0.5) * 10,
      ),
      velocity: -playerVelocity * 0.3 + Offset(
        (Random().nextDouble() - 0.5) * 2,
        (Random().nextDouble() - 0.5) * 2,
      ),
      life: 30,
      maxLife: 30,
      color: Colors.blue.withOpacity(0.6),
      size: Random().nextDouble() * 2 + 2,
      shape: ParticleShape.values[Random().nextInt(ParticleShape.values.length)],
      rotation: Random().nextDouble() * 2 * pi,
      rotationSpeed: (Random().nextDouble() - 0.5) * 0.2,
    ));
  }
  
  void _addSuccessParticles() {
    for (int i = 0; i < 15; i++) {
      particles.add(Particle(
        position: playerPosition,
        velocity: Offset(
          (Random().nextDouble() - 0.5) * 8,
          (Random().nextDouble() - 0.5) * 8,
        ),
        life: 60,
        maxLife: 60,
        color: [Colors.green, Colors.lightGreen, Colors.greenAccent][Random().nextInt(3)],
        size: Random().nextDouble() * 3 + 3,
        shape: ParticleShape.star,
        rotation: Random().nextDouble() * 2 * pi,
        rotationSpeed: (Random().nextDouble() - 0.5) * 0.3,
      ));
    }
  }
  
  void _addExplosionParticles() {
    for (int i = 0; i < 20; i++) {
      particles.add(Particle(
        position: playerPosition,
        velocity: Offset(
          (Random().nextDouble() - 0.5) * 10,
          (Random().nextDouble() - 0.5) * 10,
        ),
        life: 40,
        maxLife: 40,
        color: [Colors.orange, Colors.red, Colors.deepOrange][Random().nextInt(3)],
        size: Random().nextDouble() * 3 + 4,
        shape: ParticleShape.diamond,
        rotation: Random().nextDouble() * 2 * pi,
        rotationSpeed: (Random().nextDouble() - 0.5) * 0.4,
      ));
    }
  }
  
  void _addVictoryParticles() {
    for (int i = 0; i < 30; i++) {
      particles.add(Particle(
        position: Offset(
          Random().nextDouble() * fieldWidth,
          Random().nextDouble() * fieldHeight,
        ),
        velocity: Offset(
          (Random().nextDouble() - 0.5) * 6,
          Random().nextDouble() * -8 - 2,
        ),
        life: 120,
        maxLife: 120,
        color: [Colors.yellow, Colors.green, Colors.blue, Colors.purple, Colors.pink][Random().nextInt(5)],
        size: Random().nextDouble() * 4 + 4,
        shape: ParticleShape.values[Random().nextInt(ParticleShape.values.length)],
        rotation: Random().nextDouble() * 2 * pi,
        rotationSpeed: (Random().nextDouble() - 0.5) * 0.5,
      ));
    }
  }
  
  void _updateParticles() {
    particles.removeWhere((particle) {
      particle.update();
      return particle.life <= 0;
    });
    
    trailParticles.removeWhere((particle) {
      particle.update();
      return particle.life <= 0;
    });
  }
  
  void _checkCollisions() {
    for (Guard guard in guards) {
      double distance = (playerPosition - guard.getCurrentPosition()).distance;
      if (distance < (playerSize + guardSize) / 2 + 8) {
        _playerCaught();
        break;
      }
    }
  }
  
  void _playerCaught() {
    if (playerCaught || playerCompleted) return; // Prevent multiple calls
    
    setState(() {
      playerCaught = true;
      playersFailed++;
      gameMessage = 'Pemain $currentPlayer Tertangkap! Gagal.';
      playerVelocity = Offset.zero;
      joystickActive = false;
      knobPosition = Offset(joystickRadius + 20, joystickRadius + 20);
    });
    
    _addExplosionParticles();
    
    // Show caught message then move to next player
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _nextPlayer();
      }
    });
  }
  
  void _playerCompletedRound() {
    if (playerCaught || playerCompleted) return; // Prevent multiple calls
    
    setState(() {
      playerCompleted = true;
      playersCompleted++;
      totalScore++;
      gameMessage = 'Pemain $currentPlayer Berhasil Sampai Finish! (+1 Poin)';
      playerVelocity = Offset.zero;
      joystickActive = false;
      knobPosition = Offset(joystickRadius + 20, joystickRadius + 20);
    });
    
    _addSuccessParticles();
    _addVictoryParticles();
    
    // Show success message then move to next player
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _nextPlayer();
      }
    });
  }
  
  void _nextPlayer() {
    // Check if all 5 players have played
    if (currentPlayer >= 5) {
      // Game finished - all 5 players have played
      setState(() {
        gameOver = true;
        gameStarted = false;
        gameMessage = 'Game Selesai! Skor: $totalScore/5';
      });
      _addVictoryParticles();
    } else {
      // Next player
      setState(() {
        currentPlayer++;
        playerCaught = false;
        playerCompleted = false;
        playerPosition = const Offset(200, 460);
        gameMessage = 'Pemain $currentPlayer - Capai Garis Finish!';
        playerVelocity = Offset.zero;
        joystickActive = false;
        knobPosition = Offset(joystickRadius + 20, joystickRadius + 20);
        // Clear particles
        particles.clear();
        trailParticles.clear();
      });
    }
  }
  
  @override
  void dispose() {
    _guardController.dispose();
    _gameController.dispose();
    _particleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a237e),
      appBar: AppBar(
        title: const Text(
          'Gobak Sodor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0d47a1),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Game status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF0d47a1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusCard('Pemain', '$currentPlayer/5'),
                    _buildStatusCard('Berhasil', '$playersCompleted'),
                    _buildStatusCard('Gagal', '$playersFailed'),
                    _buildStatusCard('Skor', '$totalScore/5'),
                  ],
                ),
                if (gameMessage.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: playerCaught 
                          ? Colors.red.withOpacity(0.2)
                          : playerCompleted 
                              ? Colors.green.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: playerCaught 
                            ? Colors.red 
                            : playerCompleted 
                                ? Colors.green 
                                : Colors.blue,
                      ),
                    ),
                    child: Text(
                      gameMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          Expanded(
            child: Center(
              child: Container(
                width: fieldWidth,
                height: fieldHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFF4caf50),
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Field background with lines
                    CustomPaint(
                      painter: GameFieldPainter(),
                      size: Size(fieldWidth, fieldHeight),
                    ),
                    // Particles
                    CustomPaint(
                      painter: ParticlePainter(
                        particles: particles,
                        trailParticles: trailParticles,
                      ),
                      size: Size(fieldWidth, fieldHeight),
                    ),
                    // Guards
                    AnimatedBuilder(
                      animation: _guardController,
                      builder: (context, child) {
                        return Stack(
                          children: guards.map((guard) {
                            Offset pos = guard.getCurrentPosition();
                            return Positioned(
                              left: pos.dx - guardSize / 2,
                              top: pos.dy - guardSize / 2,
                              child: Container(
                                width: guardSize,
                                height: guardSize,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(guardSize / 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '${guard.id}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    // Player
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 50),
                      left: playerPosition.dx - playerSize / 2,
                      top: playerPosition.dy - playerSize / 2,
                      child: Container(
                        width: playerMoving ? playerSize + 4 : playerSize,
                        height: playerMoving ? playerSize + 4 : playerSize,
                        decoration: BoxDecoration(
                          color: playerCaught 
                              ? Colors.orange
                              : playerCompleted 
                                  ? Colors.green 
                                  : Colors.blue,
                          borderRadius: BorderRadius.circular(playerSize / 2),
                          boxShadow: [
                            BoxShadow(
                              color: playerCaught 
                                  ? Colors.orange.withOpacity(0.6)
                                  : playerCompleted 
                                      ? Colors.green.withOpacity(0.6)
                                      : Colors.blue.withOpacity(0.6),
                              blurRadius: playerMoving ? 8 : 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Controls with FIXED Virtual Joystick
          Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (!gameStarted)
                  ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4caf50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32, 
                        vertical: 16
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Text(gameOver ? 'Main Lagi' : 'Mulai Game'),
                  ),
                
                if (gameStarted && !gameOver) ...[
                  // FIXED Virtual Joystick
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        key: joystickKey,
                        width: (joystickRadius + 20) * 2,
                        height: (joystickRadius + 20) * 2,
                        child: GestureDetector(
                          onPanStart: (details) => _handleJoystickStart(details.globalPosition),
                          onPanUpdate: (details) => _handleJoystickUpdate(details.globalPosition),
                          onPanEnd: (details) => _stopJoystick(),
                          onTapDown: (details) => _handleJoystickStart(details.globalPosition),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular((joystickRadius + 20)),
                            ),
                            child: CustomPaint(
                              painter: JoystickPainter(
                                center: Offset(joystickRadius + 20, joystickRadius + 20),
                                knobPosition: knobPosition,
                                joystickRadius: joystickRadius,
                                knobRadius: knobRadius,
                                isActive: joystickActive,
                              ),
                              size: Size((joystickRadius + 20) * 2, (joystickRadius + 20) * 2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Instructions
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Sentuh dan geser joystick untuk bergerak',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                
                if (gameOver)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: totalScore >= 3 
                          ? const Color(0xFF4caf50) 
                          : totalScore >= 1 
                              ? Colors.orange 
                              : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          totalScore == 5 
                              ? '🏆 PERFECT! Semua pemain lolos!'
                              : totalScore >= 3 
                                  ? '🎉 Bagus! $totalScore dari 5 pemain berhasil!'
                                  : totalScore >= 1 
                                      ? '👍 Lumayan! $totalScore dari 5 pemain berhasil!'
                                      : '😔 Coba lagi! Tidak ada yang berhasil.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Skor Akhir: $totalScore/5',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Guard class
class Guard {
  final int id;
  final Offset basePosition;
  final bool isHorizontal;
  final double movementRange;
  final AnimationController controller;
  
  Guard(this.id, this.basePosition, this.isHorizontal, this.movementRange, this.controller);
  
  Offset getCurrentPosition() {
    double progress = controller.value;
    double movement = sin(progress * 2 * pi + id * 0.3) * (movementRange / 2);
    
    if (isHorizontal) {
      return Offset(basePosition.dx + movement, basePosition.dy);
    } else {
      return Offset(basePosition.dx, basePosition.dy + movement);
    }
  }
}

// Custom painter for the game field
class GameFieldPainter extends CustomPainter {
  GameFieldPainter();
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Draw field lines
    paint.color = Colors.white;
    paint.strokeWidth = 3;
    
    // Horizontal lines
    for (int i = 1; i <= 4; i++) {
      double y = 80.0 * i + 20;
      canvas.drawLine(
        Offset(20, y),
        Offset(size.width - 20, y),
        paint,
      );
    }
    
    // Vertical center line
    canvas.drawLine(
      Offset(size.width / 2, 100),
      Offset(size.width / 2, 340),
      paint,
    );
    
    // Left and right boundary lines
    canvas.drawLine(
      Offset(20, 80), // Start from finish area
      Offset(20, size.height - 80), // End at start area
      paint,
    );
    
    canvas.drawLine(
      Offset(size.width - 20, 80), // Start from finish area
      Offset(size.width - 20, size.height - 80), // End at start area
      paint,
    );
    
    // Draw start area
    paint.color = Colors.blue.withOpacity(0.2);
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, size.height - 80, size.width - 40, 60),
        const Radius.circular(8),
      ),
      paint,
    );
    
    // Draw finish area
    paint.color = Colors.yellow.withOpacity(0.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, 20, size.width - 40, 60),
        const Radius.circular(8),
      ),
      paint,
    );
    
    // Draw area labels
    final textStyle = TextStyle(
      color: Colors.white.withOpacity(0.8),
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
    
    // START label
    TextPainter startPainter = TextPainter(
      text: TextSpan(text: 'START', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    startPainter.layout();
    startPainter.paint(
      canvas,
      Offset(
        (size.width - startPainter.width) / 2,
        size.height - 55,
      ),
    );
    
    // FINISH label
    TextPainter finishPainter = TextPainter(
      text: TextSpan(text: 'FINISH', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    finishPainter.layout();
    finishPainter.paint(
      canvas,
      Offset(
        (size.width - finishPainter.width) / 2,
        45,
      ),
    );
  }
  
  @override
  bool shouldRepaint(GameFieldPainter oldDelegate) {
    return false;
  }
}

// Particle shapes
enum ParticleShape {
  circle,
  square,
  diamond,
  star,
  triangle,
}

// Particle class
class Particle {
  Offset position;
  Offset velocity;
  int life;
  int maxLife;
  Color color;
  double size;
  ParticleShape shape;
  double rotation;
  double rotationSpeed;
  
  Particle({
    required this.position,
    required this.velocity,
    required this.life,
    required this.maxLife,
    required this.color,
    required this.size,
    this.shape = ParticleShape.circle,
    this.rotation = 0,
    this.rotationSpeed = 0,
  });
  
  void update() {
    position += velocity;
    velocity *= 0.98; // Friction
    rotation += rotationSpeed;
    life--;
  }
  
  double get opacity {
    return (life / maxLife).clamp(0.0, 1.0);
  }
}

// Particle painter
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final List<Particle> trailParticles;
  
  ParticlePainter({
    required this.particles,
    required this.trailParticles,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Draw trail particles
    for (Particle particle in trailParticles) {
      paint.color = particle.color.withOpacity(particle.opacity * 0.4);
      _drawParticle(canvas, paint, particle, true);
    }
    
    // Draw main particles with glow effect
    for (Particle particle in particles) {
      // Draw glow
      paint.color = particle.color.withOpacity(particle.opacity * 0.3);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      _drawParticle(canvas, paint, particle, false);
      
      // Draw main particle
      paint.maskFilter = null;
      paint.color = particle.color.withOpacity(particle.opacity);
      _drawParticle(canvas, paint, particle, false);
    }
  }
  
  void _drawParticle(Canvas canvas, Paint paint, Particle particle, bool isTrail) {
    canvas.save();
    canvas.translate(particle.position.dx, particle.position.dy);
    canvas.rotate(particle.rotation);
    
    double currentSize = particle.size * particle.opacity;
    if (isTrail) currentSize *= 0.7;
    
    switch (particle.shape) {
      case ParticleShape.circle:
        canvas.drawCircle(Offset.zero, currentSize, paint);
        break;
      case ParticleShape.square:
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: currentSize * 2, height: currentSize * 2),
          paint,
        );
        break;
      case ParticleShape.diamond:
        _drawDiamond(canvas, paint, currentSize);
        break;
      case ParticleShape.star:
        _drawStar(canvas, paint, currentSize);
        break;
      case ParticleShape.triangle:
        _drawTriangle(canvas, paint, currentSize);
        break;
    }
    
    canvas.restore();
  }
  
  void _drawDiamond(Canvas canvas, Paint paint, double size) {
    Path path = Path();
    path.moveTo(0, -size);
    path.lineTo(size, 0);
    path.lineTo(0, size);
    path.lineTo(-size, 0);
    path.close();
    canvas.drawPath(path, paint);
  }
  
  void _drawStar(Canvas canvas, Paint paint, double size) {
    Path path = Path();
    for (int i = 0; i < 10; i++) {
      double angle = (i * pi) / 5;
      double radius = (i % 2 == 0) ? size : size * 0.5;
      double x = cos(angle) * radius;
      double y = sin(angle) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }
  
  void _drawTriangle(Canvas canvas, Paint paint, double size) {
    Path path = Path();
    path.moveTo(0, -size);
    path.lineTo(size * 0.866, size * 0.5);
    path.lineTo(-size * 0.866, size * 0.5);
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return true;
  }
}

// FIXED Joystick painter
class JoystickPainter extends CustomPainter {
  final Offset center;
  final Offset knobPosition;
  final double joystickRadius;
  final double knobRadius;
  final bool isActive;
  
  JoystickPainter({
    required this.center,
    required this.knobPosition,
    required this.joystickRadius,
    required this.knobRadius,
    required this.isActive,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Draw joystick outer ring
    paint.color = Colors.white.withOpacity(0.3);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;
    canvas.drawCircle(center, joystickRadius, paint);
    
    // Draw joystick base
    paint.color = Colors.white.withOpacity(0.1);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, joystickRadius, paint);
    
    // Draw direction indicator line if active
    if (isActive) {
      paint.color = Colors.blue.withOpacity(0.4);
      paint.strokeWidth = 3;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(center, knobPosition, paint);
    }
    
    // Draw knob shadow
    paint.color = Colors.black.withOpacity(0.2);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(knobPosition + const Offset(2, 2), knobRadius, paint);
    
    // Draw knob
    paint.style = PaintingStyle.fill;
    paint.color = isActive 
        ? const Color(0xFF2196F3) 
        : Colors.white.withOpacity(0.8);
    canvas.drawCircle(knobPosition, knobRadius, paint);
    
    // Draw knob border
    paint.color = isActive ? Colors.white : Colors.grey[400]!;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawCircle(knobPosition, knobRadius, paint);
    
    // Draw center dot on knob
    paint.color = isActive ? Colors.white : Colors.grey[600]!;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(knobPosition, 4, paint);
  }
  
  @override
  bool shouldRepaint(JoystickPainter oldDelegate) {
    return knobPosition != oldDelegate.knobPosition || 
           isActive != oldDelegate.isActive;
  }
}