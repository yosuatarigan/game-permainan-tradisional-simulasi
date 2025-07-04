// File: lib/main.dart - Updated with complete integration
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_permainan_tradisional_simulasi/services/error_handler.dart';
import 'package:game_permainan_tradisional_simulasi/services/performance_monitor.dart';
import 'package:game_permainan_tradisional_simulasi/utils/debug_tools.dart';
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
    
    // Print system info in debug mode
    // DebugTools.printSystemInfo();
    
    runApp(const HadangGameApp());
  } catch (e, stackTrace) {
    ErrorHandler.instance.handleGameError(
      'Failed to initialize app',
      details: e.toString(),
      stackTrace: stackTrace,
    );
    
    // Still try to run the app with basic functionality
    runApp(const HadangGameApp());
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

class HadangGameApp extends StatelessWidget {
  const HadangGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hadang - Permainan Tradisional',
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
      // Global error handling
      // builder: (context, child) {
      //   return Stack(
      //     children: [
      //       child ?? const SizedBox(),
      //       DebugTools.buildDebugOverlay(context),
      //     ],
      //   );
      // },
    );
  }
}

// // File: lib/screens/enhanced_game_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../game/enhanced_hadang_game.dart';
// import '../game/game_manager.dart';
// import '../utils/game_constants.dart';
// import '../widgets/game_ui_components.dart';
// import '../widgets/animated_widgets.dart';
// import '../services/audio_service.dart';
// import '../services/performance_monitor.dart';
// import 'game_result_screen.dart';

// class EnhancedGameScreen extends StatefulWidget {
//   const EnhancedGameScreen({super.key});

//   @override
//   State<EnhancedGameScreen> createState() => _EnhancedGameScreenState();
// }

// class _EnhancedGameScreenState extends State<EnhancedGameScreen> 
//     with WidgetsBindingObserver {
//   late EnhancedHadangGame game;
//   final _gameManager = GameManager.instance;
//   final _audio = AudioService.instance;
//   final _performance = PerformanceMonitor.instance;
  
//   bool _isPaused = false;
//   String _currentHint = 'Tap pemain biru untuk memilih, tap area untuk bergerak';
//   bool _showFloatingScore = false;
  
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _initializeGame();
//     _performance.startMonitoring();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _performance.stopMonitoring();
//     _gameManager.dispose();
//     super.dispose();
//   }

//   void _initializeGame() {
//     game = EnhancedHadangGame();
//     _gameManager.initializeGame(context);
    
//     // Setup game callbacks
//     _setupGameCallbacks();
//   }

//   void _setupGameCallbacks() {
//     // This would be implemented with a proper event system
//     // For now, we'll use periodic updates
    
//     // Listen for game events
//     game.addListener(() {
//       if (mounted) {
//         setState(() {
//           _isPaused = game.isPaused;
//         });
//       }
//     });
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
    
//     switch (state) {
//       case AppLifecycleState.paused:
//       case AppLifecycleState.detached:
//         if (!_isPaused) {
//           game.pauseResumeGame();
//         }
//         _audio.pauseBackgroundMusic();
//         break;
//       case AppLifecycleState.resumed:
//         _audio.resumeBackgroundMusic();
//         break;
//       default:
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: GameColors.backgroundColor,
//       appBar: AppBar(
//         title: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.sports_soccer, size: 20),
//             const SizedBox(width: 8),
//             const Text(
//               'Hadang',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             if (_isPaused) ...[
//               const SizedBox(width: 8),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.orange,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Text(
//                   'PAUSED',
//                   style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ],
//           ],
//         ),
//         backgroundColor: GameColors.primaryGreen,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         actions: [
//           IconButton(
//             onPressed: _showGameMenu,
//             icon: const Icon(Icons.menu),
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               GameColors.backgroundColor,
//               Colors.white,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Game HUD
//               GameHUD(
//                 teamAScore: game.scoreTeamA,
//                 teamBScore: game.scoreTeamB,
//                 timeText: _formatGameTime(),
//                 phaseText: _getPhaseText(),
//                 teamAHighlighted: _showFloatingScore,
//                 teamBHighlighted: _showFloatingScore,
//               ),
              
