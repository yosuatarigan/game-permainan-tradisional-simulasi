// // File: lib/screens/game_screen.dart  
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../game/hadang_game.dart';
// import '../utils/game_constants.dart';

// class GameScreen extends StatefulWidget {
//   const GameScreen({super.key});

//   @override
//   State<GameScreen> createState() => _GameScreenState();
// }

// class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
//   late HadangGame game;
//   late AnimationController _scoreAnimationController;
//   late AnimationController _timeAnimationController;
  
//   String _currentTime = '15:00';
//   bool _isPaused = false;
//   bool _gameLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeGame();
//     _initializeAnimations();
//     _waitForGameLoad();
//   }

//   void _initializeGame() {
//     try {
//       game = HadangGame();
//     } catch (e) {
//       print('Error initializing game: $e');
//       game = HadangGame();
//     }
//   }

//   void _waitForGameLoad() {
//     // Wait for game to load before updating UI
//     Timer.periodic(const Duration(milliseconds: 100), (timer) {
//       if (game.isLoaded) {
//         setState(() {
//           _gameLoaded = true;
//         });
//         timer.cancel();
//       }
//     });
//   }

//   void _initializeAnimations() {
//     _scoreAnimationController = AnimationController(
//       duration: GameConstants.scoreEffectDuration,
//       vsync: this,
//     );
    
//     _timeAnimationController = AnimationController(
//       duration: const Duration(seconds: 1),
//       vsync: this,
//     )..repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _scoreAnimationController.dispose();
//     _timeAnimationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: GameColors.backgroundColor,
//       appBar: _buildAppBar(),
//       body: _buildGameBody(),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       title: Column(
//         children: [
//           Text(
//             GameTexts.appTitle,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//               fontSize: 20,
//             ),
//           ),
//           Text(
//             GameTexts.appSubtitle,
//             style: const TextStyle(
//               color: Colors.white70,
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//       backgroundColor: GameColors.primaryGreen,
//       elevation: 0,
//       centerTitle: true,
//       systemOverlayStyle: SystemUiOverlayStyle.light,
//       actions: [
//         IconButton(
//           icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
//           onPressed: _togglePause,
//           color: Colors.white,
//           tooltip: _isPaused ? GameTexts.resumeButton : GameTexts.pauseButton,
//         ),
//       ],
//     );
//   }

