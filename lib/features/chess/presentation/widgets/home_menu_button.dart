import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../provider/chess_game_notifier.dart';
import '../provider/game_state.dart';
import '../pages/chess_game_page.dart';

class HomeMenuButton extends ConsumerWidget {
  final String label;
  final IconData icon;
  final GameMode mode;
  final VoidCallback? onTap;

  const HomeMenuButton({
    super.key,
    required this.label,
    required this.icon,
    required this.mode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 280.w,
      height: 60.h,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          elevation: 0,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.08),
          foregroundColor: Theme.of(context).colorScheme.primary,
        ).copyWith(elevation: ButtonStyleButton.allOrNull(0)),
        onPressed:
            onTap ??
            () {
              ref.read(chessGameProvider.notifier).initGame(mode);
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ChessGamePage()));
            },
        icon: Icon(icon, size: 24.sp),
        label: Text(
          label,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
