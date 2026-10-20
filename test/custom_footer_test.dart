import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/widgets/custom_footer.dart';

void main() {
  testWidgets('footer shows contact details on mobile and desktop widths', (
    tester,
  ) async {
    for (final width in [390.0, 900.0]) {
      await tester.binding.setSurfaceSize(Size(width, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: width,
              child: const CustomFooter(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('INFORMACIÓN'), findsOneWidget);
      expect(
        find.text(
          'Carrera 27 A No. 48 -144 Kilómetro 1 Salida Sur, Tuluá - Valle del Cauca - Colombia.',
        ),
        findsOneWidget,
      );
      expect(find.text('Código Postal: 763022'), findsOneWidget);
      expect(find.text('igsclac@gmail.com'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }

    await tester.binding.setSurfaceSize(null);
  });
}