//   Widget _buildGameBody() {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             GameColors.backgroundColor,
//             GameColors.fieldBackground,
//           ],
//         ),
//       ),
//       child: SafeArea(
//         child: Column(
//           children: [
//             _buildGameInfoPanel(),
//             _buildGameCanvas(),
//             _buildControlPanel(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildGameInfoPanel() {
//     return Container(
//       margin: const EdgeInsets.all(GameConstants.uiElementSpacing),
//       padding: const EdgeInsets.all(GameConstants.uiElementSpacing),
//       decoration: BoxDecoration(
//         color: GameColors.cardBackground,
//         borderRadius: BorderRadius.circular(GameConstants.cardRadius),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8.0,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildScoreCard(
//             GameTexts.teamRed, 
//             _gameLoaded ? game.scoreTeamA : 0, 
//             GameColors.teamAColor
//           ),
//           _buildTimeCard(),
//           _buildScoreCard(
//             GameTexts.teamBlue, 
//             _gameLoaded ? game.scoreTeamB : 0, 
//             GameColors.teamBColor
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildScoreCard(String teamName, int score, Color color) {
//     return Column(
//       children: [
//         Text(
//           teamName,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: color,
//           ),
//         ),
//         const SizedBox(height: 4),
//         AnimatedBuilder(
//           animation: _scoreAnimationController,
//           builder: (context, child) {
//             return Transform.scale(
//               scale: 1.0 + (_scoreAnimationController.value * 0.1),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: color.withOpacity(0.3)),
//                 ),
//                 child: Text(
//                   '$score',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: color,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildTimeCard() {
//     return Column(
//       children: [
//         Text(
//           GameTexts.timeLabel,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w600,
//             color: GameColors.textSecondary,
//           ),
//         ),
//         const SizedBox(height: 4),
//         AnimatedBuilder(
//           animation: _timeAnimationController,
//           builder: (context, child) {
//             return Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: _isPaused 
//                     ? GameColors.warningColor.withOpacity(0.1)
//                     : GameColors.textSecondary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: _isPaused 
//                       ? GameColors.warningColor.withOpacity(0.3)
//                       : GameColors.textSecondary.withOpacity(0.3)
//                 ),
//               ),
//               child: Text(
//                 _gameLoaded ? game.gameTime.toGameTime() : _currentTime,
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: _isPaused ? GameColors.warningColor : GameColors.textSecondary,
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildGameCanvas() {
//     return Expanded(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: GameConstants.uiElementSpacing),
//         decoration: BoxDecoration(
//           color: GameColors.cardBackground,
//           borderRadius: BorderRadius.circular(GameConstants.cardRadius),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8.0,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(GameConstants.cardRadius),
//           child: _buildGameWidget(),
//         ),
//       ),
//     );
//   }

//   Widget _buildGameWidget() {
//     try {
//       // Show loading indicator if game not loaded
//       if (!_gameLoaded) {
//         return _buildLoadingWidget();
//       }
      
//       // Wrap dengan GestureDetector untuk tap handling
//       return GestureDetector(
//         onTapDown: (details) {
//           try {
//             if (_gameLoaded) {
//               // Call game method untuk move closest attacker
//               game.moveClosestAttacker(details.localPosition);
//             }
//           } catch (e) {
//             print('Error handling tap in UI: $e');
//           }
//         },
//         child: game.widget,
//       );
//     } catch (e) {
//       print('Error building game widget: $e');
//       return _buildErrorWidget();
//     }
//   }

//   Widget _buildLoadingWidget() {
//     return Container(
//       color: GameColors.fieldBackground,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(GameColors.primaryGreen),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Loading ${GameTexts.appTitle}...',
//               style: TextStyle(
//                 color: GameColors.textPrimary,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               GameTexts.appSubtitle,
//               style: TextStyle(
//                 color: GameColors.textSecondary,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorWidget() {
//     return Container(
//       color: GameColors.fieldBackground,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.sports_soccer,
//               size: 64,
//               color: GameColors.primaryGreen,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Loading ${GameTexts.appTitle}...',
//               style: TextStyle(
//                 color: GameColors.textPrimary,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               GameTexts.appSubtitle,
//               style: TextStyle(
//                 color: GameColors.textSecondary,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildControlPanel() {
//     return Container(
//       margin: const EdgeInsets.all(GameConstants.uiElementSpacing),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _buildControlButton(
//             GameTexts.restartButton,
//             Icons.refresh,
//             GameColors.warningColor,
//             _restartGame,
//           ),
//           _buildControlButton(
//             _isPaused ? GameTexts.resumeButton : GameTexts.pauseButton,
//             _isPaused ? Icons.play_arrow : Icons.pause,
//             GameColors.infoColor,
//             _togglePause,
//           ),
//           _buildControlButton(
//             GameTexts.switchButton,
//             Icons.swap_horiz,
//             GameColors.secondaryGreen,
//             _switchTeams,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildControlButton(
//     String label,
//     IconData icon,
//     Color color,
//     VoidCallback onPressed,
//   ) {
//     return Expanded(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         height: GameConstants.buttonHeight,
//         child: ElevatedButton.icon(
//           onPressed: onPressed,
//           icon: Icon(icon, size: 20),
//           label: Text(
//             label,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 12,
//             ),
//           ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: color,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(GameConstants.cardRadius),
//             ),
//             elevation: 2,
//           ),
//         ),
//       ),
//     );
//   }

//   // Game Control Methods
//   void _restartGame() {
//     if (GameSettings.hapticEnabled) {
//       HapticFeedback.mediumImpact();
//     }
    
//     try {
//       if (_gameLoaded) {
//         game.restartGame();
//         _currentTime = GameConstants.halfDuration.toGameTime();
//         _isPaused = false;
//         setState(() {});
        
//         _showGameMessage(GameTexts.gameStarted);
//       }
//     } catch (e) {
//       print('Error restarting game: $e');
//     }
//   }

//   void _togglePause() {
//     if (GameSettings.hapticEnabled) {
//       HapticFeedback.lightImpact();
//     }
    
//     try {
//       if (_gameLoaded) {
//         game.pauseResumeGame();
//         _isPaused = !_isPaused;
//         setState(() {});
        
//         _showGameMessage(_isPaused ? 'Game Paused' : 'Game Resumed');
//       }
//     } catch (e) {
//       print('Error toggling pause: $e');
//       _isPaused = !_isPaused;
//       setState(() {});
//     }
//   }

//   void _switchTeams() {
//     if (GameSettings.hapticEnabled) {
//       HapticFeedback.mediumImpact();
//     }
    
//     try {
//       if (_gameLoaded) {
//         game.switchTeams();
//         _scoreAnimationController.forward().then((_) {
//           _scoreAnimationController.reset();
//         });
        
//         _showGameMessage(GameTexts.teamSwitched);
//       }
//     } catch (e) {
//       print('Error switching teams: $e');
//     }
//   }

//   void _showGameMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: const TextStyle(color: Colors.white),
//         ),
//         backgroundColor: GameColors.primaryGreen,
//         duration: const Duration(seconds: 2),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(GameConstants.cardRadius),
//         ),
//       ),
//     );
//   }

//   // Game event listeners
//   void _onScoreAwarded(String teamName, int newScore) {
//     _scoreAnimationController.forward().then((_) {
//       _scoreAnimationController.reset();
//     });
    
//     _showGameMessage('${GameTexts.scoreAwarded} $teamName: $newScore');
//   }

//   void _onPlayerTouched(String guardTeam, String attackerTeam) {
//     if (GameSettings.hapticEnabled) {
//       HapticFeedback.heavyImpact();
//     }
    
//     _showGameMessage(GameTexts.playerTouched);
//   }

//   void _onGamePhaseChanged(String newPhase) {
//     String message;
//     switch (newPhase) {
//       case 'firstHalf':
//         message = GameTexts.gameStarted;
//         break;
//       case 'halfTime':
//         message = GameTexts.halfTimeReached;
//         break;
//       case 'secondHalf':
//         message = GameTexts.secondHalfStarted;
//         break;
//       case 'finished':
//         message = GameTexts.gameEnded;
//         break;
//       default:
//         message = 'Phase: $newPhase';
//     }
    
//     _showGameMessage(message);
//   }
// }