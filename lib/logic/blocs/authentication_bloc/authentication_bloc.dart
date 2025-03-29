import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:montra/logic/api/users/models/user_model.dart';
import 'package:montra/logic/api/users/user_api.dart';
import 'package:montra/logic/blocs/authentication_bloc/auth_repository.dart';
import 'package:montra/logic/database/database_helper.dart';
import 'package:montra/logic/dio_factory.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montra/logic/services/initialization_service.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';
part 'authentication_bloc.freezed.dart';

Logger log = Logger(printer: PrettyPrinter());

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  factory AuthenticationBloc() {
    return _instance;
  }
  AuthenticationBloc._internal() : super(_Initial()) {
    on<_CheckExisting>(_checkExisting);
    on<_UserLogin>(_userLoggedIn);
    on<_UploadProfileImage>(_uploadProfileImage);
    on<_Logout>(_logout);
    on<_UserSignUp>(_userSignUp);
  }

  final String _logTag = 'LoginBloc';
  final userApi = UserApi(DioFactory().create());
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  static final AuthenticationBloc _instance = AuthenticationBloc._internal();
  final _authRepository = AuthRepository(
    userApi: UserApi(DioFactory().create()),
  );

  Future<void> _userSignUp(
    _UserSignUp event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      emit(AuthenticationState.inProgress());
      await _authRepository.setAuthToken(event.authToken);
      await _authRepository.setUser(event.user);
      final db = await _databaseHelper.database;

      emit(AuthenticationState.userSignedUp());
    } catch (e) {
      log.e('Error signing up user: $e');
      emit(AuthenticationState.failure(error: e.toString()));
    }
  }

  Future<void> _logout(_Logout event, Emitter<AuthenticationState> emit) async {
    try {
      emit(AuthenticationState.inProgress());

      await _authRepository.logout();
      /* Login for updating the device token to the backend */
      await _databaseHelper.deleteDatabaseFile();
      emit(AuthenticationState.loggedOut());
      add(const AuthenticationEvent.checkExisting());
    } on Exception catch (error, stackTrace) {
      log.e(_logTag, error: 'Caught an exception  $error     $stackTrace');
      emit(AuthenticationState.failure(error: error.toString()));
    }
  }

  Future<void> _userLoggedIn(
    _UserLogin event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      emit(AuthenticationState.inProgress());
      log.d('Auth token for user is : ${event.authToken}');
      await _authRepository.setAuthToken(event.authToken);
      await _authRepository.setUser(event.user);

      await _authRepository.getProfileImage();

      final user = await _authRepository.getAuthUser();

      // final user = await _authRepository.userApi.getMe();

      final db = await _databaseHelper.database;
      final initializationService = InitializationService();
      await initializationService.initializeWallets();

      emit(
        AuthenticationState.userLoggedIn(
          user: user!,
          authToken: event.authToken,
        ),
      );
    } on Exception catch (error, stackTrace) {
      log.e(_logTag, error: 'Caught an exception  $error     $stackTrace');

      String message = error.toString().replaceFirst('Exception: ', '');
      log.e(message);

      emit(AuthenticationState.failure(error: message));
    }
  }

  Future<void> _checkExisting(
    _CheckExisting event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      emit(AuthenticationState.inProgress());

      final authToken = await _authRepository.getAuthToken();
      final authUser = await _authRepository.getAuthUser();

      if (authToken != null && authUser != null) {
        // final user = await _authRepository.userApi.getMe();

        if (authUser.imgUrl == null) {
          emit(AuthenticationState.userSignedUp());
          return;
        } else {
          final db = await _databaseHelper.database;
          final initializationService = InitializationService();
          await initializationService.initializeWallets();
          emit(
            AuthenticationState.authenticated(
              user: authUser,
              authToken: authToken,
            ),
          );
        }
      } else {
        emit(AuthenticationState.unAuthenticated());
      }
    } on Exception catch (error, stackTrace) {
      log.e(_logTag, error: 'Caught an exception  $error     $stackTrace');
      emit(AuthenticationState.failure(error: error.toString()));
    }
  }

  Future<void> _uploadProfileImage(
    _UploadProfileImage event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      emit(AuthenticationState.inProgress());

      final imageFile = event.image;

      String fileName = imageFile.path.split('/').last;

      // Get MIME type
      String? mimeType = lookupMimeType(imageFile.path) ?? "image/jpeg";
      List<String> mimeTypeData = mimeType.split('/');

      // Convert File to MultipartFile
      MultipartFile multipartFile = await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
        contentType: MediaType(
          mimeTypeData[0],
          mimeTypeData[1],
        ), // Specify MIME type
      );

      // Create FormData
      FormData formData = FormData.fromMap({"file": multipartFile});

      // Call API
      final response = await userApi.uploadImage(formData);
      log.d("✅ Image Uploaded Successfully: ${response.imgUrl}");
      log.d("✅ Image Uploaded Data: ${response.toJson()}");

      await _authRepository.getProfileImage();

      final user = await _authRepository.getAuthUser();

      emit(AuthenticationState.userImageUploaded(user: user!));
    } catch (e) {
      log.e('Error uploading profile image: $e');
      emit(AuthenticationState.failure(error: e.toString()));
    }
  }

  bool isAuthenticated() {
    return state.isAuthenticated;
  }

  Future<UserModel> getAuthUser() async {
    final user = await _authRepository.getAuthUser();
    return user!;
  }
}
