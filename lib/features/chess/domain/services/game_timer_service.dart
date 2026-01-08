// // lib/features/chess/domain/services/game_timer_service.dart
// import 'dart:async';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../presentation/provider/game_state.dart';

// class GameTimerService {
//   Timer? _timer;
//   final Ref _ref;

//   GameTimerService(this._ref);

//   void startTimer() {
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       _ref.read(chessGameProvider.notifier).updateTimer();
//     });
//   }

//   void stopTimer() {
//     _timer?.cancel();
//     _timer = null;
//   }

//   void dispose() {
//     _timer?.cancel();
//   }
// }