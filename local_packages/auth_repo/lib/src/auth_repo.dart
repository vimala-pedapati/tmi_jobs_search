import 'dart:async';
import 'package:auth_repo/src/auth_congnito.dart';
import 'package:auth_repo/src/auth_representations.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  exception,
  sessionExpired
}

class AuthenticationRepositary {
  // ignore: constant_identifier_names
  static const String AUTH_REFRESH_TOKEN_HIVE_KEY = 'cognito_auth_refresh_key';
  final _controller = StreamController<AuthStatus>();
  final auth = AuthCognito();

  AuthenticationRepositary({required Box authHiveBox}) {
    // fetch the cognito refresh token if available in HiveDB
    String? authRefreshToken =
        authHiveBox.get(AUTH_REFRESH_TOKEN_HIVE_KEY) as String?;
    if (kDebugMode) {
      print("$authRefreshToken");
      print("authRefreshToken -----GETTING FROM HIVE BOX-------------> $authRefreshToken");
    }
    // configure cognito client and initialize session from the token obtained above
    auth.configureAndInitSession(
        refreshToken: authRefreshToken,
        saveRefreshTokenCallback: (String? token) async {
          if (kDebugMode) {
            print(
                "..... Save Refresh Token Call Back : $AUTH_REFRESH_TOKEN_HIVE_KEY : $token");
          }
          await authHiveBox.put(AUTH_REFRESH_TOKEN_HIVE_KEY, token);
        },
        clearRefreshTokenCallback: () async {
           if (kDebugMode) {
            print(
                ".....Clear refresh token callback.....");
          }
          await authHiveBox.delete(AUTH_REFRESH_TOKEN_HIVE_KEY);
        });
  }

  Stream<AuthStatus> get status async* {
    var session = await auth.currentSession();
    if (kDebugMode) {
      print(session);
    }
    while (true) {
      if (session != null) {
        yield session.isException
            ? AuthStatus.exception
            : (session.isSignedIn
                ? AuthStatus.authenticated
                : AuthStatus.unauthenticated);
        yield* _controller.stream;
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 3000));
        if (kDebugMode) {
          print("null session loop");
        }
        session = await auth.currentSession();
      }
    }
  }

  Future<String> getAccessTokenJwt() async {
    if (kDebugMode) {
      print(".... GET ACCESS JWT TOKEN...called");
    }
    final session = await auth.currentSession();
    if (session != null) {
      if (kDebugMode) {
        print(".... ACCESS TOKEN: ${session.accessTokenJwt()}");
      }
      return session.accessTokenJwt();
    } else {
      if (kDebugMode) {
        print(".... ACCESS TOKEN: null");
      }
      return "";
    }
  }

  Future<AuthFlowResponse> getLoginOtp({required String username}) async {
    try {
      return await auth.initiateCustomAuth(username: username);
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return const AuthFlowResponse.unknownError();
    }
  }

  Future<AuthFlowResponse> logInWithOTP({required String otp}) async {
    try {
      var loginResponse = await auth.completeCustomAuth(otp: otp);
      if (kDebugMode) {
        print("response--> $loginResponse");
      }
      if (loginResponse.runtimeType ==  const AuthFlowResponse.signinSucceeded().runtimeType) {
        _controller.add(AuthStatus.authenticated);
      }
      return loginResponse;
    } on Exception catch (e) {
      if (kDebugMode) {
        print("response--> $e");
      }
      return const AuthFlowResponse.unknownError();
    }
  }

  void sessionExpired() {
    _controller.add(AuthStatus.sessionExpired);
  }

  Future<void> logOut() async {
    try {
      if (await auth.signOut()) {
        _controller.add(AuthStatus.unauthenticated);
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  void dispose() => _controller.close();
}
