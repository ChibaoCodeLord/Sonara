import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xmusic/modules/profile/presentations/widgets/profile_menu.dart';

void main() {
  testWidgets('menu values end flush right whatever the title length', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    const rows = {
      'Độ nhạy mic AI Hum': 'Ultra Clean',
      'Bộ chỉnh âm': 'Vocal Dynamic Warmth',
      'Thiết bị phát': 'AirPods Pro 2',
      'Giao diện': 'Theo hệ thống',
    };
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              for (final row in rows.entries)
                ProfileMenuRow(
                  icon: Icons.tune_rounded,
                  title: row.key,
                  value: row.value,
                  onTap: () {},
                ),
            ],
          ),
        ),
      ),
    );

    final rightEdges = rows.values.map((value) {
      final paragraph = tester.renderObject<RenderParagraph>(find.text(value));
      final boxes = paragraph.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: value.length),
      );
      return paragraph.localToGlobal(Offset(boxes.last.right, 0)).dx.round();
    }).toSet();

    expect(rightEdges, hasLength(1));
  });
}
