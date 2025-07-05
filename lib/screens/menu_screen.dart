// File: lib/screens/menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_permainan_tradisional_simulasi/enchanced/enchanced_game_screen.dart';
import 'package:game_permainan_tradisional_simulasi/screens/setting_screen.dart';
import 'package:game_permainan_tradisional_simulasi/simple/simple_game_screen.dart';
import '../utils/game_constants.dart';
import '../services/local_storage_service.dart';
import 'game_screen.dart';
import 'statistics_screen.dart';
import 'about_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _initializeServices() async {
    await LocalStorageService.instance.initialize();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
        Expanded(
          flex: 3,
          child: _buildHeader(),
        ),
        
        // Menu Buttons
        Expanded(
          flex: 4,
          child: _buildMenuButtons(),
        ),
        
        // Footer
        Expanded(
          flex: 1,
          child: _buildFooter(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo/Icon
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
              Icons.sports_soccer,
              size: 60,
              color: GameColors.primaryGreen,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Title
          Text(
            GameTexts.appTitle,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            GameTexts.appSubtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
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
          _buildMenuButton(
            icon: Icons.play_arrow,
            label: GameTexts.playButton,
            color: GameColors.successColor,
            onPressed: _startGame,
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildMenuButton(
                  icon: Icons.bar_chart,
                  label: 'Statistik',
                  color: GameColors.infoColor,
                  onPressed: _showStatistics,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: _buildMenuButton(
                  icon: Icons.settings,
                  label: GameTexts.settingsButton,
                  color: GameColors.warningColor,
                  onPressed: _showSettings,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildMenuButton(
            icon: Icons.info_outline,
            label: GameTexts.aboutButton,
            color: GameColors.textSecondary,
            onPressed: _showAbout,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: color.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
          Text(
            '🎮 Melestarikan Budaya Indonesia',
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
    );
  }

  void _startGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EnhancedGameScreen()),
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
      MaterialPageRoute(builder: (context) =>  SettingsScreen()),
    );
  }

  void _showAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutScreen()),
    );
  }
}
