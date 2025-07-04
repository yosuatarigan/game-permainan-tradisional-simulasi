
// File: lib/services/error_handler.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/game_constants.dart';

class ErrorHandler {
  static ErrorHandler? _instance;
  static ErrorHandler get instance => _instance ??= ErrorHandler._();
  ErrorHandler._();

  final List<AppError> _errors = [];
  final Map<String, int> _errorCounts = {};

  void initialize() {
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };
    
    if (kDebugMode) {
      print('🛡️ Error handler initialized');
    }
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    final error = AppError(
      type: ErrorType.flutter,
      message: details.exception.toString(),
      stackTrace: details.stack.toString(),
      timestamp: DateTime.now(),
    );
    
    _logError(error);
    
    // In debug mode, still show the red screen
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  }

  void handleGameError(String message, {String? details, StackTrace? stackTrace}) {
    final error = AppError(
      type: ErrorType.game,
      message: message,
      details: details,
      stackTrace: stackTrace?.toString(),
      timestamp: DateTime.now(),
    );
    
    _logError(error);
  }

  void handleAudioError(String message, {String? details}) {
    final error = AppError(
      type: ErrorType.audio,
      message: message,
      details: details,
      timestamp: DateTime.now(),
    );
    
    _logError(error);
  }

  void handleNetworkError(String message, {String? details}) {
    final error = AppError(
      type: ErrorType.network,
      message: message,
      details: details,
      timestamp: DateTime.now(),
    );
    
    _logError(error);
  }

  void _logError(AppError error) {
    _errors.add(error);
    _errorCounts[error.type.name] = (_errorCounts[error.type.name] ?? 0) + 1;
    
    // Keep only last 100 errors
    if (_errors.length > 100) {
      _errors.removeAt(0);
    }
    
    if (kDebugMode) {
      print('❌ ${error.type.name.toUpperCase()} ERROR: ${error.message}');
      if (error.details != null) {
        print('   Details: ${error.details}');
      }
      if (error.stackTrace != null) {
        print('   Stack: ${error.stackTrace}');
      }
    }
  }

  void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: GameColors.errorColor),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: GameColors.errorColor,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Tutup',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  List<AppError> get recentErrors => List.unmodifiable(_errors.take(10));
  Map<String, int> get errorCounts => Map.unmodifiable(_errorCounts);
  
  bool get hasErrors => _errors.isNotEmpty;
  
  void clearErrors() {
    _errors.clear();
    _errorCounts.clear();
  }

  Map<String, dynamic> getErrorReport() {
    return {
      'totalErrors': _errors.length,
      'errorCounts': _errorCounts,
      'recentErrors': _errors.take(5).map((e) => {
        'type': e.type.name,
        'message': e.message,
        'timestamp': e.timestamp.toIso8601String(),
      }).toList(),
      'hasErrors': hasErrors,
    };
  }
}

class AppError {
  final ErrorType type;
  final String message;
  final String? details;
  final String? stackTrace;
  final DateTime timestamp;

  AppError({
    required this.type,
    required this.message,
    this.details,
    this.stackTrace,
    required this.timestamp,
  });
}

enum ErrorType {
  flutter,
  game,
  audio,
  network,
  storage,
  unknown,
}
