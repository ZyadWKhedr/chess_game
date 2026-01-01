import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_application_1/core/extensions/piece_symbol.dart';
import '../../domain/entities/piece.dart';
import '../provider/chess_game_notifier.dart';
import '../provider/game_state.dart';
import '../widgets/chessboard_widget.dart';
import '../widgets/captured_pieces_widget.dart';
import '../widgets/game_status_widget.dart';
import '../widgets/game_over_helper.dart';

class ChessGamePage extends ConsumerWidget {
  const ChessGamePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chessGameProvider);

    ref.listen(chessGameProvider, (previous, next) {
      if (next.pendingPromotion != null && previous?.pendingPromotion == null) {
        _showPromotionDialog(context, ref, next.turn);
      }

      if (next.status == GameStatus.checkmate) {
        final winner = next.turn == PieceColor.white ? 'Black' : 'White';
        GameOverHelper.showGameOverDialog(
          context,
          ref,
          'Checkmate!',
          '$winner wins the game.',
        );
      } else if (next.status == GameStatus.draw) {
        GameOverHelper.showGameOverDialog(
          context,
          ref,
          'Draw!',
          'The game ended in a draw.',
        );
      }
    });

    final showRotation = state.gameMode == GameMode.pvp;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          state.gameMode == GameMode.pvp ? 'Local Multiplayer' : 'Solo vs AI',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: IconButton(
              icon: Icon(Icons.refresh_rounded, size: 28.sp),
              tooltip: 'Restart Game',
              onPressed: () {
                ref.read(chessGameProvider.notifier).initGame(state.gameMode);
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (state.isThinking) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: AnimatedRotation(
                turns: (showRotation && state.turn == PieceColor.black)
                    ? 0.5
                    : 0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: Column(
                  children: [
                    GameStatusWidget(turn: state.turn, status: state.status),
                    CapturedPiecesWidget(captured: state.blackCaptured),
                    const Expanded(child: Center(child: ChessBoardWidget())),
                    CapturedPiecesWidget(captured: state.whiteCaptured),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPromotionDialog(
    BuildContext context,
    WidgetRef ref,
    PieceColor color,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Promote Pawn'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
              [
                PieceType.queen,
                PieceType.rook,
                PieceType.bishop,
                PieceType.knight,
              ].map((type) {
                final piece = Piece(type: type, color: color);
                return GestureDetector(
                  onTap: () {
                    ref.read(chessGameProvider.notifier).promotePiece(type);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: piece.render(fontSize: 40.sp),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
