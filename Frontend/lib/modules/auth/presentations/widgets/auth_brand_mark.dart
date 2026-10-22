import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';

class AuthBrandMark extends StatelessWidget {
  final double size;

  const AuthBrandMark({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppColors.aiGradient,
            borderRadius: BorderRadius.circular(size * 0.3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33B3122E),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.graphic_eq_rounded,
            color: Colors.white,
            size: size * 0.6,
          ),
        ),
        SizedBox(width: size * 0.3),
        Flexible(
          child: Text(
            'Sonara',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.headlineLg.copyWith(
              fontSize: size * 0.7,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
