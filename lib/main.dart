import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'common/constants/app_colors.dart';
import 'common/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'modules/app/bloc/app_cubit.dart';
import 'modules/app/presentations/main_shell_screen.dart';
import 'modules/home/bloc/home_cubit.dart';
import 'modules/player/bloc/player_cubit.dart';

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
  runApp(const ResonanceMusicApp());
}

class ResonanceMusicApp extends StatelessWidget {
  const ResonanceMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppCubit>(create: (_) => AppCubit()),
        BlocProvider<HomeCubit>(create: (_) => HomeCubit()),
        BlocProvider<PlayerCubit>(create: (_) => PlayerCubit()),
      ],
      child: MaterialApp(
        title: 'Resonance AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const MainShellScreen(),
      ),
    );
  }
}
