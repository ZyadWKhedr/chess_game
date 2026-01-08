import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/extensions/piece_symbol.dart';
import '../provider/chess_game_notifier.dart';
import '../provider/game_state.dart';
import '../../domain/entities/piece.dart';

class ChessBoardWidget extends ConsumerWidget {
  const ChessBoardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chessGameProvider);
    final notifier = ref.read(chessGameProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Pro-grade tournament colors
    final lightSquareColor = isDark
        ? const Color(0xFF323438)
        : const Color(0xFFEAE9D2);
    final darkSquareColor = isDark
        ? const Color(0xFF1C1E21)
        : const Color(0xFF4B7399);

    final selectedColor = const Color(0xFFF7EC78).withValues(alpha: 0.5);
    final lastMoveColor = const Color(0xFF7BADE3).withValues(alpha: 0.35);
    final checkColor = const Color(0xFFE91E63).withValues(alpha: 0.4);

    final isFlipped = state.playerColor == PieceColor.black;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.brown[900]!, width: 4),
          borderRadius: BorderRadius.circular(4.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 64,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
          ),
          itemBuilder: (context, index) {
            final visualRow = index ~/ 8;
            final visualCol = index % 8;

            final row = isFlipped ? 7 - visualRow : visualRow;
            final col = isFlipped ? 7 - visualCol : visualCol;

            final piece = state.board.pieceAt(row, col);
            final isSelected =
                state.selected?.row == row && state.selected?.col == col;

            final isPossibleMove = state.possibleMoves.any(
              (m) => m.toRow == row && m.toCol == col,
            );

            final isLastMoveSource =
                state.lastMove?.fromRow == row &&
                state.lastMove?.fromCol == col;
            final isLastMoveTarget =
                state.lastMove?.toRow == row && state.lastMove?.toCol == col;

            final isCheckedKing =
                piece?.type == PieceType.king &&
                piece?.color == state.turn &&
                (state.status == GameStatus.check ||
                    state.status == GameStatus.checkmate);

            final isDarkSquare = (row + col) % 2 == 1;
            final squareColor = isCheckedKing
                ? checkColor
                : isSelected
                ? selectedColor
                : isLastMoveSource || isLastMoveTarget
                ? lastMoveColor
                : isDarkSquare
                ? darkSquareColor
                : lightSquareColor;

            return GestureDetector(
              onTap: () {
                final piece = state.board.pieceAt(row, col);

                if (piece != null && piece.color == state.turn) {
                  notifier.selectSquare(row, col);
                } else if (state.selected != null) {
                  notifier.tryMove(row, col);
                }
              },
              child: Container(
                color: squareColor,
                child: Stack(
                  children: [
                    // Vertical Rank Coordinate (Inside Left Squares)
                    if (visualCol == 0)
                      Positioned(
                        top: 2,
                        left: 2,
                        child: Text(
                          (8 - row).toString(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: isDarkSquare
                                ? lightSquareColor
                                : darkSquareColor,
                          ),
                        ),
                      ),
                    // Horizontal File Coordinate (Inside Bottom Squares)
                    if (visualRow == 7)
                      Positioned(
                        bottom: 0,
                        right: 2,
                        child: Text(
                          String.fromCharCode(97 + col).toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: !isDarkSquare
                                ? lightSquareColor
                                : darkSquareColor,
                          ),
                        ),
                      ),
                    if (isPossibleMove)
                      Center(
                        child: Container(
                          width: 14.w,
                          height: 14.h,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    Center(child: _buildPiece(context, piece, state.gameMode)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPiece(BuildContext context, Piece? piece, GameMode gameMode) {
    if (piece == null) return const SizedBox.shrink();

    // Precise hierarchical scaling for a professional look
    final double fontSize = switch (piece.type) {
      PieceType.king => 44.sp,
      PieceType.queen => 40.sp,
      PieceType.bishop => 36.sp,
      PieceType.knight => 36.sp,
      PieceType.rook => 34.sp,
      PieceType.pawn => 26.sp,
    };

    final widget = piece.render(fontSize: fontSize);

    // In local multiplayer, rotate black pieces to face the black player (who sits at the top)
    if (gameMode == GameMode.pvp && piece.color == PieceColor.black) {
      return RotatedBox(quarterTurns: 2, child: widget);
    }

    return widget;
  }
}
