// // File: lib/screens/simple_game_screen.dart (Fixed + Fallback)
// import 'package:flutter/material.dart';
// import 'package:game_permainan_tradisional_simulasi/simple/simple_hadang_game.dart';
// import '../utils/game_constants.dart';

// class SimpleGameScreen extends StatefulWidget {
//   const SimpleGameScreen({super.key});

//   @override
//   State<SimpleGameScreen> createState() => _SimpleGameScreenState();
// }

// class _SimpleGameScreenState extends State<SimpleGameScreen> {
//   SimpleHadangGame? game;
//   bool isPaused = false;
//   bool gameLoaded = false;
//   String loadingStatus = 'Initializing...';

//   @override
//   void initState() {
//     super.initState();
//     print('SimpleGameScreen: Initializing...');
//     _initializeGame();
//   }

//   void _initializeGame() async {
//     try {
//       setState(() {
//         loadingStatus = 'Creating game...';
//       });
      
//       game = SimpleHadangGame();
//       print('SimpleGameScreen: Game created successfully');
      
//       // Give it a moment to initialize
//       await Future.delayed(const Duration(milliseconds: 500));
      
//       setState(() {
//         gameLoaded = true;
//         loadingStatus = 'Game ready!';
//       });
      
//       print('SimpleGameScreen: Initialization complete');
      
//     } catch (e) {
//       print('SimpleGameScreen: Error creating game: $e');
//       setState(() {
//         loadingStatus = 'Error: $e';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('SimpleGameScreen: Building UI... (gameLoaded: $gameLoaded)');
    
//     return Scaffold(
//       backgroundColor: GameColors.backgroundColor,
//       appBar: AppBar(
//         title: const Text('Simple Hadang Test'),
//         backgroundColor: GameColors.primaryGreen,
//         foregroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           // Status Panel
//           Container(
//             margin: const EdgeInsets.all(16),
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: gameLoaded ? Colors.green.shade100 : Colors.orange.shade100,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: gameLoaded ? Colors.green : Colors.orange,
//                 width: 2,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   gameLoaded ? Icons.check_circle : Icons.hourglass_empty,
//                   color: gameLoaded ? Colors.green : Colors.orange,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   loadingStatus,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: gameLoaded ? Colors.green.shade800 : Colors.orange.shade800,
//                   ),
//                 ),
//               ],
//             ),
//           ),
          
//           // Score Panel
//           if (gameLoaded && game != null)
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _buildScoreCard('Red Team', game!.scoreTeamA, Colors.red),
//                   _buildScoreCard('Blue Team', game!.scoreTeamB, Colors.blue),
//                 ],
//               ),
//             ),
          
//           const SizedBox(height: 16),
          
//           // Game Area
//           Expanded(
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: _buildGameArea(),
//               ),
//             ),
//           ),
          
//           // Control Panel
//           Container(
//             margin: const EdgeInsets.all(16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildControlButton(
//                   'Restart',
//                   Colors.orange,
//                   gameLoaded ? () {
//                     game?.restartGame();
//                     setState(() {});
//                   } : null,
//                 ),
//                 _buildControlButton(
//                   isPaused ? 'Resume' : 'Pause',
//                   Colors.blue,
//                   gameLoaded ? () {
//                     game?.pauseResumeGame();
//                     isPaused = !isPaused;
//                     setState(() {});
//                   } : null,
//                 ),
//                 _buildControlButton(
//                   'Switch',
//                   Colors.green,
//                   gameLoaded ? () {
//                     game?.switchTeams();
//                     setState(() {});
//                   } : null,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGameArea() {
//     if (!gameLoaded || game == null) {
//       return _buildLoadingArea();
//     }
    
//     try {
//       // Try using Flame GameWidget
//       return GestureDetector(
//         onTapDown: (details) {
//           try {
//             print('Tap detected at: ${details.localPosition}');
//             game?.moveClosestAttacker(details.localPosition);
//           } catch (e) {
//             print('Error handling tap: $e');
//           }
//         },
//         child: game!.widget,
//       );
//     } catch (e) {
//       print('Error creating GameWidget: $e');
//       // Fallback to simple container
//       return _buildFallbackGameArea();
//     }
//   }

//   Widget _buildLoadingArea() {
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
//               loadingStatus,
//               style: TextStyle(
//                 color: GameColors.textPrimary,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFallbackGameArea() {
//     return GestureDetector(
//       onTapDown: (details) {
//         print('Fallback tap at: ${details.localPosition}');
//         game?.moveClosestAttacker(details.localPosition);
//       },
//       child: Container(
//         color: GameColors.fieldBackground,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 300,
//                 height: 200,
//                 decoration: BoxDecoration(
//                   color: GameColors.fieldAlternate,
//                   border: Border.all(color: Colors.white, width: 3),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Stack(
//                   children: [
//                     // Field label
//                     const Positioned(
//                       top: 10,
//                       left: 10,
//                       child: Text(
//                         'HADANG FIELD',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
                    
//                     // Simple players representation
//                     Positioned(
//                       bottom: 20,
//                       left: 20,
//                       child: Row(
//                         children: [
//                           for (int i = 0; i < 5; i++)
//                             Container(
//                               margin: const EdgeInsets.only(right: 8),
//                               width: 20,
//                               height: 20,
//                               decoration: BoxDecoration(
//                                 color: Colors.red,
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: Colors.white, width: 1),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   '${i + 1}',
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
                    
//                     // Blue team
//                     Positioned(
//                       top: 20,
//                       left: 20,
//                       child: Row(
//                         children: [
//                           for (int i = 0; i < 5; i++)
//                             Container(
//                               margin: const EdgeInsets.only(right: 8),
//                               width: 20,
//                               height: 20,
//                               decoration: BoxDecoration(
//                                 color: Colors.blue,
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: Colors.white, width: 1),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   '${i + 1}',
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
                    
//                     // Tap instruction
//                     const Positioned(
//                       bottom: 70,
//                       left: 0,
//                       right: 0,
//                       child: Text(
//                         'TAP TO INTERACT',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
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
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: color.withOpacity(0.3)),
//           ),
//           child: Text(
//             '$score',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildControlButton(String label, Color color, VoidCallback? onPressed) {
//     return Expanded(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         child: ElevatedButton(
//           onPressed: onPressed,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: onPressed != null ? color : Colors.grey,
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(vertical: 12),
//           ),
//           child: Text(label),
//         ),
//       ),
//     );
//   }
// }