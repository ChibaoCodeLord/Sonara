import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xmusic/core/routes/app_router.dart';
import 'package:xmusic/modules/app/bloc/app_cubit.dart';
import 'package:xmusic/modules/auth/bloc/auth_cubit.dart';
import 'package:xmusic/modules/auth/presentations/otp_verification_screen.dart';
import 'package:xmusic/modules/charts/bloc/charts_cubit.dart';
import 'package:xmusic/modules/home/bloc/home_cubit.dart';
import 'package:xmusic/modules/library/bloc/library_cubit.dart';
import 'package:xmusic/modules/player/bloc/player_cubit.dart';
import 'package:xmusic/modules/player/presentations/sheets/audio_device_sheet.dart';
import 'package:xmusic/modules/player/presentations/sheets/queue_sheet.dart';
import 'package:xmusic/modules/player/presentations/sheets/share_song_sheet.dart';
import 'package:xmusic/modules/player/presentations/sheets/sleep_timer_sheet.dart';
import 'package:xmusic/modules/player/presentations/sheets/song_options_sheet.dart';
import 'package:xmusic/modules/playlist/presentations/sheets/add_to_playlist_sheet.dart';
import 'package:xmusic/modules/playlist/presentations/sheets/playlist_editor_sheet.dart';
import 'package:xmusic/modules/profile/bloc/profile_cubit.dart';
import 'package:xmusic/modules/settings/bloc/settings_cubit.dart';

Widget _app({required String route, Object? arguments, Widget? home}) {
  return MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => AppCubit()),
      BlocProvider(create: (_) => HomeCubit()),
      BlocProvider(create: (_) => PlayerCubit()),
      BlocProvider(create: (_) => LibraryCubit()),
      BlocProvider(create: (_) => ChartsCubit()),
      BlocProvider(create: (_) => ProfileCubit()),
      BlocProvider(create: (_) => AuthCubit()),
      BlocProvider(create: (_) => SettingsCubit()),
    ],
    child: home != null
        ? MaterialApp(home: home, onGenerateRoute: AppRouter.onGenerateRoute)
        : MaterialApp(
            initialRoute: route,
            onGenerateInitialRoutes: (name) => [
              AppRouter.onGenerateRoute(
                RouteSettings(name: name, arguments: arguments),
              ),
            ],
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
  );
}

void _usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  final routes = <String, Object?>{
    AppRouter.welcome: null,
    AppRouter.signIn: null,
    AppRouter.signUp: null,
    AppRouter.otpVerification: null,
    AppRouter.tastePicker: true,
    '${AppRouter.tastePicker}#follow': false,
    AppRouter.search: null,
    '${AppRouter.search}#query': 'mưa',
    AppRouter.searchResults: 'vũ',
    '${AppRouter.searchResults}#empty': 'zzzz',
    AppRouter.categoryDetail: null,
    AppRouter.artistDetail: 'artist_vu',
    AppRouter.albumDetail: 'album_mot_van_nam',
    AppRouter.followingArtists: null,
    AppRouter.allMixes: null,
    AppRouter.fullChart: 'vn',
    AppRouter.lyrics: null,
    AppRouter.equalizer: null,
    AppRouter.offlineMusic: null,
    AppRouter.listeningHistory: null,
    AppRouter.humHistory: null,
    AppRouter.premium: null,
    AppRouter.settings: null,
    AppRouter.editProfile: null,
    AppRouter.recap: null,
    AppRouter.waveCodeScanner: null,
  };

  for (final entry in routes.entries) {
    testWidgets('renders ${entry.key} on a narrow phone', (tester) async {
      _usePhoneSize(tester);
      final route = entry.key.split('#').first;
      await tester.pumpWidget(_app(route: route, arguments: entry.value));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);

      // Scroll to the bottom to lay out every section.
      final scrollables = find.byType(Scrollable);
      if (scrollables.evaluate().isNotEmpty) {
        await tester.drag(scrollables.first, const Offset(0, -2000));
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      }

      // Unmount so timers and animation controllers are disposed.
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('bottom sheets open on a narrow phone', (tester) async {
    _usePhoneSize(tester);
    final sheets = <String, void Function(BuildContext)>{
      'queue': (c) => QueueSheet.show(c),
      'sleep': (c) => SleepTimerSheet.show(c),
      'device': (c) => AudioDeviceSheet.show(c),
      'options': (c) => SongOptionsSheet.show(
            c,
            c.read<PlayerCubit>().state.song,
            isNowPlaying: true,
          ),
      'add': (c) =>
          AddToPlaylistSheet.show(c, c.read<PlayerCubit>().state.song),
      'share': (c) => ShareSongSheet.show(
            c,
            id: 'song_bau_troi_moi',
            title: 'Bầu Trời Mới',
            subtitle: 'Da LAB',
            coverUrl: 'assets/images/bau_troi_moi.jpg',
          ),
      'editor': (c) => PlaylistEditorSheet.show(c),
    };

    await tester.pumpWidget(
      _app(
        route: '',
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                for (final entry in sheets.entries)
                  TextButton(
                    onPressed: () => entry.value(context),
                    child: Text('open-${entry.key}'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    for (final key in sheets.keys) {
      await tester.tap(find.text('open-$key'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull, reason: 'sheet $key');
      await tester.tapAt(const Offset(10, 10)); // dismiss via barrier
      await tester.pump(const Duration(milliseconds: 400));
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('sign up → OTP → taste picker → home', (tester) async {
    _usePhoneSize(tester);
    await tester.pumpWidget(_app(route: AppRouter.signUp));
    await tester.pump();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Nguyễn Văn A');
    await tester.enterText(fields.at(1), 'a@sonara.vn');
    await tester.enterText(fields.at(2), 'Sonara2026');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text('Tiếp tục'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Xác thực email'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byType(OtpVerificationScreen),
        matching: find.byType(TextField),
      ),
      '246810',
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Gu âm nhạc của bạn là gì?'), findsOneWidget);

    for (final genre in ['Pop', 'Ballad', 'Indie']) {
      await tester.tap(find.text(genre));
      await tester.pump();
    }
    await tester.tap(find.text('Hoàn tất & Khám phá'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Khám phá'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
