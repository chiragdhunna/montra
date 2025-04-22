import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:montra/screens/on_boarding/sign_up_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montra/logic/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:montra/logic/blocs/login_bloc/login_bloc.dart';

class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}

class MockLoginBloc extends Mock implements LoginBloc {}

void main() {
  late AuthenticationBloc authBloc;
  late LoginBloc loginBloc;

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>.value(value: authBloc),
        BlocProvider<LoginBloc>.value(value: loginBloc),
      ],
      child: const MaterialApp(home: SignUpScreen()),
    );
  }

  setUp(() {
    authBloc = AuthenticationBloc();
    loginBloc = LoginBloc();
  });

  group('SignUpScreen UI Tests', () {
    testWidgets('should display all input fields', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(TextField), findsNWidgets(3));
      expect(find.widgetWithText(TextField, 'Name'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
    });

    testWidgets('should display password visibility toggle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('should display Sign Up button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
    });

    testWidgets('should display Login navigation text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(
        find.widgetWithText(TextButton, 'Already have an account? Login'),
        findsOneWidget,
      );
    });
  });

  group('SignUpScreen Interaction Tests', () {
    testWidgets('should toggle password visibility', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      // Initially obscure
      final passwordField = find.widgetWithText(TextField, 'Password');
      expect(passwordField, findsOneWidget);

      // Tap the visibility icon
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();
      // Now the icon should be visibility
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should check and uncheck the terms checkbox', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);

      // Initially unchecked
      Checkbox cb = tester.widget(checkbox);
      expect(cb.value, false);

      // Tap to check
      await tester.tap(checkbox);
      await tester.pump();
      cb = tester.widget(checkbox);
      expect(cb.value, true);

      // Tap to uncheck
      await tester.tap(checkbox);
      await tester.pump();
      cb = tester.widget(checkbox);
      expect(cb.value, false);
    });

    testWidgets('should show error if Sign Up pressed with empty fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump(); // show SnackBar
      expect(find.text('Please fill all the fields'), findsOneWidget);
    });

    testWidgets(
      'should enable Sign Up button only when all fields filled and checked',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Enter text in all fields
        await tester.enterText(
          find.widgetWithText(TextField, 'Name'),
          'Test User',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Email'),
          'test@example.com',
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Password'),
          'password123',
        );
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        final elevatedButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Sign Up'),
        );
        final buttonStyle = elevatedButton.style!;
        final backgroundColor = buttonStyle.backgroundColor?.resolve({});
        expect(backgroundColor, Colors.purple);
      },
    );
  });
}
