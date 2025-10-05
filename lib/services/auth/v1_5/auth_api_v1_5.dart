import 'package:dio/dio.dart';

import '../../../constants/base_url.dart';
import '../app_interceptors.dart';

class AuthApiV1_5 {

  final dio = createDio();

  AuthApiV1_5._internal();

  static final _singleton = AuthApiV1_5._internal();

  factory AuthApiV1_5() => _singleton;

  static Dio createDio() {
    var dio = Dio(
        BaseOptions(
          baseUrl: apiUrl_v1_5,
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