
// File: lib/screens/about_screen.dart
import 'package:flutter/material.dart';
import '../utils/game_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Tentang Hadang'),
        backgroundColor: GameColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Info
          _buildAppInfo(),
          
          const SizedBox(height: 24),
          
          // Game Info
          _buildGameInfo(),
          
          const SizedBox(height: 24),
          
          // Rules
          _buildRulesSection(),
          
          const SizedBox(height: 24),
          
          // Credits
          _buildCreditsSection(),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.sports_soccer,
              size: 80,
              color: GameColors.primaryGreen,
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Hadang',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: GameColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              'Permainan Tradisional Indonesia Digital',
              style: TextStyle(
                fontSize: 16,
                color: GameColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: GameColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: GameColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tentang Permainan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: GameColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Hadang (juga dikenal sebagai Gobag Sodor atau Galah Asin) adalah permainan tradisional Indonesia yang telah dimainkan turun-temurun. Permainan ini melatih ketangkasan, strategi, dan kerja sama tim.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Game ini dikembangkan berdasarkan aturan resmi Permainan Olahraga Tradisional Hadang dengan menggunakan teknologi Flutter untuk melestarikan budaya Indonesia.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aturan Dasar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: GameColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildRuleItem('🏟️', 'Lapangan berukuran 15m x 9m dibagi menjadi 6 petak'),
            _buildRuleItem('👥', '2 tim dengan 5 pemain aktif + 3 cadangan'),
            _buildRuleItem('⏱️', 'Durasi 2 x 15 menit dengan istirahat 5 menit'),
            _buildRuleItem('🛡️', 'Penjaga harus tetap di garis yang ditentukan'),
            _buildRuleItem('🏃', 'Penyerang berusaha melewati tanpa tersentuh'),
            _buildRuleItem('✋', 'Sentuhan harus dengan telapak tangan terbuka'),
            _buildRuleItem('🔄', 'Tim bertukar peran saat ada sentuhan'),
            _buildRuleItem('🏆', '1 poin untuk setiap crossing berhasil'),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Credits',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: GameColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildCreditItem('🎮', 'Game Engine', 'Flutter & Flame'),
            _buildCreditItem('📋', 'Aturan Resmi', 'Permainan Olahraga Tradisional Hadang'),
            _buildCreditItem('🏛️', 'Cultural Heritage', 'Indonesia Traditional Games'),
            _buildCreditItem('❤️', 'Made with', 'Love for Indonesian Culture'),
            
            const SizedBox(height: 16),
            
            const Center(
              child: Text(
                '🇮🇩 Melestarikan Budaya Indonesia 🇮🇩',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: GameColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditItem(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
