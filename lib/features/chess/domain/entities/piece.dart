enum PieceType {
  king,
  queen,
  rook,
  bishop,
  knight,
  pawn,
}

enum PieceColor {
  white,
  black,
}

class Piece {
  final PieceType type;
  final PieceColor color;

  const Piece({
    required this.type,
    required this.color,
  });

  @override
  String toString() => '$color $type';
}
