import '../../presentation/provider/game_state.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/move.dart';
import '../../domain/entities/piece.dart';
import '../../domain/services/move_validator.dart';

class ChessAIService {
  final MoveValidator _validator = MoveValidator();

  final Map<PieceType, int> _pieceValues = {
    PieceType.pawn: 100,
    PieceType.knight: 320,
    PieceType.bishop: 330,
    PieceType.rook: 500,
    PieceType.queen: 900,
    PieceType.king: 20000,
  };

  // Piece-Square Tables (PST) - values from simplified evaluation
  static const List<List<int>> _pawnPST = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [50, 50, 50, 50, 50, 50, 50, 50],
    [10, 10, 20, 30, 30, 20, 10, 10],
    [5, 5, 10, 25, 25, 10, 5, 5],
    [0, 0, 0, 20, 20, 0, 0, 0],
    [5, -5, -10, 0, 0, -10, -5, 5],
    [5, 10, 10, -20, -20, 10, 10, 5],
    [0, 0, 0, 0, 0, 0, 0, 0],
  ];

  static const List<List<int>> _knightPST = [
    [-50, -40, -30, -30, -30, -30, -40, -50],
    [-40, -20, 0, 0, 0, 0, -20, -40],
    [-30, 0, 10, 15, 15, 10, 0, -30],
    [-30, 5, 15, 20, 20, 15, 5, -30],
    [-30, 0, 15, 20, 20, 15, 0, -30],
    [-30, 5, 10, 15, 15, 10, 5, -30],
    [-40, -20, 0, 5, 5, 0, -20, -40],
    [-50, -40, -30, -30, -30, -30, -40, -50],
  ];

  static const List<List<int>> _bishopPST = [
    [-20, -10, -10, -10, -10, -10, -10, -20],
    [-10, 0, 0, 0, 0, 0, 0, -10],
    [-10, 0, 5, 10, 10, 5, 0, -10],
    [-10, 5, 5, 10, 10, 5, 5, -10],
    [-10, 0, 10, 10, 10, 10, 0, -10],
    [-10, 10, 10, 10, 10, 10, 10, -10],
    [-10, 5, 0, 0, 0, 0, 5, -10],
    [-20, -10, -10, -10, -10, -10, -10, -20],
  ];

  Move? findBestMove(Board board, PieceColor aiColor, Difficulty difficulty) {
    int depth;
    switch (difficulty) {
      case Difficulty.beginner:
        depth = 1;
        break;
      case Difficulty.intermediate:
        depth = 2;
        break;
      case Difficulty.master:
        depth = 3;
        break;
      case Difficulty.grandmaster:
        depth = 4;
        break;
    }

    Move? bestMove;
    int bestValue = -999999;

    final moves = _getAllLegalMoves(board, aiColor);
    if (moves.isEmpty) return null;

    // Sorting moves slightly to improve pruning (captures first)
    moves.sort((a, b) {
      final targetA = board.pieceAt(a.toRow, a.toCol);
      final targetB = board.pieceAt(b.toRow, b.toCol);
      if (targetA != null && targetB == null) return -1;
      if (targetA == null && targetB != null) return 1;
      return 0;
    });

    for (final move in moves) {
      final newBoard = _applyMoveToBoard(board, move);
      final boardValue = _minimax(
        newBoard,
        depth - 1,
        -1000000,
        1000000,
        false,
        aiColor,
      );

      // Add a little randomness for beginner/intermediate to avoid identical games
      if (difficulty == Difficulty.beginner &&
          (boardValue == bestValue) &&
          (DateTime.now().microsecond % 2 == 0)) {
        bestMove = move;
      } else if (boardValue > bestValue) {
        bestValue = boardValue;
        bestMove = move;
      }
    }

    return bestMove;
  }

  // Exposed for checking board status (Chat features)
  int evaluateBoardState(Board board, PieceColor color) {
    return _evaluateBoard(board, color);
  }

  int _minimax(
    Board board,
    int depth,
    int alpha,
    int beta,
    bool isMaximizing,
    PieceColor aiColor,
  ) {
    if (depth == 0) {
      return _evaluateBoard(board, aiColor);
    }

    final currentPlayer = isMaximizing
        ? aiColor
        : (aiColor == PieceColor.white ? PieceColor.black : PieceColor.white);
    final moves = _getAllLegalMoves(board, currentPlayer);

    if (moves.isEmpty) {
      if (_validator.isKingInCheck(board, currentPlayer)) {
        return isMaximizing ? -50000 * (depth + 1) : 50000 * (depth + 1);
      }
      return 0; // Draw
    }

    if (isMaximizing) {
      int maxEval = -999999;
      for (final move in moves) {
        final newBoard = _applyMoveToBoard(board, move);
        final eval = _minimax(newBoard, depth - 1, alpha, beta, false, aiColor);
        maxEval = _max(maxEval, eval);
        alpha = _max(alpha, eval);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      int minEval = 999999;
      for (final move in moves) {
        final newBoard = _applyMoveToBoard(board, move);
        final eval = _minimax(newBoard, depth - 1, alpha, beta, true, aiColor);
        minEval = _min(minEval, eval);
        beta = _min(beta, eval);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  int _evaluateBoard(Board board, PieceColor aiColor) {
    int totalValue = 0;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.pieceAt(r, c);
        if (piece != null) {
          int val = _pieceValues[piece.type]!;

          // Add PST bonus
          if (piece.type == PieceType.pawn) {
            val += piece.color == PieceColor.white
                ? _pawnPST[7 - r][c]
                : _pawnPST[r][c];
          } else if (piece.type == PieceType.knight) {
            val += _knightPST[r][c];
          } else if (piece.type == PieceType.bishop) {
            val += _bishopPST[r][c];
          }

          if (piece.color == aiColor) {
            totalValue += val;
          } else {
            totalValue -= val;
          }
        }
      }
    }
    return totalValue;
  }

  List<Move> _getAllLegalMoves(Board board, PieceColor color) {
    final moves = <Move>[];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.pieceAt(r, c);
        if (piece != null && piece.color == color) {
          for (int tr = 0; tr < 8; tr++) {
            for (int tc = 0; tc < 8; tc++) {
              final move = Move(fromRow: r, fromCol: c, toRow: tr, toCol: tc);
              if (_validator.isValidMove(board: board, move: move)) {
                moves.add(move);
              }
            }
          }
        }
      }
    }
    return moves;
  }

  Board _applyMoveToBoard(Board board, Move move) {
    final newSquares = board.squares
        .map((row) => List<Piece?>.of(row))
        .toList();
    newSquares[move.toRow][move.toCol] = newSquares[move.fromRow][move.fromCol];
    newSquares[move.fromRow][move.fromCol] = null;
    return Board(newSquares);
  }

  int _max(int a, int b) => a > b ? a : b;
  int _min(int a, int b) => a < b ? a : b;
}
