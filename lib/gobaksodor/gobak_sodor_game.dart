import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:math';
//check

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
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;

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
  bool hasFinishPoint = false;

  // Guards positions and directions
  List<Guard> guards = [];

  // Joystick
  Offset joystickPosition = Offset.zero;
  Offset knobPosition = Offset.zero;
  bool joystickActive = false;
  final double joystickRadius = 30;
  final double knobRadius = 18;
  final GlobalKey joystickKey = GlobalKey();

  // Particles
  List<Particle> particles = [];
  List<Particle> trailParticles = [];

  // Game settings
  final double fieldWidth = 400;
  final double fieldHeight = 500;
  final double playerSize = 40;
  final double guardSize = 40;
  final double maxSpeed = 3.0;

  @override
  void initState() {
    super.initState();
    _initializeGame();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        joystickPosition = Offset(joystickRadius + 20, joystickRadius + 20);
        knobPosition = joystickPosition;
      });
    });
  }

  Future<void> _playAudio() async {
    try {
      await _audioPlayer.play(AssetSource('audio.mp3'));
      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> _playSuccess() async {
    try {
      await _audioPlayer.play(
        AssetSource('succes.mp3'),
        position: Duration(seconds: 1),
      );
      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> _playFailed() async {
    try {
      await _audioPlayer.play(
        AssetSource('failed.mp3'),
        position: Duration(seconds: 2),
      );
      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _initializeGame() {
    _guardController = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    )..repeat();

    _gameController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 16),
      vsync: this,
    )..repeat();

    _particleController.addListener(_gameLoop);

    guards = [
      Guard(1, const Offset(200, 100), true, 140, _guardController),
      Guard(2, const Offset(200, 180), true, 140, _guardController),
      Guard(3, const Offset(200, 260), true, 140, _guardController),
      Guard(4, const Offset(200, 340), true, 140, _guardController),
      Guard(5, const Offset(200, 220), false, 110, _guardController),
    ];
  }

  void _gameLoop() {
    if (!gameStarted || gameOver || playerCaught || playerCompleted) return;

    setState(() {
      if (joystickActive) {
        double newX = (playerPosition.dx + playerVelocity.dx).clamp(
          30 + playerSize / 2,
          fieldWidth - 30 - playerSize / 2,
        );
        double newY = (playerPosition.dy + playerVelocity.dy).clamp(
          40,
          fieldHeight - 70,
        );

        playerPosition = Offset(newX, newY);

        if (playerVelocity.distance > 0.5) {
          _addTrailParticle();
        }

        playerMoving = playerVelocity.distance > 0.5;
      } else {
        playerMoving = false;
      }

      _checkGameState();
      _checkCollisions();
      _updateParticles();
    });
  }

  void _checkGameState() {
    if (!hasReachedFinish && playerPosition.dy <= 65) {
      hasReachedFinish = true;
      returningHome = true;

      if (!hasFinishPoint) {
        hasFinishPoint = true;
        totalScore++;
        gameMessage =
            'Pemain $currentPlayer - Mencapai Finish! (+1 Poin) - Kembali ke Start!';
        _addSuccessParticles();
      }
    }

    if (hasReachedFinish && returningHome && playerPosition.dy >= 420) {
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
      returningHome = false;
      hasReachedFinish = false;
      hasFinishPoint = false;
      playerCaught = false;
      playerCompleted = false;
      gameMessage = 'Pemain 1 - Menuju Finish';
    });
  }

  void _handleJoystickStart(Offset globalPosition) {
    if (!gameStarted || gameOver || playerCaught || playerCompleted) return;

    final RenderBox? renderBox =
        joystickKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final localPosition = renderBox.globalToLocal(globalPosition);
      _updateJoystick(localPosition);
    }
  }

  void _handleJoystickUpdate(Offset globalPosition) {
    if (!gameStarted || gameOver || playerCaught || playerCompleted) return;

    final RenderBox? renderBox =
        joystickKey.currentContext?.findRenderObject() as RenderBox?;
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
        joystickActive = distance > 8;
      } else {
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

  void _addTrailParticle() {
    if (trailParticles.length > 20) {
      trailParticles.removeAt(0);
    }

    trailParticles.add(
      Particle(
        position:
            playerPosition +
            Offset(
              (Random().nextDouble() - 0.5) * 10,
              (Random().nextDouble() - 0.5) * 10,
            ),
        velocity:
            -playerVelocity * 0.3 +
            Offset(
              (Random().nextDouble() - 0.5) * 2,
              (Random().nextDouble() - 0.5) * 2,
            ),
        life: 30,
        maxLife: 30,
        color: Colors.blue.withOpacity(0.6),
        size: Random().nextDouble() * 2 + 2,
        shape:
            ParticleShape.values[Random().nextInt(ParticleShape.values.length)],
        rotation: Random().nextDouble() * 2 * pi,
        rotationSpeed: (Random().nextDouble() - 0.5) * 0.2,
      ),
    );
  }

  void _addSuccessParticles() {
    for (int i = 0; i < 15; i++) {
      particles.add(
        Particle(
          position: playerPosition,
          velocity: Offset(
            (Random().nextDouble() - 0.5) * 8,
            (Random().nextDouble() - 0.5) * 8,
          ),
          life: 60,
          maxLife: 60,
          color:
              [Colors.green, Colors.lightGreen, Colors.greenAccent][Random()
                  .nextInt(3)],
          size: Random().nextDouble() * 3 + 3,
          shape: ParticleShape.star,
          rotation: Random().nextDouble() * 2 * pi,
          rotationSpeed: (Random().nextDouble() - 0.5) * 0.3,
        ),
      );
    }
  }

  void _addExplosionParticles() {
    for (int i = 0; i < 20; i++) {
      particles.add(
        Particle(
          position: playerPosition,
          velocity: Offset(
            (Random().nextDouble() - 0.5) * 10,
            (Random().nextDouble() - 0.5) * 10,
          ),
          life: 40,
          maxLife: 40,
          color:
              [Colors.orange, Colors.red, Colors.deepOrange][Random().nextInt(
                3,
              )],
          size: Random().nextDouble() * 3 + 4,
          shape: ParticleShape.diamond,
          rotation: Random().nextDouble() * 2 * pi,
          rotationSpeed: (Random().nextDouble() - 0.5) * 0.4,
        ),
      );
    }
  }

  void _addVictoryParticles() {
    for (int i = 0; i < 30; i++) {
      particles.add(
        Particle(
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
          color:
              [
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.purple,
                Colors.pink,
              ][Random().nextInt(5)],
          size: Random().nextDouble() * 4 + 4,
          shape:
              ParticleShape.values[Random().nextInt(
                ParticleShape.values.length,
              )],
          rotation: Random().nextDouble() * 2 * pi,
          rotationSpeed: (Random().nextDouble() - 0.5) * 0.5,
        ),
      );
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
    _playFailed().then((_) {
      Future.delayed(const Duration(seconds: 4), () {
        _playAudio();
      });
    });
    if (playerCaught || playerCompleted) return;

    setState(() {
      playerCaught = true;
      playersFailed++;
      gameMessage = 'Pemain $currentPlayer Tertangkap! Gagal.';
      playerVelocity = Offset.zero;
      joystickActive = false;
      knobPosition = Offset(joystickRadius + 20, joystickRadius + 20);
    });

    _addExplosionParticles();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showResultDialog(false);
      }
    });
  }

  void _playerCompletedRound() {
    if (playerCaught || playerCompleted) return;

    _playSuccess().then((_) {
      Future.delayed(const Duration(seconds: 4), () {
        _playAudio();
      });
    });

    setState(() {
      playerCompleted = true;
      playersCompleted++;
      totalScore++;
      gameMessage =
          'Pemain $currentPlayer Berhasil Pulang! (+1 Poin) Total: 2 Poin';
      playerVelocity = Offset.zero;
      joystickActive = false;
      knobPosition = Offset(joystickRadius + 20, joystickRadius + 20);
    });

    _addVictoryParticles();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showResultDialog(true);
      }
    });
  }

  void _showResultDialog(bool isSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isSuccess
                          ? [const Color(0xFF4caf50), const Color(0xFF45a049)]
                          : [const Color(0xFFf44336), const Color(0xFFe53935)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSuccess ? Icons.check_circle : Icons.cancel,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isSuccess ? 'BERHASIL!' : 'TERTANGKAP!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isSuccess
                        ? 'Pemain $currentPlayer berhasil pulang\ndengan selamat! (+2 Poin)'
                        : 'Pemain $currentPlayer tertangkap\noleh penjaga!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Skor Total: $totalScore/10',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _nextPlayer();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor:
                          isSuccess
                              ? const Color(0xFF4caf50)
                              : const Color(0xFFf44336),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      currentPlayer >= 5 ? 'SELESAI' : 'LANJUT',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _nextPlayer() {
    if (currentPlayer >= 5) {
      setState(() {
        gameOver = true;
        gameStarted = false;
        gameMessage = 'Game Selesai! Skor: $totalScore/10';
      });
      _addVictoryParticles();
    } else {
      setState(() {
        currentPlayer++;
        playerCaught = false;
        playerCompleted = false;
        playerPosition = const Offset(200, 460);
        returningHome = false;
        hasReachedFinish = false;
        hasFinishPoint = false;
        gameMessage = 'Pemain $currentPlayer - Menuju Finish';
        playerVelocity = Offset.zero;
        joystickActive = false;
        knobPosition = Offset(joystickRadius + 20, joystickRadius + 20);
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF1a237e),
        appBar: AppBar(
          title: const Text(
            'Hadang',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF0d47a1),
          elevation: 0,
        ),
        body: Column(
          children: [
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
                      _buildStatusCard('Skor', '$totalScore/10'),
                    ],
                  ),
                  if (gameMessage.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            playerCaught
                                ? Colors.red.withOpacity(0.2)
                                : hasReachedFinish
                                ? Colors.green.withOpacity(0.2)
                                : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              playerCaught
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
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: GameFieldPainter(),
                        size: Size(fieldWidth, fieldHeight),
                      ),
                      CustomPaint(
                        painter: ParticlePainter(
                          particles: particles,
                          trailParticles: trailParticles,
                        ),
                        size: Size(fieldWidth, fieldHeight),
                      ),
                      AnimatedBuilder(
                        animation: _guardController,
                        builder: (context, child) {
                          return Stack(
                            children:
                                guards.map((guard) {
                                  Offset pos = guard.getCurrentPosition();
                                  return Positioned(
                                    left: pos.dx - guardSize / 2,
                                    top: pos.dy - guardSize / 2,
                                    child: Container(
                                      width: guardSize,
                                      height: guardSize,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          guardSize / 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.5),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          'assets/red.png',
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              color: Colors.red,
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
                          );
                        },
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 50),
                        left: playerPosition.dx - playerSize / 2,
                        top: playerPosition.dy - playerSize / 2,
                        child: Container(
                          width: playerMoving ? playerSize + 4 : playerSize,
                          height: playerMoving ? playerSize + 4 : playerSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(playerSize / 2),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    playerCaught
                                        ? Colors.red.withOpacity(0.6)
                                        : Colors.blue.withOpacity(0.6),
                                blurRadius: playerMoving ? 12 : 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/blue.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.blue,
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              height: 120,
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
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(gameOver ? 'Main Lagi' : 'Mulai Game'),
                    ),

                  if (gameStarted && !gameOver) ...[
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          key: joystickKey,
                          width: (joystickRadius + 20) * 2,
                          height: (joystickRadius + 20) * 2,
                          child: GestureDetector(
                            onPanStart:
                                (details) => _handleJoystickStart(
                                  details.globalPosition,
                                ),
                            onPanUpdate:
                                (details) => _handleJoystickUpdate(
                                  details.globalPosition,
                                ),
                            onPanEnd: (details) => _stopJoystick(),
                            onTapDown:
                                (details) => _handleJoystickStart(
                                  details.globalPosition,
                                ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(
                                  (joystickRadius + 20),
                                ),
                              ),
                              child: CustomPaint(
                                painter: JoystickPainter(
                                  center: Offset(
                                    joystickRadius + 20,
                                    joystickRadius + 20,
                                  ),
                                  knobPosition: knobPosition,
                                  joystickRadius: joystickRadius,
                                  knobRadius: knobRadius,
                                  isActive: joystickActive,
                                ),
                                size: Size(
                                  (joystickRadius + 20) * 2,
                                  (joystickRadius + 20) * 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  if (gameOver)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            totalScore >= 6
                                ? const Color(0xFF4caf50)
                                : totalScore >= 3
                                ? Colors.orange
                                : Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            totalScore == 10
                                ? '🏆 PERFECT! Semua pemain bolak-balik!'
                                : totalScore >= 6
                                ? '🎉 Bagus! $totalScore dari 10 poin berhasil!'
                                : totalScore >= 3
                                ? '👍 Lumayan! $totalScore dari 10 poin berhasil!'
                                : '😔 Coba lagi! Skor: $totalScore dari 10.',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Skor Akhir: $totalScore/10',
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
            style: const TextStyle(color: Colors.white70, fontSize: 12),
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

class Guard {
  final int id;
  final Offset basePosition;
  final bool isHorizontal;
  final double movementRange;
  final AnimationController controller;

  Guard(
    this.id,
    this.basePosition,
    this.isHorizontal,
    this.movementRange,
    this.controller,
  );

  Offset getCurrentPosition() {
    double progress = controller.value;
    double movement = sin(progress * 2 * pi + id * 0.5);

    if (isHorizontal) {
      double minX = 40;
      double maxX = 350;
      double x = minX + (maxX - minX) * ((movement + 1) / 2);
      return Offset(x, basePosition.dy);
    } else {
      double minY = 120;
      double maxY = 320;
      double y = minY + (maxY - minY) * ((movement + 1) / 2);
      return Offset(basePosition.dx, y);
    }
  }
}

class GameFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    paint.color = Colors.white;
    paint.strokeWidth = 3;

    for (int i = 1; i <= 4; i++) {
      double y = 80.0 * i + 20;
      canvas.drawLine(Offset(20, y), Offset(size.width - 20, y), paint);
    }

    canvas.drawLine(
      Offset(size.width / 2, 100),
      Offset(size.width / 2, 340),
      paint,
    );

    canvas.drawLine(Offset(20, 80), Offset(20, size.height - 80), paint);

    canvas.drawLine(
      Offset(size.width - 20, 80),
      Offset(size.width - 20, size.height - 80),
      paint,
    );

    paint.color = Colors.blue.withOpacity(0.2);
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, size.height - 80, size.width - 40, 60),
        const Radius.circular(8),
      ),
      paint,
    );

    paint.color = Colors.yellow.withOpacity(0.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, 10, size.width - 40, 55),
        const Radius.circular(8),
      ),
      paint,
    );

    final textStyle = TextStyle(
      color: Colors.white.withOpacity(0.8),
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    TextPainter startPainter = TextPainter(
      text: TextSpan(text: 'DEPAN', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    startPainter.layout();
    startPainter.paint(
      canvas,
      Offset((size.width - startPainter.width) / 2, size.height - 55),
    );

    TextPainter finishPainter = TextPainter(
      text: TextSpan(text: 'BELAKANG', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    finishPainter.layout();
    finishPainter.paint(
      canvas,
      Offset((size.width - finishPainter.width) / 2, 32),
    );
  }

  @override
  bool shouldRepaint(GameFieldPainter oldDelegate) {
    return false;
  }
}

enum ParticleShape { circle, square, diamond, star, triangle }

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
    velocity *= 0.98;
    rotation += rotationSpeed;
    life--;
  }

  double get opacity {
    return (life / maxLife).clamp(0.0, 1.0);
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final List<Particle> trailParticles;

  ParticlePainter({required this.particles, required this.trailParticles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (Particle particle in trailParticles) {
      paint.color = particle.color.withOpacity(particle.opacity * 0.4);
      _drawParticle(canvas, paint, particle, true);
    }

    for (Particle particle in particles) {
      paint.color = particle.color.withOpacity(particle.opacity * 0.3);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      _drawParticle(canvas, paint, particle, false);

      paint.maskFilter = null;
      paint.color = particle.color.withOpacity(particle.opacity);
      _drawParticle(canvas, paint, particle, false);
    }
  }

  void _drawParticle(
    Canvas canvas,
    Paint paint,
    Particle particle,
    bool isTrail,
  ) {
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
          Rect.fromCenter(
            center: Offset.zero,
            width: currentSize * 2,
            height: currentSize * 2,
          ),
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

    paint.color = Colors.white.withOpacity(0.3);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;
    canvas.drawCircle(center, joystickRadius, paint);

    paint.color = Colors.white.withOpacity(0.1);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, joystickRadius, paint);

    if (isActive) {
      paint.color = Colors.blue.withOpacity(0.4);
      paint.strokeWidth = 3;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(center, knobPosition, paint);
    }

    paint.color = Colors.black.withOpacity(0.2);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(knobPosition + const Offset(2, 2), knobRadius, paint);

    paint.style = PaintingStyle.fill;
    paint.color =
        isActive ? const Color(0xFF2196F3) : Colors.white.withOpacity(0.8);
    canvas.drawCircle(knobPosition, knobRadius, paint);

    paint.color = isActive ? Colors.white : Colors.grey[400]!;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawCircle(knobPosition, knobRadius, paint);

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
