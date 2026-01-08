import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/move.dart';
import '../../domain/entities/piece.dart';
import '../../domain/entities/square_position.dart';
import '../../domain/services/move_validator.dart';
import '../../domain/services/chess_ai_service.dart';
import '../../domain/services/ai_trash_talk_service.dart';
import '../../domain/services/chess_game_service.dart';
import 'game_state.dart';

class ChessGameNotifier extends StateNotifier<GameState> {
  ChessGameNotifier() : super(GameState.initial());

  Timer? _gameTimer;

  final ChessAIService _aiService = ChessAIService();
  late final ChessGameService _gameService = ChessGameService(
    MoveValidator(),
    _aiService,
    AiTrashTalkService(),
  );

  void initGame(
    GameMode mode, {
    PieceColor playerColor = PieceColor.white,
    Difficulty difficulty = Difficulty.intermediate,
    Duration? maxTime,
  }) {
    _gameTimer?.cancel();
    state = GameState.initial(
      mode: mode,
      playerColor: playerColor,
      difficulty: difficulty,
      maxTime: maxTime,
    );

    if (maxTime != null) {
      _startTimer();
    }

    if (mode == GameMode.pva && playerColor == PieceColor.black) {
      _makeAiMove();
    }
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.status != GameStatus.ongoing &&
          state.status != GameStatus.check) {
        _gameTimer?.cancel();
        return;
      }

      if (state.turn == PieceColor.white) {
        final newTime = state.whiteTime! - const Duration(seconds: 1);
        if (newTime.inSeconds <= 0) {
          state = state.copyWith(
            whiteTime: Duration.zero,
            status: GameStatus.timeout,
          );
          _gameTimer?.cancel();
        } else {
          state = state.copyWith(whiteTime: newTime);
        }
      } else {
        final newTime = state.blackTime! - const Duration(seconds: 1);
        if (newTime.inSeconds <= 0) {
          state = state.copyWith(
            blackTime: Duration.zero,
            status: GameStatus.timeout,
          );
          _gameTimer?.cancel();
        } else {
          state = state.copyWith(blackTime: newTime);
        }
      }
    });
  }

  void selectSquare(int row, int col) {
    if (state.isThinking ||
        state.status == GameStatus.checkmate ||
        state.status == GameStatus.draw ||
        state.status == GameStatus.timeout) {
      return;
    }

    if (state.gameMode == GameMode.pva && state.turn != state.playerColor) {
      return;
    }

    final piece = state.board.pieceAt(row, col);

    if (state.selected?.row == row && state.selected?.col == col) {
      state = state.copyWith(selected: () => null, possibleMoves: []);
      return;
    }

    if (piece != null && piece.color == state.turn) {
      HapticFeedback.lightImpact();
      final moves = _gameService.generateMoves(state, row, col);
      state = state.copyWith(
        selected: () => SquarePosition(row, col),
        possibleMoves: moves,
      );
    }
  }

  void tryMove(int toRow, int toCol) {
    if (state.isThinking ||
        state.status == GameStatus.checkmate ||
        state.status == GameStatus.draw ||
        state.status == GameStatus.timeout) {
      return;
    }

    if (state.gameMode == GameMode.pva && state.turn != state.playerColor) {
      return;
    }

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

  void promotePiece(PieceType type) {
    var newState = _gameService.promotePiece(state, type);
    newState = newState.copyWith(isThinking: false);
    _handleStateUpdates(newState);
  }

  void _applyMove(Move move) {
    var newState = _gameService.applyMove(state, move);
    newState = newState.copyWith(isThinking: false);
    _handleStateUpdates(newState);
  }

  void _handleStateUpdates(GameState newState) {
    if (newState.aiMessage != null) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) state = state.copyWith(clearMessage: true);
      });
    }

    state = newState;

    if (state.status == GameStatus.checkmate ||
        state.status == GameStatus.draw ||
        state.status == GameStatus.timeout) {
      _gameTimer?.cancel();
      return;
    }

    if (state.gameMode == GameMode.pva && state.turn != state.playerColor) {
      _makeAiMove();
    }
  }

  Future<void> _makeAiMove() async {
    state = state.copyWith(isThinking: true);
    await Future.delayed(const Duration(milliseconds: 800));

    final bestMove = _aiService.findBestMove(state);
    if (bestMove != null) {
      _applyMove(bestMove);
    } else {
      if (state.isThinking) state = state.copyWith(isThinking: false);
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}

final chessGameProvider = StateNotifierProvider<ChessGameNotifier, GameState>(
  (ref) => ChessGameNotifier(),
);
