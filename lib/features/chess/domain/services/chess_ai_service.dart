import 'dart:math';
import '../../presentation/provider/game_state.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/move.dart';
import '../../domain/entities/piece.dart';
import '../../domain/entities/square_position.dart';
import '../../domain/services/move_validator.dart';

enum TTEntryType { exact, lowerBound, upperBound }

class TTEntry {
  final int value;
  final int depth;
  final Move? bestMove;
  final TTEntryType type;

  TTEntry({
    required this.value,
    required this.depth,
    this.bestMove,
    required this.type,
  });
}

class ChessAIService {
  final MoveValidator _validator = MoveValidator();
  final Random _random = Random();
  final Map<String, TTEntry> _transpositionTable = {};

  final Map<PieceType, int> _pieceValues = {
    PieceType.pawn: 100,
    PieceType.knight: 320,
    PieceType.bishop: 330,
    PieceType.rook: 500,
    PieceType.queen: 900,
    PieceType.king: 20000,
  };

  // Piece-Square Tables (PST) - values from a perspective of White.
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

  static const List<List<int>> _rookPST = [
    [0, 0, 0, 5, 5, 0, 0, 0],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [-5, 0, 0, 0, 0, 0, 0, -5],
    [5, 10, 10, 10, 10, 10, 10, 5],
    [0, 0, 0, 0, 0, 0, 0, 0],
  ];

  static const List<List<int>> _queenPST = [
    [-20, -10, -10, -5, -5, -10, -10, -20],
    [-10, 0, 0, 0, 0, 0, 0, -10],
    [-10, 0, 5, 5, 5, 5, 0, -10],
    [-5, 0, 5, 5, 5, 5, 0, -5],
    [0, 0, 5, 5, 5, 5, 0, -5],
    [-10, 5, 5, 5, 5, 5, 0, -10],
    [-10, 0, 5, 0, 0, 0, 0, -10],
    [-20, -10, -10, -5, -5, -10, -10, -20],
  ];

  static const List<List<int>> _kingPST = [
    [20, 30, 10, 0, 0, 10, 30, 20],
    [20, 20, 0, 0, 0, 0, 20, 20],
    [-10, -20, -20, -20, -20, -20, -20, -10],
    [-20, -30, -30, -40, -40, -30, -30, -20],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
    [-30, -40, -40, -50, -50, -40, -40, -30],
  ];

  static const int _infinity = 1000000;

  Move? findBestMove(GameState state) {
    _transpositionTable.clear();
    final aiColor = state.turn;
    final difficulty = state.aiDifficulty;

    int maxDepth;
    switch (difficulty) {
      case Difficulty.beginner:
        maxDepth = 1;
        break;
      case Difficulty.intermediate:
        maxDepth = 2;
        break;
      case Difficulty.master:
        maxDepth = 3;
        break;
      case Difficulty.grandmaster:
        maxDepth = 4;
        break;
    }

    Move? overallBestMove;

    // Iterative Deepening
    for (int currentDepth = 1; currentDepth <= maxDepth; currentDepth++) {
      final result = _searchRoot(state, currentDepth, aiColor);
      if (result != null) {
        overallBestMove = result;
      }
    }

    return overallBestMove;
  }

  Move? _searchRoot(GameState state, int depth, PieceColor aiColor) {
    final moves = _getAllLegalMoves(
      state.board,
      aiColor,
      state.enPassantTarget,
      aiColor == PieceColor.white
          ? state.canCastleWhiteKingSide
          : state.canCastleBlackKingSide,
      aiColor == PieceColor.white
          ? state.canCastleWhiteQueenSide
          : state.canCastleBlackQueenSide,
    );

    if (moves.isEmpty) return null;

    _sortMoves(state.board, moves, aiColor);

    Move? bestMove;
    int bestValue = -_infinity;
    int alpha = -_infinity;
    int beta = _infinity;

    for (final move in moves) {
      final newBoard = _applyMoveToBoard(state.board, move);

      // Repetition check for root
      int penalty = _calculateRepetitionPenalty(state, move, newBoard, aiColor);

      int value = -_negamax(
        newBoard,
        depth - 1,
        -beta,
        -alpha,
        (aiColor == PieceColor.white ? PieceColor.black : PieceColor.white),
        null, // Search currently doesn't track EP target changes deeply for perf
        false, // Nor castling rights changes deeply
        false,
        aiColor,
      );

      value -= penalty;
      value += _random.nextInt(10); // Small jitter

      if (value > bestValue) {
        bestValue = value;
        bestMove = move;
      }
      alpha = _max(alpha, value);
    }

    return bestMove;
  }

