import 'package:flutter/material.dart';
import '../../../../common/constants/app_colors.dart';
import '../../../../common/constants/app_text_styles.dart';

/// A titled white card holding [ProfileMenuRow]s separated by dividers.
class ProfileMenuSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ProfileMenuSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: AppTextStyles.headlineSm.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceCrisp,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      indent: 52,
                      color: AppColors.borderSubtle,
                    ),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Uniform row: icon, title, optional value text and a trailing control
/// (chevron by default when tappable).
class ProfileMenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? color;

  const ProfileMenuRow({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
    this.trailing,
    this.color,
  });

  /// A row with an on/off switch.
  factory ProfileMenuRow.toggle({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ProfileMenuRow(
      icon: icon,
      title: title,
      onTap: () => onChanged(!value),
      trailing: Switch(
        value: value,
        activeThumbColor: Colors.white,
        activeTrackColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColors.textCharcoal;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 54),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 10, 6),
          child: Row(
            children: [
              Icon(icon, color: tint, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLg.copyWith(
                    color: tint,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodySm,
                  ),
                ),
              ],
              if (trailing != null)
                trailing!
              else if (onTap != null)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
