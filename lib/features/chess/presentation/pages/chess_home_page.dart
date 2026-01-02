import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/piece.dart';
import '../provider/chess_game_notifier.dart';
import '../provider/game_state.dart';
import '../provider/theme_provider.dart';
import '../widgets/home_menu_button.dart';
import '../widgets/home_logo.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/side_selection_dialog.dart';
import '../widgets/difficulty_selection_dialog.dart';
import '../../../../core/providers/ad_provider.dart';
import 'chess_game_page.dart';

class ChessHomePage extends ConsumerWidget {
  const ChessHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize Ad Service early so it's ready when game ends
    ref.read(interstitialAdProvider);
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
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const HomeLogo(),
                        const SizedBox(height: 60),
                        const HomeMenuButton(
                          label: 'Local Multiplayer',
                          icon: Icons.people,
                          mode: GameMode.pvp,
                        ),
                        const SizedBox(height: 20),
                        HomeMenuButton(
                          label: 'Play vs AI',
                          icon: Icons.computer,
                          mode: GameMode.pva,
                          onTap: () => _showSideSelectionDialog(context, ref),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSideSelectionDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final selectedColor = await showDialog<PieceColor>(
      context: context,
      builder: (context) => const SideSelectionDialog(),
    );

    if (selectedColor != null && context.mounted) {
      final selectedDifficulty = await showDialog<Difficulty>(
        context: context,
        builder: (context) => const DifficultySelectionDialog(),
      );

      if (selectedDifficulty != null && context.mounted) {
        _startGame(context, ref, selectedColor, selectedDifficulty);
      }
    }
  }

  void _startGame(
    BuildContext context,
    WidgetRef ref,
    PieceColor color,
    Difficulty difficulty,
  ) {
    ref
        .read(chessGameProvider.notifier)
        .initGame(GameMode.pva, playerColor: color, difficulty: difficulty);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChessGamePage()));
  }
}
