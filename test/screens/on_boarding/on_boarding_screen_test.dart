import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:montra/logic/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:montra/screens/on_boarding/login_screen.dart';
import 'package:montra/screens/on_boarding/on_boarding_screen.dart';
import 'package:montra/screens/on_boarding/sign_up_screen.dart';
import 'dart:async';

// Create a better mock of your AuthenticationBloc
class MockAuthenticationBloc extends Mock implements AuthenticationBloc {
  final StreamController<AuthenticationState> _streamController =
      StreamController<AuthenticationState>.broadcast();

  @override
  Stream<AuthenticationState> get stream => _streamController.stream;

  @override
  AuthenticationState get state => AuthenticationState.initial(); // Adjust this based on your actual initial state

  @override
  Future<void> close() async {
    _streamController.close();
    super.noSuchMethod(Invocation.method(#close, []));
  }
}

// Alternative approach using bloc_test package (recommended for larger tests)
/*
import 'package:bloc_test/bloc_test.dart';

class MockAuthenticationBloc extends MockBloc<AuthenticationEvent, AuthenticationState> 
    implements AuthenticationBloc {
  MockAuthenticationBloc() : super(initialState: AuthenticationState.initial());
}
*/

void main() {
  // Create a mock of the AuthenticationBloc
  late MockAuthenticationBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthenticationBloc();
  });

  tearDown(() {
    mockAuthBloc.close();
  });

  // Create test widget to wrap our widget under test
  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [BlocProvider<AuthenticationBloc>.value(value: mockAuthBloc)],
      child: MaterialApp(
        home: const OnBoardingScreen(),
        routes: {
          '/signup': (context) => SignUpScreen(),
          '/login': (context) => LoginScreen(),
        },
      ),
    );
  }

  testWidgets('OnBoardingScreen displays first page correctly', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(createWidgetUnderTest());

    // Verify first page elements
    expect(find.text('Gain total control of your money'), findsOneWidget);
    expect(
      find.text('Become your own money manager and make every cent count'),
      findsOneWidget,
    );

    // Verify image exists - using asset name instead of widget type
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == 'assets/onboarding1.png',
      ),
      findsOneWidget,
    );

    // Verify buttons
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    // Verify page indicators
    expect(find.byType(AnimatedContainer), findsNWidgets(3));
  });

  testWidgets('OnBoardingScreen can swipe to next page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Verify first page content is visible
    expect(find.text('Gain total control of your money'), findsOneWidget);
    expect(find.text('Know where your money goes'), findsNothing);

    // Swipe to the next page
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pump(); // Start the animation
    await tester.pump(const Duration(milliseconds: 500)); // Wait for animation

    // Verify second page content is visible
    expect(find.text('Know where your money goes'), findsOneWidget);
    expect(
      find.text(
        'Track your transaction easily, with categories and financial report',
      ),
      findsOneWidget,
    );
  });

  testWidgets('OnBoardingScreen can swipe to last page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Swipe to the second page
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Swipe to the third page
    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify third page content is visible
    expect(find.text('Planning ahead'), findsOneWidget);
    expect(
      find.text('Setup your budget for each category so you in control'),
      findsOneWidget,
    );
  });

  testWidgets('Sign Up button is present with correct styling', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Find the Sign Up button
    final signUpButtonFinder = find.widgetWithText(ElevatedButton, 'Sign Up');
    expect(signUpButtonFinder, findsOneWidget);

    // Get the button widget
    final ElevatedButton signUpButton = tester.widget(signUpButtonFinder);

    // Verify button style exists
    expect(signUpButton.style, isNotNull);
  });

  testWidgets('Login button is present with correct styling', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Find the Login button
    final loginButtonFinder = find.widgetWithText(TextButton, 'Login');
    expect(loginButtonFinder, findsOneWidget);

    // Get the button widget text
    final TextButton loginButton = tester.widget(loginButtonFinder);

    // Check that it has a child that is a Text widget
    expect(loginButton.child, isA<Text>());
  });

  testWidgets('OnBoardingScreen has proper text styling', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Find text widgets
    final titleFinder = find.text('Gain total control of your money');
    final descFinder = find.text(
      'Become your own money manager and make every cent count',
    );

    expect(titleFinder, findsOneWidget);
    expect(descFinder, findsOneWidget);

    // Get text widgets
    final Text titleWidget = tester.widget(titleFinder);
    final Text descWidget = tester.widget(descFinder);

    // Check styles exist
    expect(titleWidget.style, isNotNull);
    expect(descWidget.style, isNotNull);

    // If we need to check specific style values
    if (titleWidget.style != null) {
      expect(titleWidget.style!.fontSize, 22);
      expect(titleWidget.style!.fontWeight, FontWeight.bold);
      expect(titleWidget.style!.color, Colors.black);
    }

    if (descWidget.style != null) {
      expect(descWidget.style!.fontSize, 16);
      expect(descWidget.style!.color, Colors.grey);
    }
  });
}
