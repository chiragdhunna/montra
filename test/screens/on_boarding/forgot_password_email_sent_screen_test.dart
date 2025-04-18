import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:montra/screens/on_boarding/reset_password_screen.dart';
import 'package:montra/screens/on_boarding/forgot_password_email_sent_screen.dart';

void main() {
  testWidgets('ForgotPasswordEmailSentScreen - renders correctly', (
    WidgetTester tester,
  ) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(home: const ForgotPasswordEmailSentScreen()),
    );

    // Verify widget structure
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Your email is on the way'), findsOneWidget);
    expect(
      find.text(
        'Check your email test@test.com and follow the instructions to reset your password',
      ),
      findsOneWidget,
    );
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Back to Login'), findsOneWidget);
  });

  testWidgets(
    'ForgotPasswordEmailSentScreen - button navigates to ResetPasswordScreen',
    (WidgetTester tester) async {
      // Build our widget and trigger a frame
      await tester.pumpWidget(
        MaterialApp(home: const ForgotPasswordEmailSentScreen()),
      );

      // Find and tap the button
      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
      await tester.tap(button);
      await tester.pumpAndSettle();

      // After navigation, we should have a ResetPasswordScreen in the widget tree
      expect(find.byType(ResetPasswordScreen), findsOneWidget);
    },
  );

  testWidgets('ForgotPasswordEmailSentScreen - button has correct styling', (
    WidgetTester tester,
  ) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(home: const ForgotPasswordEmailSentScreen()),
    );

    // Find the button
    final buttonFinder = find.byType(ElevatedButton);
    final button = tester.widget<ElevatedButton>(buttonFinder);

    // Check if the button uses a Material design with purple background
    final Material material = tester.widget<Material>(
      find.descendant(of: buttonFinder, matching: find.byType(Material)),
    );
    expect(material.color, Colors.purple);

    // Verify text styling
    final textFinder = find.text('Back to Login');
    final text = tester.widget<Text>(textFinder);
    expect(text.style?.color, Colors.white);
    expect(text.style?.fontSize, 16);
  });

  testWidgets('ForgotPasswordEmailSentScreen - content alignment test', (
    WidgetTester tester,
  ) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(home: const ForgotPasswordEmailSentScreen()),
    );

    // Find all columns and verify at least one exists
    final columnFinder = find.byType(Column);
    expect(columnFinder, findsWidgets);

    // Test the Column widgets more specifically
    bool foundMainColumn = false;
    for (final element in tester.elementList(columnFinder)) {
      final Column column = element.widget as Column;
      if (column.mainAxisAlignment == MainAxisAlignment.center) {
        foundMainColumn = true;
        expect(
          column.children.length,
          7,
        ); // Expected number of children in main Column
        break;
      }
    }
    expect(
      foundMainColumn,
      true,
      reason: "Did not find a Column with MainAxisAlignment.center",
    );

    // Verify padding exists
    final paddingFinder = find.byType(Padding);
    expect(paddingFinder, findsWidgets);

    // Verify if there's a Padding with horizontal 30
    bool foundMainPadding = false;
    for (final element in tester.elementList(paddingFinder)) {
      final Padding padding = element.widget as Padding;
      if (padding.padding == const EdgeInsets.symmetric(horizontal: 30)) {
        foundMainPadding = true;
        break;
      }
    }
    expect(
      foundMainPadding,
      true,
      reason: "Did not find a Padding with horizontal: 30",
    );
  });

  testWidgets('ForgotPasswordEmailSentScreen - text alignment test', (
    WidgetTester tester,
  ) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(home: const ForgotPasswordEmailSentScreen()),
    );

    // Find the text widgets
    final titleFinder = find.text('Your email is on the way');
    final title = tester.widget<Text>(titleFinder);

    final descriptionFinder = find.text(
      'Check your email test@test.com and follow the instructions to reset your password',
    );
    final description = tester.widget<Text>(descriptionFinder);

    // Verify text alignment
    expect(title.textAlign, TextAlign.center);
    expect(description.textAlign, TextAlign.center);

    // Verify text styling
    expect(title.style?.fontSize, 22);
    expect(title.style?.fontWeight, FontWeight.bold);
    expect(title.style?.color, Colors.black);

    expect(description.style?.fontSize, 16);
    expect(description.style?.color, Colors.black54);
  });

  testWidgets('ForgotPasswordEmailSentScreen - image renders correctly', (
    WidgetTester tester,
  ) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(home: const ForgotPasswordEmailSentScreen()),
    );

    // Find the image widget
    final imageFinder = find.byType(Image);
    final image = tester.widget<Image>(imageFinder);

    // Verify image source
    expect((image.image as AssetImage).assetName, 'assets/email_sent.png');

    // Verify image height
    expect(image.height, 200);
  });

  testWidgets('ForgotPasswordEmailSentScreen - spacing test', (
    WidgetTester tester,
  ) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(home: const ForgotPasswordEmailSentScreen()),
    );

    // Find SizedBox widgets - we now know there are 4 in total, not 3
    final sizedBoxes = find.byType(SizedBox);

    // There should be 4 SizedBox widgets (3 for vertical spacing + 1 for button width)
    expect(sizedBoxes, findsNWidgets(4));

    // Find the SizedBoxes with height properties
    final sizedBoxList = tester.widgetList<SizedBox>(sizedBoxes).toList();

    // Count SizedBoxes with specific heights
    int heightOf30Count = 0;
    int heightOf10Count = 0;
    int heightOf40Count = 0;

    for (final box in sizedBoxList) {
      if (box.height == 30.0) heightOf30Count++;
      if (box.height == 10.0) heightOf10Count++;
      if (box.height == 40.0) heightOf40Count++;
    }

    // Verify heights match the expected values: 30, 10, 40
    expect(
      heightOf30Count,
      1,
      reason: "Expected one SizedBox with height 30.0",
    );
    expect(
      heightOf10Count,
      1,
      reason: "Expected one SizedBox with height 10.0",
    );
    expect(
      heightOf40Count,
      1,
      reason: "Expected one SizedBox with height 40.0",
    );

    // Verify we have one SizedBox with width: double.infinity
    int infinityWidthCount = 0;
    for (final box in sizedBoxList) {
      if (box.width == double.infinity) infinityWidthCount++;
    }
    expect(
      infinityWidthCount,
      1,
      reason: "Expected one SizedBox with width double.infinity",
    );
  });

  testWidgets('ForgotPasswordEmailSentScreen - button width test', (
    WidgetTester tester,
  ) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(home: const ForgotPasswordEmailSentScreen()),
    );

    // Find SizedBoxes with width double.infinity
    final sizedBoxes = find.byType(SizedBox);

    bool foundWidthBox = false;
    for (final element in tester.elementList(sizedBoxes)) {
      final SizedBox box = element.widget as SizedBox;
      if (box.width == double.infinity) {
        foundWidthBox = true;

        // Verify this SizedBox contains an ElevatedButton
        final buttonFinder = find.descendant(
          of: find.byWidget(box),
          matching: find.byType(ElevatedButton),
        );
        expect(buttonFinder, findsOneWidget);
        break;
      }
    }
    expect(
      foundWidthBox,
      true,
      reason:
          "Did not find a SizedBox with width double.infinity containing an ElevatedButton",
    );
  });

  testWidgets('ForgotPasswordEmailSentScreen - scaffold background color', (
    WidgetTester tester,
  ) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(home: const ForgotPasswordEmailSentScreen()),
    );

    // Find the Scaffold
    final scaffoldFinder = find.byType(Scaffold);
    final scaffold = tester.widget<Scaffold>(scaffoldFinder);

    // Verify scaffold background color
    expect(scaffold.backgroundColor, Colors.white);
  });

  testWidgets('ForgotPasswordEmailSentScreen - button has correct shape', (
    WidgetTester tester,
  ) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(home: const ForgotPasswordEmailSentScreen()),
    );

    // Find and check button
    final buttonFinder = find.byType(ElevatedButton);
    final button = tester.widget<ElevatedButton>(buttonFinder);

    // Check button style properties
    final buttonStyle = button.style!;

    // We need to verify the shape by checking the actual style property
    final shape = buttonStyle.shape?.resolve({});
    expect(shape, isA<RoundedRectangleBorder>());

    if (shape is RoundedRectangleBorder) {
      expect(shape.borderRadius, BorderRadius.circular(10));
    }
  });
}
