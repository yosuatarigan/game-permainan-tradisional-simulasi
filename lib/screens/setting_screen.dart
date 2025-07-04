
// File: lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/game_constants.dart';
import '../services/local_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = LocalStorageService.instance;
  
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _hapticEnabled = true;
  bool _showMovementTrails = true;
  bool _showRuleHints = true;
  double _soundVolume = 0.8;
  double _musicVolume = 0.6;
  String _difficulty = 'normal';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _soundEnabled = _storage.soundEnabled;
      _musicEnabled = _storage.musicEnabled;
      _hapticEnabled = _storage.hapticEnabled;
      _showMovementTrails = _storage.showMovementTrails;
      _showRuleHints = _storage.showRuleHints;
      _soundVolume = _storage.soundVolume;
      _musicVolume = _storage.musicVolume;
      _difficulty = _storage.difficulty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: GameColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Audio'),
          _buildAudioSettings(),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader('Gameplay'),
          _buildGameplaySettings(),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader('Visual'),
          _buildVisualSettings(),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader('Data'),
          _buildDataSettings(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: GameColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildAudioSettings() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSwitchTile(
              'Suara Efek',
              'Aktifkan sound effects dalam permainan',
              Icons.volume_up,
              _soundEnabled,
              (value) {
                setState(() => _soundEnabled = value);
                _storage.soundEnabled = value;
                if (value) HapticFeedback.lightImpact();
              },
            ),
            
            if (_soundEnabled) ...[
              const SizedBox(height: 8),
              _buildSliderTile(
                'Volume Suara',
                Icons.volume_down,
                Icons.volume_up,
                _soundVolume,
                (value) {
                  setState(() => _soundVolume = value);
                  _storage.soundVolume = value;
                },
              ),
            ],
            
            const Divider(),
            
            _buildSwitchTile(
              'Musik Latar',
              'Aktifkan musik background',
              Icons.music_note,
              _musicEnabled,
              (value) {
                setState(() => _musicEnabled = value);
                _storage.musicEnabled = value;
              },
            ),
            
            if (_musicEnabled) ...[
              const SizedBox(height: 8),
              _buildSliderTile(
                'Volume Musik',
                Icons.music_off,
                Icons.library_music,
                _musicVolume,
                (value) {
                  setState(() => _musicVolume = value);
                  _storage.musicVolume = value;
                },
              ),
            ],
            
            const Divider(),
            
            _buildSwitchTile(
              'Getaran',
              'Aktifkan haptic feedback',
              Icons.vibration,
              _hapticEnabled,
              (value) {
                setState(() => _hapticEnabled = value);
                _storage.hapticEnabled = value;
                if (value) HapticFeedback.mediumImpact();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameplaySettings() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDropdownTile(
              'Tingkat Kesulitan',
              'Pilih tingkat kesulitan AI',
              Icons.psychology,
              _difficulty,
              GameDifficulty.difficultyLevels.map((key, value) => 
                MapEntry(key, value['name'] as String)),
              (value) {
                if (value != null) {
                  setState(() => _difficulty = value);
                  _storage.difficulty = value;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualSettings() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSwitchTile(
              'Trail Gerakan',
              'Tampilkan jejak pergerakan pemain',
              Icons.timeline,
              _showMovementTrails,
              (value) {
                setState(() => _showMovementTrails = value);
                _storage.showMovementTrails = value;
              },
            ),
            
            const Divider(),
            
            _buildSwitchTile(
              'Petunjuk Aturan',
              'Tampilkan hint aturan permainan',
              Icons.help_outline,
              _showRuleHints,
              (value) {
                setState(() => _showRuleHints = value);
                _storage.showRuleHints = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSettings() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildActionTile(
              'Reset Statistik',
              'Hapus semua data statistik permainan',
              Icons.bar_chart,
              Colors.orange,
              _showResetStatisticsDialog,
            ),
            
            const Divider(),
            
            _buildActionTile(
              'Reset Achievement',
              'Hapus semua pencapaian yang sudah dibuka',
              Icons.emoji_events,
              Colors.red,
              _showResetAchievementsDialog,
            ),
            
            const Divider(),
            
            _buildActionTile(
              'Reset Semua',
              'Kembalikan ke pengaturan awal',
              Icons.restore,
              Colors.red.shade700,
              _showResetAllDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: GameColors.primaryGreen),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: GameColors.primaryGreen,
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    IconData iconMin,
    IconData iconMax,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(iconMin, color: Colors.grey),
          Expanded(
            child: Slider(
              value: value,
              onChanged: onChanged,
              activeColor: GameColors.primaryGreen,
              inactiveColor: Colors.grey[300],
            ),
          ),
          Icon(iconMax, color: GameColors.primaryGreen),
          const SizedBox(width: 8),
          Text(
            '${(value * 100).round()}%',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    Map<String, String> options,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: GameColors.primaryGreen),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: options.entries.map((entry) {
          return DropdownMenuItem(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
      onTap: onPressed,
    );
  }

  Future<void> _showResetStatisticsDialog() async {
    final confirmed = await _showConfirmDialog(
      'Reset Statistik',
      'Apakah Anda yakin ingin menghapus semua data statistik permainan?',
    );
    
    if (confirmed == true) {
      await _storage.resetStatistics();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Statistik berhasil direset')),
        );
      }
    }
  }

  Future<void> _showResetAchievementsDialog() async {
    final confirmed = await _showConfirmDialog(
      'Reset Achievement',
      'Apakah Anda yakin ingin menghapus semua pencapaian?',
    );
    
    if (confirmed == true) {
      await _storage.resetAchievements();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Achievement berhasil direset')),
        );
      }
    }
  }

  Future<void> _showResetAllDialog() async {
    final confirmed = await _showConfirmDialog(
      'Reset Semua Data',
      'Apakah Anda yakin ingin menghapus SEMUA data termasuk pengaturan, statistik, dan achievement? Tindakan ini tidak dapat dibatalkan.',
    );
    
    if (confirmed == true) {
      await _storage.resetAll();
      _loadSettings(); // Reload default settings
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua data berhasil direset')),
        );
      }
    }
  }

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}