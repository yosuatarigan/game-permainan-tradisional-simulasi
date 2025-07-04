// File: lib/screens/tutorial_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/game_constants.dart';
import '../services/local_storage_service.dart';
import '../services/audio_service.dart';

class TutorialScreen extends StatefulWidget {
  final bool isFirstTime;
  final VoidCallback? onCompleted;

  const TutorialScreen({
    super.key,
    this.isFirstTime = false,
    this.onCompleted,
  });

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 7;
  
  final _storage = LocalStorageService.instance;
  final _audio = AudioService.instance;

  @override
  void initState() {
    super.initState();
    _audio.playMenuMusic();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Cara Bermain Hadang'),
        backgroundColor: GameColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!widget.isFirstTime)
            TextButton(
              onPressed: _completeTutorial,
              child: const Text(
                'Lewati',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / _totalPages,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(GameColors.primaryGreen),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: GameColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          // Tutorial content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
                _audio.playMenuTransition();
              },
              children: [
                _buildWelcomePage(),
                _buildObjectivePage(),
                _buildFieldLayoutPage(),
                _buildPlayerRolesPage(),
                _buildGameRulesPage(),
                _buildControlsPage(),
                _buildScoringPage(),
              ],
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  ElevatedButton.icon(
                    onPressed: _previousPage,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Sebelumnya'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                    ),
                  )
                else
                  const SizedBox(),
                
                ElevatedButton.icon(
                  onPressed: _currentPage == _totalPages - 1 ? _completeTutorial : _nextPage,
                  icon: Icon(_currentPage == _totalPages - 1 ? Icons.check : Icons.arrow_forward),
                  label: Text(_currentPage == _totalPages - 1 ? 'Selesai' : 'Selanjutnya'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GameColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return _buildTutorialPage(
      title: 'Selamat Datang!',
      content: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: GameColors.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sports_soccer,
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Hadang (Gobag Sodor)',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: GameColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Permainan tradisional Indonesia yang membutuhkan kecepatan, strategi, dan kerja sama tim.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GameColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '💡 Tutorial ini akan mengajarkan Anda cara bermain Hadang dengan aturan resmi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: GameColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectivePage() {
    return _buildTutorialPage(
      title: 'Tujuan Permainan',
      content: Column(
        children: [
          _buildObjectiveCard(
            '🎯',
            'Tujuan Utama',
            'Raih poin dengan cara melewati lapangan dari garis start hingga finish tanpa tersentuh penjaga.',
          ),
          
          const SizedBox(height: 16),
          
          _buildObjectiveCard(
            '🏆',
            'Cara Menang',
            'Tim dengan poin terbanyak setelah 2 x 15 menit menjadi pemenang.',
          ),
          
          const SizedBox(height: 16),
          
          _buildObjectiveCard(
            '🔄',
            'Pergantian Tim',
            'Tim bertukar peran (penyerang ↔ penjaga) ketika penyerang tersentuh penjaga.',
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLayoutPage() {
    return _buildTutorialPage(
      title: 'Layout Lapangan',
      content: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: GameColors.fieldBackground,
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Field sections
                _buildFieldSection(0, 0, '1'),
                _buildFieldSection(1, 0, '2'),
                _buildFieldSection(2, 0, '3'),
                _buildFieldSection(0, 1, '4'),
                _buildFieldSection(1, 1, '5'),
                _buildFieldSection(2, 1, '6'),
                
                // Guard lines
                _buildHorizontalLine(0.33),
                _buildHorizontalLine(0.67),
                _buildVerticalLine(0.5),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          const Text(
            'Lapangan berukuran 15m x 9m dibagi menjadi 6 petak',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: GameColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          _buildLegendItem(Colors.red, 'Garis Penjaga Horizontal (4 penjaga)'),
          _buildLegendItem(Colors.blue, 'Garis Penjaga Tengah/Sodor (1 penjaga)'),
        ],
      ),
    );
  }

  Widget _buildPlayerRolesPage() {
    return _buildTutorialPage(
      title: 'Peran Pemain',
      content: Column(
        children: [
          _buildRoleCard(
            '🛡️',
            'Penjaga (5 pemain)',
            'Bertugas menghalangi penyerang dengan cara menyentuh mereka. Penjaga harus tetap berada di garis yang ditentukan.',
            GameColors.teamAColor,
          ),
          
          const SizedBox(height: 20),
          
          _buildRoleCard(
            '🏃',
            'Penyerang (5 pemain)',
            'Berusaha melewati lapangan dari start hingga finish tanpa tersentuh penjaga. Harus bergerak maju dan tidak boleh keluar garis samping.',
            GameColors.teamBColor,
          ),
          
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.swap_horiz, color: Colors.orange, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tim bertukar peran setiap kali ada sentuhan atau pergantian babak',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameRulesPage() {
    return _buildTutorialPage(
      title: 'Aturan Penting',
      content: Column(
        children: [
          _buildRuleItem('✋', 'Sentuhan harus dengan telapak tangan terbuka'),
          _buildRuleItem('📍', 'Penjaga harus tetap dengan kedua kaki di garis'),
          _buildRuleItem('🚫', 'Penyerang tidak boleh keluar garis samping'),
          _buildRuleItem('⬆️', 'Penyerang harus bergerak maju (tidak boleh mundur)'),
          _buildRuleItem('⏱️', 'Batas waktu 2 menit tanpa gerakan = tukar tim'),
          _buildRuleItem('🔄', 'Maksimal 3 pergantian pemain per tim'),
          _buildRuleItem('⏳', 'Durasi: 2 x 15 menit + istirahat 5 menit'),
        ],
      ),
    );
  }

  Widget _buildControlsPage() {
    return _buildTutorialPage(
      title: 'Cara Bermain',
      content: Column(
        children: [
          _buildControlItem(
            Icons.touch_app,
            'Pilih Pemain',
            'Tap pada pemain penyerang untuk memilihnya',
          ),
          
          const SizedBox(height: 16),
          
          _buildControlItem(
            Icons.my_location,
            'Gerakkan Pemain',
            'Tap pada area tujuan untuk menggerakkan pemain yang dipilih',
          ),
          
          const SizedBox(height: 16),
          
          _buildControlItem(
            Icons.visibility,
            'Amati Penjaga',
            'Perhatikan pergerakan penjaga dan cari celah untuk melewati',
          ),
          
          const SizedBox(height: 16),
          
          _buildControlItem(
            Icons.speed,
            'Strategi',
            'Gunakan kecepatan dan timing yang tepat untuk menghindari sentuhan',
          ),
        ],
      ),
    );
  }

  Widget _buildScoringPage() {
    return _buildTutorialPage(
      title: 'Sistem Poin',
      content: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: GameColors.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GameColors.successColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_events,
                  size: 48,
                  color: GameColors.successColor,
                ),
                
                const SizedBox(height: 12),
                
                const Text(
                  '1 POIN',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: GameColors.successColor,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Untuk setiap crossing berhasil\n(start → finish atau finish → start)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildScoringRule('📍', 'Pemain harus mencapai garis finish'),
          _buildScoringRule('🔄', 'Bisa kembali ke start untuk poin tambahan'),
          _buildScoringRule('👥', 'Semua anggota tim bisa mencetak poin'),
          _buildScoringRule('🏆', 'Tim dengan poin terbanyak menang'),
          
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GameColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '🎉 Selamat! Anda siap bermain Hadang!\nSelamat melestarikan budaya Indonesia!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: GameColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialPage({required String title, required Widget content}) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: GameColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectiveCard(String emoji, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: GameColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: GameColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldSection(int x, int y, String number) {
    final width = 1.0 / 3;
    final height = 1.0 / 2;
    
    return Positioned(
      left: x * width * 300,
      top: y * height * 200,
      width: width * 300,
      height: height * 200,
      child: Container(
        decoration: BoxDecoration(
          color: (x + y) % 2 == 0 ? GameColors.fieldBackground : GameColors.fieldAlternate,
          border: Border.all(color: Colors.white.withOpacity(0.5)),
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalLine(double position) {
    return Positioned(
      left: 0,
      top: position * 200,
      right: 0,
      child: Container(
        height: 3,
        color: Colors.red,
      ),
    );
  }

  Widget _buildVerticalLine(double position) {
    return Positioned(
      left: position * 300,
      top: 0,
      bottom: 0,
      child: Container(
        width: 3,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 3,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: GameColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(String emoji, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String emoji, String rule) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              rule,
              style: const TextStyle(fontSize: 16, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlItem(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: GameColors.primaryGreen,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: GameColors.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoringRule(String emoji, String rule) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              rule,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _audio.playButtonClick();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _audio.playButtonClick();
    }
  }

  void _completeTutorial() {
    _storage.tutorialCompleted = true;
    _audio.playSuccessSound();
    
    if (widget.onCompleted != null) {
      widget.onCompleted!();
    } else {
      Navigator.pop(context);
    }
  }
}
