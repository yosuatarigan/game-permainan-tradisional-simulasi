// File: lib/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../utils/game_constants.dart';
import 'local_storage_service.dart';

class AudioService {
  static AudioService? _instance;
  static AudioService get instance => _instance ??= AudioService._();
  AudioService._();

  final AudioPlayer _soundPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  final Map<String, AudioPlayer> _soundCache = {};
  
  final _storage = LocalStorageService.instance;
  
  bool _isInitialized = false;
  bool _isMusicPlaying = false;
  String? _currentMusicTrack;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Set audio context for mobile
      await _soundPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _musicPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      
      // Initialize volume settings
      await updateVolumes();
      
      // Setup music player events
      _musicPlayer.onPlayerComplete.listen((_) {
        _isMusicPlaying = false;
      });
      
      _isInitialized = true;
      
      if (kDebugMode) {
        print('🎵 AudioService initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AudioService initialization failed: $e');
      }
    }
  }

  Future<void> updateVolumes() async {
    if (!_isInitialized) return;
    
    final soundVolume = _storage.soundEnabled ? _storage.soundVolume : 0.0;
    final musicVolume = _storage.musicEnabled ? _storage.musicVolume : 0.0;
    
    await _soundPlayer.setVolume(soundVolume);
    await _musicPlayer.setVolume(musicVolume);
    
    // Update cached players volume
    for (final player in _soundCache.values) {
      await player.setVolume(soundVolume);
    }
  }

  // Sound Effects
  Future<void> playSoundEffect(String soundPath, {double? volumeOverride}) async {
    if (!_isInitialized || !_storage.soundEnabled) return;
    
    try {
      final volume = volumeOverride ?? _storage.soundVolume;
      
      // Use cached player for frequently used sounds
      if (_soundCache.containsKey(soundPath)) {
        final player = _soundCache[soundPath]!;
        await player.setVolume(volume);
        await player.stop();
        await player.play(AssetSource(soundPath));
      } else {
        await _soundPlayer.setVolume(volume);
        await _soundPlayer.play(AssetSource(soundPath));
      }
      
      // Add haptic feedback for important sounds
      if (_storage.hapticEnabled) {
        _addHapticFeedback(soundPath);
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to play sound: $soundPath - $e');
      }
    }
  }

  void _addHapticFeedback(String soundPath) {
    // Add haptic feedback based on sound type
    if (soundPath.contains('touch') || soundPath.contains('collision')) {
      HapticFeedback.mediumImpact();
    } else if (soundPath.contains('score') || soundPath.contains('win')) {
      HapticFeedback.heavyImpact();
    } else if (soundPath.contains('move') || soundPath.contains('select')) {
      HapticFeedback.lightImpact();
    }
  }

  // Pre-cache frequently used sounds
  Future<void> preloadSounds(List<String> soundPaths) async {
    if (!_isInitialized) return;
    
    for (final soundPath in soundPaths) {
      try {
        final player = AudioPlayer();
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setVolume(_storage.soundVolume);
        _soundCache[soundPath] = player;
        
        if (kDebugMode) {
          print('🎵 Preloaded sound: $soundPath');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Failed to preload sound: $soundPath - $e');
        }
      }
    }
  }

  // Background Music
  Future<void> playBackgroundMusic(String musicPath, {bool loop = true}) async {
    if (!_isInitialized || !_storage.musicEnabled) return;
    
    try {
      // Stop current music if different track
      if (_isMusicPlaying && _currentMusicTrack != musicPath) {
        await stopBackgroundMusic();
      }
      
      if (!_isMusicPlaying) {
        await _musicPlayer.setVolume(_storage.musicVolume);
        await _musicPlayer.play(
          AssetSource(musicPath),
          mode: loop ? PlayerMode.mediaPlayer : PlayerMode.lowLatency,
        );
        
        if (loop) {
          await _musicPlayer.setReleaseMode(ReleaseMode.loop);
        }
        
        _isMusicPlaying = true;
        _currentMusicTrack = musicPath;
        
        if (kDebugMode) {
          print('🎵 Playing background music: $musicPath');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to play background music: $musicPath - $e');
      }
    }
  }

  Future<void> pauseBackgroundMusic() async {
    if (!_isInitialized || !_isMusicPlaying) return;
    
    try {
      await _musicPlayer.pause();
      if (kDebugMode) {
        print('⏸️ Background music paused');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to pause background music: $e');
      }
    }
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_isInitialized) return;
    
    try {
      if (_musicPlayer.state == PlayerState.paused) {
        await _musicPlayer.resume();
        if (kDebugMode) {
          print('▶️ Background music resumed');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to resume background music: $e');
      }
    }
  }

  Future<void> stopBackgroundMusic() async {
    if (!_isInitialized) return;
    
    try {
      await _musicPlayer.stop();
      _isMusicPlaying = false;
      _currentMusicTrack = null;
      
      if (kDebugMode) {
        print('⏹️ Background music stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to stop background music: $e');
      }
    }
  }

  // Game-specific sound methods
  Future<void> playPlayerMoveSound() async {
    await playSoundEffect(GameSounds.soundPlayerMove, volumeOverride: 0.6);
  }

  Future<void> playPlayerTouchSound() async {
    await playSoundEffect(GameSounds.soundPlayerTouch, volumeOverride: 0.8);
  }

  Future<void> playScoreSound() async {
    await playSoundEffect(GameSounds.soundScore, volumeOverride: 0.9);
  }

  Future<void> playWhistleSound() async {
    await playSoundEffect(GameSounds.soundWhistle, volumeOverride: 0.7);
  }

  Future<void> playHalfTimeSound() async {
    await playSoundEffect(GameSounds.soundHalfTime, volumeOverride: 0.8);
  }

  Future<void> playGameEndSound() async {
    await playSoundEffect(GameSounds.soundGameEnd, volumeOverride: 1.0);
  }

  Future<void> playTeamSwitchSound() async {
    await playSoundEffect(GameSounds.soundTeamSwitch, volumeOverride: 0.7);
  }

  // UI sound methods
  Future<void> playButtonClick() async {
    await playSoundEffect('audio/ui/button_click.mp3', volumeOverride: 0.5);
  }

  Future<void> playMenuTransition() async {
    await playSoundEffect('audio/ui/menu_transition.mp3', volumeOverride: 0.4);
  }

  Future<void> playAchievementUnlock() async {
    await playSoundEffect('audio/ui/achievement_unlock.mp3', volumeOverride: 0.8);
  }

  Future<void> playErrorSound() async {
    await playSoundEffect('audio/ui/error.mp3', volumeOverride: 0.6);
  }

  Future<void> playSuccessSound() async {
    await playSoundEffect('audio/ui/success.mp3', volumeOverride: 0.7);
  }

  // Music control methods
  Future<void> playMenuMusic() async {
    await playBackgroundMusic(GameSounds.musicMenu);
  }

  Future<void> playGameplayMusic() async {
    await playBackgroundMusic(GameSounds.musicGameplay);
  }

  // Cleanup
  Future<void> dispose() async {
    try {
      await _soundPlayer.dispose();
      await _musicPlayer.dispose();
      
      for (final player in _soundCache.values) {
        await player.dispose();
      }
      _soundCache.clear();
      
      _isInitialized = false;
      
      if (kDebugMode) {
        print('🗑️ AudioService disposed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AudioService disposal failed: $e');
      }
    }
  }

  // Settings update
  Future<void> onSettingsChanged() async {
    await updateVolumes();
    
    // Stop music if disabled
    if (!_storage.musicEnabled && _isMusicPlaying) {
      await stopBackgroundMusic();
    }
  }

  // Utility methods
  bool get isMusicPlaying => _isMusicPlaying;
  bool get isInitialized => _isInitialized;
  String? get currentMusicTrack => _currentMusicTrack;
  
  // Audio state for UI
  Map<String, dynamic> get audioState => {
    'isInitialized': _isInitialized,
    'isMusicPlaying': _isMusicPlaying,
    'currentTrack': _currentMusicTrack,
    'soundEnabled': _storage.soundEnabled,
    'musicEnabled': _storage.musicEnabled,
    'soundVolume': _storage.soundVolume,
    'musicVolume': _storage.musicVolume,
  };
}
