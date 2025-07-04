// // File: lib/widgets/animated_widgets.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import '../utils/game_constants.dart';

// class AnimatedScoreCard extends StatelessWidget {
//   final String teamName;
//   final int score;
//   final Color color;
//   final bool isHighlighted;

//   const AnimatedScoreCard({
//     super.key,
//     required this.teamName,
//     required this.score,
//     required this.color,
//     this.isHighlighted = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: GameConstants.uiTransitionDuration,
//       curve: Curves.easeInOut,
//       decoration: BoxDecoration(
//         color: isHighlighted ? color.withOpacity(0.2) : color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: isHighlighted ? color : color.withOpacity(0.3),
//           width: isHighlighted ? 2 : 1,
//         ),
//         boxShadow: isHighlighted ? [
//           BoxShadow(
//             color: color.withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ] : null,
//       ),
//       child: Column(
//         children: [
//           Text(
//             teamName,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: color,
//             ),
//           )
//             .animate(target: isHighlighted ? 1 : 0)
//             .scale(begin: 1.0, end: 1.1)
//             .then()
//             .scale(begin: 1.1, end: 1.0),
          
//           const SizedBox(height: 4),
          
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Text(
//               '$score',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             )
//               .animate(target: isHighlighted ? 1 : 0)
//               .fadeIn(duration: 200.ms)
//               .scale(begin: 1.0, end: 1.3)
//               .then()
//               .scale(begin: 1.3, end: 1.0),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class PulsingButton extends StatefulWidget {
//   final String label;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onPressed;
//   final bool isPrimary;

//   const PulsingButton({
//     super.key,
//     required this.label,
//     required this.icon,
//     required this.color,
//     required this.onPressed,
//     this.isPrimary = false,
//   });

//   @override
//   State<PulsingButton> createState() => _PulsingButtonState();
// }

// class _PulsingButtonState extends State<PulsingButton> with TickerProviderStateMixin {
//   late AnimationController _pulseController;
//   bool _isPressed = false;

//   @override
//   void initState() {
//     super.initState();
//     _pulseController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );
    
//     if (widget.isPrimary) {
//       _pulseController.repeat();
//     }
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) => setState(() => _isPressed = true),
//       onTapUp: (_) => setState(() => _isPressed = false),
//       onTapCancel: () => setState(() => _isPressed = false),
//       child: AnimatedBuilder(
//         animation: _pulseController,
//         builder: (context, child) {
//           return Transform.scale(
//             scale: _isPressed ? 0.95 : (widget.isPrimary ? 
//               1.0 + (0.05 * _pulseController.value) : 1.0),
//             child: Container(
//               width: double.infinity,
//               height: 60,
//               decoration: BoxDecoration(
//                 color: widget.color,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: widget.color.withOpacity(0.3),
//                     blurRadius: _isPressed ? 4 : 8,
//                     offset: Offset(0, _isPressed ? 2 : 4),
//                   ),
//                 ],
//               ),
//               child: Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   onTap: widget.onPressed,
//                   borderRadius: BorderRadius.circular(16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         widget.icon,
//                         color: Colors.white,
//                         size: 24,
//                       ),
//                       const SizedBox(width: 12),
//                       Text(
//                         widget.label,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class FloatingScoreIndicator extends StatefulWidget {
//   final int points;
//   final Color color;
//   final VoidCallback? onComplete;

//   const FloatingScoreIndicator({
//     super.key,
//     required this.points,
//     required this.color,
//     this.onComplete,
//   });

//   @override
//   State<FloatingScoreIndicator> createState() => _FloatingScoreIndicatorState();
// }

// class _FloatingScoreIndicatorState extends State<FloatingScoreIndicator>
//     with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.0,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
//     ));

//     _slideAnimation = Tween<Offset>(
//       begin: Offset.zero,
//       end: const Offset(0, -3),
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.elasticOut,
//     ));

//     _scaleAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
//     ));

//     _controller.forward().then((_) {
//       if (widget.onComplete != null) {
//         widget.onComplete!();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return FadeTransition(
//           opacity: _fadeAnimation,
//           child: SlideTransition(
//             position: _slideAnimation,
//             child: ScaleTransition(
//               scale: _scaleAnimation,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: widget.color,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: widget.color.withOpacity(0.4),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Text(
//                   '+${widget.points}',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class GameLoadingIndicator extends StatefulWidget {
//   final String loadingText;
//   final Color color;