  int _negamax(
    Board board,
    int depth,
    int alpha,
    int beta,
    PieceColor turn,
    SquarePosition? ep,
    bool cks,
    bool cqs,
    PieceColor aiColor,
  ) {
    // 1. TT Lookup
    final posKey = _getBoardKey(board, turn);
    final ttEntry = _transpositionTable[posKey];
    if (ttEntry != null && ttEntry.depth >= depth) {
      if (ttEntry.type == TTEntryType.exact) {
        return ttEntry.value;
      }
      if (ttEntry.type == TTEntryType.lowerBound) {
        alpha = _max(alpha, ttEntry.value);
      } else if (ttEntry.type == TTEntryType.upperBound) {
        beta = _min(beta, ttEntry.value);
      }
      if (alpha >= beta) {
        return ttEntry.value;
      }
    }

    if (depth <= 0) {
      return _quiescenceSearch(board, alpha, beta, turn, aiColor);
    }

    final moves = _getAllLegalMoves(board, turn, ep, cks, cqs);
    if (moves.isEmpty) {
      if (_validator.isKingInCheck(board, turn)) {
        return -(_infinity - 100) + (4 - depth); // Prefer faster checkmate
      }
      return 0; // Draw
    }

    _sortMoves(board, moves, turn);

    int bestValue = -_infinity;
    Move? bestMove;
    int originalAlpha = alpha;

    for (final move in moves) {
      final nextBoard = _applyMoveToBoard(board, move);
      final nextTurn = (turn == PieceColor.white
          ? PieceColor.black
          : PieceColor.white);

      int value = -_negamax(
        nextBoard,
        depth - 1,
        -beta,
        -alpha,
        nextTurn,
        null,
        false,
        false,
        aiColor,
      );

      if (value > bestValue) {
        bestValue = value;
        bestMove = move;
      }
      alpha = _max(alpha, value);
      if (alpha >= beta) break; // Alpha-beta pruning
    }

    // 2. TT Store
    TTEntryType type = TTEntryType.exact;
    if (bestValue <= originalAlpha) {
      type = TTEntryType.upperBound;
    } else if (bestValue >= beta) {
      type = TTEntryType.lowerBound;
    }

    _transpositionTable[posKey] = TTEntry(
      value: bestValue,
      depth: depth,
      bestMove: bestMove,
      type: type,
    );

    return bestValue;
  }

  int _quiescenceSearch(
    Board board,
    int alpha,
    int beta,
    PieceColor turn,
    PieceColor aiColor,
  ) {
    int standPat = _evaluateBoard(
      board,
      turn == aiColor
          ? aiColor
          : (aiColor == PieceColor.white ? PieceColor.black : PieceColor.white),
    );
    // If turn is opponent, we need the score from their perspective for negamax
    if (turn != aiColor) standPat = -standPat;

    if (standPat >= beta) return beta;
    if (alpha < standPat) alpha = standPat;

    final captures = _getAllLegalMoves(
      board,
      turn,
      null,
      false,
      false,
    ).where((m) => board.pieceAt(m.toRow, m.toCol) != null).toList();

    _sortMoves(board, captures, turn);

    for (final move in captures) {
      final nextBoard = _applyMoveToBoard(board, move);
      final nextTurn = (turn == PieceColor.white
          ? PieceColor.black
          : PieceColor.white);
      int value = -_quiescenceSearch(
        nextBoard,
        -beta,
        -alpha,
        nextTurn,
        aiColor,
      );

      if (value >= beta) return beta;
      if (value > alpha) alpha = value;
    }

    return alpha;
  }

  String _getBoardKey(Board board, PieceColor turn) {
    // Simplified board key for TT performance
    final buffer = StringBuffer();
    for (var r = 0; r < 8; r++) {
      for (var c = 0; c < 8; c++) {
        final p = board.pieceAt(r, c);
        if (p == null) {
          buffer.write('.');
        } else {
          final char = p.type.toString()[10]; // Get 1st letter of type
          buffer.write(
            p.color == PieceColor.white
                ? char.toUpperCase()
                : char.toLowerCase(),
          );
        }
      }
    }
    buffer.write(turn == PieceColor.white ? 'w' : 'b');
    return buffer.toString();
  }

  void _sortMoves(Board board, List<Move> moves, PieceColor turn) {
    moves.sort((a, b) {
      final scoreA = _getMoveScore(board, a, turn);
      final scoreB = _getMoveScore(board, b, turn);
      return scoreB.compareTo(scoreA); // Highest score first
    });
  }

