// File: lib/screens/splash_screen.dart (Updated for Game Selection)
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/game_constants.dart';
import '../services/asset_manager.dart';
import '../services/audio_service.dart';
import '../services/local_storage_service.dart';
import '../screens/game_selection_screen.dart';
import '../screens/egrang_tutorial_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;

  String _loadingText = 'Memuat permainan...';
  double _progress = 0.0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _playAudio();
    _initializeAnimations();
    _initializeApp();
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

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _logoController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Load assets
      setState(() {
        _loadingText = 'Memuat aset...';
        _progress = 0.2;
      });
      await AssetManager.instance.preloadAllAssets();

      await Future.delayed(const Duration(milliseconds: 500));

      // Step 2: Initialize audio
      setState(() {
        _loadingText = 'Menyiapkan audio...';
        _progress = 0.5;
      });
      await AudioService.instance.initialize();

      await Future.delayed(const Duration(milliseconds: 500));

      // Step 3: Load settings
      setState(() {
        _loadingText = 'Memuat pengaturan...';
        _progress = 0.8;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // Step 4: Complete
      setState(() {
        _loadingText = 'Siap bermain!';
        _progress = 1.0;
      });

      await _progressController.forward();
      await AudioService.instance.playMenuMusic();

      // Navigate to game selection
      await Future.delayed(const Duration(milliseconds: 1000));
      _navigateToNextScreen();
    } catch (e) {
      setState(() {
        _hasError = true;
        _loadingText = 'Terjadi kesalahan';
      });

      // Show error and continue anyway
      await Future.delayed(const Duration(seconds: 2));
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    final isFirstTime = !LocalStorageService.instance.tutorialCompleted;

    if (isFirstTime) {
      // Show Egrang tutorial for first-time users as introduction
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => EgrangTutorialScreen(
                onCompleted: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameSelectionScreen(),
                    ),
                  );
                },
              ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GameSelectionScreen()),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.primaryGreen,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [GameColors.primaryGreen, GameColors.secondaryGreen],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Logo section
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _logoAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.sports_handball,
                                  size: 60,
                                  color: GameColors.primaryGreen,
                                ),
                              ),

                              const SizedBox(height: 24),

                              const Text(
                                'PERMAINAN TRADISIONAL',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'Hadang & Egrang',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Loading section
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_hasError)
                      Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _loadingText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _navigateToNextScreen,
                            child: const Text(
                              'Lanjutkan',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          // Progress indicator
                          Container(
                            width: 200,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) {
                                return FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _progress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            _loadingText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            '${(_progress * 100).toInt()}%',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      '🇮🇩 Melestarikan Budaya Indonesia',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Made with ❤️ for Traditional Games',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
