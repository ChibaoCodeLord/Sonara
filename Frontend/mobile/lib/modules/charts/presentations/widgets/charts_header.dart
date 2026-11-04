import 'package:flutter/material.dart';
import '../../../../common/widgets/main_section_header.dart';

class ChartsHeader extends StatelessWidget {
  const ChartsHeader({super.key, this.onProfileTap, this.onSearchTap});

  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) => MainSectionHeader(
        title: 'Bảng xếp hạng',
        onProfileTap: onProfileTap,
        onSearchTap: onSearchTap,
      );
}
