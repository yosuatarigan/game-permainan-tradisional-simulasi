// File: lib/main.dart (Updated)
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_permainan_tradisional_simulasi/services/error_handler.dart';
import 'package:game_permainan_tradisional_simulasi/services/performance_monitor.dart';
import 'utils/game_constants.dart';
import 'screens/splash_screen.dart';
import 'services/asset_manager.dart';
import 'services/audio_service.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize error handling first
  ErrorHandler.instance.initialize();
  
  try {
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    // Initialize core services
    await _initializeServices();
    
    runApp(const TraditionalGamesApp());
  } catch (e, stackTrace) {
    ErrorHandler.instance.handleGameError(
      'Failed to initialize app',
      details: e.toString(),
      stackTrace: stackTrace,
    );
    
    // Still try to run the app with basic functionality
    runApp(const TraditionalGamesApp());
  }
}

Future<void> _initializeServices() async {
  // Initialize services in order
  await LocalStorageService.instance.initialize();
  await AssetManager.instance.initialize();
  await AudioService.instance.initialize();
  
  // Start performance monitoring in debug mode
  if (kDebugMode) {
    PerformanceMonitor.instance.startMonitoring();
  }
}

class TraditionalGamesApp extends StatelessWidget {
  const TraditionalGamesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Permainan Tradisional Indonesia',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: GameColors.primaryGreen,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: GameColors.primaryGreen,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: GameColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: GameColors.primaryGreen,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}