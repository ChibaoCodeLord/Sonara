import '../models/premium_plan_model.dart';

class PremiumState {
  final List<PremiumPlanModel> plans;
  final List<PremiumFeatureRow> comparison;
  final List<PaymentMethodModel> paymentMethods;
  final String selectedPlanId;
  final String selectedPaymentId;
  final bool isProcessing;

  const PremiumState({
    this.plans = const [],
    this.comparison = const [],
    this.paymentMethods = const [],
    this.selectedPlanId = 'yearly',
    this.selectedPaymentId = 'momo',
    this.isProcessing = false,
  });

  PremiumPlanModel get selectedPlan =>
      plans.firstWhere((p) => p.id == selectedPlanId);

  PremiumState copyWith({
    String? selectedPlanId,
    String? selectedPaymentId,
    bool? isProcessing,
  }) {
    return PremiumState(
      plans: plans,
      comparison: comparison,
      paymentMethods: paymentMethods,
      selectedPlanId: selectedPlanId ?? this.selectedPlanId,
      selectedPaymentId: selectedPaymentId ?? this.selectedPaymentId,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}
