import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';

/// Time-of-day greeting plus a search pill whose mic opens Hum-to-Search.
class HomeSearchPrompt extends StatelessWidget {
  final String userName;
  final VoidCallback onSearchTap;
  final VoidCallback onHumTap;

  const HomeSearchPrompt({
    super.key,
    required this.userName,
    required this.onSearchTap,
    required this.onHumTap,
  });

  static String greetingFor(DateTime time) {
    if (time.hour < 11) return 'Chào buổi sáng';
    if (time.hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  @override
  Widget build(BuildContext context) {
    // Vietnamese names put the given name last.
    final givenName = userName.trim().split(' ').last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${greetingFor(DateTime.now())}, $givenName',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.headlineMd.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        Material(
          color: AppColors.surfaceCrisp,
          shape: const StadiumBorder(
            side: BorderSide(color: AppColors.borderMuted),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onSearchTap,
            child: SizedBox(
              height: 52,
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search_rounded, color: AppColors.textMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bài hát, nghệ sĩ, lời bài hát…',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Tooltip(
                      message: 'Ngân nga để tìm bài hát',
                      child: Material(
                        color: AppColors.primary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onHumTap,
                          child: const SizedBox(
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.mic_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
