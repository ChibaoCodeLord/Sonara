import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'app_network_image.dart';

/// The same compact page header across the four main tabs.
class MainSectionHeader extends StatelessWidget {
  const MainSectionHeader({
    super.key,
    required this.title,
    this.onProfileTap,
    this.onSearchTap,
    this.actions = const [],
  });

  final String title;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchTap;
  final List<Widget> actions;

  static const _avatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuD7duxPs1DpjO6pOuSivTM7hDgDn1CrarsTO1-5t9k7n2pg7ZEjcFNr0ZMzHssB3UfCVaaynS09o4TvAh4O56tfzkxG4SJ3rD8eoWA1yYo-gtp2XHrwxfF32iOaFhIwlbcUO5uiYmtpyfMS9ttmmhvuj4x2Ys3hI6QZhz4CEWhLoVRag1dpg3ctZI21MA9bTvRyZaPt9vMXhbTVVeV9NJSNSESPTHqdkpo4VvrQkJ-dsh-WastTqTnNlQ';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.aiGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.graphic_eq_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onSearchTap != null)
                IconButton(
                  tooltip: 'Tìm kiếm',
                  icon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textCharcoal,
                  ),
                  onPressed: onSearchTap,
                ),
              ...actions,
              if (onProfileTap != null)
                Semantics(
                  button: true,
                  label: 'Mở hồ sơ',
                  child: InkWell(
                    onTap: onProfileTap,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Container(
                        width: 36,
                        height: 36,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const AppNetworkImage(
                          imageUrl: _avatarUrl,
                          borderRadius: 999,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
