import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/widgets/app_layout.dart';
import 'package:frontend_flutter/widgets/app_page_scroll_view.dart';

void main() {
  testWidgets('banner and footer scroll with mobile screen content', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pumpWidget(
      MaterialApp(
        home: AppLayout(
          currentRoute: '/user/home',
          title: 'Inicio',
          child: SingleChildScrollView(
            child: Column(
              children: List.generate(
                30,
                (index) => SizedBox(
                  height: 100,
                  child: Text('Contenido $index'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final footerTitle = find.text('INFORMACIÓN', skipOffstage: false);
    final banner = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.semanticLabel ==
              'Banner de la Facultad de Ingeniería de Sistemas',
      skipOffstage: false,
    );
    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    expect(scrollable.position.pixels, 0);
    expect(tester.getTopLeft(banner).dy, greaterThanOrEqualTo(0));
    expect(tester.getTopLeft(footerTitle).dy, greaterThan(800));

    scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
    await tester.pumpAndSettle();

    expect(scrollable.position.pixels, greaterThan(0));
    expect(tester.getTopLeft(banner).dy, lessThan(0));
    expect(tester.getTopLeft(footerTitle).dy, lessThan(800));
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('page-owned mobile scroll reaches the complete footer', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pumpWidget(
      MaterialApp(
        home: AppLayout(
          currentRoute: '/user/home',
          title: 'Inicio',
          mobilePageOwnsScroll: true,
          child: RefreshIndicator(
            onRefresh: () async {},
            child: const AppPageScrollView(
              child: SizedBox(
                height: 2400,
                child: Center(child: Text('Contenido desplazable')),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CustomScrollView), findsOneWidget);
    final footerTitle = find.text('INFORMACIÓN', skipOffstage: false);
    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    expect(tester.getTopLeft(footerTitle).dy, greaterThan(800));

    scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(footerTitle).dy, lessThan(800));
    expect(tester.getBottomRight(find.text('igsclac@gmail.com')).dy,
        lessThanOrEqualTo(800));
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });
}
