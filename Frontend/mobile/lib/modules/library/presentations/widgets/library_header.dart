import 'package:flutter/material.dart';
import '../../../../common/widgets/main_section_header.dart';

class LibraryHeader extends StatelessWidget {
  const LibraryHeader({super.key, this.onProfileTap, this.onSearchTap});

  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) => MainSectionHeader(
        title: 'Thư viện',
        onProfileTap: onProfileTap,
        onSearchTap: onSearchTap,
      );
}
