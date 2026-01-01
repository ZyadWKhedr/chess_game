import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/game_state.dart';
import '../provider/theme_provider.dart';
import '../widgets/home_menu_button.dart';
import '../widgets/home_logo.dart';

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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HomeLogo(),
                SizedBox(height: 60),
                HomeMenuButton(
                  label: 'Local Multiplayer',
                  icon: Icons.people,
                  mode: GameMode.pvp,
                ),
                SizedBox(height: 20),
                HomeMenuButton(
                  label: 'Play vs AI',
                  icon: Icons.computer,
                  mode: GameMode.pva,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
