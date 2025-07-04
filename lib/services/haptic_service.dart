
// File: lib/services/haptic_service.dart
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'local_storage_service.dart';

class HapticService {
  static HapticService? _instance;
  static HapticService get instance => _instance ??= HapticService._();
  HapticService._();

  final _storage = LocalStorageService.instance;

  // Game event haptics
  Future<void> playerMove() async {
    if (!_storage.hapticEnabled) return;
    
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Haptic feedback failed: $e');
      }
    }
  }

  Future<void> playerTouch() async {
    if (!_storage.hapticEnabled) return;
    
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Haptic feedback failed: $e');
      }
    }
  }

  Future<void> score() async {
    if (!_storage.hapticEnabled) return;
    
    try {
      await HapticFeedback.heavyImpact();
      // Double impact for score
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Haptic feedback failed: $e');
      }
    }
  }

  Future<void> gameEnd() async {
    if (!_storage.hapticEnabled) return;
    
    try {
      // Victory pattern
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Haptic feedback failed: $e');
      }
    }
  }

  Future<void> teamSwitch() async {
    if (!_storage.hapticEnabled) return;
    
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Haptic feedback failed: $e');
      }
    }
  }

  // UI haptics
  Future<void> buttonPress() async {
    if (!_storage.hapticEnabled) return;
    
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Haptic feedback failed: $e');
      }
    }
  }

  Future<void> error() async {
    if (!_storage.hapticEnabled) return;
    
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Haptic feedback failed: $e');
      }
    }
  }

  Future<void> success() async {
    if (!_storage.hapticEnabled) return;
    
    try {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.lightImpact();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Haptic feedback failed: $e');
      }
    }
  }

  Future<void> achievementUnlock() async {
    if (!_storage.hapticEnabled) return;
    
    try {
      // Special achievement pattern
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Haptic feedback failed: $e');
      }
    }
  }

  // Selection haptics
  Future<void> selectionChanged() async {
    if (!_storage.hapticEnabled) return;
    
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Haptic feedback failed: $e');
      }
    }
  }

  // Custom haptic patterns
  Future<void> customPattern(List<int> pattern) async {
    if (!_storage.hapticEnabled) return;
    
    try {
      for (int i = 0; i < pattern.length; i++) {
        switch (pattern[i]) {
          case 1:
            await HapticFeedback.lightImpact();
            break;
          case 2:
            await HapticFeedback.mediumImpact();
            break;
          case 3:
            await HapticFeedback.heavyImpact();
            break;
          case 0:
          default:
            await Future.delayed(const Duration(milliseconds: 100));
            break;
        }
        
        if (i < pattern.length - 1) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Custom haptic pattern failed: $e');
      }
    }
  }
}