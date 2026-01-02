import '../entities/board.dart';
import '../entities/move.dart';
import '../entities/piece.dart';
import '../entities/square_position.dart';

class MoveValidator {
  bool isValidMove({
    required Board board,
    required Move move,
    SquarePosition? enPassantTarget,
    bool? canCastleKingSide,
    bool? canCastleQueenSide,
  }) {
    final piece = board.pieceAt(move.fromRow, move.fromCol);

    if (piece == null) return false;

    // Can't move to the same square
    if (move.fromRow == move.toRow && move.fromCol == move.toCol) {
      return false;
    }

    // Normal capture rule (can't capture own piece)
    final targetPiece = board.pieceAt(move.toRow, move.toCol);
    if (targetPiece != null && targetPiece.color == piece.color) {
      return false;
    }

    bool potentialValid = false;
    switch (piece.type) {
      case PieceType.pawn:
        potentialValid = _validatePawnMove(board, piece, move, enPassantTarget);
        break;
      case PieceType.rook:
        potentialValid = _validateRookMove(board, move);
        break;
      case PieceType.knight:
        potentialValid = _validateKnightMove(move);
        break;
      case PieceType.bishop:
        potentialValid = _validateBishopMove(board, move);
        break;
      case PieceType.queen:
        potentialValid = _validateQueenMove(board, move);
        break;
      case PieceType.king:
        potentialValid =
            _validateKingMove(move) ||
            _validateCastling(
              board,
              piece,
              move,
              canCastleKingSide ?? false,
              canCastleQueenSide ?? false,
            );
        break;
    }

    if (!potentialValid) return false;

    // A move is only valid if it doesn't leave the king in check
    // Special case for castling: the king cannot pass through check
    if (piece.type == PieceType.king &&
        (move.toCol - move.fromCol).abs() == 2) {
      // Castling logic already checks square safety in _validateCastling
      return true;
    }

    // Apply move to a hypothetical board to check for king safety
    Board hypotheticalBoard = _applyMoveToBoard(board, move);

    // Handle En Passant capture on hypothetical board
    // If pawn moves diagonally to an empty square, it's En Passant
    if (piece.type == PieceType.pawn &&
        (move.toCol - move.fromCol).abs() == 1 &&
        board.pieceAt(move.toRow, move.toCol) == null) {
      // Remove the captured pawn (which is at [fromRow, toCol])
      final newSquares = hypotheticalBoard.squares
          .map((row) => List<Piece?>.from(row))
          .toList();
      newSquares[move.fromRow][move.toCol] = null;
      hypotheticalBoard = Board(newSquares);
    }

    if (isKingInCheck(hypotheticalBoard, piece.color)) {
      return false;
    }

    return true;
  }

