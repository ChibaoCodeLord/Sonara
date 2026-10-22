import '../models/premium_plan_model.dart';

class PremiumMockService {
  List<PremiumPlanModel> getPlans() {
    return const [
      PremiumPlanModel(
        id: 'monthly',
        name: 'VIP Tháng',
        priceText: '59.000đ',
        priceVnd: 59000,
        period: '/tháng',
        description: 'Hủy bất cứ lúc nào',
      ),
      PremiumPlanModel(
        id: 'yearly',
        name: 'VIP Năm',
        priceText: '590.000đ',
        priceVnd: 590000,
        period: '/năm',
        description: 'Chỉ 49.000đ/tháng',
        badge: 'Tiết kiệm 17%',
      ),
      PremiumPlanModel(
        id: 'student',
        name: 'Học sinh / Sinh viên',
        priceText: '29.000đ',
        priceVnd: 29000,
        period: '/tháng',
        description: 'Xác minh thẻ sinh viên',
        badge: 'Giảm 50%',
      ),
      PremiumPlanModel(
        id: 'family',
        name: 'Gia đình',
        priceText: '99.000đ',
        priceVnd: 99000,
        period: '/tháng',
        description: 'Tối đa 6 tài khoản Premium',
      ),
    ];
  }

  List<PremiumFeatureRow> getComparison() {
    return const [
      PremiumFeatureRow(
        'Chất lượng âm thanh',
        '320kbps',
        'Hi-Res FLAC 24-bit/192kHz',
      ),
      PremiumFeatureRow('Quảng cáo', 'Có', 'Không quảng cáo'),
      PremiumFeatureRow('Nghe ngoại tuyến', 'Không', 'Không giới hạn'),
      PremiumFeatureRow('Tìm kiếm AI Hum', '10 lượt/ngày', 'Không giới hạn'),
      PremiumFeatureRow('Spatial Audio 3D', 'Không', 'Có'),
      PremiumFeatureRow('Karaoke AI Stem', 'Không', 'Có'),
      PremiumFeatureRow('Bỏ qua bài hát', '6 lần/giờ', 'Không giới hạn'),
    ];
  }

  List<PaymentMethodModel> getPaymentMethods() {
    return const [
      PaymentMethodModel('momo', 'Ví MoMo', 'Liên kết ví điện tử'),
      PaymentMethodModel('zalopay', 'ZaloPay', 'Thanh toán qua ZaloPay'),
      PaymentMethodModel(
        'card',
        'Thẻ ngân hàng',
        'Visa, Mastercard, ATM nội địa',
      ),
      PaymentMethodModel('iap', 'In-App Purchase', 'App Store / Google Play'),
    ];
  }

  Future<void> purchase(String planId, String paymentId) =>
      Future<void>.delayed(const Duration(milliseconds: 1200));
}
