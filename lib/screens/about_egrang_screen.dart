// File: lib/screens/about_egrang_screen.dart
import 'package:flutter/material.dart';
import '../utils/game_constants.dart';

class AboutEgrangScreen extends StatelessWidget {
  const AboutEgrangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Tentang Egrang'),
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
              Icons.height,
              size: 80,
              color: GameColors.primaryGreen,
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Egrang',
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
              'Egrang adalah permainan tradisional Indonesia yang menggunakan dua batang bambu atau kayu sebagai penyangga kaki. Permainan ini melatih keseimbangan, koordinasi, dan kepercayaan diri anak-anak.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Game ini dikembangkan untuk melestarikan warisan budaya Indonesia dengan teknologi Flutter, memberikan pengalaman bermain egrang secara digital yang tetap mengutamakan nilai-nilai tradisional.',
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
            
            _buildRuleItem('🎋', 'Gunakan dua batang egrang dengan tinggi yang sama'),
            _buildRuleItem('👣', 'Pijakan kaki harus sejajar dan kuat'),
            _buildRuleItem('⚖️', 'Jaga keseimbangan dengan postur tubuh tegak'),
            _buildRuleItem('👀', 'Pandangan lurus ke depan, jangan melihat kaki'),
            _buildRuleItem('🚶', 'Mulai dengan langkah kecil dan perlahan'),
            _buildRuleItem('🤝', 'Boleh dibantu teman saat belajar'),
            _buildRuleItem('🏁', 'Menang jika berhasil mencapai garis finish'),
            _buildRuleItem('⚠️', 'Jatuh dari egrang berarti harus mulai lagi'),
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
            _buildCreditItem('🎋', 'Traditional Game', 'Egrang Bambu Indonesia'),
            _buildCreditItem('🏛️', 'Cultural Heritage', 'Indonesia Traditional Games'),
            _buildCreditItem('⚖️', 'Skills Developed', 'Balance & Coordination'),
            
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