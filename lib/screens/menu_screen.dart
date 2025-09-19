// File: lib/screens/menu_screen.dart - Updated with Game Navigation
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_permainan_tradisional_simulasi/gobaksodor/gobak_sodor_game.dart';
import 'package:game_permainan_tradisional_simulasi/screens/setting_screen.dart';
import 'package:game_permainan_tradisional_simulasi/screens/tutorial_screen.dart';
import '../utils/game_constants.dart';
import '../services/local_storage_service.dart';
import '../game/hadang_game_screen.dart'; // Import game screen
import 'statistics_screen.dart';
import 'about_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeServices();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  Future<void> _initializeServices() async {
    await LocalStorageService.instance.initialize();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              GameColors.primaryGreen,
              GameColors.secondaryGreen,
              GameColors.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildMenuContent(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMenuContent() {
    return Column(
      children: [
        // Header
        Expanded(flex: 3, child: _buildEnhancedHeader()),

        // Menu Buttons
        Expanded(flex: 4, child: _buildEnhancedMenuButtons()),

        // Footer
        Expanded(flex: 1, child: _buildEnhancedFooter()),
      ],
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Logo
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.sports_handball,
                        size: 70,
                        color: GameColors.primaryGreen,
                      ),
                      Positioned(
                        bottom: 25,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '2P',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Enhanced Title
          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [Colors.white, Colors.yellow.shade200],
                ).createShader(bounds),
            child: Text(
              GameTexts.appTitle,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: const Offset(3, 3),
                    blurRadius: 6,
                    color: Colors.black.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Enhanced Subtitle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              GameTexts.appSubtitle + ' • 2 Players',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMenuButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main Play Button - Enhanced
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.03),
                child: _buildEnhancedMenuButton(
                  icon: Icons.play_arrow,
                  label: 'MAIN SEKARANG',
                  subtitle: '2 Pemain • Layar Sama',
                  color: GameColors.successColor,
                  onPressed: _startGame, // Updated to navigate to game
                  isMainButton: true,
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Secondary buttons row
          Row(
            children: [
              Expanded(
                child: _buildEnhancedMenuButton(
                  icon: Icons.school,
                  label: 'Tutorial',
                  subtitle: 'Cara Bermain',
                  color: Colors.purple[600]!,
                  onPressed: _showTutorial,
                ),
              ),

              // const SizedBox(width: 16),

              // Expanded(
              //   child: _buildEnhancedMenuButton(
              //     icon: Icons.bar_chart,
              //     label: 'Statistik',
              //     subtitle: 'Riwayat Game',
              //     color: GameColors.infoColor,
              //     onPressed: _showStatistics,
              //   ),
              // ),
            ],
          ),

          const SizedBox(height: 16),

          // Bottom buttons row
          Row(
            children: [
              // Expanded(
              //   child: _buildEnhancedMenuButton(
              //     icon: Icons.settings,
              //     label: GameTexts.settingsButton,
              //     subtitle: 'Pengaturan',
              //     color: GameColors.warningColor,
              //     onPressed: _showSettings,
              //   ),
              // ),

              // const SizedBox(width: 16),

              Expanded(
                child: _buildEnhancedMenuButton(
                  icon: Icons.info_outline,
                  label: GameTexts.aboutButton,
                  subtitle: 'Tentang Game',
                  color: GameColors.warningColor,
                  onPressed: _showAbout,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMenuButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onPressed,
    bool isMainButton = false,
  }) {
    return Container(
      width: double.infinity,
      height: isMainButton ? 80 : 70,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: isMainButton ? 12 : 8,
          shadowColor: color.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMainButton ? 20 : 16),
          ),
          padding: const EdgeInsets.all(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: isMainButton ? 28 : 24),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isMainButton ? 20 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (isMainButton) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sports_handball,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '🎮 Melestarikan Budaya Indonesia',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Made with ❤️ for Traditional Games • v2.0 Enhanced',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // UPDATED: Navigate to game screen
  void _startGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GobakSodorGame(),
      ),
    );
  }

  void _showTutorial() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => TutorialScreen(
              isFirstTime: false,
              onCompleted: () {
                Navigator.pop(context);
              },
            ),
      ),
    );
  }

  void _showStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StatisticsScreen()),
    );
  }

  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  }

  void _showAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutScreen()),
    );
  }
}