//   const GameLoadingIndicator({
//     super.key,
//     this.loadingText = 'Memuat permainan...',
//     this.color = GameColors.primaryGreen,
//   });

//   @override
//   State<GameLoadingIndicator> createState() => _GameLoadingIndicatorState();
// }

// class _GameLoadingIndicatorState extends State<GameLoadingIndicator>
//     with TickerProviderStateMixin {
//   late AnimationController _rotationController;
//   late AnimationController _pulseController;

//   @override
//   void initState() {
//     super.initState();
//     _rotationController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat();

//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _rotationController.dispose();
//     _pulseController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           AnimatedBuilder(
//             animation: _rotationController,
//             builder: (context, child) {
//               return Transform.rotate(
//                 angle: _rotationController.value * 2 * 3.14159,
//                 child: Container(
//                   width: 60,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: widget.color,
//                       width: 4,
//                     ),
//                     gradient: SweepGradient(
//                       colors: [
//                         widget.color,
//                         widget.color.withOpacity(0.1),
//                         widget.color,
//                       ],
//                     ),
//                   ),
//                   child: Icon(
//                     Icons.sports_soccer,
//                     color: widget.color,
//                     size: 30,
//                   ),
//                 ),
//               );
//             },
//           ),
          
//           const SizedBox(height: 24),
          
//           AnimatedBuilder(
//             animation: _pulseController,
//             builder: (context, child) {
//               return Opacity(
//                 opacity: 0.5 + (0.5 * _pulseController.value),
//                 child: Text(
//                   widget.loadingText,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: widget.color,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AchievementPopup extends StatefulWidget {
//   final Map<String, dynamic> achievement;
//   final VoidCallback? onDismiss;

//   const AchievementPopup({
//     super.key,
//     required this.achievement,
//     this.onDismiss,
//   });

//   @override
//   State<AchievementPopup> createState() => _AchievementPopupState();
// }

// class _AchievementPopupState extends State<AchievementPopup>
//     with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 2500),
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
//     ));

//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
//     ));

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, -1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.1, 0.5, curve: Curves.elasticOut),
//     ));

