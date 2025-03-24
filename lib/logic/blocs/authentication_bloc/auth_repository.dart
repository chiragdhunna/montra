import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:montra/logic/api/users/models/user_model.dart';
import 'package:montra/logic/api/users/user_api.dart';
import 'package:path_provider/path_provider.dart';

Logger log = Logger(printer: PrettyPrinter());

class AuthRepository {
  AuthRepository({required this.userApi});

  final String _logTag = 'AuthRepository';
  final authTokenkey = 'authToken';
  final authUserKey = 'authUser';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final UserApi userApi;

  Future<void> logout() async {
    try {
      // await userApi.logout(userDeviceToken);
    } catch (e) {
      log.e('Error in Logout user : $e');
    }

    await _storage.delete(key: authTokenkey);
    await _storage.delete(key: authUserKey);
    /* Logout for deleting the auth token from the backend */
  }

  Future<String?> getAuthToken() async {
    final authToken = await _storage.read(key: authTokenkey);
    log.d(_logTag, error: 'Returning the authToken : $authToken');
    return authToken;
  }

  Future<String?> setAuthToken(String authToken) async {
    await _storage.write(key: authTokenkey, value: authToken);
    return _storage.read(key: authTokenkey);
  }

  Future<UserModel?> getAuthUser() async {
    final data = await _storage.read(key: authUserKey);
    if (data != null) {
      final userData = jsonDecode(data);
      try {
        final user = UserModel.fromJson(userData as Map<String, dynamic>);
        log.d(_logTag, error: 'Returning the user : $user');
        return user;
      } on Exception catch (e) {
        // Anything else that is an exception
        log.e(
          _logTag,
          error: 'Exception converting to user:  userString: $data $e',
        );
      }
    }

    return null;
  }

  Future<UserModel?> setUser(UserModel user) async {
    await _storage.write(key: authUserKey, value: jsonEncode(user.toJson()));
    return getAuthUser();
  }

  Future<void> getProfileImage() async {
    try {
      final response = await userApi.getImage();
      log.d('GetImage Response: $response');

      // Update user data in secure storage

      await saveProfileImage(response.data);
    } catch (e) {
      log.e('Error uploading profile image: $e');
      // You need to handle the error case by either:
      rethrow; // Re-throw the error, or
      // Return a default HttpResponse object that represents an error
    }
  }

  Future<void> saveProfileImage(List<int> imageBytes) async {
    // 1. Save the image to local storage
    final appDocDir = await getApplicationDocumentsDirectory();
    final fileName =
        'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = '${appDocDir.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(imageBytes);

    // 2. Store only the file path in secure storage (not the image itself)
    // final secureStorage = FlutterSecureStorage();
    // await secureStorage.write(key: 'profile_image_path', value: filePath);
    final user = await getAuthUser();
    final updatedUser = user!.copyWith(imgUrl: filePath);
    await setUser(updatedUser);
  }
}
