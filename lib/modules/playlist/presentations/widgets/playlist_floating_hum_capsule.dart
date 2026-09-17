import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';

class PlaylistFloatingHumCapsule extends StatefulWidget {
  final VoidCallback onHumTap;

  const PlaylistFloatingHumCapsule({
    super.key,
    required this.onHumTap,
  });

  @override
  State<PlaylistFloatingHumCapsule> createState() =>
      _PlaylistFloatingHumCapsuleState();
}

class _PlaylistFloatingHumCapsuleState
    extends State<PlaylistFloatingHumCapsule>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCrisp.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x261A1A1A),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  final val = _animController.value;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildWaveBar(6 + val * 6),
                      const SizedBox(width: 3),
                      _buildWaveBar(16 - val * 8),
                      const SizedBox(width: 3),
                      _buildWaveBar(10 + val * 5),
                    ],
                  );
                },
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tìm kiếm giai điệu?',
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Ngân nga một đoạn bất kỳ',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Mic FAB
          GestureDetector(
            onTap: widget.onHumTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.aiGradient,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x59B3122E),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.mic_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveBar(double height) {
    return Container(
      width: 3,
      height: height.clamp(4, 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
