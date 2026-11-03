import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/widgets/confirm_dialog.dart';
import '../../../core/routes/app_router.dart';
import '../../player/bloc/player_cubit.dart';
import '../bloc/auth_cubit.dart';

/// Confirms, clears the session and returns to the Welcome screen.
Future<void> confirmAndSignOut(BuildContext context) async {
  final ok = await showConfirmDialog(
    context,
    title: 'Đăng xuất tài khoản?',
    message: 'Nhạc đã tải và lịch sử AI Hum trên thiết bị này sẽ được giữ lại.',
    confirmLabel: 'Đăng xuất',
  );
  if (!ok || !context.mounted) return;
  context.read<AuthCubit>().signOut();
  context.read<PlayerCubit>()
    ..pause()
    ..cancelSleepTimer();
  Navigator.of(context)
      .pushNamedAndRemoveUntil(AppRouter.welcome, (_) => false);
}
