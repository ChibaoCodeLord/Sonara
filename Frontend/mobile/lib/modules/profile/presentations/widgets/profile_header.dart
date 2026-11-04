import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/widgets/main_section_header.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, this.onSettingsTap});

  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) => MainSectionHeader(
        title: 'Hồ sơ',
        actions: [
          if (onSettingsTap != null)
            IconButton(
              tooltip: 'Cài đặt',
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.textCharcoal,
              ),
              onPressed: onSettingsTap,
            ),
        ],
      );
}
