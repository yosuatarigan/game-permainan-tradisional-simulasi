// File: lib/screens/statistics_screen.dart
import 'package:flutter/material.dart';
import '../utils/game_constants.dart';
import '../services/local_storage_service.dart';
import '../services/statistics_service.dart';
import '../services/achievement_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _statisticsService = StatisticsService.instance;
  final _achievementService = AchievementService.instance;
  
  Map<String, dynamic> _statistics = {};
  List<Map<String, dynamic>> _achievements = [];
  List<Map<String, String>> _recentGames = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _statistics = _statisticsService.getStatistics();
      _achievements = _achievementService.getAllAchievements();
      _recentGames = _statisticsService.getRecentGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Statistik & Pencapaian'),
        backgroundColor: GameColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart), text: 'Statistik'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Pencapaian'),
            Tab(icon: Icon(Icons.history), text: 'Riwayat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatisticsTab(),
          _buildAchievementsTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Overview Cards
        _buildStatsOverview(),
        
        const SizedBox(height: 24),
        
        // Detailed Stats
        _buildDetailedStats(),
      ],
    );
  }

  Widget _buildStatsOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: GameColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Permainan',
                '${_statistics['gamesPlayed'] ?? 0}',
                Icons.sports_soccer,
                GameColors.infoColor,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: _buildStatCard(
                'Menang',
                '${_statistics['gamesWon'] ?? 0}',
                Icons.emoji_events,
                GameColors.successColor,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Win Rate',
                '${(_statistics['winRate'] ?? 0.0).toStringAsFixed(1)}%',
                Icons.trending_up,
                GameColors.warningColor,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: _buildStatCard(
                'Best Score',
                '${_statistics['bestScore'] ?? 0}',
                Icons.star,
                GameColors.errorColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStats() {
    final totalPlayTime = _statistics['totalPlayTime'] as Duration? ?? Duration.zero;
    final averageGameTime = _statistics['averageGameTime'] as Duration? ?? Duration.zero;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Statistik',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: GameColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildStatRow('Total Skor', '${_statistics['totalScore'] ?? 0}'),
            _buildStatRow('Rata-rata Skor', '${(_statistics['averageScore'] ?? 0.0).toStringAsFixed(1)}'),
            _buildStatRow('Total Waktu Bermain', _formatDuration(totalPlayTime)),
            _buildStatRow('Rata-rata Durasi', _formatDuration(averageGameTime)),
            _buildStatRow('Pencapaian Terbuka', '${_statistics['achievementPoints'] ?? 0} poin'),
            _buildStatRow('Progress Pencapaian', '${((_statistics['achievementProgress'] ?? 0.0) * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: GameColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Progress Overview
        _buildAchievementProgress(),
        
        const SizedBox(height: 24),
        
        // Achievement List
        ..._achievements.map((achievement) => _buildAchievementCard(achievement)),
      ],
    );
  }

  Widget _buildAchievementProgress() {
    final totalAchievements = _achievements.length;
    final unlockedCount = _achievements.where((a) => a['unlocked'] == true).length;
    final progress = totalAchievements > 0 ? unlockedCount / totalAchievements : 0.0;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Progress Pencapaian',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: GameColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8 * progress,
                  height: 20,
                  decoration: BoxDecoration(
                    color: GameColors.successColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              '$unlockedCount / $totalAchievements Terbuka',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: GameColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final isUnlocked = achievement['unlocked'] as bool;
    
    return Card(
      elevation: isUnlocked ? 4 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Opacity(
        opacity: isUnlocked ? 1.0 : 0.6,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isUnlocked ? GameColors.successColor : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    achievement['icon'] ?? '🏆',
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement['name'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? GameColors.textPrimary : Colors.grey[600],
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      achievement['description'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: isUnlocked ? Colors.grey[700] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              
              if (isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: GameColors.successColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${achievement['points']} poin',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Permainan Terakhir',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: GameColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        if (_recentGames.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.sports_soccer,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada permainan',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mulai bermain untuk melihat riwayat',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._recentGames.map((game) => _buildGameHistoryCard(game)),
      ],
    );
  }

  Widget _buildGameHistoryCard(Map<String, String> game) {
    final date = DateTime.tryParse(game['date'] ?? '');
    final score = game['score'] ?? '0';
    final duration = game['duration'] ?? '0';
    final winner = game['winner'] ?? '';
    final won = winner == 'Player';
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: won ? GameColors.successColor : GameColors.errorColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                won ? Icons.emoji_events : Icons.close,
                color: Colors.white,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    won ? 'Menang' : 'Kalah',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: won ? GameColors.successColor : GameColors.errorColor,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    'Skor: $score • Durasi: ${duration}m',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  if (date != null)
                    Text(
                      _formatDate(date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}j ${minutes}m';
    }
    return '${minutes}m';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Hari ini';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
