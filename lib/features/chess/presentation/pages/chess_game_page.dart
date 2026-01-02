import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/extensions/piece_symbol.dart';
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
                ref
                    .read(chessGameProvider.notifier)
                    .initGame(state.gameMode, playerColor: state.playerColor);
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            final isFlipped = state.playerColor == PieceColor.black;

            final topCaptured = isFlipped
                ? state.whiteCaptured
                : state.blackCaptured;
            final bottomCaptured = isFlipped
                ? state.blackCaptured
                : state.whiteCaptured;

            if (isWide) {
              return Column(
                children: [
                  if (state.isThinking)
                    const LinearProgressIndicator(minHeight: 2),
                  GameStatusWidget(turn: state.turn, status: state.status),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: SingleChildScrollView(
                              child: CapturedPiecesWidget(
                                captured: topCaptured,
                              ),
                            ),
                          ),
                          SizedBox(width: 20.w),
                          const AspectRatio(
                            aspectRatio: 1,
                            child: ChessBoardWidget(),
                          ),
                          SizedBox(width: 20.w),
                          Expanded(
                            flex: 1,
                            child: SingleChildScrollView(
                              child: CapturedPiecesWidget(
                                captured: bottomCaptured,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                if (state.isThinking)
                  const LinearProgressIndicator(minHeight: 2),
                Expanded(
                  child: Column(
                    children: [
                      GameStatusWidget(turn: state.turn, status: state.status),
                      CapturedPiecesWidget(captured: topCaptured),
                      const Expanded(child: Center(child: ChessBoardWidget())),
                      CapturedPiecesWidget(captured: bottomCaptured),
                    ],
                  ),
                ),
              ],
            );
          },
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
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
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
