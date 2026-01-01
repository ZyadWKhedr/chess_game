import 'piece.dart';

class Board {
  /// 8x8 chess board
  /// Null means empty square
  final List<List<Piece?>> squares;

  const Board(this.squares);

  /// Factory for initial chess position
  factory Board.initial() {
    return Board(_createInitialBoard());
  }

  static List<List<Piece?>> _createInitialBoard() {
    final board = List.generate(
      8,
      (_) => List<Piece?>.filled(8, null),
    );

    // Pawns
    for (int col = 0; col < 8; col++) {
      board[1][col] = const Piece(type: PieceType.pawn, color: PieceColor.black);
      board[6][col] = const Piece(type: PieceType.pawn, color: PieceColor.white);
    }

    // Rooks
    board[0][0] = board[0][7] =
        const Piece(type: PieceType.rook, color: PieceColor.black);
    board[7][0] = board[7][7] =
        const Piece(type: PieceType.rook, color: PieceColor.white);

    // Knights
    board[0][1] = board[0][6] =
        const Piece(type: PieceType.knight, color: PieceColor.black);
    board[7][1] = board[7][6] =
        const Piece(type: PieceType.knight, color: PieceColor.white);

    // Bishops
    board[0][2] = board[0][5] =
        const Piece(type: PieceType.bishop, color: PieceColor.black);
    board[7][2] = board[7][5] =
        const Piece(type: PieceType.bishop, color: PieceColor.white);

    // Queens
    board[0][3] =
        const Piece(type: PieceType.queen, color: PieceColor.black);
    board[7][3] =
        const Piece(type: PieceType.queen, color: PieceColor.white);

    // Kings
    board[0][4] =
        const Piece(type: PieceType.king, color: PieceColor.black);
    board[7][4] =
        const Piece(type: PieceType.king, color: PieceColor.white);

    return board;
  }

  Piece? pieceAt(int row, int col) => squares[row][col];
}
