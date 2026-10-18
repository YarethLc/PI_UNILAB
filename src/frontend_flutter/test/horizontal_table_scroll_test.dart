import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/widgets/horizontal_table_scroll.dart';

void main() {
  testWidgets('horizontal table scrollbar can scroll wide content', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 240));
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HorizontalTableScroll(
            child: SizedBox(width: 900, height: 80),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    expect(scrollable.position.maxScrollExtent, greaterThan(0));

    final scrollbarRect = tester.getRect(find.byType(Scrollbar));
    await tester.dragFrom(
      Offset(scrollbarRect.left + 50, scrollbarRect.bottom - 2),
      const Offset(120, 0),
    );
    await tester.pumpAndSettle();

    expect(scrollable.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });
}
