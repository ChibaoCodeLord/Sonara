import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';
import '../../../../common/widgets/app_network_image.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback? onSearchTap;

  const ProfileHeader({
    super.key,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              // Logo icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.aiGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.graphic_eq_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // App Title & Subtitle
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RESONANCE AI',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Hồ Sơ',
                      style: AppTextStyles.headlineSm.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              // Search button
              IconButton(
                icon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textCharcoal,
                  size: 24,
                ),
                onPressed: onSearchTap ?? () {},
              ),
              const SizedBox(width: 4),
              // Profile Avatar
              Container(
                width: 34,
                height: 34,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: const AppNetworkImage(
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuD7duxPs1DpjO6pOuSivTM7hDgDn1CrarsTO1-5t9k7n2pg7ZEjcFNr0ZMzHssB3UfCVaaynS09o4TvAh4O56tfzkxG4SJ3rD8eoWA1yYo-gtp2XHrwxfF32iOaFhIwlbcUO5uiYmtpyfMS9ttmmhvuj4x2Ys3hI6QZhz4CEWhLoVRag1dpg3ctZI21MA9bTvRyZaPt9vMXhbTVVeV9NJSNSESPTHqdkpo4VvrQkJ-dsh-WastTqTnNlQ',
                  borderRadius: 999,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
