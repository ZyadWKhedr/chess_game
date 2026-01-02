import '../../domain/entities/board.dart';
import '../../domain/entities/move.dart';
import '../../domain/entities/piece.dart';
import '../../domain/entities/square_position.dart';

enum GameMode {
  pvp, // Player vs Player
  pva, // Player vs AI
}

enum GameStatus { ongoing, check, checkmate, draw }

class GameState {
  final Board board;
  final PieceColor turn;
  final SquarePosition? selected;
  final List<Move> possibleMoves;
  final List<Piece> whiteCaptured;
  final List<Piece> blackCaptured;
  final GameMode gameMode;
  final bool isThinking;
  final GameStatus status;
  final Move? lastMove;
  final Move? pendingPromotion;

  final PieceColor playerColor;

  // Advanced Rules State
  final SquarePosition? enPassantTarget;
  final bool canCastleWhiteKingSide;
  final bool canCastleWhiteQueenSide;
  final bool canCastleBlackKingSide;
  final bool canCastleBlackQueenSide;

  const GameState({
    required this.board,
    required this.turn,
    this.selected,
    required this.possibleMoves,
    required this.whiteCaptured,
    required this.blackCaptured,
    required this.gameMode,
    this.playerColor = PieceColor.white,
    this.isThinking = false,
    this.status = GameStatus.ongoing,
    this.lastMove,
    this.pendingPromotion,
    this.enPassantTarget,
    this.canCastleWhiteKingSide = true,
    this.canCastleWhiteQueenSide = true,
    this.canCastleBlackKingSide = true,
    this.canCastleBlackQueenSide = true,
  });

  factory GameState.initial({
    GameMode mode = GameMode.pvp,
    PieceColor playerColor = PieceColor.white,
  }) {
    return GameState(
      board: Board.initial(),
      turn: PieceColor.white,
      selected: null,
      possibleMoves: const [],
      whiteCaptured: const [],
      blackCaptured: const [],
      gameMode: mode,
      playerColor: playerColor,
    );
  }

  GameState copyWith({
    Board? board,
    PieceColor? turn,
    SquarePosition? selected,
    List<Move>? possibleMoves,
    List<Piece>? whiteCaptured,
    List<Piece>? blackCaptured,
    GameMode? gameMode,
    bool? isThinking,
    GameStatus? status,
    Move? lastMove,
    Move? pendingPromotion,
    SquarePosition? enPassantTarget,
    bool? canCastleWhiteKingSide,
    bool? canCastleWhiteQueenSide,
    bool? canCastleBlackKingSide,
    bool? canCastleBlackQueenSide,
    PieceColor? playerColor,
  }) {
    return GameState(
      board: board ?? this.board,
      turn: turn ?? this.turn,
      selected: selected, // can be null to deselect
      possibleMoves: possibleMoves ?? this.possibleMoves,
      whiteCaptured: whiteCaptured ?? this.whiteCaptured,
      blackCaptured: blackCaptured ?? this.blackCaptured,
      gameMode: gameMode ?? this.gameMode,
      isThinking: isThinking ?? this.isThinking,
      status: status ?? this.status,
      lastMove: lastMove ?? this.lastMove,
      pendingPromotion: pendingPromotion ?? this.pendingPromotion,
      enPassantTarget: enPassantTarget ?? this.enPassantTarget,
      canCastleWhiteKingSide:
          canCastleWhiteKingSide ?? this.canCastleWhiteKingSide,
      canCastleWhiteQueenSide:
          canCastleWhiteQueenSide ?? this.canCastleWhiteQueenSide,
      canCastleBlackKingSide:
          canCastleBlackKingSide ?? this.canCastleBlackKingSide,
      canCastleBlackQueenSide:
          canCastleBlackQueenSide ?? this.canCastleBlackQueenSide,
      playerColor: playerColor ?? this.playerColor,
    );
  }
}
