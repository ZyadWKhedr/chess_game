import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/extensions/piece_symbol.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

    // Highest contrast tournament colors
    final lightSquareColor = isDark
        ? const Color(0xFF4B4B4B)
        : const Color(0xFFF0D9B5);
    final darkSquareColor = isDark
        ? const Color(0xFF2B2B2B)
        : const Color(0xFFB58863);

    final selectedColor = Colors.yellow.withOpacity(0.6);
    final lastMoveColor = Colors.blue.withOpacity(0.4);
    final checkColor = Colors.red.withOpacity(0.6);

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.brown[900]!, width: 4),
          borderRadius: BorderRadius.circular(4.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
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
            final row = index ~/ 8;
            final col = index % 8;

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
                    if (col == 0)
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
                    if (row == 7)
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
                            color: Colors.black.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    Center(child: _buildPiece(context, piece)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPiece(BuildContext context, Piece? piece) {
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

    return piece.render(fontSize: fontSize);
  }
}
