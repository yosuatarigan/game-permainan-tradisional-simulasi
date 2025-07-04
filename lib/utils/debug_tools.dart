
// // File: lib/utils/debug_tools.dart
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:game_permainan_tradisional_simulasi/services/asset_manager.dart';
// import 'package:game_permainan_tradisional_simulasi/services/error_handler.dart';
// import 'package:game_permainan_tradisional_simulasi/services/performance_monitor.dart';
// import '../services/audio_service.dart';
// import '../services/local_storage_service.dart';

// class DebugTools {
//   static Widget buildDebugOverlay(BuildContext context) {
//     if (!kDebugMode) return const SizedBox.shrink();
    
//     return Positioned(
//       top: 100,
//       right: 10,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           _buildPerformanceWidget(),
//           const SizedBox(height: 8),
//           _buildErrorWidget(),
//           const SizedBox(height: 8),
//           _buildAudioWidget(),
//         ],
//       ),
//     );
//   }

//   static Widget _buildPerformanceWidget() {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.7),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Text(
//             'Performance',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             'FPS: ${PerformanceMonitor.instance.currentFPS.toStringAsFixed(1)}',
//             style: TextStyle(
//               color: _getFPSColor(PerformanceMonitor.instance.currentFPS),
//               fontSize: 10,
//             ),
//           ),
//           Text(
//             'Mem: ${PerformanceMonitor.instance.currentMemoryUsage}MB',
//             style: const TextStyle(color: Colors.white, fontSize: 10),
//           ),
//         ],
//       ),
//     );
//   }

//   static Widget _buildErrorWidget() {
//     final hasErrors = ErrorHandler.instance.hasErrors;
    
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: hasErrors ? Colors.red.withOpacity(0.7) : Colors.green.withOpacity(0.7),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             hasErrors ? Icons.error : Icons.check_circle,
//             color: Colors.white,
//             size: 16,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             hasErrors ? 'Errors' : 'OK',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   static Widget _buildAudioWidget() {
//     final audioState = AudioService.instance.audioState;
    
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Colors.blue.withOpacity(0.7),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             audioState['isMusicPlaying'] ? Icons.music_note : Icons.music_off,
//             color: Colors.white,
//             size: 16,
//           ),
//           const SizedBox(width: 4),
//           Text(
//             'Audio',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   static Color _getFPSColor(double fps) {
//     if (fps >= 55) return Colors.green;
//     if (fps >= 45) return Colors.yellow;
//     if (fps >= 30) return Colors.orange;
//     return Colors.red;
//   }

//   static void printSystemInfo() {
//     if (!kDebugMode) return;
    
//     print('\n🔧 SYSTEM INFO:');
//     print('   Performance Monitor: ${PerformanceMonitor.instance.isMonitoring}');
//     print('   Audio Service: ${AudioService.instance.isInitialized}');
//     print('   Local Storage: ${LocalStorageService.instance}');
//     print('   Error Handler: ${ErrorHandler.instance.hasErrors ? "Has Errors" : "Clean"}');
//     print('   Platform: ${defaultTargetPlatform.name}');
//     print('   Debug Mode: $kDebugMode\n');
//   }

//   static Map<String, dynamic> getSystemReport() {
//     return {
//       'performance': PerformanceMonitor.instance.getPerformanceReport(),
//       'errors': ErrorHandler.instance.getErrorReport(),
//       'audio': AudioService.instance.audioState,
//       'platform': defaultTargetPlatform.name,
//       'debugMode': kDebugMode,
//       'timestamp': DateTime.now().toIso8601String(),
//     };
//   }
// }