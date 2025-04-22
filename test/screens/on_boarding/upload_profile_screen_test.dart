import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:montra/logic/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:montra/screens/on_boarding/upload_profile_screen.dart';

class MockAuthenticationBloc extends Mock implements AuthenticationBloc {}

class FakeAuthenticationState extends Fake implements AuthenticationState {}

class FakeAuthenticationEvent extends Fake implements AuthenticationEvent {}

void main() {
  late AuthenticationBloc authBloc;

  setUpAll(() {
    registerFallbackValue(FakeAuthenticationState());
    registerFallbackValue(FakeAuthenticationEvent());
  });

  setUp(() {
    authBloc = MockAuthenticationBloc();
    when(() => authBloc.state).thenReturn(const AuthenticationState.initial());
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: BlocProvider.value(
        value: authBloc,
        child: const UploadImageScreen(),
      ),
    );
  }

  testWidgets('renders UploadImageScreen with all UI elements', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text("Profile Photo"), findsOneWidget);
    expect(find.text("A photo of you"), findsOneWidget);
    expect(find.text("Take Photo"), findsOneWidget);
    expect(find.text("Choose from Gallery"), findsOneWidget);
    expect(find.text("Upload Image"), findsOneWidget);
  });

  testWidgets('Take Photo and Choose from Gallery buttons are tappable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget());

    final takePhotoBtn = find.text("Take Photo");
    final galleryBtn = find.text("Choose from Gallery");

    expect(takePhotoBtn, findsOneWidget);
    expect(galleryBtn, findsOneWidget);

    await tester.tap(takePhotoBtn);
    await tester.pump();

    await tester.tap(galleryBtn);
    await tester.pump();
  });

  testWidgets('Upload Image button is disabled when no image is picked', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget());

    final uploadBtn = find.text("Upload Image");
    final ElevatedButton btnWidget = tester.widget(
      find.ancestor(of: uploadBtn, matching: find.byType(ElevatedButton)),
    );

    expect(btnWidget.onPressed, isNull);
  });

  // You can add more tests for image picking logic using mockito or image_picker platform mocking.
}
