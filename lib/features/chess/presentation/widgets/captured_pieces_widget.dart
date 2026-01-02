import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/core/extensions/piece_symbol.dart';
import '../../domain/entities/piece.dart';

class CapturedPiecesWidget extends StatelessWidget {
  final List<Piece> captured;

  const CapturedPiecesWidget({super.key, required this.captured});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      color: isDark ? Colors.black26 : Colors.grey[200],
      child: Row(
        children: captured.map((p) => _buildCapturedPiece(context, p)).toList(),
      ),
    );
  }

  Widget _buildCapturedPiece(BuildContext context, Piece piece) {
    final double fontSize = switch (piece.type) {
      PieceType.king => 28.sp,
      PieceType.queen => 26.sp,
      PieceType.bishop => 24.sp,
      PieceType.knight => 24.sp,
      PieceType.rook => 22.sp,
      PieceType.pawn => 18.sp,
    };

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: piece.render(fontSize: fontSize, bold: false),
    );
  }
}
