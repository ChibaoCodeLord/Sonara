import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'common/constants/app_colors.dart';
import 'common/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'modules/app/bloc/app_cubit.dart';
import 'modules/app/presentations/main_shell_screen.dart';
import 'modules/charts/bloc/charts_cubit.dart';
import 'modules/home/bloc/home_cubit.dart';
import 'modules/library/bloc/library_cubit.dart';
import 'modules/player/bloc/player_cubit.dart';
import 'modules/profile/bloc/profile_cubit.dart';

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
      ],
      child: MaterialApp(
        title: 'Sonara',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const MainShellScreen(),
      ),
    );
  }
}
