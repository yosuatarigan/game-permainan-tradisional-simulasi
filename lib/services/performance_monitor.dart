
// File: lib/services/performance_monitor.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'local_storage_service.dart';

class PerformanceMonitor {
  static PerformanceMonitor? _instance;
  static PerformanceMonitor get instance => _instance ??= PerformanceMonitor._();
  PerformanceMonitor._();

  final _storage = LocalStorageService.instance;
  
  // Performance metrics
  final List<double> _frameRates = [];
  final List<int> _memoryUsage = [];
  Timer? _monitoringTimer;
  
  bool _isMonitoring = false;
  int _frameCount = 0;
  DateTime _lastFrameTime = DateTime.now();
  
  // Performance thresholds
  static const double targetFPS = 60.0;
  static const double warningFPS = 45.0;
  static const double criticalFPS = 30.0;
  static const int maxMemoryMB = 200;

  void startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _frameRates.clear();
    _memoryUsage.clear();
    
    // Monitor frame rate
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
    
    // Monitor memory usage every second
    _monitoringTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkMemoryUsage();
    });
    
    if (kDebugMode) {
      print('📊 Performance monitoring started');
    }
  }

  void stopMonitoring() {
    if (!_isMonitoring) return;
    
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    
    if (kDebugMode) {
      print('📊 Performance monitoring stopped');
      _logPerformanceSummary();
    }
  }

  void _onFrame(Duration timestamp) {
    if (!_isMonitoring) return;
    
    final now = DateTime.now();
    final frameDuration = now.difference(_lastFrameTime);
    _lastFrameTime = now;
    
    if (frameDuration.inMilliseconds > 0) {
      final fps = 1000.0 / frameDuration.inMilliseconds;
      _frameRates.add(fps);
      
      // Keep only last 60 frames for rolling average
      if (_frameRates.length > 60) {
        _frameRates.removeAt(0);
      }
      
      // Check for performance issues
      if (fps < criticalFPS) {
        _onPerformanceIssue('Critical FPS drop: ${fps.toStringAsFixed(1)}');
      } else if (fps < warningFPS) {
        _onPerformanceWarning('Low FPS: ${fps.toStringAsFixed(1)}');
      }
    }
    
    _frameCount++;
    
    // Schedule next frame callback
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _checkMemoryUsage() {
    // Note: Flutter doesn't provide direct memory usage APIs
    // This is a placeholder for memory monitoring
    // In a real app, you might use platform channels or other methods
    
    final estimatedMemory = _estimateMemoryUsage();
    _memoryUsage.add(estimatedMemory);
    
    // Keep only last 60 measurements
    if (_memoryUsage.length > 60) {
      _memoryUsage.removeAt(0);
    }
    
    if (estimatedMemory > maxMemoryMB) {
      _onPerformanceIssue('High memory usage: ${estimatedMemory}MB');
    }
  }

  int _estimateMemoryUsage() {
    // Simple estimation based on frame count and other factors
    // This is not accurate but gives a rough idea
    final baseMemory = 50; // Base app memory
    final frameMemory = (_frameCount * 0.001).round(); // Estimated frame memory
    return baseMemory + frameMemory;
  }

  void _onPerformanceWarning(String message) {
    if (kDebugMode) {
      print('⚠️ Performance Warning: $message');
    }
  }

  void _onPerformanceIssue(String message) {
    if (kDebugMode) {
      print('🚨 Performance Issue: $message');
    }
    
    // Could trigger performance optimizations here
    _suggestOptimizations();
  }

  void _suggestOptimizations() {
    if (kDebugMode) {
      print('💡 Suggested optimizations:');
      print('  - Reduce visual effects');
      print('  - Lower animation quality');
      print('  - Decrease particle count');
      print('  - Optimize game logic');
    }
  }

  void _logPerformanceSummary() {
    if (_frameRates.isEmpty) return;
    
    final avgFPS = _frameRates.reduce((a, b) => a + b) / _frameRates.length;
    final minFPS = _frameRates.reduce((a, b) => a < b ? a : b);
    final maxFPS = _frameRates.reduce((a, b) => a > b ? a : b);
    
    print('📊 Performance Summary:');
    print('  Average FPS: ${avgFPS.toStringAsFixed(1)}');
    print('  Min FPS: ${minFPS.toStringAsFixed(1)}');
    print('  Max FPS: ${maxFPS.toStringAsFixed(1)}');
    print('  Total Frames: $_frameCount');
    
    if (_memoryUsage.isNotEmpty) {
      final avgMemory = _memoryUsage.reduce((a, b) => a + b) / _memoryUsage.length;
      print('  Average Memory: ${avgMemory.toStringAsFixed(1)}MB');
    }
  }

  // Public getters for performance data
  double get currentFPS {
    if (_frameRates.isEmpty) return 0.0;
    return _frameRates.last;
  }

  double get averageFPS {
    if (_frameRates.isEmpty) return 0.0;
    return _frameRates.reduce((a, b) => a + b) / _frameRates.length;
  }

  int get currentMemoryUsage {
    if (_memoryUsage.isEmpty) return 0;
    return _memoryUsage.last;
  }

  bool get isPerformanceGood {
    return averageFPS >= targetFPS && currentMemoryUsage < maxMemoryMB;
  }

  bool get isMonitoring => _isMonitoring;

  Map<String, dynamic> getPerformanceReport() {
    return {
      'isMonitoring': _isMonitoring,
      'frameCount': _frameCount,
      'currentFPS': currentFPS,
      'averageFPS': averageFPS,
      'minFPS': _frameRates.isNotEmpty ? _frameRates.reduce((a, b) => a < b ? a : b) : 0.0,
      'maxFPS': _frameRates.isNotEmpty ? _frameRates.reduce((a, b) => a > b ? a : b) : 0.0,
      'currentMemory': currentMemoryUsage,
      'averageMemory': _memoryUsage.isNotEmpty 
          ? _memoryUsage.reduce((a, b) => a + b) / _memoryUsage.length 
          : 0.0,
      'isPerformanceGood': isPerformanceGood,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
