// File: lib/screens/game_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/game_constants.dart';
import '../screens/menu_screen.dart';
import '../screens/egrang_menu_screen.dart';
import '../screens/about_screen.dart';

class GameSelectionScreen extends StatefulWidget {
  const GameSelectionScreen({super.key});

  @override
  State<GameSelectionScreen> createState() => _GameSelectionScreenState();
}

class _GameSelectionScreenState extends State<GameSelectionScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _animationController.forward();
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
                  child: _buildContent(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Header
        Expanded(flex: 2, child: _buildHeader()),
        
        // Game Selection Cards
        Expanded(flex: 4, child: _buildGameSelection()),
        
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
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
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
          
          // Text(
          //   'PERMAINAN TRADISIONAL',
          //   style: TextStyle(
          //     fontSize: 28,
          //     fontWeight: FontWeight.bold,
          //     color: Colors.white,
          //     shadows: [
          //       Shadow(
          //         offset: const Offset(2, 2),
          //         blurRadius: 4,
          //         color: Colors.black.withOpacity(0.4),
          //       ),
          //     ],
          //   ),
          // ),
          
          const SizedBox(height: 8),
          
          Text(
            'Pilih Permainan Favorit Anda',
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

  Widget _buildGameSelection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Hadang Game Card
          Expanded(
            child: _buildGameCard(
              title: 'HADANG',
              subtitle: 'Gobag Sodor • 2 Pemain',
              description: 'Permainan strategi menghindar dan menghadang',
              icon: Icons.sports_soccer,
              color: GameColors.teamBColor,
              onTap: _navigateToHadang,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Egrang Game Card
          Expanded(
            child: _buildGameCard(
              title: 'EGRANG',
              subtitle: 'Bamboo Stilts • 1-4 Pemain',
              description: 'Permainan keseimbangan dan ketangkasan',
              icon: Icons.height,
              color: GameColors.teamAColor,
              onTap: _navigateToEgrang,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // About Button
          _buildAboutButton(),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.1),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                // Game Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Game Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      
                      // const SizedBox(height: 4),
                      
                      // Text(
                      //   subtitle,
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.w600,
                      //     color: color.withOpacity(0.8),
                      //   ),
                      // ),
                      
                      // const SizedBox(height: 8),
                      
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: color.withOpacity(0.6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _navigateToAbout,
        icon: const Icon(Icons.info_outline),
        label: const Text('Tentang Aplikasi'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
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
            '🇮🇩 Melestarikan Budaya Indonesia 🇮🇩',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Made with ❤️ for Traditional Games',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToHadang() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MenuScreen()),
    );
  }

  void _navigateToEgrang() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EgrangMenuScreen()),
    );
  }

  void _navigateToAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AboutScreen()),
    );
  }
}