import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_bottom_sheet.dart';
import '../../../profile/bloc/profile_cubit.dart';
import '../../bloc/player_cubit.dart';
import '../../bloc/player_state.dart';
import '../../models/audio_device_model.dart';
import '../../services/player_service.dart';

/// Picks the audio output (headphones, speakers, TV, car...).
class AudioDeviceSheet extends StatelessWidget {
  const AudioDeviceSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showAppBottomSheet<void>(
      context: context,
      title: 'Chọn thiết bị phát',
      subtitle: 'Bluetooth, AirPlay & Chromecast',
      builder: (_) => const AudioDeviceSheet(),
    );
  }

  IconData _iconFor(AudioDeviceType type) {
    switch (type) {
      case AudioDeviceType.headphones:
        return Icons.headphones_rounded;
      case AudioDeviceType.phone:
        return Icons.smartphone_rounded;
      case AudioDeviceType.speaker:
        return Icons.speaker_rounded;
      case AudioDeviceType.tv:
        return Icons.tv_rounded;
      case AudioDeviceType.car:
        return Icons.directions_car_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final devices = PlayerService().getAudioDevices();
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(top: 4, bottom: 24),
          children: [
            for (final device in devices)
              SheetActionTile(
                icon: _iconFor(device.type),
                label: device.name,
                subtitle: device.detail,
                color: device.name == state.audioRouteDevice
                    ? AppColors.primary
                    : null,
                trailing: device.name == state.audioRouteDevice
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () {
                  context.read<PlayerCubit>().setAudioRoute(device.name);
                  context
                      .read<ProfileCubit>()
                      .setPairedDevice('${device.name} • ${device.detail.split(' • ').first}');
                  Navigator.of(context).pop();
                },
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const Icon(
                    Icons.bluetooth_searching_rounded,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Không thấy thiết bị? Bật Bluetooth và đảm bảo thiết bị ở gần.',
                      style: AppTextStyles.bodySm,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
