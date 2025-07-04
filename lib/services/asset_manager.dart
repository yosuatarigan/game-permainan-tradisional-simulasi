// File: lib/services/asset_manager.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../utils/game_constants.dart';

class AssetManager {
  static AssetManager? _instance;
  static AssetManager get instance => _instance ??= AssetManager._();
  AssetManager._();

  final Map<String, String> _loadedAssets = {};
  final Map<String, bool> _assetStatus = {};
  bool _isInitialized = false;

  // Asset paths - Update these based on your actual asset structure
  static const Map<String, String> assetPaths = {
    // Audio files
    'player_move': 'audio/player_move.mp3',
    'player_touch': 'audio/player_touch.mp3',
    'score': 'audio/score.mp3',
    'whistle': 'audio/whistle.mp3',
    'half_time': 'audio/half_time.mp3',
    'game_end': 'audio/game_end.mp3',
    'team_switch': 'audio/team_switch.mp3',
    'gameplay_music': 'audio/gameplay_music.mp3',
    'menu_music': 'audio/menu_music.mp3',
    'button_click': 'audio/ui/button_click.mp3',
    'menu_transition': 'audio/ui/menu_transition.mp3',
    'achievement_unlock': 'audio/ui/achievement_unlock.mp3',
    'error': 'audio/ui/error.mp3',
    'success': 'audio/ui/success.mp3',
    
    // Image files (if any)
    'field_texture': 'images/field_texture.png',
    'player_red': 'images/player_red.png',
    'player_blue': 'images/player_blue.png',
    'logo': 'images/logo.png',
    
    // Font files
    'poppins_regular': 'fonts/Poppins-Regular.ttf',
    'poppins_medium': 'fonts/Poppins-Medium.ttf',
    'poppins_bold': 'fonts/Poppins-Bold.ttf',
  };

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _preloadCriticalAssets();
      _isInitialized = true;
      
      if (kDebugMode) {
        print('📦 AssetManager initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AssetManager initialization failed: $e');
      }
    }
  }

  Future<void> _preloadCriticalAssets() async {
    // Preload essential audio files for smooth gameplay
    final criticalAssets = [
      'player_move',
      'player_touch',
      'score',
      'whistle',
    ];

    for (final assetKey in criticalAssets) {
      await _loadAsset(assetKey);
    }
  }

  Future<void> _loadAsset(String assetKey) async {
    if (_assetStatus[assetKey] == true) return;

    final assetPath = assetPaths[assetKey];
    if (assetPath == null) {
      if (kDebugMode) {
        print('⚠️ Asset key not found: $assetKey');
      }
      return;
    }

    try {
      // For audio files, we just mark them as available
      // The actual loading is handled by AudioService
      if (assetPath.contains('.mp3') || assetPath.contains('.wav')) {
        _assetStatus[assetKey] = true;
        _loadedAssets[assetKey] = assetPath;
        
        if (kDebugMode) {
          print('🎵 Audio asset marked as available: $assetPath');
        }
        return;
      }

      // For other assets (images, fonts), check if they exist
      await rootBundle.load(assetPath);
      _assetStatus[assetKey] = true;
      _loadedAssets[assetKey] = assetPath;
      
      if (kDebugMode) {
        print('📦 Asset loaded: $assetPath');
      }
    } catch (e) {
      _assetStatus[assetKey] = false;
      
      if (kDebugMode) {
        print('❌ Failed to load asset: $assetPath - $e');
      }
    }
  }

  Future<void> preloadAllAssets() async {
    final futures = assetPaths.keys.map((key) => _loadAsset(key));
    await Future.wait(futures);
    
    if (kDebugMode) {
      final loaded = _assetStatus.values.where((status) => status).length;
      final total = _assetStatus.length;
      print('📦 Preloaded $loaded/$total assets');
    }
  }

  String? getAssetPath(String assetKey) {
    return _loadedAssets[assetKey];
  }

  bool isAssetLoaded(String assetKey) {
    return _assetStatus[assetKey] == true;
  }

  bool get isInitialized => _isInitialized;

  Map<String, bool> get assetStatus => Map.unmodifiable(_assetStatus);

  // Generate default assets if missing
  void generateDefaultAssets() {
    // This method can be used to create fallback assets or
    // generate procedural assets if files are missing
    
    final missingAssets = assetPaths.keys
        .where((key) => _assetStatus[key] != true)
        .toList();
    
    if (missingAssets.isNotEmpty && kDebugMode) {
      print('⚠️ Missing assets: ${missingAssets.join(', ')}');
      print('💡 Consider creating these assets or using fallbacks');
    }
  }
}
