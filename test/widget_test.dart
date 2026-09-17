import 'package:flutter_test/flutter_test.dart';
import 'package:xmusic/main.dart';

void main() {
  testWidgets('Resonance AI Music App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ResonanceMusicApp());
    await tester.pump();

    // Verify key elements exist on home tab
    expect(find.text('RESONANCE AI'), findsOneWidget);
    expect(find.text('Khám Phá'), findsWidgets);
    expect(find.text('AI HUM'), findsOneWidget);

    // Switch to Thư Viện tab
    await tester.tap(find.text('Thư viện'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Thư viện của tôi'), findsOneWidget);
    expect(find.text('Bài hát yêu thích'), findsOneWidget);

    // Switch to Xếp hạng tab
    await tester.tap(find.text('Xếp hạng'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Việt Nam Hot 50'), findsOneWidget);
    expect(find.text('Từng Là Của Nhau'), findsOneWidget);

    // Switch to Hồ sơ tab
    await tester.tap(find.text('Hồ sơ'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Lê Hải Đăng'), findsOneWidget);
    expect(find.text('Resonance AI Engine'), findsOneWidget);
  });
}
