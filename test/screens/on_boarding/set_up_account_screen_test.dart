import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:montra/screens/on_boarding/add_new_account_screen.dart';
import 'package:montra/screens/on_boarding/set_up_account_screen.dart';

// Create mock classes
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockRoute extends Mock implements Route<dynamic> {}

void main() {
  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(MockRoute());
    registerFallbackValue(ModalRoute.withName('/dummy'));
  });

  // This will run first to help us determine what's actually in the screen
  testWidgets('Debug widget tree', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SetUpAccountScreen()));

    // Print all text widgets in the tree
    tester.widgetList<Text>(find.byType(Text)).forEach((text) {
      print('DEBUG TEXT: "${text.data}"');
    });

    // Print button text
    final buttonTexts = tester.widgetList<Text>(
      find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.byType(Text),
      ),
    );

    buttonTexts.forEach((text) {
      print('DEBUG BUTTON TEXT: "${text.data}"');
    });
  });

  group('SetUpAccountScreen Widget Tests', () {
    testWidgets('should render all UI elements correctly', (
      WidgetTester tester,
    ) async {
      // Build the widget
      await tester.pumpWidget(const MaterialApp(home: SetUpAccountScreen()));

      // Check for any Text widgets and a button, which should always be present
      expect(
        find.byType(Text),
        findsAtLeastNWidgets(2),
      ); // At least title and subtitle
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Look for Text widgets that are children of a Column
      expect(
        find.descendant(of: find.byType(Column), matching: find.byType(Text)),
        findsAtLeastNWidgets(2),
      );
    });

    testWidgets(
      'should navigate to AddNewAccountScreen when button is pressed',
      (WidgetTester tester) async {
        // Create mock observer
        final mockObserver = MockNavigatorObserver();

        // Build the widget with the observer
        await tester.pumpWidget(
          MaterialApp(
            home: const SetUpAccountScreen(),
            navigatorObservers: [mockObserver],
          ),
        );

        // Let the widget fully settle before our test
        await tester.pumpAndSettle();

        // Clear any previous navigation events
        clearInteractions(mockObserver);

        // Tap the button
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Verify navigation occurred
        verify(() => mockObserver.didPush(any(), any())).called(1);

        // Verify we're on the AddNewAccountScreen
        expect(find.byType(AddNewAccountScreen), findsOneWidget);
      },
    );
  });
}
