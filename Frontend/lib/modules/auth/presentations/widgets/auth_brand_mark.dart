import 'package:flutter/material.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/sonara_logo.dart';

class AuthBrandMark extends StatelessWidget {
  final double size;

  const AuthBrandMark({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SonaraLogo(size: size, showShadow: true),
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
