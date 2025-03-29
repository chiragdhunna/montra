import 'package:dio/dio.dart';
import 'package:dio_brotli_transformer/dio_brotli_transformer.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:montra/logic/api_base.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioFactory {
  DioFactory({this.baseUrl = apiBase});

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final String baseUrl;

  Future<String?> getAuthToken() {
    return _storage.read(key: 'authToken');
  }

  Dio create() {
    final dio = Dio(_createBaseOptions());

    dio.options.contentType = Headers.jsonContentType;
    dio.interceptors.add(
      PrettyDioLogger(requestBody: true, requestHeader: true, compact: false),
    );

    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: print, // specify log function
        retries: 4, // Retry up to 4 times
        retryDelays: const [
          Duration(seconds: 1), // Wait 1 sec before first retry
          Duration(seconds: 3), // Wait 3 sec before second retry
          Duration(seconds: 5), // Wait 5 sec before third retry
          Duration(seconds: 10), // Wait 10 sec before fourth retry
        ],
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final authToken = await getAuthToken();
          if (authToken != null) {
            options.headers['token'] = authToken;
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // todo: will finish this
          return handler.next(error);
        },
      ),
    );

    dio.transformer = DioBrotliTransformer();

    return dio;
  }

  BaseOptions _createBaseOptions() => BaseOptions(
    baseUrl: baseUrl,
    receiveTimeout: const Duration(seconds: 60), // ⬆ Increase from 15s to 60s
    sendTimeout: const Duration(seconds: 60), // ⬆ Also increase send timeout
    connectTimeout: const Duration(
      seconds: 60,
    ), // ⬆ Ensure connect timeout is high
    headers: <String, dynamic>{'accept-encoding': 'br'},
  );
}
