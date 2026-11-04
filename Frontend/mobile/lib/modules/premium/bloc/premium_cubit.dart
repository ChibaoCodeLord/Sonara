import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/premium_mock_service.dart';
import 'premium_state.dart';

class PremiumCubit extends Cubit<PremiumState> {
  final PremiumMockService _service;

  PremiumCubit({PremiumMockService? service})
    : _service = service ?? PremiumMockService(),
      super(
        PremiumState(
          plans: (service ?? PremiumMockService()).getPlans(),
          comparison: (service ?? PremiumMockService()).getComparison(),
          paymentMethods: (service ?? PremiumMockService()).getPaymentMethods(),
        ),
      );

  void selectPlan(String planId) =>
      emit(state.copyWith(selectedPlanId: planId));

  void selectPayment(String paymentId) =>
      emit(state.copyWith(selectedPaymentId: paymentId));

  Future<void> purchase() async {
    emit(state.copyWith(isProcessing: true));
    await _service.purchase(state.selectedPlanId, state.selectedPaymentId);
    emit(state.copyWith(isProcessing: false));
  }
}
