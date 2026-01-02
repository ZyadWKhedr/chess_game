import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grandmaster_chess/features/chess/presentation/pages/chess_home_page.dart';

void main() {
  testWidgets('ChessHomePage renders correctly', (WidgetTester tester) async {
    // Set up a physical size for the tester to avoid layout errors with ScreenUtil
    await tester.binding.setSurfaceSize(const Size(360, 690));

    await tester.pumpWidget(
      ProviderScope(
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (context, child) => const MaterialApp(home: ChessHomePage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('FLUTTER CHESS'), findsOneWidget);
    expect(find.text('Local Multiplayer'), findsOneWidget);
    expect(find.text('Play vs AI'), findsOneWidget);

    // Reset surface size
    await tester.binding.setSurfaceSize(null);
  });
}
