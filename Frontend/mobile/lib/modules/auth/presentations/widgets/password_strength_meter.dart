import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';

class PasswordStrengthMeter extends StatelessWidget {
  final String password;

  const PasswordStrengthMeter({super.key, required this.password});

  /// 0..4: length, mixed case, digit, symbol.
  static int scoreOf(String password) {
    if (password.isEmpty) return 0;
    var score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[A-Z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    final score = scoreOf(password);
    const labels = ['Rất yếu', 'Yếu', 'Trung bình', 'Mạnh', 'Rất mạnh'];
    const colors = [
      AppColors.textMuted,
      Color(0xFFE85D04),
      Color(0xFFF2A900),
      AppColors.emeraldActive,
      Color(0xFF059669),
    ];

    return Row(
      children: [
        for (var i = 0; i < 4; i++)
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 4,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: i < score ? colors[score] : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        const SizedBox(width: 6),
        SizedBox(
          width: 70,
          child: Text(
            password.isEmpty ? '' : labels[score],
            textAlign: TextAlign.right,
            style: AppTextStyles.labelSm.copyWith(
              color: colors[score],
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
