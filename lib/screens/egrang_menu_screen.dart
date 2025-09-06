// File: lib/screens/egrang_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_permainan_tradisional_simulasi/screens/egrang_game_screen.dart';
import '../utils/game_constants.dart';
import '../services/local_storage_service.dart';
import '../screens/egrang_tutorial_screen.dart';
import '../screens/about_screen.dart';

class EgrangMenuScreen extends StatefulWidget {
  const EgrangMenuScreen({super.key});

  @override
  State<EgrangMenuScreen> createState() => _EgrangMenuScreenState();
}

class _EgrangMenuScreenState extends State<EgrangMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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
              GameColors.teamAColor,
              GameColors.teamAColor.withOpacity(0.8),
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
        Expanded(flex: 3, child: _buildHeader()),

        // Menu Buttons
        Expanded(flex: 4, child: _buildMenuButtons()),

        // Footer
        Expanded(flex: 1, child: _buildFooter()),
      ],
    );
  }

  Widget _buildHeader() {
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
                  child: const Icon(
                    Icons.height,
                    size: 70,
                    color: GameColors.teamAColor,
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
                  colors: [Colors.white, Colors.orange.shade200],
                ).createShader(bounds),
            child: const Text(
              'EGRANG',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
            child: const Text(
              'Bamboo Stilts • Keseimbangan & Ketangkasan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main Play Button
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.03),
                child: _buildMenuButton(
                  icon: Icons.play_arrow,
                  label: 'MAIN SEKARANG',
                  subtitle: 'Segera Hadir!',
                  color: Colors.grey.shade600,
                  onPressed: () {
                    //push
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>  EgrangRaceScreen(),
                      ),
                    );
                  },
                  isMainButton: true,
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Tutorial Button
          _buildMenuButton(
            icon: Icons.school,
            label: 'Tutorial',
            subtitle: 'Cara Bermain Egrang',
            color: Colors.purple[600]!,
            onPressed: _showTutorial,
          ),

          const SizedBox(height: 16),

          // About Button
          _buildMenuButton(
            icon: Icons.info_outline,
            label: 'Tentang Egrang',
            subtitle: 'Sejarah & Aturan',
            color: GameColors.warningColor,
            onPressed: _showAbout,
          ),

          const SizedBox(height: 16),

          // Back Button
          _buildMenuButton(
            icon: Icons.arrow_back,
            label: 'Kembali',
            subtitle: 'Pilih Game Lain',
            color: GameColors.textSecondary,
            onPressed: _goBack,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
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

  Widget _buildFooter() {
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
                const Icon(Icons.height, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  '🎋 Permainan Keseimbangan Tradisional',
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
            'Melatih Keseimbangan & Kepercayaan Diri',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.construction, color: GameColors.warningColor),
                const SizedBox(width: 8),
                const Text('Segera Hadir!'),
              ],
            ),
            content: const Text(
              'Game Egrang sedang dalam pengembangan. '
              'Sementara ini, Anda bisa mempelajari cara bermain '
              'melalui tutorial yang tersedia.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showTutorial();
                },
                child: const Text('Lihat Tutorial'),
              ),
            ],
          ),
    );
  }

  void _showTutorial() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EgrangTutorialScreen(
              onCompleted: () {
                Navigator.pop(context);
              },
            ),
      ),
    );
  }

  void _showAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutScreen()),
    );
  }

  void _goBack() {
    Navigator.pop(context);
  }
}
