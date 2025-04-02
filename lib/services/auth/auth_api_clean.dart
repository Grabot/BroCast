import 'dart:io';

import 'package:dio/dio.dart';
import 'package:jwt_decode/jwt_decode.dart';

import '../../constants/base_url.dart';
import '../../utils/secure_storage.dart';
import '../../utils/settings.dart';
import 'models/login_response.dart';


class AuthApiClean {
  final dio = createDio();

  AuthApiClean._internal();

  static final _singleton = AuthApiClean._internal();

  factory AuthApiClean() => _singleton;

  static Dio createDio() {
    var dio = Dio(
        BaseOptions(
          baseUrl: baseUrl_v1_0,
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

  Settings settings = Settings();
  SecureStorage secureStorage = SecureStorage();

  AppInterceptors(this.dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {

    int? expiration = await secureStorage.getAccessTokenExpiration();
    String? accessToken = await secureStorage.getAccessToken();

    print("Access token: $accessToken");
    if (accessToken == null || accessToken == "" || expiration == null) {
      DioException dioError = DioException(requestOptions: options,
          type: DioExceptionType.cancel,
          error: "User not authorized");
      print("reject 1 clean");
      return handler.reject(dioError, true);
    } else {
      int current = (DateTime
          .now()
          .millisecondsSinceEpoch / 1000).round();

      if ((expiration - current) < 60) {
        // We see that the access token is almost expired. We should refresh it.
        String? refreshToken = await secureStorage.getRefreshToken();
        print("refresh token: $refreshToken");

        if (refreshToken == null || refreshToken == "") {
          // We don't have a refresh token. We should log the user out.
          DioException dioError = DioException(requestOptions: options,
              type: DioExceptionType.cancel,
              error: "User not authorized");
          print("reject 2 clean");
          return handler.reject(dioError, true);
        } else {
          settings.setLoggingIn(true);
          print("refresh action 3");
          String endPoint = "refresh";
          var response = await Dio(
              BaseOptions(
                baseUrl: apiUrl_v1_4,
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
            print("reject 3 clean");
            DioException dioError = DioException(requestOptions: options,
                type: DioExceptionType.cancel,
                error: "User not authorized");
            print("reject 4 clean");
            return handler.reject(dioError, true);
          });

          LoginResponse loginRefresh = LoginResponse.fromJson(response.data);
          if (loginRefresh.getResult()) {
            // With a token refresh we don't want to update all the bro settings, only the tokens
            String? newAccessToken = loginRefresh.getAccessToken();
            if (newAccessToken != null) {
              // the access token will be set in memory and local storage.
              settings.setAccessToken(newAccessToken);
              settings.setAccessTokenExpiration(Jwt.parseJwt(newAccessToken)['exp']);
              await secureStorage.setAccessToken(newAccessToken);
              await secureStorage.setAccessTokenExpiration(Jwt.parseJwt(newAccessToken)['exp']);
              accessToken = newAccessToken;
            }

            String? newRefreshToken = loginRefresh.getRefreshToken();
            if (newRefreshToken != null) {
              // the refresh token will only be set in memory.
              settings.setRefreshToken(newRefreshToken);
              settings.setRefreshTokenExpiration(Jwt.parseJwt(newRefreshToken)['exp']);
              await secureStorage.setRefreshToken(newRefreshToken);
              await secureStorage.setRefreshTokenExpiration(Jwt.parseJwt(newRefreshToken)['exp']);
            }
          } else {
            DioException dioError = DioException(requestOptions: options,
                type: DioExceptionType.cancel,
                error: "User not authorized");
            print("reject 4 clean");
            return handler.reject(dioError, true);
          }
        }
      }
      options.headers['Authorization'] = 'Bearer: $accessToken';
      return handler.next(options);
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