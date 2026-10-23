import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/sonara_logo.dart';

class HumFlowHeader extends StatelessWidget {
  const HumFlowHeader({super.key, required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            IconButton(
              onPressed: onBackTap,
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.textCharcoal,
              tooltip: 'Quay lại',
            ),
            const SizedBox(width: 4),
            const SonaraLogo(size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tìm bằng giai điệu',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineSm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
