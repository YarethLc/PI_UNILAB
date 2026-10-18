import 'package:flutter_test/flutter_test.dart';

import 'package:frontend_flutter/main.dart';

void main() {
  testWidgets('la aplicación arranca en el login con la marca LabAcces', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SaiciApp());
    await tester.pump();

    expect(find.textContaining('LabAcces'), findsWidgets);
  });
}