  bool isKingInCheck(Board board, PieceColor color) {
    // 1. Find the king
    int kingRow = -1;
    int kingCol = -1;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.pieceAt(r, c);
        if (piece != null &&
            piece.type == PieceType.king &&
            piece.color == color) {
          kingRow = r;
          kingCol = c;
          break;
        }
      }
      if (kingRow != -1) break;
    }

    if (kingRow == -1) return false; // Should not happen in real chess

    return isSquareAttacked(
      board,
      kingRow,
      kingCol,
      color == PieceColor.white ? PieceColor.black : PieceColor.white,
    );
  }

  bool isSquareAttacked(
    Board board,
    int row,
    int col,
    PieceColor attackerColor,
  ) {
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.pieceAt(r, c);
        if (piece != null && piece.color == attackerColor) {
          final move = Move(fromRow: r, fromCol: c, toRow: row, toCol: col);

          // Use basic validation (without check check to avoid recursion)
          bool attacked = false;
          switch (piece.type) {
            case PieceType.pawn:
              final direction = piece.color == PieceColor.white ? -1 : 1;
              attacked = (row - r == direction) && (col - c).abs() == 1;
              break;
            case PieceType.rook:
              attacked = _validateRookMove(board, move);
              break;
            case PieceType.knight:
              attacked = _validateKnightMove(move);
              break;
            case PieceType.bishop:
              attacked = _validateBishopMove(board, move);
              break;
            case PieceType.queen:
              attacked = _validateQueenMove(board, move);
              break;
            case PieceType.king:
              attacked = _validateKingMove(move);
              break;
          }
          if (attacked) return true;
        }
      }
    }
    return false;
  }

  // ---------------- PAWN ----------------

  bool _validatePawnMove(
    Board board,
    Piece piece,
    Move move,
    SquarePosition? enPassantTarget,
  ) {
    final direction = piece.color == PieceColor.white ? -1 : 1;
    final startRow = piece.color == PieceColor.white ? 6 : 1;

    final rowDiff = move.toRow - move.fromRow;
    final colDiff = (move.toCol - move.fromCol).abs();

    // Forward move
    if (colDiff == 0) {
      if (rowDiff == direction &&
          board.pieceAt(move.toRow, move.toCol) == null) {
        return true;
      }
      if (move.fromRow == startRow &&
          rowDiff == 2 * direction &&
          board.pieceAt(move.fromRow + direction, move.fromCol) == null &&
          board.pieceAt(move.toRow, move.toCol) == null) {
        return true;
      }
    }

    // Diagonal capture
    if (colDiff == 1 && rowDiff == direction) {
      final target = board.pieceAt(move.toRow, move.toCol);
      if (target != null && target.color != piece.color) {
        return true;
      }

      // En Passant
      if (enPassantTarget != null &&
          move.toRow == enPassantTarget.row &&
          move.toCol == enPassantTarget.col) {
        return true;
      }
    }

    return false;
  }

  // ---------------- ROOK ----------------

  bool _validateRookMove(Board board, Move move) {
    if (move.fromRow != move.toRow && move.fromCol != move.toCol) return false;

    final rowStep = (move.toRow - move.fromRow).sign.toInt();
    final colStep = (move.toCol - move.fromCol).sign.toInt();

    int r = move.fromRow + rowStep;
    int c = move.fromCol + colStep;

    while (r != move.toRow || c != move.toCol) {
      if (board.pieceAt(r, c) != null) return false;
      r += rowStep;
      c += colStep;
    }
    return true;
  }

  // ---------------- BISHOP ----------------

  bool _validateBishopMove(Board board, Move move) {
    if ((move.toRow - move.fromRow).abs() != (move.toCol - move.fromCol).abs())
      return false;

    final rowStep = (move.toRow - move.fromRow).sign.toInt();
    final colStep = (move.toCol - move.fromCol).sign.toInt();

    int r = move.fromRow + rowStep;
    int c = move.fromCol + colStep;

    while (r != move.toRow || c != move.toCol) {
      if (board.pieceAt(r, c) != null) return false;
      r += rowStep;
      c += colStep;
    }
    return true;
  }

  // ---------------- QUEEN ----------------

  bool _validateQueenMove(Board board, Move move) {
    return _validateRookMove(board, move) || _validateBishopMove(board, move);
  }

  // ---------------- KNIGHT ----------------

  bool _validateKnightMove(Move move) {
    final dr = (move.toRow - move.fromRow).abs();
    final dc = (move.toCol - move.fromCol).abs();
    return (dr == 2 && dc == 1) || (dr == 1 && dc == 2);
  }

  // ---------------- KING ----------------

  bool _validateKingMove(Move move) {
    return (move.toRow - move.fromRow).abs() <= 1 &&
        (move.toCol - move.fromCol).abs() <= 1;
  }

  bool _validateCastling(
    Board board,
    Piece piece,
    Move move,
    bool canCastleKingSide,
    bool canCastleQueenSide,
  ) {
    if (move.fromRow != move.toRow) return false;
    final row = move.fromRow;

    // Check if the king is currently in check
    if (isKingInCheck(board, piece.color)) return false;

    // King-side castling
    if (canCastleKingSide && move.toCol - move.fromCol == 2) {
      // Path must be clear
      if (board.pieceAt(row, 5) != null || board.pieceAt(row, 6) != null)
        return false;
      // Square 5 and 6 must not be attacked
      final opponentColor = piece.color == PieceColor.white
          ? PieceColor.black
          : PieceColor.white;
      if (isSquareAttacked(board, row, 5, opponentColor) ||
          isSquareAttacked(board, row, 6, opponentColor))
        return false;
      return true;
    }

    // Queen-side castling
    if (canCastleQueenSide && move.toCol - move.fromCol == -2) {
      // Path must be clear
      if (board.pieceAt(row, 1) != null ||
          board.pieceAt(row, 2) != null ||
          board.pieceAt(row, 3) != null)
        return false;
      // Square 2 and 3 must not be attacked (usually just 2 and 3, square 1 doesn't matter for check)
      final opponentColor = piece.color == PieceColor.white
          ? PieceColor.black
          : PieceColor.white;
      if (isSquareAttacked(board, row, 2, opponentColor) ||
          isSquareAttacked(board, row, 3, opponentColor))
        return false;
      return true;
    }

    return false;
  }

  Board _applyMoveToBoard(Board board, Move move) {
    final newSquares = board.squares
        .map((row) => List<Piece?>.from(row))
        .toList();
    newSquares[move.toRow][move.toCol] = newSquares[move.fromRow][move.fromCol];
    newSquares[move.fromRow][move.fromCol] = null;
    return Board(newSquares);
  }
}
