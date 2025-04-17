import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:montra/logic/blocs/notification_bloc/notification_bloc.dart';
import 'package:montra/screens/notification/notification_screen.dart';

class MockNotificationBloc extends Mock implements NotificationBloc {}

class MockStream extends Mock implements Stream<NotificationState> {}

class MockStreamSubscription extends Mock
    implements StreamSubscription<NotificationState> {}

class FakeNotificationState extends Fake implements NotificationState {}

class FakeNotificationEvent extends Fake implements NotificationEvent {}

void main() {
  late MockNotificationBloc mockNotificationBloc;
  late MockStream mockStream;
  late MockStreamSubscription mockSubscription;

  setUpAll(() {
    registerFallbackValue(FakeNotificationState());
    registerFallbackValue(FakeNotificationEvent());
  });

  setUp(() {
    mockNotificationBloc = MockNotificationBloc();
    mockStream = MockStream();
    mockSubscription = MockStreamSubscription();

    // Set up the stream mock to be returned by bloc.stream
    when(() => mockNotificationBloc.stream).thenAnswer((_) => mockStream);

    // Set up the subscription mock to be returned by stream.listen
    when(() => mockStream.listen(any())).thenReturn(mockSubscription);

    // Mock the cancel method to return a Future<void> instead of null
    when(
      () => mockSubscription.cancel(),
    ).thenAnswer((_) => Future<void>.value());

    // Set up the initial state
    when(
      () => mockNotificationBloc.state,
    ).thenReturn(const NotificationState.initial());

    // Mock the add method
    when(
      () => mockNotificationBloc.add(any(that: isA<NotificationEvent>())),
    ).thenAnswer((_) => Future.value());
  });

  testWidgets(
    'NotificationScreen should cancel stream subscription when disposed',
    (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<NotificationBloc>.value(
            value: mockNotificationBloc,
            child: const NotificationScreen(),
          ),
        ),
      );

      // Verify that the stream was accessed at least once
      verify(() => mockNotificationBloc.stream).called(greaterThanOrEqualTo(1));

      // Listen might be called multiple times (by BlocProvider and/or NotificationScreen)
      // Just verify it was called at least once
      verify(() => mockStream.listen(any())).called(greaterThanOrEqualTo(1));

      // Navigate away to trigger disposal
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();

      // Verify subscription was canceled at least once
      // The number of cancels should match the number of listens
      verify(() => mockSubscription.cancel()).called(greaterThanOrEqualTo(1));
    },
  );
}