  int _getMoveScore(Board board, Move move, PieceColor turn) {
    int score = 0;
    final piece = board.pieceAt(move.fromRow, move.fromCol);
    final target = board.pieceAt(move.toRow, move.toCol);

    // 1. MVV-LVA (Most Valuable Victim - Least Valuable Attacker)
    if (target != null) {
      score +=
          10 * _pieceValues[target.type]! - (_pieceValues[piece!.type]! ~/ 10);
    }

    // 2. PST advancement
    if (piece != null) {
      final isWhite = piece.color == PieceColor.white;
      final fromPST = _getPSTValue(
        piece.type,
        isWhite ? 7 - move.fromRow : move.fromRow,
        move.fromCol,
      );
      final toPST = _getPSTValue(
        piece.type,
        isWhite ? 7 - move.toRow : move.toRow,
        move.toCol,
      );
      score += (toPST - fromPST);
    }

    return score;
  }

  int _getPSTValue(PieceType type, int row, int col) {
    switch (type) {
      case PieceType.pawn:
        return _pawnPST[row][col];
      case PieceType.knight:
        return _knightPST[row][col];
      case PieceType.bishop:
        return _bishopPST[row][col];
      case PieceType.rook:
        return _rookPST[row][col];
      case PieceType.queen:
        return _queenPST[row][col];
      case PieceType.king:
        return _kingPST[row][col];
    }
  }

  int _calculateRepetitionPenalty(
    GameState state,
    Move move,
    Board nextBoard,
    PieceColor aiColor,
  ) {
    int penalty = 0;
    final hypState = state.copyWith(
      board: nextBoard,
      turn: aiColor == PieceColor.white ? PieceColor.black : PieceColor.white,
    );
    final posKey = GameState.generatePositionKey(hypState);
    if (state.positionCounts.containsKey(posKey)) {
      final count = state.positionCounts[posKey]!;
      penalty += (count >= 2 ? 15000 : 500);
    }

    if (state.lastMove != null) {
      if (move.toRow == state.lastMove!.fromRow &&
          move.toCol == state.lastMove!.fromCol &&
          move.fromRow == state.lastMove!.toRow &&
          move.fromCol == state.lastMove!.toCol) {
        final movingPiece = state.board.pieceAt(move.fromRow, move.fromCol);
        final capturedSomething =
            state.board.pieceAt(move.toRow, move.toCol) != null;

        if (!capturedSomething && movingPiece?.type != PieceType.pawn) {
          penalty += 1200;
        }
      }
    }
    return penalty;
  }

  int evaluateBoardState(Board board, PieceColor color) {
    return _evaluateBoard(board, color);
  }

  int _evaluateBoard(Board board, PieceColor aiColor) {
    int totalValue = 0;
    int enemyKingRow = -1;
    int enemyKingCol = -1;
    final enemyColor = (aiColor == PieceColor.white
        ? PieceColor.black
        : PieceColor.white);

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board.pieceAt(r, c);
        if (p != null && p.type == PieceType.king && p.color == enemyColor) {
          enemyKingRow = r;
          enemyKingCol = c;
          break;
        }
      }
      if (enemyKingRow != -1) break;
    }

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.pieceAt(r, c);
        if (piece == null) continue;

        int val = _pieceValues[piece.type]!;
        final isWhite = piece.color == PieceColor.white;
        val += _getPSTValue(piece.type, isWhite ? 7 - r : r, c);

        // Agression
        if (piece.color == aiColor &&
            enemyKingRow != -1 &&
            piece.type != PieceType.king) {
          final distSq =
              (r - enemyKingRow) * (r - enemyKingRow) +
              (c - enemyKingCol) * (c - enemyKingCol);
          val += (64 - distSq) ~/ 4;
        }

        if (piece.color == aiColor) {
          totalValue += val;
        } else {
          totalValue -= val;
        }
      }
    }
    return totalValue;
  }

  List<Move> _getAllLegalMoves(
    Board board,
    PieceColor color,
    SquarePosition? ep,
    bool cks,
    bool cqs,
  ) {
    final moves = <Move>[];
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final piece = board.pieceAt(r, c);
        if (piece != null && piece.color == color) {
          for (int tr = 0; tr < 8; tr++) {
            for (int tc = 0; tc < 8; tc++) {
              final move = Move(fromRow: r, fromCol: c, toRow: tr, toCol: tc);
              if (_validator.isValidMove(
                board: board,
                move: move,
                enPassantTarget: ep,
                canCastleKingSide: cks,
                canCastleQueenSide: cqs,
              )) {
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
        .map((row) => List<Piece?>.from(row))
        .toList();
    newSquares[move.toRow][move.toCol] = newSquares[move.fromRow][move.fromCol];
    newSquares[move.fromRow][move.fromCol] = null;
    return Board(newSquares);
  }

  int _max(int a, int b) => a > b ? a : b;
  int _min(int a, int b) => a < b ? a : b;
}
