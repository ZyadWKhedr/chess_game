import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/piece.dart';

class GameTimerWidget extends StatelessWidget {
  final Duration? time;
  final bool isActive;
  final PieceColor color;

  const GameTimerWidget({
    super.key,
    required this.time,
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (time == null) return const SizedBox.shrink();

    final minutes = time!.inMinutes.toString().padLeft(2, '0');
    final seconds = (time!.inSeconds % 60).toString().padLeft(2, '0');
    final isLowTime = time!.inSeconds < 30;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isActive
            ? (isLowTime
                  ? Colors.red.withValues(alpha: 0.2)
                  : Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: isActive
              ? (isLowTime ? Colors.red : Theme.of(context).colorScheme.primary)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Text(
        '$minutes:$seconds',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: isActive
              ? (isLowTime ? Colors.red : Theme.of(context).colorScheme.primary)
              : Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
