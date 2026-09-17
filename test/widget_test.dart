import 'package:flutter_test/flutter_test.dart';
import 'package:xmusic/main.dart';

void main() {
  testWidgets('Resonance AI Music App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ResonanceMusicApp());
    await tester.pump();

    // Verify key elements exist
    expect(find.text('RESONANCE AI'), findsOneWidget);
    expect(find.text('Khám Phá'), findsWidgets);
    expect(find.text('AI HUM'), findsOneWidget);
  });
}
