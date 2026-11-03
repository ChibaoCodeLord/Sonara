import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'common/constants/app_colors.dart';
import 'common/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'modules/app/bloc/app_cubit.dart';
import 'modules/auth/bloc/auth_cubit.dart';
import 'modules/charts/bloc/charts_cubit.dart';
import 'modules/home/bloc/home_cubit.dart';
import 'modules/library/bloc/library_cubit.dart';
import 'modules/player/bloc/player_cubit.dart';
import 'modules/profile/bloc/profile_cubit.dart';
import 'modules/settings/bloc/settings_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surfaceCrisp,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const SonaraApp());
}

class SonaraApp extends StatelessWidget {
  const SonaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppCubit>(create: (_) => AppCubit()),
        BlocProvider<HomeCubit>(create: (_) => HomeCubit()),
        BlocProvider<PlayerCubit>(create: (_) => PlayerCubit()),
        BlocProvider<LibraryCubit>(create: (_) => LibraryCubit()),
        BlocProvider<ChartsCubit>(create: (_) => ChartsCubit()),
        BlocProvider<ProfileCubit>(create: (_) => ProfileCubit()),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
        BlocProvider<SettingsCubit>(create: (_) => SettingsCubit()),
      ],
      child: MaterialApp(
        title: 'Sonara',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRouter.welcome,
        // Start on Welcome alone; the default would stack '/' underneath.
        onGenerateInitialRoutes: (initialRoute) => [
          AppRouter.onGenerateRoute(RouteSettings(name: initialRoute)),
        ],
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
