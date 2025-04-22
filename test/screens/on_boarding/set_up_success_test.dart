import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:montra/screens/on_boarding/set_up_success.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(home: SetUpSuccess());
  }

  group('SetUpSuccess UI Tests', () {
    testWidgets('should display green check icon in a circle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final containerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == Colors.green,
      );
      expect(containerFinder, findsOneWidget);

      final iconFinder = find.byIcon(Icons.check);
      expect(iconFinder, findsOneWidget);
    });

    testWidgets('should display success text', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text("You are set!"), findsOneWidget);
    });

    testWidgets('should have white background', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.white);
    });

    testWidgets('should have a SizedBox with height 20 between icon and text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      final sizedBoxFinder = find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 20,
      );
      expect(sizedBoxFinder, findsOneWidget);
    });

    testWidgets('should center content vertically and horizontally', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      // There may be more than one Center, so check at least one exists
      expect(find.byType(Center), findsAtLeastNWidgets(1));

      // Check that a Column is a direct child of a Center
      final centerFinder = find.byType(Center);
      final columnFinder = find.descendant(
        of: centerFinder,
        matching: find.byType(Column),
      );
      expect(columnFinder, findsWidgets);

      // Optionally, check the mainAxisAlignment of the Column
      final column = tester.widget<Column>(columnFinder.first);
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('should have icon size 40 and color white', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      final icon = tester.widget<Icon>(find.byIcon(Icons.check));
      expect(icon.size, 40);
      expect(icon.color, Colors.white);
    });

    testWidgets('should have text with correct style', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      final text = tester.widget<Text>(find.text("You are set!"));
      final style = text.style!;
      expect(style.fontSize, 18);
      expect(style.fontWeight, FontWeight.bold);
      expect(style.color, Colors.black);
    });
  });
}
