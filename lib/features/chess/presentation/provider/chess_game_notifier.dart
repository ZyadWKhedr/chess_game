import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/board.dart';
import '../../domain/entities/move.dart';
import '../../domain/entities/piece.dart';
import '../../domain/entities/square_position.dart';
import '../../domain/services/move_validator.dart';
import '../../domain/services/chess_ai_service.dart';
import 'game_state.dart';

class ChessGameNotifier extends StateNotifier<GameState> {
  ChessGameNotifier() : super(GameState.initial());

  final MoveValidator _validator = MoveValidator();
  final ChessAIService _aiService = ChessAIService();

  void initGame(GameMode mode, {PieceColor playerColor = PieceColor.white}) {
    state = GameState.initial(mode: mode, playerColor: playerColor);
    if (mode == GameMode.pva && playerColor == PieceColor.black) {
      _makeAiMove();
    }
  }

  void selectSquare(int row, int col) {
    if (state.isThinking ||
        state.status == GameStatus.checkmate ||
        state.status == GameStatus.draw)
      return;

    // In PvA, prevent user from selecting pieces if it's not their turn
    if (state.gameMode == GameMode.pva && state.turn != state.playerColor) {
      return;
    }

    final piece = state.board.pieceAt(row, col);

    if (state.selected?.row == row && state.selected?.col == col) {
      state = state.copyWith(selected: null, possibleMoves: []);
      return;
    }

    if (piece != null && piece.color == state.turn) {
      HapticFeedback.lightImpact();
      state = state.copyWith(
        selected: SquarePosition(row, col),
        possibleMoves: _generateMoves(row, col),
      );
    }
  }

