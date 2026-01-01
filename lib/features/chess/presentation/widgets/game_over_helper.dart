import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/chess_game_notifier.dart';

class GameOverHelper {
  static void showGameOverDialog(
    BuildContext context,
    WidgetRef ref,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Back to home
            },
            child: const Text('Exit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              final mode = ref.read(chessGameProvider).gameMode;
              ref.read(chessGameProvider.notifier).initGame(mode);
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }
}
