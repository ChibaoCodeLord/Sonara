import 'package:flutter/material.dart';
import '../../../../common/widgets/main_section_header.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, this.onProfileTap});

  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) =>
      MainSectionHeader(title: 'Khám phá', onProfileTap: onProfileTap);
}
