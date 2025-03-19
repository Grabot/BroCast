import 'dart:io';
import 'package:dio/dio.dart';
import 'package:jwt_decode/jwt_decode.dart';

import '../../constants/base_url.dart';
import '../../utils/secure_storage.dart';
import '../../utils/settings.dart';
import 'models/login_response.dart';


class AuthApi {
  final dio = createDio();

  AuthApi._internal();

  static final _singleton = AuthApi._internal();

  factory AuthApi() => _singleton;

  static Dio createDio() {
    var dio = Dio(
        BaseOptions(
          baseUrl: apiUrl_v1_0,
          receiveTimeout: const Duration(milliseconds: 15000),
          connectTimeout: const Duration(milliseconds: 15000),
          sendTimeout: const Duration(milliseconds: 15000),
        )
    );

    dio.interceptors.addAll({
      AppInterceptors(dio)
    });

    return dio;
  }
}

class AppInterceptors extends Interceptor {
  final Dio dio;

  AppInterceptors(this.dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    Settings settings = Settings();
    int expiration = settings.getAccessTokenExpiration();
    if (expiration == 0) {
      // Just continue the request since it probably was a refresh
      return handler.next(options);
    } else {
      String? accessToken = await SecureStorage().getAccessToken();

      if (accessToken == null) {
        DioException dioError = DioException(requestOptions: options,
            type: DioExceptionType.cancel,
            error: "User not authorized");
        return handler.reject(dioError, true);
      } else {
        int current = (DateTime
            .now()
            .millisecondsSinceEpoch / 1000).round();

        if ((expiration - current) < 60) {
          // We see that the access token is almost expired. We should refresh it.
          String refreshToken = settings.getRefreshToken();

          if (refreshToken == "") {
            // We don't have a refresh token. We should log the user out.
            DioException dioError = DioException(requestOptions: options,
                type: DioExceptionType.cancel,
                error: "User not authorized");
            return handler.reject(dioError, true);
          } else {
            settings.setLoggingIn(true);
            String endPoint = "refresh";
            var response = await Dio(
                BaseOptions(
                  baseUrl: apiUrl_v1_0,
                  receiveTimeout: const Duration(milliseconds: 15000),
                  connectTimeout: const Duration(milliseconds: 15000),
                  sendTimeout: const Duration(milliseconds: 15000),
                )
            ).post(endPoint,
                options: Options(headers: {
                  HttpHeaders.contentTypeHeader: "application/json",
                }),
                data: {
                  "access_token": accessToken,
                  "refresh_token": refreshToken
                }
            ).catchError((error, stackTrace) {
              return handler.reject(error, true);
            });

            LoginResponse loginRefresh = LoginResponse.fromJson(response.data);
            if (loginRefresh.getResult()) {
              SecureStorage secureStorage = SecureStorage();
              // With a token refresh we don't want to update all the bro settings, only the tokens
              String? accessToken = loginRefresh.getAccessToken();
              if (accessToken != null) {
                // the access token will be set in memory and local storage.
                settings.setAccessToken(accessToken);
                settings.setAccessTokenExpiration(Jwt.parseJwt(accessToken)['exp']);
                await secureStorage.setAccessToken(accessToken);
              }

              String? refreshToken = loginRefresh.getRefreshToken();
              if (refreshToken != null) {
                // the refresh token will only be set in memory.
                settings.setRefreshToken(refreshToken);
                settings.setRefreshTokenExpiration(Jwt.parseJwt(refreshToken)['exp']);
                await secureStorage.setRefreshToken(refreshToken);
              }
            } else {
              DioException dioError = DioException(requestOptions: options,
                  type: DioExceptionType.cancel,
                  error: "User not authorized");
              return handler.reject(dioError, true);
            }
          }
        }
        options.headers['Authorization'] = 'Bearer: $accessToken';
        return handler.next(options);
      }
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw DeadlineExceededException(err.requestOptions);
      case DioExceptionType.badResponse:
        if (err.response == null) {
          throw BadRequestException(err.requestOptions);
        }
        switch (err.response?.statusCode) {
          case 400:
            throw BadRequestException(err.requestOptions);
          case 401:
            throw UnauthorizedException(err.requestOptions);
          case 404:
            throw NotFoundException(err.requestOptions);
          case 409:
            throw ConflictException(err.requestOptions);
          case 500:
            throw InternalServerErrorException(err.requestOptions);
        }
        break;
      case DioExceptionType.cancel:
        throw BadRequestException(err.requestOptions);
      case DioExceptionType.unknown:
        throw NoInternetConnectionException(err.requestOptions);
      case DioExceptionType.badCertificate:
        throw BadRequestException(err.requestOptions);
      case DioExceptionType.connectionError:
        throw NoInternetConnectionException(err.requestOptions);
    }

    return handler.next(err);
  }
}

class BadRequestException extends DioException {
  BadRequestException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Invalid request';
  }
}

class InternalServerErrorException extends DioException {
  InternalServerErrorException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Unknown error occurred, please try again later.';
  }
}

class ConflictException extends DioException {
  ConflictException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Conflict occurred';
  }
}

class UnauthorizedException extends DioException {
  UnauthorizedException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'Access denied';
  }
}

class NotFoundException extends DioException {
  NotFoundException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'The requested information could not be found';
  }
}

class NoInternetConnectionException extends DioException {
  NoInternetConnectionException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'No internet connection detected, please try again.';
  }
}

class DeadlineExceededException extends DioException {
  DeadlineExceededException(RequestOptions r) : super(requestOptions: r);

  @override
  String toString() {
    return 'The connection has timed out, please try again.';
  }
}