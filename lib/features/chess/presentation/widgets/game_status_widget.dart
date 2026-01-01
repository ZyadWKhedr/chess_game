import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../provider/game_state.dart';
import '../../domain/entities/piece.dart';

class GameStatusWidget extends StatelessWidget {
  final PieceColor turn;
  final GameStatus status;

  const GameStatusWidget({super.key, required this.turn, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            turn == PieceColor.white ? "WHITE'S TURN" : "BLACK'S TURN",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ),
          ),
          if (status == GameStatus.check)
            Container(
              margin: EdgeInsets.only(left: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'CHECK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
