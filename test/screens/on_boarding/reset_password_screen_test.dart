import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:montra/screens/on_boarding/set_up_pin_screen.dart';
import 'package:montra/screens/on_boarding/reset_password_screen.dart';

// Mock Navigator observer to verify navigation
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Create a mock version of SetUpPinScreen to avoid rendering issues
class MockSetUpPinScreen extends StatelessWidget {
  const MockSetUpPinScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Mock SetUpPinScreen')));
  }
}

void main() {
  group('ResetPasswordScreen', () {
    late MockNavigatorObserver mockObserver;

    setUp(() {
      mockObserver = MockNavigatorObserver();
    });

    testWidgets('renders all UI elements correctly', (
      WidgetTester tester,
    ) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: const ResetPasswordScreen(),
          navigatorObservers: [mockObserver],
        ),
      );

      // Verify app bar elements
      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Verify text fields
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.hintText('New Password'), findsOneWidget);
      expect(find.hintText('Retype new password'), findsOneWidget);

      // Verify visibility toggle buttons
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));

      // Verify continue button
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('toggles password visibility when visibility icon is pressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const ResetPasswordScreen()));

      // Find password and confirm password fields
      final passwordField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'New Password',
      );
      final confirmPasswordField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'Retype new password',
      );

      // Initial state should be obscured
      TextField passwordWidget = tester.widget(passwordField);
      TextField confirmPasswordWidget = tester.widget(confirmPasswordField);
      expect(passwordWidget.obscureText, true);
      expect(confirmPasswordWidget.obscureText, true);

      // Find and tap the visibility toggle icons
      final passwordVisibilityIcon = find.descendant(
        of: passwordField,
        matching: find.byIcon(Icons.visibility_off),
      );
      await tester.tap(passwordVisibilityIcon);
      await tester.pump();

      final confirmPasswordVisibilityIcon = find.descendant(
        of: confirmPasswordField,
        matching: find.byIcon(Icons.visibility_off),
      );
      await tester.tap(confirmPasswordVisibilityIcon);
      await tester.pump();

      // Verify visibility toggled
      passwordWidget = tester.widget(passwordField);
      confirmPasswordWidget = tester.widget(confirmPasswordField);
      expect(passwordWidget.obscureText, false);
      expect(confirmPasswordWidget.obscureText, false);

      // Toggle back to obscured
      await tester.tap(
        find.descendant(
          of: passwordField,
          matching: find.byIcon(Icons.visibility),
        ),
      );
      await tester.pump();

      passwordWidget = tester.widget(passwordField);
      expect(passwordWidget.obscureText, true);
    });

    testWidgets('navigates back when back button is pressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ResetPasswordScreen(),
          navigatorObservers: [mockObserver],
        ),
      );

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify that we've navigated back (widget is no longer in the tree)
      expect(find.byType(ResetPasswordScreen), findsNothing);
    });

    testWidgets('text fields accept and maintain entered text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: const ResetPasswordScreen()));

      const passwordText = 'NewSecurePass123';
      const confirmPasswordText = 'NewSecurePass123';

      // Enter text in password fields
      await tester.enterText(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.hintText == 'New Password',
        ),
        passwordText,
      );
      await tester.enterText(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.hintText == 'Retype new password',
        ),
        confirmPasswordText,
      );

      // Verify text was entered correctly
      expect(
        (tester.widget(
                  find.byWidgetPredicate(
                    (widget) =>
                        widget is TextField &&
                        widget.decoration?.hintText == 'New Password',
                  ),
                )
                as TextField)
            .controller
            ?.text,
        passwordText,
      );
      expect(
        (tester.widget(
                  find.byWidgetPredicate(
                    (widget) =>
                        widget is TextField &&
                        widget.decoration?.hintText == 'Retype new password',
                  ),
                )
                as TextField)
            .controller
            ?.text,
        confirmPasswordText,
      );
    });
  });
}

// Extension to help find widgets by hint text
extension FinderExtensions on CommonFinders {
  Finder hintText(String hintText) {
    return find.byWidgetPredicate((widget) {
      if (widget is TextField) {
        return widget.decoration?.hintText == hintText;
      }
      return false;
    });
  }
}
