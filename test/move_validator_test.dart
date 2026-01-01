import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/chess/domain/entities/board.dart';
import 'package:flutter_application_1/features/chess/domain/entities/move.dart';
import 'package:flutter_application_1/features/chess/domain/entities/piece.dart';
import 'package:flutter_application_1/features/chess/domain/services/move_validator.dart';

void main() {
  late MoveValidator validator;
  late Board initialBoard;

  setUp(() {
    validator = MoveValidator();
    initialBoard = Board.initial();
  });

  group('MoveValidator - Basic Pawn Moves', () {
    test('White pawn can move forward one square', () {
      final move = Move(fromRow: 6, fromCol: 3, toRow: 5, toCol: 3);
      expect(validator.isValidMove(board: initialBoard, move: move), isTrue);
    });

    test('White pawn can move forward two squares from start', () {
      final move = Move(fromRow: 6, fromCol: 3, toRow: 4, toCol: 3);
      expect(validator.isValidMove(board: initialBoard, move: move), isTrue);
    });

    test('Pawn cannot move forward if blocked', () {
      final squares = initialBoard.squares
          .map((r) => List<Piece?>.from(r))
          .toList();
      squares[5][3] = Piece(type: PieceType.rook, color: PieceColor.black);
      final blockedBoard = Board(squares);

      final move = Move(fromRow: 6, fromCol: 3, toRow: 5, toCol: 3);
      expect(validator.isValidMove(board: blockedBoard, move: move), isFalse);
    });
  });

  group('MoveValidator - Knight Moves', () {
    test('Knight can jump over pieces', () {
      final move = Move(fromRow: 7, fromCol: 1, toRow: 5, toCol: 2);
      expect(validator.isValidMove(board: initialBoard, move: move), isTrue);
    });

    test('Knight invalid move pattern', () {
      final move = Move(fromRow: 7, fromCol: 1, toRow: 5, toCol: 1);
      expect(validator.isValidMove(board: initialBoard, move: move), isFalse);
    });
  });

  group('MoveValidator - King & Check', () {
    test('King cannot move into check', () {
      // Clear board except kings and an enemy rook
      final squares = List.generate(8, (_) => List<Piece?>.filled(8, null));
      squares[7][4] = Piece(type: PieceType.king, color: PieceColor.white);
      squares[0][4] = Piece(type: PieceType.king, color: PieceColor.black);
      squares[5][5] = Piece(type: PieceType.rook, color: PieceColor.black);
      final board = Board(squares);

      // Move into rook's vertical line
      final move = Move(fromRow: 7, fromCol: 4, toRow: 7, toCol: 5);
      expect(validator.isValidMove(board: board, move: move), isFalse);
    });
  });
}
