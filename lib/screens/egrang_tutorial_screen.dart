// File: lib/screens/egrang_tutorial_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/game_constants.dart';
import '../services/local_storage_service.dart';

class EgrangTutorialScreen extends StatefulWidget {
  final VoidCallback? onCompleted;

  const EgrangTutorialScreen({super.key, this.onCompleted});

  @override
  State<EgrangTutorialScreen> createState() => _EgrangTutorialScreenState();
}

class _EgrangTutorialScreenState extends State<EgrangTutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 7;

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
        title: const Text('Tutorial Egrang'),
        backgroundColor: GameColors.teamAColor,
        foregroundColor: Colors.white,
        elevation: 0,
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
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      GameColors.teamAColor,
                    ),
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
                HapticFeedback.lightImpact();
              },
              children: [
                _buildWelcomePage(),
                _buildAboutPage(),
                _buildEquipmentPage(),
                _buildFieldPage(),
                _buildRulesPage(),
                _buildTechniquePage(),
                _buildBenefitsPage(),
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
                  onPressed: _currentPage == _totalPages - 1
                      ? _completeTutorial
                      : _nextPage,
                  icon: Icon(
                    _currentPage == _totalPages - 1
                        ? Icons.check
                        : Icons.arrow_forward,
                  ),
                  label: Text(
                    _currentPage == _totalPages - 1 ? 'Selesai' : 'Selanjutnya',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GameColors.teamAColor,
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
              color: GameColors.teamAColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.height,
              size: 60,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'EGRANG',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: GameColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Bamboo Stilts',
            style: TextStyle(
              fontSize: 16,
              color: GameColors.teamAColor,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Permainan tradisional Indonesia yang membutuhkan keseimbangan, '
            'keberanian, dan ketekunan untuk berjalan menggunakan bambu tinggi.',
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
              color: GameColors.teamAColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '🎋 Tutorial ini akan mengajarkan Anda cara bermain Egrang '
              'dengan aman dan menyenangkan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: GameColors.teamAColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutPage() {
    return _buildTutorialPage(
      title: 'Tentang Egrang',
      content: Column(
        children: [
          _buildInfoCard(
            '🎯',
            'Tujuan',
            'Berjalan menggunakan dua batang bambu tinggi dari start hingga finish tanpa terjatuh.',
          ),

          const SizedBox(height: 16),

          _buildInfoCard(
            '🏆',
            'Cara Menang',
            'Pemain yang mencapai garis finish terlebih dahulu tanpa terjatuh adalah pemenang.',
          ),

          const SizedBox(height: 16),

          _buildInfoCard(
            '👥',
            'Jumlah Pemain',
            'Dapat dimainkan 1-4 pemain, baik secara individu maupun berkelompok.',
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GameColors.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GameColors.successColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: GameColors.successColor,
                  size: 32,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tahukah Anda?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: GameColors.successColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Egrang sudah ada sejak zaman dahulu dan dimainkan '
                  'di berbagai daerah di Indonesia dengan nama yang berbeda-beda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentPage() {
    return _buildTutorialPage(
      title: 'Peralatan Egrang',
      content: Column(
        children: [
          // Egrang Illustration
          Container(
            width: 200,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.brown.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.brown.shade300),
            ),
            child: Stack(
              children: [
                // Egrang sticks
                Positioned(
                  left: 80,
                  top: 20,
                  child: Container(
                    width: 8,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.brown.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Positioned(
                  right: 80,
                  top: 20,
                  child: Container(
                    width: 8,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.brown.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                
                // Footrests
                Positioned(
                  left: 60,
                  bottom: 80,
                  child: Container(
                    width: 30,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.brown.shade600,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Positioned(
                  right: 60,
                  bottom: 80,
                  child: Container(
                    width: 30,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.brown.shade600,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                // Labels
                const Positioned(
                  right: 10,
                  top: 30,
                  child: Text(
                    '2.5m',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
                const Positioned(
                  right: 10,
                  bottom: 120,
                  child: Text(
                    '50cm',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildSpecItem('📏', 'Tinggi', '2.5 meter'),
          const SizedBox(height: 8),
          _buildSpecItem('🦶', 'Pijakan', '50 cm dari bawah'),
          const SizedBox(height: 8),
          _buildSpecItem('🎋', 'Bahan', 'Bambu atau kayu kuat'),
          const SizedBox(height: 8),
          _buildSpecItem('🔧', 'Permukaan', 'Rata dan anti selip'),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GameColors.warningColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GameColors.warningColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: GameColors.warningColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pastikan egrang dalam kondisi baik dan aman sebelum digunakan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
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

  Widget _buildFieldPage() {
    return _buildTutorialPage(
      title: 'Lapangan Egrang',
      content: Column(
        children: [
          // Field diagram
          Container(
            width: 280,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Stack(
              children: [
                // Track lines
                for (int i = 0; i <= 5; i++)
                  Positioned(
                    left: 20 + (i * 40),
                    top: 20,
                    bottom: 20,
                    child: Container(
                      width: 2,
                      color: Colors.green.shade400,
                    ),
                  ),

                // Start line
                Positioned(
                  left: 20,
                  bottom: 20,
                  right: 20,
                  child: Container(
                    height: 4,
                    color: Colors.blue.shade600,
                    child: const Center(
                      child: Text(
                        'START',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // Finish line
                Positioned(
                  left: 20,
                  top: 20,
                  right: 20,
                  child: Container(
                    height: 4,
                    color: Colors.red.shade600,
                    child: const Center(
                      child: Text(
                        'FINISH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // Distance label
                const Positioned(
                  right: 10,
                  top: 80,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      '50 meter',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),

                // Track labels
                for (int i = 1; i <= 5; i++)
                  Positioned(
                    left: 15 + (i * 40),
                    top: 100,
                    child: Text(
                      '$i',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildFieldSpec('📐', 'Panjang Lapangan', '50 meter'),
          const SizedBox(height: 8),
          _buildFieldSpec('📏', 'Jumlah Lintasan', '5 lintasan'),
          const SizedBox(height: 8),
          _buildFieldSpec('🏁', 'Garis Start & Finish', 'Jelas dan terlihat'),
          const SizedBox(height: 8),
          _buildFieldSpec('🌱', 'Permukaan', 'Rata, datar, dan aman'),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GameColors.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '💡 Lapangan sebaiknya berada di area terbuka dengan '
              'permukaan yang tidak licin untuk keamanan pemain.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: GameColors.infoColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesPage() {
    return _buildTutorialPage(
      title: 'Aturan Permainan',
      content: Column(
        children: [
          _buildRuleItem('🚦', 'Start', 'Tunggu aba-aba: "Bersedia... Siap... Ya!"'),
          _buildRuleItem('⚖️', 'Keseimbangan', 'Jaga keseimbangan, jangan sampai terjatuh'),
          _buildRuleItem('🏁', 'Finish', 'Capai garis finish terlebih dahulu untuk menang'),
          _buildRuleItem('❌', 'Penalti', 'Terjatuh atau menyentuh tanah = gugur'),
          _buildRuleItem('🏃', 'Gerakan', 'Berjalan atau berlari sesuai kemampuan'),
          _buildRuleItem('🎯', 'Lintasan', 'Tetap di lintasan masing-masing'),
          _buildRuleItem('🤝', 'Fair Play', 'Tidak boleh mengganggu pemain lain'),
          _buildRuleItem('🏆', 'Pemenang', 'Yang pertama sampai finish tanpa jatuh'),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GameColors.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GameColors.errorColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.warning,
                  color: GameColors.errorColor,
                  size: 24,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Keselamatan Utama!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: GameColors.errorColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selalu gunakan perlengkapan pelindung dan bermain di area yang aman. '
                  'Berhenti bermain jika merasa lelah atau tidak nyaman.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechniquePage() {
    return _buildTutorialPage(
      title: 'Teknik Bermain',
      content: Column(
        children: [
          _buildTechniqueStep(
            '1',
            'Menaiki Egrang',
            'Pegang egrang dengan kuat, letakkan kaki di pijakan, '
            'gunakan dinding atau teman untuk berpegangan saat naik.',
          ),

          const SizedBox(height: 16),

          _buildTechniqueStep(
            '2',
            'Mencari Keseimbangan',
            'Berdiri tegak, pandangan lurus ke depan, rileks, '
            'rasakan keseimbangan sebelum mulai berjalan.',
          ),

          const SizedBox(height: 16),

          _buildTechniqueStep(
            '3',
            'Melangkah',
            'Angkat satu kaki perlahan, gerakkan egrang ke depan, '
            'turunkan dengan hati-hati, ulangi dengan kaki lainnya.',
          ),

          const SizedBox(height: 16),

          _buildTechniqueStep(
            '4',
            'Menjaga Ritme',
            'Temukan ritme yang nyaman, jangan terburu-buru, '
            'fokus pada keseimbangan daripada kecepatan.',
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GameColors.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates, 
                    color: GameColors.successColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tips: Mulai dengan egrang yang lebih pendek, '
                    'lalu tingkatkan secara bertahap',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
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

  Widget _buildBenefitsPage() {
    return _buildTutorialPage(
      title: 'Manfaat Bermain Egrang',
      content: Column(
        children: [
          _buildBenefitCard(
            '⚖️',
            'Keseimbangan',
            'Melatih keseimbangan tubuh dan koordinasi gerak',
            GameColors.successColor,
          ),

          const SizedBox(height: 12),

          _buildBenefitCard(
            '🧠',
            'Fokus & Konsentrasi',
            'Meningkatkan kemampuan fokus dan konsentrasi',
            GameColors.infoColor,
          ),

          const SizedBox(height: 12),

          _buildBenefitCard(
            '💪',
            'Kekuatan',
            'Memperkuat otot kaki dan otot inti tubuh',
            GameColors.teamAColor,
          ),

          const SizedBox(height: 12),

          _buildBenefitCard(
            '😊',
            'Kepercayaan Diri',
            'Membangun keberanian dan rasa percaya diri',
            GameColors.warningColor,
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GameColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '🎉 Selamat! Anda telah menyelesaikan tutorial Egrang!\n'
              'Sekarang Anda siap untuk mencoba bermain Egrang dengan aman dan menyenangkan. '
              'Ingat, latihan membuat sempurna!',
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
          Expanded(child: SingleChildScrollView(child: content)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String emoji, String title, String description) {
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
              color: GameColors.teamAColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
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

  Widget _buildSpecItem(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildFieldSpec(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem(String emoji, String title, String rule) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  rule,
                  style: const TextStyle(fontSize: 13, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechniqueStep(String number, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GameColors.teamAColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: GameColors.teamAColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                    fontSize: 13,
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

  Widget _buildBenefitCard(String emoji, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
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
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
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
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeTutorial() {
    if (widget.onCompleted != null) {
      widget.onCompleted!();
    } else {
      Navigator.pop(context);
    }
  }
}