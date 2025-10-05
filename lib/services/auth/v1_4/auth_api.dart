import 'package:dio/dio.dart';
import '../../../constants/base_url.dart';
import '../app_interceptors.dart';


class AuthApi {
  final dio = createDio();

  AuthApi._internal();

  static final _singleton = AuthApi._internal();

  factory AuthApi() => _singleton;

  static Dio createDio() {
    var dio = Dio(
        BaseOptions(
          baseUrl: apiUrl_v1_4,
          receiveTimeout: const Duration(seconds: 600),
          connectTimeout: const Duration(seconds: 600),
          sendTimeout: const Duration(seconds: 600),
        )
    );

    dio.interceptors.addAll({
      AppInterceptors(dio)
    });

    return dio;
  }
}