//               // Game Canvas
//               Expanded(
//                 child: Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Stack(
//                       children: [
//                         game.widget,
                        
//                         // Pause overlay
//                         if (_isPaused)
//                           Container(
//                             color: Colors.black.withOpacity(0.5),
//                             child: const Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.pause_circle_filled,
//                                     size: 80,
//                                     color: Colors.white,
//                                   ),
//                                   SizedBox(height: 16),
//                                   Text(
//                                     'PERMAINAN DIJEDA',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 24,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   SizedBox(height: 8),
//                                   Text(
//                                     'Tap Resume untuk melanjutkan',
//                                     style: TextStyle(
//                                       color: Colors.white70,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
              
//               // Hint Banner
//               HintBanner(
//                 hint: _currentHint,
//                 icon: Icons.lightbulb_outline,
//               ),
              
//               // Control Panel
//               GameControlPanel(
//                 onRestart: _restartGame,
//                 onPause: _pauseResumeGame,
//                 onSwitch: _switchTeams,
//                 isPaused: _isPaused,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _formatGameTime() {
//     // This would get actual time from game
//     return '15:00';
//   }

//   String _getPhaseText() {
//     // This would get actual phase from game
//     return 'Babak 1';
//   }

//   void _restartGame() {
//     HapticFeedback.mediumImpact();
//     _audio.playButtonClick();
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Restart Permainan'),
//         content: const Text('Apakah Anda yakin ingin memulai ulang permainan?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Batal'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               game.restartGame();
//               setState(() {
//                 _currentHint = 'Permainan dimulai ulang!';
//               });
//             },
//             child: const Text('Restart'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _pauseResumeGame() {
//     HapticFeedback.lightImpact();
//     _audio.playButtonClick();
    
//     game.pauseResumeGame();
//     setState(() {
//       _isPaused = game.isPaused;
//       _currentHint = _isPaused ? 'Permainan dijeda' : 'Permainan dilanjutkan';
//     });
//   }

//   void _switchTeams() {
//     HapticFeedback.mediumImpact();
//     _audio.playButtonClick();
    
//     game.switchTeams();
//     setState(() {
//       _currentHint = 'Tim bertukar peran!';
//     });
//   }

//   void _showGameMenu() {
//     HapticFeedback.lightImpact();
//     _audio.playButtonClick();
    
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               margin: const EdgeInsets.symmetric(vertical: 12),
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
            
//             const Text(
//               'Menu Permainan',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: GameColors.textPrimary,
//               ),
//             ),
            
//             const SizedBox(height: 20),
            
//             ListTile(
//               leading: const Icon(Icons.settings, color: GameColors.primaryGreen),
//               title: const Text('Pengaturan'),
//               onTap: () {
//                 Navigator.pop(context);
//                 // Navigate to settings
//               },
//             ),
            
//             ListTile(
//               leading: const Icon(Icons.help_outline, color: GameColors.primaryGreen),
//               title: const Text('Bantuan'),
//               onTap: () {
//                 Navigator.pop(context);
//                 // Show help
//               },
//             ),
            
//             ListTile(
//               leading: const Icon(Icons.exit_to_app, color: GameColors.errorColor),
//               title: const Text('Keluar'),
//               onTap: () {
//                 Navigator.pop(context);
//                 _exitGame();
//               },
//             ),
            
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   void _exitGame() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Keluar Permainan'),
//         content: const Text('Apakah Anda yakin ingin keluar? Progress akan hilang.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Batal'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             style: TextButton.styleFrom(foregroundColor: GameColors.errorColor),
//             child: const Text('Keluar'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showGameResult(bool playerWon, Map<String, dynamic> stats) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => GameResultScreen(
//           playerWon: playerWon,
//           playerScore: stats['playerScore'] ?? 0,
//           aiScore: stats['aiScore'] ?? 0,
//           gameDuration: stats['gameTime'] ?? Duration.zero,
//           gameStats: stats,
//         ),
//       ),
//     ).then((result) {
//       if (result == 'play_again') {
//         game.restartGame();
//       } else if (result == 'menu') {
//         Navigator.pop(context);
//       }
//     });
//   }
// }