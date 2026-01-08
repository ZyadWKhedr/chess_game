import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'features/chess/presentation/pages/splash_screen.dart';
import 'features/chess/presentation/provider/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const ProviderScope(child: ChessApp()));
}

class ChessApp extends ConsumerWidget {
  const ChessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          title: 'Grandmaster Chess',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1A1C2E),
              primary: const Color(0xFF1A1C2E),
              secondary: const Color(0xFF4B7399),
              surface: Colors.white,
              surfaceContainerLowest: const Color(0xFFF8F9FE),
            ),
            scaffoldBackgroundColor: const Color(0xFFF8F9FE),
            cardTheme: CardThemeData(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFFF8F9FE),
              foregroundColor: const Color(0xFF1A1C2E),
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20.sp,
                letterSpacing: 1.2,
                color: const Color(0xFF1A1C2E),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0F111A),
              brightness: Brightness.dark,
              primary: const Color(0xFFE2E2FF),
              secondary: const Color(0xFF94A3B8),
              surface: const Color(0xFF0F111A),
              surfaceContainerHighest: const Color(0xFF1E293B),
            ),
            scaffoldBackgroundColor: const Color(0xFF0F111A),
            cardTheme: CardThemeData(
              elevation: 0,
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF0F111A),
              foregroundColor: const Color(0xFFE2E2FF),
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20.sp,
                letterSpacing: 1.2,
                color: const Color(0xFFE2E2FF),
              ),
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
