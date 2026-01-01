import '../../features/chess/domain/entities/piece.dart';
import 'package:flutter/material.dart';

/// Provides a symbol and a colorable TextStyle for each chess piece
extension PieceSymbol on Piece {
  /// Classic Unicode set (Outline for White, Filled for Black)
  /// This ensures maximum visibility and "chess-standard" consistency.
  String get symbol {
    final isWhite = color == PieceColor.white;
    return isWhite
        ? const {
            PieceType.king: '♔',
            PieceType.queen: '♕',
            PieceType.rook: '♖',
            PieceType.bishop: '♗',
            PieceType.knight: '♘',
            PieceType.pawn: '♙',
          }[type]!
        : const {
            PieceType.king: '♚',
            PieceType.queen: '♛',
            PieceType.rook: '♜',
            PieceType.bishop: '♝',
            PieceType.knight: '♞',
            PieceType.pawn: '♟',
          }[type]!;
  }

  /// Generates a Text widget ready to render the piece
  Text render({double fontSize = 38, Color? color, bool bold = true}) {
    final isWhite = this.color == PieceColor.white;
    // We use slightly different weights to make the outline and filled symbols feel matched
    final fontWeight = isWhite ? FontWeight.bold : FontWeight.normal;

    return Text(
      symbol,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: 1.0,
        // We use pure white/black but with forced foreground to avoid emoji rendering
        foreground: Paint()
          ..color = color ?? (isWhite ? Colors.white : Colors.black),
        shadows: [
          Shadow(
            blurRadius: 1.5,
            color: isWhite ? Colors.black54 : Colors.white54,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
  }
}
