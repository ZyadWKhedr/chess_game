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
        style:
            ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
              ),
            ).copyWith(
              elevation: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) return 0;
                return 8;
              }),
              shadowColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
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
