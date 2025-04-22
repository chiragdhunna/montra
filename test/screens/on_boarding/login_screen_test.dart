import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:montra/screens/on_boarding/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:montra/logic/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:montra/logic/blocs/login_bloc/login_bloc.dart';
import 'package:montra/screens/on_boarding/forgot_password_screen.dart';
import 'package:montra/screens/on_boarding/sign_up_screen.dart';

class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}

class MockLoginBloc extends Mock implements LoginBloc {}

class FakeLoginEvent extends Fake implements LoginEvent {}

void main() {
  late MockAuthenticationBloc mockAuthBloc;
  late MockLoginBloc mockLoginBloc;

  setUpAll(() {
    registerFallbackValue(FakeLoginEvent());
  });

  setUp(() {
    mockAuthBloc = MockAuthenticationBloc();
    mockLoginBloc = MockLoginBloc();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>.value(value: mockAuthBloc),
          BlocProvider<LoginBloc>.value(value: mockLoginBloc),
        ],
        child: const LoginScreen(),
      ),
    );
  }

  testWidgets('Login screen UI elements appear correctly', (tester) async {
    when(
      () => mockAuthBloc.state,
    ).thenReturn(const AuthenticationState.initial());
    when(
      () => mockAuthBloc.stream,
    ).thenAnswer((_) => Stream<AuthenticationState>.empty());
    when(() => mockLoginBloc.state).thenReturn(const LoginState.initial());
    when(
      () => mockLoginBloc.stream,
    ).thenAnswer((_) => Stream<LoginState>.empty());

    await tester.pumpWidget(createTestWidget());

    expect(find.widgetWithText(ElevatedButton, "Login"), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text("Forgot Password?"), findsOneWidget);
    expect(find.text("Don’t have an account yet? Sign Up"), findsOneWidget);
  });

  testWidgets('Password visibility toggle works', (tester) async {
    when(
      () => mockAuthBloc.state,
    ).thenReturn(const AuthenticationState.initial());
    when(
      () => mockAuthBloc.stream,
    ).thenAnswer((_) => Stream<AuthenticationState>.empty());
    when(() => mockLoginBloc.state).thenReturn(const LoginState.initial());
    when(
      () => mockLoginBloc.stream,
    ).thenAnswer((_) => Stream<LoginState>.empty());

    await tester.pumpWidget(createTestWidget());

    final visibilityToggle = find.byIcon(Icons.visibility_off);
    expect(visibilityToggle, findsOneWidget);
    await tester.tap(visibilityToggle);
    await tester.pump();
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('Login button triggers event if fields are filled', (
    tester,
  ) async {
    when(
      () => mockAuthBloc.state,
    ).thenReturn(const AuthenticationState.initial());
    when(
      () => mockAuthBloc.stream,
    ).thenAnswer((_) => Stream<AuthenticationState>.empty());
    when(() => mockLoginBloc.state).thenReturn(const LoginState.initial());
    when(
      () => mockLoginBloc.stream,
    ).thenAnswer((_) => Stream<LoginState>.empty());

    await tester.pumpWidget(createTestWidget());

    final emailField = find.byType(TextField).first;
    final passwordField = find.byType(TextField).last;

    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, "Login"));
    await tester.pump();

    verify(() => mockLoginBloc.add(any(that: isA<LoginEvent>()))).called(1);
  });

  testWidgets('Login button shows snackbar if fields are empty', (
    tester,
  ) async {
    when(
      () => mockAuthBloc.state,
    ).thenReturn(const AuthenticationState.initial());
    when(
      () => mockAuthBloc.stream,
    ).thenAnswer((_) => Stream<AuthenticationState>.empty());
    when(() => mockLoginBloc.state).thenReturn(const LoginState.initial());
    when(
      () => mockLoginBloc.stream,
    ).thenAnswer((_) => Stream<LoginState>.empty());

    await tester.pumpWidget(createTestWidget());
    await tester.tap(find.widgetWithText(ElevatedButton, "Login"));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text("Please fill in all fields"), findsOneWidget);
  });

  testWidgets('Forgot password button navigates to ForgotPasswordScreen', (
    tester,
  ) async {
    when(
      () => mockAuthBloc.state,
    ).thenReturn(const AuthenticationState.initial());
    when(
      () => mockAuthBloc.stream,
    ).thenAnswer((_) => Stream<AuthenticationState>.empty());
    when(() => mockLoginBloc.state).thenReturn(const LoginState.initial());
    when(
      () => mockLoginBloc.stream,
    ).thenAnswer((_) => Stream<LoginState>.empty());

    await tester.pumpWidget(createTestWidget());
    await tester.tap(find.text("Forgot Password?"));
    await tester.pumpAndSettle();

    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
  });
}