//     _controller.forward().then((_) {
//       Future.delayed(const Duration(seconds: 3), () {
//         if (mounted) {
//           _controller.reverse().then((_) {
//             if (widget.onDismiss != null) {
//               widget.onDismiss!();
//             }
//           });
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return FadeTransition(
//           opacity: _fadeAnimation,
//           child: SlideTransition(
//             position: _slideAnimation,
//             child: ScaleTransition(
//               scale: _scaleAnimation,
//               child: Container(
//                 margin: const EdgeInsets.all(16),
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.amber.shade100,
//                       Colors.amber.shade50,
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.amber, width: 2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.amber.withOpacity(0.3),
//                       blurRadius: 16,
//                       offset: const Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 60,
//                       height: 60,
//                       decoration: BoxDecoration(
//                         color: Colors.amber,
//                         shape: BoxShape.circle,
//                       ),
//                       child: Center(
//                         child: Text(
//                           widget.achievement['icon'] ?? '🏆',
//                           style: const TextStyle(fontSize: 30),
//                         ),
//                       ),
//                     ),
                    
//                     const SizedBox(width: 16),
                    
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Text(
//                             'Achievement Unlocked!',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.amber,
//                             ),
//                           ),
                          
//                           const SizedBox(height: 4),
                          
//                           Text(
//                             widget.achievement['name'] ?? '',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
                          
//                           const SizedBox(height: 2),
                          
//                           Text(
//                             '${widget.achievement['points']} poin',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class CountdownTimer extends StatefulWidget {
//   final int seconds;
//   final VoidCallback? onComplete;
//   final Color color;

//   const CountdownTimer({
//     super.key,
//     required this.seconds,
//     this.onComplete,
//     this.color = GameColors.primaryGreen,
//   });

//   @override
//   State<CountdownTimer> createState() => _CountdownTimerState();
// }

// class _CountdownTimerState extends State<CountdownTimer>
//     with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//   late int _currentSeconds;

//   @override
//   void initState() {
//     super.initState();
//     _currentSeconds = widget.seconds;
    
//     _controller = AnimationController(
//       duration: const Duration(seconds: 1),
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.3,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.elasticOut,
//     ));

//     _startCountdown();
//   }

//   void _startCountdown() {
//     _controller.forward().then((_) {
//       _controller.reverse().then((_) {
//         if (_currentSeconds > 1) {
//           setState(() => _currentSeconds--);
//           _startCountdown();
//         } else {
//           if (widget.onComplete != null) {
//             widget.onComplete!();
//           }
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _scaleAnimation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: Container(
//             width: 120,
//             height: 120,
//             decoration: BoxDecoration(
//               color: widget.color,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: widget.color.withOpacity(0.4),
//                   blurRadius: 20,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),
//             child: Center(
//               child: Text(
//                 '$_currentSeconds',
//                 style: const TextStyle(
//                   fontSize: 48,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // File: lib/widgets/game_ui_components.dart
// import 'package:flutter/material.dart';
// import '../utils/game_constants.dart';
// import 'animated_widgets.dart';

// class GameHUD extends StatelessWidget {
//   final int teamAScore;
//   final int teamBScore;
//   final String timeText;
//   final String phaseText;
//   final bool teamAHighlighted;
//   final bool teamBHighlighted;

//   const GameHUD({
//     super.key,
//     required this.teamAScore,
//     required this.teamBScore,
//     required this.timeText,
//     required this.phaseText,
//     this.teamAHighlighted = false,
//     this.teamBHighlighted = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.95),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           AnimatedScoreCard(
//             teamName: 'Tim Merah',
//             score: teamAScore,
//             color: GameColors.teamAColor,
//             isHighlighted: teamAHighlighted,
//           ),
          
//           _buildCenterInfo(),
          
//           AnimatedScoreCard(
//             teamName: 'Tim Biru',
//             score: teamBScore,
//             color: GameColors.teamBColor,
//             isHighlighted: teamBHighlighted,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCenterInfo() {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: GameColors.primaryGreen.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             phaseText,
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: GameColors.primaryGreen,
//             ),
//           ),
//         ),
        
//         const SizedBox(height: 8),
        
//         Text(
//           timeText,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: GameColors.textPrimary,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class GameControlPanel extends StatelessWidget {
//   final VoidCallback onRestart;
//   final VoidCallback onPause;
//   final VoidCallback onSwitch;
//   final bool isPaused;

//   const GameControlPanel({
//     super.key,
//     required this.onRestart,
//     required this.onPause,
//     required this.onSwitch,
//     this.isPaused = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _buildControlButton(
//             label: 'Restart',
//             icon: Icons.refresh,
//             color: GameColors.warningColor,
//             onPressed: onRestart,
//           ),
          
//           _buildControlButton(
//             label: isPaused ? 'Resume' : 'Pause',
//             icon: isPaused ? Icons.play_arrow : Icons.pause,
//             color: GameColors.infoColor,
//             onPressed: onPause,
//           ),
          
//           _buildControlButton(
//             label: 'Switch',
//             icon: Icons.swap_horiz,
//             color: Colors.purple,
//             onPressed: onSwitch,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildControlButton({
//     required String label,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onPressed,
//   }) {
//     return Expanded(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         child: ElevatedButton.icon(
//           onPressed: onPressed,
//           icon: Icon(icon, size: 20),
//           label: Text(label),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: color,
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//             elevation: 4,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class HintBanner extends StatefulWidget {
//   final String hint;
//   final Color backgroundColor;
//   final IconData? icon;

//   const HintBanner({
//     super.key,
//     required this.hint,
//     this.backgroundColor = GameColors.primaryGreen,
//     this.icon,
//   });

//   @override
//   State<HintBanner> createState() => _HintBannerState();
// }

// class _HintBannerState extends State<HintBanner>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.elasticOut,
//     ));

//     _controller.forward();
//   }

//   @override
//   void didUpdateWidget(HintBanner oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.hint != widget.hint) {
//       _controller.reset();
//       _controller.forward();
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SlideTransition(
//       position: _slideAnimation,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: widget.backgroundColor.withOpacity(0.9),
//           borderRadius: const BorderRadius.vertical(
//             top: Radius.circular(12),
//           ),
//         ),
//         child: Row(
//           children: [
//             if (widget.icon != null) ...[
//               Icon(
//                 widget.icon!,
//                 color: Colors.white,
//                 size: 20,
//               ),
//               const SizedBox(width: 8),
//             ],
            
//             Expanded(
//               child: Text(
//                 widget.hint,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }