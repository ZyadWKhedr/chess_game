class Move {
  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;

  const Move({
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
  });

  @override
  String toString() {
    return 'Move ($fromRow,$fromCol) -> ($toRow,$toCol)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Move &&
          fromRow == other.fromRow &&
          fromCol == other.fromCol &&
          toRow == other.toRow &&
          toCol == other.toCol;

  @override
  int get hashCode => fromRow ^ fromCol ^ toRow ^ toCol;
}
