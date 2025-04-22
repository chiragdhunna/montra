import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:montra/screens/on_boarding/forgot_password_screen.dart';
import 'package:montra/screens/on_boarding/forgot_password_email_sent_screen.dart';
import 'package:montra/screens/on_boarding/set_up_pin_screen.dart';
import 'package:montra/screens/on_boarding/set_up_account_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(home: ForgotPasswordScreen());
  }

  group('ForgotPasswordScreen UI Tests', () {
    testWidgets('should display app bar with correct title', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final titleFinder = find.text('Forgot Password');

      // Assert
      expect(titleFinder, findsOneWidget);
    });

    testWidgets('should display back button in app bar', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final backButtonFinder = find.byIcon(Icons.arrow_back);

      // Assert
      expect(backButtonFinder, findsOneWidget);
    });

    testWidgets('should display email text field with correct hint', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final emailFieldFinder = find.byType(TextField);
      final hintTextFinder = find.text('Email');

      // Assert
      expect(emailFieldFinder, findsOneWidget);
      expect(hintTextFinder, findsOneWidget);
    });

    testWidgets('should display continue button with correct text', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final continueButtonFinder = find.byType(ElevatedButton);
      final buttonTextFinder = find.text('Continue');

      // Assert
      expect(continueButtonFinder, findsOneWidget);
      expect(buttonTextFinder, findsOneWidget);
    });

    testWidgets('should have purple background color for continue button', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final buttonStyle = button.style as ButtonStyle;
      final backgroundColor = buttonStyle.backgroundColor?.resolve({});

      // Assert
      expect(backgroundColor, Colors.purple);
    });
  });

  group('ForgotPasswordScreen Interaction Tests', () {
    testWidgets('should allow typing in email field', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      const testEmail = 'test@example.com';

      // Act
      await tester.enterText(find.byType(TextField), testEmail);
      await tester.pump();

      // Assert
      expect(find.text(testEmail), findsOneWidget);
    });

    testWidgets('should navigate back when back button is pressed', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return const ForgotPasswordScreen();
                        },
                      ),
                    );
                  },
                  child: const Text('Go to Forgot Password'),
                ),
              );
            },
          ),
        ),
      );

      // Navigate to ForgotPasswordScreen
      await tester.tap(find.text('Go to Forgot Password'));
      await tester.pumpAndSettle();

      // Verify we're on ForgotPasswordScreen
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);

      // Act - press back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Assert - back on previous screen
      expect(find.byType(ForgotPasswordScreen), findsNothing);
    });

    testWidgets(
      'should navigate to ForgotPasswordEmailSentScreen when continue button is pressed',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ForgotPasswordEmailSentScreen), findsOneWidget);
      },
    );
  });

  group('ForgotPasswordScreen State Management Tests', () {
    testWidgets('email controller should update when text is entered', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      const testEmail = 'test@example.com';

      // Act
      await tester.enterText(find.byType(TextField), testEmail);
      await tester.pump();

      // Assert - visual verification that text field contains the entered text
      expect(find.text(testEmail), findsOneWidget);
    });
  });

  group('ForgotPasswordScreen Layout Tests', () {
    testWidgets('should have proper padding around content', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final paddingFinder = find.byType(Padding).first;
      final padding = tester.widget<Padding>(paddingFinder).padding;

      // Assert
      expect(padding, const EdgeInsets.symmetric(horizontal: 30));
    });

    testWidgets('should have spacing between UI elements', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      final spacers = find.byType(SizedBox);

      // Assert
      expect(
        spacers,
        findsAtLeastNWidgets(3),
      ); // There should be at least 3 SizedBox widgets for spacing
    });
  });

  // Add these placeholders for future implementation
  group('Future Implementation Tests', () {
    // These tests would be implemented when validation is added to the screen

    test('PLACEHOLDER: should validate email format before submitting', () {
      // Will be implemented when validation is added
    });

    test('PLACEHOLDER: should show error for empty email field', () {
      // Will be implemented when validation is added
    });

    test('PLACEHOLDER: should handle network errors when submitting', () {
      // Will be implemented when API integration is added
    });
  });
}
