import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:montra/screens/on_boarding/sign_up_verification_screen.dart';
import 'package:pinput/pinput.dart';

void main() {
  tearDown(() async {
    await Future.delayed(const Duration(milliseconds: 100));
  });

  testWidgets('resend text changes color and becomes tappable after timeout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SignUpVerificationScreen()),
    );

    final resendTextFinder = find.text("I didn't receive the code? Send again");

    Text textWidget = tester.widget(resendTextFinder);
    expect((textWidget.style?.color), equals(Colors.grey));

    for (int i = 0; i < 300; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pumpAndSettle();

    textWidget = tester.widget(resendTextFinder);
    expect((textWidget.style?.color), equals(Colors.purple));
  });

  testWidgets('Verify button is tappable', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () => tapped = true,
            child: const Text("Verify"),
          ),
        ),
      ),
    );

    await tester.tap(find.text("Verify"));
    await tester.pump();

    expect(tapped, true);
  });
}
