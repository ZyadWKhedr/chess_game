import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../provider/chess_game_notifier.dart';
import '../provider/game_state.dart';
import '../provider/theme_provider.dart';
import 'chess_game_page.dart';

class ChessHomePage extends ConsumerWidget {
  const ChessHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              ref
                  .read(themeProvider.notifier)
                  .state = themeMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grid_4x4,
              size: 100.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 20.h),
            Text(
              'FLUTTER CHESS',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 60.h),
            _buildMenuButton(
              context,
              ref,
              label: 'Local Multiplayer',
              icon: Icons.people,
              mode: GameMode.pvp,
            ),
            SizedBox(height: 20.h),
            _buildMenuButton(
              context,
              ref,
              label: 'Play vs AI',
              icon: Icons.computer,
              mode: GameMode.pva,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required IconData icon,
    required GameMode mode,
  }) {
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
          ).colorScheme.primary.withOpacity(0.08),
          foregroundColor: Theme.of(context).colorScheme.primary,
        ).copyWith(elevation: ButtonStyleButton.allOrNull(0)),
        onPressed: () {
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
