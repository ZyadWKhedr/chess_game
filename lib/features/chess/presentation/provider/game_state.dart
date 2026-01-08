import '../../domain/entities/board.dart';
import '../../domain/entities/move.dart';
import '../../domain/entities/piece.dart';
import '../../domain/entities/square_position.dart';

enum GameMode {
  pvp, // Player vs Player
  pva, // Player vs AI
}

enum GameStatus { ongoing, check, checkmate, draw, timeout }

enum Difficulty { beginner, intermediate, master, grandmaster }

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
  final List<String> moveHistory; // For threefold repetition detection
  final int halfMoveClock; // For 50-move rule
  final Map<String, int> positionCounts; // For threefold repetition

  final PieceColor playerColor;
  final Difficulty aiDifficulty;
  final String? aiMessage;

  // Advanced Rules State
  final SquarePosition? enPassantTarget;
  final bool canCastleWhiteKingSide;
  final bool canCastleWhiteQueenSide;
  final bool canCastleBlackKingSide;
  final bool canCastleBlackQueenSide;
  final Duration? whiteTime;
  final Duration? blackTime;
  final Duration? maxTime;

  const GameState({
    required this.board,
    required this.turn,
    this.selected,
    required this.possibleMoves,
    required this.whiteCaptured,
    required this.blackCaptured,
    required this.gameMode,
    this.playerColor = PieceColor.white,
    this.aiDifficulty = Difficulty.intermediate,
    this.aiMessage,
    this.isThinking = false,
    this.status = GameStatus.ongoing,
    this.lastMove,
    this.pendingPromotion,
    this.enPassantTarget,
    this.canCastleWhiteKingSide = true,
    this.canCastleWhiteQueenSide = true,
    this.canCastleBlackKingSide = true,
    this.canCastleBlackQueenSide = true,
    this.moveHistory = const [],
    this.halfMoveClock = 0,
    this.positionCounts = const {},
    this.whiteTime,
    this.blackTime,
    this.maxTime,
  });

  factory GameState.initial({
    GameMode mode = GameMode.pvp,
    PieceColor playerColor = PieceColor.white,
    Difficulty difficulty = Difficulty.intermediate,
    Duration? maxTime,
  }) {
    final initialState = GameState(
      board: Board.initial(),
      turn: PieceColor.white,
      selected: null,
      possibleMoves: const [],
      whiteCaptured: const [],
      blackCaptured: const [],
      gameMode: mode,
      playerColor: playerColor,
      aiDifficulty: difficulty,
      maxTime: maxTime,
      whiteTime: maxTime,
      blackTime: maxTime,
    );

    // Initialize position counts with starting position
    final positionKey = generatePositionKey(initialState);
    return initialState.copyWith(
      positionCounts: {positionKey: 1},
      moveHistory: [positionKey],
    );
  }

  static String generatePositionKey(GameState state) {
    // Generate a unique key for the current board position
    final buffer = StringBuffer();

    // Add board state
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 8; col++) {
        final piece = state.board.pieceAt(row, col);
        if (piece != null) {
          buffer.write(
            piece.color == PieceColor.white
                ? piece.type.toString()[0].toUpperCase()
                : piece.type.toString()[0].toLowerCase(),
          );
        } else {
          buffer.write('.');
        }
      }
    }

    // Add turn
    buffer.write(state.turn == PieceColor.white ? 'w' : 'b');

    // Add castling rights
    buffer.write(state.canCastleWhiteKingSide ? 'K' : '');
    buffer.write(state.canCastleWhiteQueenSide ? 'Q' : '');
    buffer.write(state.canCastleBlackKingSide ? 'k' : '');
    buffer.write(state.canCastleBlackQueenSide ? 'q' : '');
    buffer.write(' ');

    // Add en passant marker
    buffer.write(state.enPassantTarget != null ? 'e' : '-');

    // Add halfmove clock to differentiate positions by their draw potential
    buffer.write(' h${state.halfMoveClock}');

    return buffer.toString();
  }

  GameState copyWith({
    Board? board,
    PieceColor? turn,
    SquarePosition? Function()? selected,
    List<Move>? possibleMoves,
    List<Piece>? whiteCaptured,
    List<Piece>? blackCaptured,
    GameMode? gameMode,
    bool? isThinking,
    GameStatus? status,
    Move? lastMove,
    Move? Function()? pendingPromotion,
    SquarePosition? Function()? enPassantTarget,
    bool? canCastleWhiteKingSide,
    bool? canCastleWhiteQueenSide,
    bool? canCastleBlackKingSide,
    bool? canCastleBlackQueenSide,
    PieceColor? playerColor,
    Difficulty? aiDifficulty,
    String? aiMessage,
    bool clearMessage = false,
    List<String>? moveHistory,
    int? halfMoveClock,
    Map<String, int>? positionCounts,
    Duration? whiteTime,
    Duration? blackTime,
    Duration? maxTime,
  }) {
    return GameState(
      board: board ?? this.board,
      turn: turn ?? this.turn,
      selected: selected != null ? selected() : this.selected,
      possibleMoves: possibleMoves ?? this.possibleMoves,
      whiteCaptured: whiteCaptured ?? this.whiteCaptured,
      blackCaptured: blackCaptured ?? this.blackCaptured,
      gameMode: gameMode ?? this.gameMode,
      isThinking: isThinking ?? this.isThinking,
      status: status ?? this.status,
      lastMove: lastMove ?? this.lastMove,
      pendingPromotion: pendingPromotion != null
          ? pendingPromotion()
          : this.pendingPromotion,
      enPassantTarget: enPassantTarget != null
          ? enPassantTarget()
          : this.enPassantTarget,
      canCastleWhiteKingSide:
          canCastleWhiteKingSide ?? this.canCastleWhiteKingSide,
      canCastleWhiteQueenSide:
          canCastleWhiteQueenSide ?? this.canCastleWhiteQueenSide,
      canCastleBlackKingSide:
          canCastleBlackKingSide ?? this.canCastleBlackKingSide,
      canCastleBlackQueenSide:
          canCastleBlackQueenSide ?? this.canCastleBlackQueenSide,
      playerColor: playerColor ?? this.playerColor,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
      aiMessage: clearMessage ? null : (aiMessage ?? this.aiMessage),
      moveHistory: moveHistory ?? this.moveHistory,
      halfMoveClock: halfMoveClock ?? this.halfMoveClock,
      positionCounts: positionCounts ?? this.positionCounts,
      whiteTime: whiteTime ?? this.whiteTime,
      blackTime: blackTime ?? this.blackTime,
      maxTime: maxTime ?? this.maxTime,
    );
  }
}