  List<Move> _generateMoves(int row, int col) {
    final moves = <Move>[];
    final piece = state.board.pieceAt(row, col);
    if (piece == null) return moves;

    final isWhite = piece.color == PieceColor.white;
    final canCastleKing = isWhite
        ? state.canCastleWhiteKingSide
        : state.canCastleBlackKingSide;
    final canCastleQueen = isWhite
        ? state.canCastleWhiteQueenSide
        : state.canCastleBlackQueenSide;

    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final move = Move(fromRow: row, fromCol: col, toRow: r, toCol: c);
        if (_validator.isValidMove(
          board: state.board,
          move: move,
          enPassantTarget: state.enPassantTarget,
          canCastleKingSide: canCastleKing,
          canCastleQueenSide: canCastleQueen,
        )) {
          moves.add(move);
        }
      }
    }
    return moves;
  }

  void tryMove(int toRow, int toCol) {
    if (state.isThinking ||
        state.status == GameStatus.checkmate ||
        state.status == GameStatus.draw)
      return;

    // In PvA, prevent move attempts if not user turn
    if (state.gameMode == GameMode.pva && state.turn != state.playerColor)
      return;

    final selected = state.selected;
    if (selected == null) return;

    final move = Move(
      fromRow: selected.row,
      fromCol: selected.col,
      toRow: toRow,
      toCol: toCol,
    );

    if (!state.possibleMoves.contains(move)) {
      HapticFeedback.heavyImpact();
      return;
    }

    _applyMove(move);
  }

  void _applyMove(Move move) {
    final newSquares = state.board.squares
        .map((row) => List<Piece?>.from(row))
        .toList();
    final movingPiece = newSquares[move.fromRow][move.fromCol];
    final capturedPiece = newSquares[move.toRow][move.toCol];

    if (movingPiece == null) return;

    final newWhiteCaptured = List<Piece>.from(state.whiteCaptured);
    final newBlackCaptured = List<Piece>.from(state.blackCaptured);

    // Standard Capture
    if (capturedPiece != null) {
      if (state.turn == PieceColor.white) {
        newWhiteCaptured.add(capturedPiece);
      } else {
        newBlackCaptured.add(capturedPiece);
      }
    }

    // --- EN PASSANT CAPTURE ---
    if (movingPiece.type == PieceType.pawn &&
        state.enPassantTarget?.row == move.toRow &&
        state.enPassantTarget?.col == move.toCol) {
      // It's an en passant move
      final capturedPawnRow = move.fromRow;
      final capturedPawnCol = move.toCol;
      final extraCapture = newSquares[capturedPawnRow][capturedPawnCol];
      if (extraCapture != null) {
        if (state.turn == PieceColor.white) {
          newWhiteCaptured.add(extraCapture);
        } else {
          newBlackCaptured.add(extraCapture);
        }
        newSquares[capturedPawnRow][capturedPawnCol] = null;
      }
    }

    // --- CASTLING ROOK MOVE ---
    if (movingPiece.type == PieceType.king) {
      if (move.toCol - move.fromCol == 2) {
        // King-side castle: move rook from col 7 to 5
        final rook = newSquares[move.fromRow][7];
        newSquares[move.fromRow][5] = rook;
        newSquares[move.fromRow][7] = null;
      } else if (move.toCol - move.fromCol == -2) {
        // Queen-side castle: move rook from col 0 to 3
        final rook = newSquares[move.fromRow][0];
        newSquares[move.fromRow][3] = rook;
        newSquares[move.fromRow][0] = null;
      }
    }

    // Update pieces positions
    newSquares[move.toRow][move.toCol] = movingPiece;
    newSquares[move.fromRow][move.fromCol] = null;

    // --- EN PASSANT TARGET LOGIC ---
    SquarePosition? nextEnPassantTarget;
    if (movingPiece.type == PieceType.pawn &&
        (move.toRow - move.fromRow).abs() == 2) {
      nextEnPassantTarget = SquarePosition(
        (move.fromRow + move.toRow) ~/ 2,
        move.fromCol,
      );
    }

    // --- CASTLING RIGHTS UPDATE ---
    bool nextCastleWKS = state.canCastleWhiteKingSide;
    bool nextCastleWQS = state.canCastleWhiteQueenSide;
    bool nextCastleBKS = state.canCastleBlackKingSide;
    bool nextCastleBQS = state.canCastleBlackQueenSide;

    if (movingPiece.type == PieceType.king) {
      if (movingPiece.color == PieceColor.white) {
        nextCastleWKS = false;
        nextCastleWQS = false;
      } else {
        nextCastleBKS = false;
        nextCastleBQS = false;
      }
    } else if (movingPiece.type == PieceType.rook) {
      if (movingPiece.color == PieceColor.white) {
        if (move.fromCol == 0) nextCastleWQS = false;
        if (move.fromCol == 7) nextCastleWKS = false;
      } else {
        if (move.fromCol == 0) nextCastleBQS = false;
        if (move.fromCol == 7) nextCastleBKS = false;
      }
    }
    // Also check if a rook was captured
    if (capturedPiece?.type == PieceType.rook) {
      if (move.toRow == 0 && move.toCol == 0) nextCastleBQS = false;
      if (move.toRow == 0 && move.toCol == 7) nextCastleBKS = false;
      if (move.toRow == 7 && move.toCol == 0) nextCastleWQS = false;
      if (move.toRow == 7 && move.toCol == 7) nextCastleWKS = false;
    }

    // --- PAWN PROMOTION ---
    if (movingPiece.type == PieceType.pawn) {
      if ((movingPiece.color == PieceColor.white && move.toRow == 0) ||
          (movingPiece.color == PieceColor.black && move.toRow == 7)) {
        // If it's a player move, pause for choice
        if (state.gameMode == GameMode.pvp || state.turn == state.playerColor) {
          state = state.copyWith(pendingPromotion: move);
          return;
        } else {
          // AI auto-promotes to Queen
          newSquares[move.toRow][move.toCol] = Piece(
            type: PieceType.queen,
            color: movingPiece.color,
          );
        }
      }
    }

    _finalizeMove(
      move: move,
      newSquares: newSquares,
      newWhiteCaptured: newWhiteCaptured,
      newBlackCaptured: newBlackCaptured,
      nextEnPassantTarget: nextEnPassantTarget,
      nextCastleWKS: nextCastleWKS,
      nextCastleWQS: nextCastleWQS,
      nextCastleBKS: nextCastleBKS,
      nextCastleBQS: nextCastleBQS,
    );
  }

  void promotePiece(PieceType type) {
    final move = state.pendingPromotion;
    if (move == null) return;

    final newSquares = state.board.squares
        .map((row) => List<Piece?>.from(row))
        .toList();
    final movingPiece = newSquares[move.fromRow][move.fromCol];
    if (movingPiece == null) return;

    // Redo basic move logic from _applyMove but for promotion
    final targetPiece = newSquares[move.toRow][move.toCol];
    final newWhiteCaptured = List<Piece>.from(state.whiteCaptured);
    final newBlackCaptured = List<Piece>.from(state.blackCaptured);

    if (targetPiece != null) {
      if (state.turn == PieceColor.white) {
        newWhiteCaptured.add(targetPiece);
      } else {
        newBlackCaptured.add(targetPiece);
      }
    }

    // Replace pawn with chosen piece
    newSquares[move.toRow][move.toCol] = Piece(
      type: type,
      color: movingPiece.color,
    );
    newSquares[move.fromRow][move.fromCol] = null;

    _finalizeMove(
      move: move,
      newSquares: newSquares,
      newWhiteCaptured: newWhiteCaptured,
      newBlackCaptured: newBlackCaptured,
      nextEnPassantTarget: null, // No EP target after promotion
      nextCastleWKS: state.canCastleWhiteKingSide,
      nextCastleWQS: state.canCastleWhiteQueenSide,
      nextCastleBKS: state.canCastleBlackKingSide,
      nextCastleBQS: state.canCastleBlackQueenSide,
    );
  }

  void _finalizeMove({
    required Move move,
    required List<List<Piece?>> newSquares,
    required List<Piece> newWhiteCaptured,
    required List<Piece> newBlackCaptured,
    required SquarePosition? nextEnPassantTarget,
    required bool nextCastleWKS,
    required bool nextCastleWQS,
    required bool nextCastleBKS,
    required bool nextCastleBQS,
  }) {
    final nextBoard = Board(newSquares);
    final nextTurn = state.turn == PieceColor.white
        ? PieceColor.black
        : PieceColor.white;

    final status = _calculateStatusForApply(
      nextBoard,
      nextTurn,
      nextEnPassantTarget,
      nextCastleWKS,
      nextCastleWQS,
      nextCastleBKS,
      nextCastleBQS,
    );

    state = state.copyWith(
      board: nextBoard,
      turn: nextTurn,
      selected: null,
      possibleMoves: const [],
      whiteCaptured: newWhiteCaptured,
      blackCaptured: newBlackCaptured,
      status: status,
      lastMove: move,
      pendingPromotion: null,
      enPassantTarget: nextEnPassantTarget,
      canCastleWhiteKingSide: nextCastleWKS,
      canCastleWhiteQueenSide: nextCastleWQS,
      canCastleBlackKingSide: nextCastleBKS,
      canCastleBlackQueenSide: nextCastleBQS,
    );

    if (state.status == GameStatus.checkmate || state.status == GameStatus.draw)
      return;

    if (state.gameMode == GameMode.pva && state.turn != state.playerColor) {
      _makeAiMove();
    }
  }

  // Intermediate status calculation that handles advanced rules for legal moves checking
  GameStatus _calculateStatusForApply(
    Board board,
    PieceColor turn,
    SquarePosition? enPassantTarget,
    bool wks,
    bool wqs,
    bool bks,
    bool bqs,
  ) {
    final isCheck = _validator.isKingInCheck(board, turn);

    // Check legal moves
    bool hasMoves = false;
    for (int r = 0; r < 8; r++) {
      for (int c = 0; c < 8; c++) {
        final p = board.pieceAt(r, c);
        if (p != null && p.color == turn) {
          for (int tr = 0; tr < 8; tr++) {
            for (int tc = 0; tc < 8; tc++) {
              final canCastleK = turn == PieceColor.white ? wks : bks;
              final canCastleQ = turn == PieceColor.white ? wqs : bqs;
              if (_validator.isValidMove(
                board: board,
                move: Move(fromRow: r, fromCol: c, toRow: tr, toCol: tc),
                enPassantTarget: enPassantTarget,
                canCastleKingSide: canCastleK,
                canCastleQueenSide: canCastleQ,
              )) {
                hasMoves = true;
                break;
              }
            }
            if (hasMoves) break;
          }
        }
        if (hasMoves) break;
      }
    }

    if (!hasMoves) {
      return isCheck ? GameStatus.checkmate : GameStatus.draw;
    }
    return isCheck ? GameStatus.check : GameStatus.ongoing;
  }

  Future<void> _makeAiMove() async {
    state = state.copyWith(isThinking: true);
    await Future.delayed(const Duration(milliseconds: 800)); // Smooth timing

    final bestMove = _aiService.findBestMove(state.board, state.turn, 3);
    if (bestMove != null) {
      _applyMove(bestMove);
    }
    state = state.copyWith(isThinking: false);
  }
}

final chessGameProvider = StateNotifierProvider<ChessGameNotifier, GameState>(
  (ref) => ChessGameNotifier(),
);
