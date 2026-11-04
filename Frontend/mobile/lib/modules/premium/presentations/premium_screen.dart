import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/constants/app_colors.dart';
import '../../../common/constants/app_text_styles.dart';
import '../../../common/widgets/gradient_button.dart';
import '../../profile/bloc/profile_cubit.dart';
import '../bloc/premium_cubit.dart';
import '../bloc/premium_state.dart';
import '../models/premium_plan_model.dart';

/// SCR-16: Sonara Premium subscription.
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PremiumCubit(),
      child: BlocBuilder<PremiumCubit, PremiumState>(
        builder: (context, state) {
          final cubit = context.read<PremiumCubit>();
          return Scaffold(
            backgroundColor: AppColors.surface,
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHero(context)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  sliver: SliverList.list(
                    children: [
                      Text(
                        'Free vs VIP',
                        style: AppTextStyles.headlineSm.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ComparisonTable(rows: state.comparison),
                      const SizedBox(height: 24),
                      Text(
                        'Chọn gói cước',
                        style: AppTextStyles.headlineSm.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final plan in state.plans)
                        _PlanTile(
                          plan: plan,
                          selected: plan.id == state.selectedPlanId,
                          onTap: () => cubit.selectPlan(plan.id),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        'Phương thức thanh toán',
                        style: AppTextStyles.headlineSm.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCrisp,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Material(
                          type: MaterialType.transparency,
                          child: RadioGroup<String>(
                            groupValue: state.selectedPaymentId,
                            onChanged: (value) {
                              if (value != null) cubit.selectPayment(value);
                            },
                            child: Column(
                              children: [
                                for (final method in state.paymentMethods)
                                  RadioListTile<String>(
                                    value: method.id,
                                    activeColor: AppColors.primary,
                                    secondary: Icon(
                                      _paymentIcon(method.id),
                                      color: AppColors.primary,
                                    ),
                                    title: Text(
                                      method.name,
                                      style: AppTextStyles.labelLg.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    subtitle: Text(
                                      method.detail,
                                      style: AppTextStyles.bodySm,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gói cước tự động gia hạn. Bạn có thể hủy bất cứ lúc nào trong Cài đặt > Gói cước.',
                        style: AppTextStyles.labelSm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(color: AppColors.borderSubtle),
                  ),
                ),
                child: GradientButton(
                  label:
                      'Thanh toán ${state.selectedPlan.priceText}${state.selectedPlan.period}',
                  icon: Icons.workspace_premium_rounded,
                  isLoading: state.isProcessing,
                  onPressed: () => _purchase(context, state.selectedPlan),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _purchase(BuildContext context, PremiumPlanModel plan) async {
    await context.read<PremiumCubit>().purchase();
    if (!context.mounted) return;
    context.read<ProfileCubit>().setVipTier('Sonara ${plan.name} (Lossless)');
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            gradient: AppColors.aiGradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.workspace_premium_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        title: Text(
          'Chào mừng đến Sonara VIP!',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineSm.copyWith(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Gói ${plan.name} đã được kích hoạt. Tận hưởng Hi-Res Lossless không quảng cáo.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMd,
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Bắt đầu nghe'),
          ),
        ],
      ),
    );
    if (context.mounted) Navigator.of(context).pop();
  }

  IconData _paymentIcon(String id) {
    switch (id) {
      case 'momo':
        return Icons.account_balance_wallet_rounded;
      case 'zalopay':
        return Icons.qr_code_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      default:
        return Icons.storefront_rounded;
    }
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                tooltip: 'Đóng',
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'SONARA PREMIUM',
                        style: AppTextStyles.labelSm.copyWith(
                          color: Colors.white,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Nghe trọn vẹn\nchất âm Lossless',
                      style: AppTextStyles.displayLgMobile.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dùng thử miễn phí 1 tháng. Hi-Res FLAC 24-bit, không quảng cáo, AI Hum không giới hạn.',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  final List<PremiumFeatureRow> rows;

  const _ComparisonTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCrisp,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                const Expanded(flex: 4, child: SizedBox()),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Free',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'VIP',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (final row in rows) ...[
            const Divider(height: 1, color: AppColors.borderSubtle),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(row.feature, style: AppTextStyles.labelMd),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      row.free,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySm,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      row.vip,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final PremiumPlanModel plan;
  final bool selected;
  final VoidCallback onTap;

  const _PlanTile({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryFixed.withValues(alpha: 0.6)
              : AppColors.surfaceCrisp,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderSubtle,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          plan.name,
                          style: AppTextStyles.labelLg.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (plan.badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.aiGradient,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            plan.badge!,
                            style: AppTextStyles.labelSm.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(plan.description, style: AppTextStyles.bodySm),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                text: plan.priceText,
                style: AppTextStyles.headlineSm.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                children: [
                  TextSpan(text: plan.period, style: AppTextStyles.bodySm),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
