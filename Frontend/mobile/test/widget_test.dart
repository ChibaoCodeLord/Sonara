import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xmusic/main.dart';
import 'package:xmusic/modules/hum_to_search/bloc/hum_search_cubit.dart';
import 'package:xmusic/modules/hum_to_search/presentations/hum_search_result_screen.dart';
import 'package:xmusic/modules/hum_to_search/presentations/hum_to_search_screen.dart';
import 'package:xmusic/modules/player/bloc/player_cubit.dart';
import 'package:xmusic/modules/playlist/presentations/playlist_detail_screen.dart';

void main() {
  testWidgets('Sonara app smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(const SonaraApp());
    await tester.pump();

    // App opens on Welcome; continue as a guest
    expect(find.text('Đăng ký miễn phí'), findsOneWidget);
    await tester.tap(find.text('Dùng thử'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify key elements exist on home tab
    expect(find.text('Khám phá'), findsWidgets);
    expect(find.text('AI HUM'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Switch to Thư Viện tab
    await tester.tap(find.text('Thư viện'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Bài hát yêu thích'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Switch to Xếp hạng tab
    await tester.tap(find.text('Xếp hạng'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Việt Nam Hot 50'), findsOneWidget);
    expect(find.text('Từng Là Của Nhau'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Switch to Hồ sơ tab
    await tester.tap(find.text('Hồ sơ'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Lê Hải Đăng'), findsOneWidget);
    expect(find.text('Hiệu ứng âm thanh'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Hum results fit a narrow phone', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final humCubit = HumSearchCubit()..stopAndAnalyze();
    addTearDown(humCubit.close);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: humCubit),
          BlocProvider(create: (_) => PlayerCubit()),
        ],
        child: const MaterialApp(home: HumSearchResultScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.textContaining('Đã tìm thấy'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Hum and playlist pages fit a narrow phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final humCubit = HumSearchCubit();
    await tester.pumpWidget(
      BlocProvider.value(
        value: humCubit,
        child: const MaterialApp(home: HumToSearchScreen()),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      BlocProvider(
        create: (_) => PlayerCubit(),
        child: const MaterialApp(home: PlaylistDetailScreen()),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    await humCubit.close();
  });
}
