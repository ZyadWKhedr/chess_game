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
    String statusText = turn == PieceColor.white
        ? "WHITE'S TURN"
        : "BLACK'S TURN";
    Color statusColor = Theme.of(
      context,
    ).colorScheme.primary.withValues(alpha: 0.8);

    if (status == GameStatus.checkmate) {
      statusText = "CHECKMATE";
      statusColor = Colors.redAccent;
    } else if (status == GameStatus.draw) {
      statusText = "DRAW";
      statusColor = Colors.orangeAccent;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                  color: statusColor,
                ),
                child: Text(statusText),
              ),
              if (status == GameStatus.check)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) => Transform.scale(
                    scale: value,
                    child: Container(
                      margin: EdgeInsets.only(left: 12.w),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.redAccent, Colors.red.shade900],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'CHECK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (status == GameStatus.ongoing || status == GameStatus.check)
            Container(
              margin: EdgeInsets.only(top: 4.h),
              height: 3.h,
              width: 40.w,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
        ],
      ),
    );
  }
}
