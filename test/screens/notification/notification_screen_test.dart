import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:montra/logic/blocs/notification_bloc/notification_bloc.dart';
import 'package:montra/screens/notification/notification_screen.dart';

// Create mock classes for NotificationBloc
class MockNotificationBloc extends Mock implements NotificationBloc {}

// Create mock class for NotificationState and NotificationEvent
class FakeNotificationState extends Fake implements NotificationState {}

class FakeNotificationEvent extends Fake implements NotificationEvent {}

void main() {
  late MockNotificationBloc mockNotificationBloc;

  setUpAll(() {
    // Register fallbacks for the mock classes
    registerFallbackValue(FakeNotificationState());
    registerFallbackValue(FakeNotificationEvent());
  });

  setUp(() {
    // Initialize mocks before each test
    mockNotificationBloc = MockNotificationBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<NotificationBloc>.value(
        value: mockNotificationBloc,
        child: const NotificationScreen(),
      ),
    );
  }

  group('NotificationScreen', () {
    testWidgets('should display loading indicator when state is inProgress', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockNotificationBloc.state,
      ).thenReturn(const NotificationState.inProgress());

      when(() => mockNotificationBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([const NotificationState.inProgress()]),
      );

      when(
        () => mockNotificationBloc.add(any(that: isA<NotificationEvent>())),
      ).thenAnswer((_) => Future.value());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verify that getAllNotifications event was added during initState
      verify(
        () => mockNotificationBloc.add(
          const NotificationEvent.getAllNotifications(),
        ),
      ).called(1);
    });

    testWidgets('should display empty state message when no notifications', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockNotificationBloc.state,
      ).thenReturn(const NotificationState.getAllNotificationSuccess(data: []));

      when(() => mockNotificationBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          const NotificationState.getAllNotificationSuccess(data: []),
        ]),
      );

      when(
        () => mockNotificationBloc.add(any(that: isA<NotificationEvent>())),
      ).thenAnswer((_) => Future.value());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('There is no notification for now'), findsOneWidget);
    });

    testWidgets('should display notifications when available', (
      WidgetTester tester,
    ) async {
      // Sample notification data
      final notificationsData = [
        {
          'title': 'Test Notification',
          'subtitle': 'This is a test notification',
          'time': '10:30',
        },
        {
          'title': 'Payment Due',
          'subtitle': 'Your payment is due tomorrow',
          'time': '12:45',
        },
      ];

      // Arrange
      when(() => mockNotificationBloc.state).thenReturn(
        NotificationState.getAllNotificationSuccess(data: notificationsData),
      );

      when(() => mockNotificationBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          NotificationState.getAllNotificationSuccess(data: notificationsData),
        ]),
      );

      when(
        () => mockNotificationBloc.add(any(that: isA<NotificationEvent>())),
      ).thenAnswer((_) => Future.value());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('Test Notification'), findsOneWidget);
      expect(find.text('This is a test notification'), findsOneWidget);
      expect(find.text('10:30'), findsOneWidget);

      expect(find.text('Payment Due'), findsOneWidget);
      expect(find.text('Your payment is due tomorrow'), findsOneWidget);
      expect(find.text('12:45'), findsOneWidget);
    });

    testWidgets('should handle ISO date strings in notifications', (
      WidgetTester tester,
    ) async {
      // Sample notification with ISO date
      final notificationsData = [
        {
          'title': 'ISO Date Test',
          'subtitle': 'Testing ISO date parsing',
          'time': '2025-03-30T14:30:00.000Z',
        },
      ];

      // Arrange
      when(() => mockNotificationBloc.state).thenReturn(
        NotificationState.getAllNotificationSuccess(data: notificationsData),
      );

      when(() => mockNotificationBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          NotificationState.getAllNotificationSuccess(data: notificationsData),
        ]),
      );

      when(
        () => mockNotificationBloc.add(any(that: isA<NotificationEvent>())),
      ).thenAnswer((_) => Future.value());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert - The actual time shown will depend on timezone conversions
      // Here we're just checking that it's been formatted to HH:MM format
      expect(find.text('ISO Date Test'), findsOneWidget);
      expect(find.text('Testing ISO date parsing'), findsOneWidget);

      // The exact time format depends on local timezone, but it should show a time
      // We'll check for a 5-character string (HH:MM)
      final timeFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            widget.data!.length == 5 &&
            widget.data!.contains(':'),
      );

      expect(timeFinder, findsOneWidget);
    });

    testWidgets('should show error message on failure state', (
      WidgetTester tester,
    ) async {
      // Arrange
      const errorMessage = 'Failed to load notifications';

      when(
        () => mockNotificationBloc.state,
      ).thenReturn(const NotificationState.failure(error: errorMessage));

      when(() => mockNotificationBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          const NotificationState.failure(error: errorMessage),
        ]),
      );

      when(
        () => mockNotificationBloc.add(any(that: isA<NotificationEvent>())),
      ).thenAnswer((_) => Future.value());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Since the error appears in a snackbar, pump it to render
      await tester.pump(); // Start the animation
      await tester.pump(const Duration(seconds: 1)); // Animation complete

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets(
      'should call clearAllNotifications when mark all as read is pressed',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockNotificationBloc.state).thenReturn(
          const NotificationState.getAllNotificationSuccess(data: []),
        );

        when(() => mockNotificationBloc.stream).thenAnswer(
          (_) => Stream.fromIterable([
            const NotificationState.getAllNotificationSuccess(data: []),
          ]),
        );

        when(
          () => mockNotificationBloc.add(any(that: isA<NotificationEvent>())),
        ).thenAnswer((_) => Future.value());

        // Act
        await tester.pumpWidget(createWidgetUnderTest());

        // Find and tap the menu button
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle(); // Wait for the menu to appear

        // Tap the "Mark all read" option
        await tester.tap(find.text('Mark all read'));
        await tester.pumpAndSettle();

        // Assert
        verify(
          () => mockNotificationBloc.add(
            const NotificationEvent.clearAllNotifications(),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'should call clearAllNotifications when remove all is pressed',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockNotificationBloc.state).thenReturn(
          const NotificationState.getAllNotificationSuccess(data: []),
        );

        when(() => mockNotificationBloc.stream).thenAnswer(
          (_) => Stream.fromIterable([
            const NotificationState.getAllNotificationSuccess(data: []),
          ]),
        );

        when(
          () => mockNotificationBloc.add(any(that: isA<NotificationEvent>())),
        ).thenAnswer((_) => Future.value());

        // Act
        await tester.pumpWidget(createWidgetUnderTest());

        // Find and tap the menu button
        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle(); // Wait for the menu to appear

        // Tap the "Remove all" option
        await tester.tap(find.text('Remove all'));
        await tester.pumpAndSettle();

        // Assert
        verify(
          () => mockNotificationBloc.add(
            const NotificationEvent.clearAllNotifications(),
          ),
        ).called(1);
      },
    );

    testWidgets('should navigate back when back button is pressed', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        () => mockNotificationBloc.state,
      ).thenReturn(const NotificationState.getAllNotificationSuccess(data: []));

      when(() => mockNotificationBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          const NotificationState.getAllNotificationSuccess(data: []),
        ]),
      );

      when(
        () => mockNotificationBloc.add(any(that: isA<NotificationEvent>())),
      ).thenAnswer((_) => Future.value());

      // Create a navigator for testing navigation
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => BlocProvider<NotificationBloc>.value(
                              value: mockNotificationBloc,
                              child: const NotificationScreen(),
                            ),
                      ),
                    );
                  },
                  child: const Text('Go to notifications'),
                ),
          ),
        ),
      );

      // Navigate to the notification screen
      await tester.tap(find.text('Go to notifications'));
      await tester.pumpAndSettle();

      // Verify we're on the notification screen
      expect(find.byType(NotificationScreen), findsOneWidget);

      // Tap the back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we've navigated back
      expect(find.byType(NotificationScreen), findsNothing);
    });
  });
}
