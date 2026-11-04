class PremiumPlanModel {
  final String id;
  final String name;
  final String priceText;
  final int priceVnd;
  final String period;
  final String description;
  final String? badge;

  const PremiumPlanModel({
    required this.id,
    required this.name,
    required this.priceText,
    required this.priceVnd,
    required this.period,
    required this.description,
    this.badge,
  });
}

class PremiumFeatureRow {
  final String feature;
  final String free;
  final String vip;

  const PremiumFeatureRow(this.feature, this.free, this.vip);
}

class PaymentMethodModel {
  final String id;
  final String name;
  final String detail;

  const PaymentMethodModel(this.id, this.name, this.detail);
}
