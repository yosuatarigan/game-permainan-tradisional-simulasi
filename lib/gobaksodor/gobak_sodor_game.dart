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
  
  // Game state
  int currentPlayer = 1;
  int playersCompleted = 0;
  int playersFailed = 0;
  int totalScore = 0;
  bool gameStarted = false;
  bool gameOver = false;
  bool playerCaught = false;
  String gameMessage = '';
  
  // Player position
  Offset playerPosition = const Offset(200, 460); // Start at bottom center
  bool playerMoving = false;
  bool returningHome = false;
  bool hasReachedFinish = false;
  
  // Guards positions and directions
  List<Guard> guards = [];
  
  // Game settings
  final double fieldWidth = 400;
  final double fieldHeight = 500;
  final double playerSize = 24;
  final double guardSize = 24;
  
  @override
  void initState() {
    super.initState();
    _initializeGame();
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
    
    // Initialize guards dengan posisi yang lebih akurat
    guards = [
      Guard(1, const Offset(200, 100), true, 140, _guardController), // Horizontal guard 1
      Guard(2, const Offset(200, 180), true, 140, _guardController), // Horizontal guard 2
      Guard(3, const Offset(200, 260), true, 140, _guardController), // Horizontal guard 3
      Guard(4, const Offset(200, 340), true, 140, _guardController), // Horizontal guard 4
      Guard(5, const Offset(200, 220), false, 110, _guardController), // Vertical guard 5
    ];
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
      returningHome = false;
      hasReachedFinish = false;
      playerCaught = false;
      gameMessage = 'Pemain 1 - Menuju Finish';
    });
  }
  
  void _movePlayer(Offset direction) {
    if (!gameStarted || gameOver || playerCaught) return;
    
    setState(() {
      playerMoving = true;
      double newX = (playerPosition.dx + direction.dx * 35)
          .clamp(30, fieldWidth - 30);
      double newY = (playerPosition.dy + direction.dy * 35)
          .clamp(70, fieldHeight - 70);
      
      playerPosition = Offset(newX, newY);
      
      // Check if reached finish line (top area)
      if (!hasReachedFinish && newY <= 90) {
        hasReachedFinish = true;
        returningHome = true;
        gameMessage = 'Pemain $currentPlayer - Kembali ke Start!';
      }
      
      // Check if returned home successfully
      if (hasReachedFinish && returningHome && newY >= 420) {
        _playerCompleted();
        return;
      }
      
      // Check collision with guards
      _checkCollisions();
    });
    
    // Stop moving animation after delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          playerMoving = false;
        });
      }
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
    setState(() {
      playerCaught = true;
      playersFailed++;
      gameMessage = 'Pemain $currentPlayer Tertangkap! Gagal.';
    });
    
    // Show caught message then move to next player
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _nextPlayer();
      }
    });
  }
  
  void _playerCompleted() {
    setState(() {
      playersCompleted++;
      totalScore++;
      gameMessage = 'Pemain $currentPlayer Berhasil! (+1 Poin)';
    });
    
    // Show success message then move to next player
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _nextPlayer();
      }
    });
  }
  
  void _nextPlayer() {
    if (currentPlayer >= 5) {
      // Game finished
      setState(() {
        gameOver = true;
        gameStarted = false;
        gameMessage = 'Game Selesai! Skor: $totalScore/5';
      });
    } else {
      // Next player
      setState(() {
        currentPlayer++;
        playerCaught = false;
        playerPosition = const Offset(200, 460);
        returningHome = false;
        hasReachedFinish = false;
        gameMessage = 'Pemain $currentPlayer - Menuju Finish';
      });
    }
  }
  
  @override
  void dispose() {
    _guardController.dispose();
    _gameController.dispose();
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
                          : hasReachedFinish 
                              ? Colors.green.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: playerCaught 
                            ? Colors.red 
                            : hasReachedFinish 
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
                child: AnimatedBuilder(
                  animation: _guardController,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        // Field background with lines
                        CustomPaint(
                          painter: GameFieldPainter(),
                          size: Size(fieldWidth, fieldHeight),
                        ),
                        // Guards
                        ...guards.map((guard) {
                          Offset pos = guard.getCurrentPosition();
                          return Positioned(
                            left: pos.dx - guardSize / 2,
                            top: pos.dy - guardSize / 2,
                            child: Container(
                              width: guardSize,
                              height: guardSize,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(guardSize / 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/red.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
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
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        // Player
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 200),
                          left: playerPosition.dx - playerSize / 2,
                          top: playerPosition.dy - playerSize / 2,
                          child: Container(
                            width: playerMoving ? playerSize + 4 : playerSize,
                            height: playerMoving ? playerSize + 4 : playerSize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(playerSize / 2),
                              boxShadow: [
                                BoxShadow(
                                  color: playerCaught 
                                      ? Colors.orange.withOpacity(0.6)
                                      : returningHome 
                                          ? Colors.green.withOpacity(0.6)
                                          : Colors.blue.withOpacity(0.6),
                                  blurRadius: playerMoving ? 8 : 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: playerCaught || returningHome 
                                  ? ColorFiltered(
                                      colorFilter: playerCaught
                                          ? const ColorFilter.mode(Colors.orange, BlendMode.modulate)
                                          : const ColorFilter.mode(Colors.green, BlendMode.modulate),
                                      child: Image.asset(
                                        'assets/blue.png',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: playerCaught 
                                                  ? Colors.orange 
                                                  : returningHome 
                                                      ? Colors.green 
                                                      : Colors.blue,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/blue.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Controls
          Container(
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
                
                if (gameStarted) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Up
                      Column(
                        children: [
                          _buildControlButton(
                            Icons.keyboard_arrow_up,
                            () => _movePlayer(const Offset(0, -1)),
                          ),
                          const SizedBox(height: 8),
                          // Left and Right
                          Row(
                            children: [
                              _buildControlButton(
                                Icons.keyboard_arrow_left,
                                () => _movePlayer(const Offset(-1, 0)),
                              ),
                              const SizedBox(width: 40),
                              _buildControlButton(
                                Icons.keyboard_arrow_right,
                                () => _movePlayer(const Offset(1, 0)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Down
                          _buildControlButton(
                            Icons.keyboard_arrow_down,
                            () => _movePlayer(const Offset(0, 1)),
                          ),
                        ],
                      ),
                    ],
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
  
  Widget _buildControlButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
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
    
    // Vertical line
    canvas.drawLine(
      Offset(size.width / 2, 100),
      Offset(size.width / 2, 340),
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