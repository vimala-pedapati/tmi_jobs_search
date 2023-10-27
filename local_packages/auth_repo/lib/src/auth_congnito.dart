import 'dart:convert';

import 'package:auth_repo/src/auth_representations.dart';
import 'package:auth_repo/src/auth_links.dart';
import 'package:auth_repo/src/auth_session.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'package:jwt_decoder/jwt_decoder.dart';

class AuthAlreadyConfiguredException implements Exception {
  String errMsg() => 'Cognito Auth instance has already been configured';
}

class AuthNotConfiguredException implements Exception {
  String errMsg() => 'Cognito Auth instance has not been configured';
}

class CustomAuthFlowNotInitiatedException implements Exception {
  String errMsg() => 'Custom Authentication Flow has not been initiated';
}

// enum CognitoIdpServiceAction {
//   initiateAuth,
//   respondToAuthChallenge,
//   revokeToken
// }

class AuthCognito {
  static final AuthCognito _authInstance = AuthCognito._internal();
  static const String authFlowTypeCustomAuth = 'CUSTOM_AUTH';
  static const String authFlowTypeRefreshToken = 'REFRESH_TOKEN';
  static const String authFlowChallengeNameCustom = 'CUSTOM_CHALLENGE';
  static const int tokenRefreshThresholdSeconds = 5;

  factory AuthCognito() {
    return _authInstance;
  }

  late bool _configured;
  late Function _saveRefreshTokenCallback;
  late Function _clearRefreshTokenCallback;
  AuthSession? _currentSession;

  // private constructor guaranteed to be called exactly once
  AuthCognito._internal() {
    //initialize the singleton instance
    _configured = false;
  }
  Future<void> configureAndInitSession(
      {required Function saveRefreshTokenCallback,
      required Function clearRefreshTokenCallback,
      String? refreshToken}) async {
    if (_configured) {
      throw AuthAlreadyConfiguredException();
    }

    _configured = true;
    _saveRefreshTokenCallback = saveRefreshTokenCallback;
    _clearRefreshTokenCallback = clearRefreshTokenCallback;

    if (refreshToken != null) {
      await _fetchAndSetTokensInSession(refreshToken: refreshToken);
    } else {
      _currentSession = AuthSession(isSignedIn: false, isException: false);
    }
  }

  Future<void> _fetchAndSetTokensInSession(
      {required String? refreshToken}) async {
    if (kDebugMode) {
      print(".....FETCH AND SET REFRESH TOKEN ....called");
    }
    Map<String, dynamic> data = <String, dynamic>{
      'refresh_token': refreshToken,
    };
    Response res = Response("", 201);
    try {
      res = await http.post(Uri.parse('${BaseUrl.baseUrl}get_access_tokens'),
          headers: _constructHeaders(), body: jsonEncode(data));
      if (kDebugMode) {
        print(".....get_access_tokens result: $res");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    if (res.statusCode == 201) {
      _currentSession = AuthSession(isSignedIn: false, isException: true);
      return;
    }
    if (kDebugMode) {
      print(res.statusCode);
    }
    if (res.statusCode == 400 ||
        res.statusCode == 401 ||
        res.statusCode == 500) {
      _currentSession = AuthSession(isSignedIn: false, isException: false);
      return;
    }

    var authResponse = jsonDecode(res.body) as Map<String, dynamic>;
    //add refresh token in the response
    if (kDebugMode) {
      print(authResponse);
    }
    _saveRefreshTokenCallback(authResponse['refresh_token']);
    _currentSession = AuthSession(
        isSignedIn: true,
        tokens: _formatAuthTokens(authResponse),
        isException: false);
    return;
  }

  AuthTokens? _formatAuthTokens(Map<String, dynamic> authResult) {
    if (authResult['access_token'] != null &&
        authResult['refresh_token'] != null) {
      return AuthTokens(
        accessToken: authResult['access_token'].toString(),
        refreshToken: authResult['refresh_token'].toString(),
      );
    }
    return null;
  }

  Future<AuthFlowResponse> initiateCustomAuth(
      {required String username}) async {
    /// if the authentication is already configured it will throw an exception
    if (!_configured) {
      if (kDebugMode) {
        print(
            ".................IS AUTHTHENTICATION ALREADY CONFIGURED........................................$_configured");
      }
      throw AuthNotConfiguredException();
    } else {
      if (kDebugMode) {
        print(
            ".................IS AUTHTHENTICATION ALREADY CONFIGURED........................................$_configured");
      }
    }

    _currentSession = AuthSession(isSignedIn: false, isException: false);
    if (kDebugMode) {
      print(".....USERNAME: $username");
    }
    Map<String, String> data = <String, String>{
      'username': username,
      'appkey': "123456789"
    };
    print(".................Login Started....................");
    var res = await http.post(Uri.parse('${BaseUrl.baseUrl}login'),
        headers: _constructHeaders(), body: jsonEncode(data));

    if (res.statusCode == 400 ||
        res.statusCode == 500 ||
        res.statusCode == 401 ||
        res.statusCode == 403) {
      return (res.statusCode == 403)
          ? AuthFlowResponse.disabledUser(
              dur: int.parse(
                  res.body.split(" ").toList().last.split(".").toList().first) )
          : res.statusCode == 400 || res.statusCode == 401
              ? const AuthFlowResponse.incorrectUsername()
              : const AuthFlowResponse.unknownError();
    }
    // handle successful auth response
    var authResponse = jsonDecode(res.body) as Map;
    if (kDebugMode) {
      print("THE LOGIN RESULT FOR USER LOGIN: ${res.body}, ");
    }
    _currentSession = AuthSession(
        isSignedIn: false,
        session: authResponse['session'].toString(),
        isException: false,
        username: username);
    if (kDebugMode) {
      print(".....Session stored in _cuttenrSession");
    }
    return const AuthFlowResponse.otpRequestSucceeded();
  }

  Future<AuthFlowResponse> completeCustomAuth({required String otp}) async {
    if (!_configured) {
      throw AuthNotConfiguredException();
    } else if (_currentSession?.session == null) {
      return const AuthFlowResponse.authNotInitiated();
    }

    var username = _currentSession?.username;
    Map<String, dynamic> data = <String, dynamic>{
      'username': username, 'password': otp,
      'appkey': '123456789',
      'session': _currentSession?.session
    };

    //print(data);
    var res = await http.post(Uri.parse('${BaseUrl.baseUrl}user_validate'),
        headers: _constructHeaders(), body: jsonEncode(data));
    ////print("Test response--> ${res.body}");
    if (kDebugMode) {
      print("useValidate------------->${res.statusCode}");
    }

    if (res.statusCode == 400 ||
        res.statusCode == 500 ||
        res.statusCode == 403) {
      // //print(
      //   'Error completing custom auth flow: ${res.reasonPhrase} : ${res.body}');
      // session value becomes invalid once used, so drop it
      _currentSession = AuthSession(
          isSignedIn: false, tokens: null, session: null, isException: false);
      // TODO: what if the HTTP 400 response is due to invalid session and not incorrect password
      return (res.statusCode == 403)
          ? AuthFlowResponse.disabledUser(
              dur: int.parse(
                  res.body.split(" ").toList().last.split(".").toList().first))
          : res.statusCode == 400
              ? const AuthFlowResponse.incorrectPassword()
              : const AuthFlowResponse.unknownError();
    }
    // handle successful auth response
    var authResponse = jsonDecode(res.body) as Map<String, dynamic>;
    _currentSession = AuthSession(
        isSignedIn: true,
        tokens: _formatAuthTokens(authResponse),
        isException: false);
    await _saveRefreshTokenCallback(_currentSession?.tokens?.refreshToken);
    return const AuthFlowResponse.signinSucceeded();
  }

  Future<void> _checkAndRefreshSession() async {
    if (kDebugMode) {
      print("..... CHECK AND REFERSH SESSION... called");
    }
    if (_configured && _currentSession?.tokens?.accessToken != null) {
      Duration expiringIn =
          JwtDecoder.getRemainingTime((_currentSession?.tokens?.accessToken)!);
      if (expiringIn.inSeconds <= tokenRefreshThresholdSeconds) {
        await _fetchAndSetTokensInSession(
            refreshToken: _currentSession?.tokens?.refreshToken);
      }
    }
    if (kDebugMode) {
      print("..... CHECK AND REFERSH SESSION... ended");
    }
  }

  Future<AuthSession?> currentSession() async {
    await _checkAndRefreshSession();
    return _currentSession;
  }

  Future<bool> signOut() async {
    if (_currentSession == null) {
      if (kDebugMode) {
        print("hello1------------------->null");
      }
    } else {
      if (!_configured) {
        throw AuthNotConfiguredException();
      } else if (_currentSession?.isSignedIn == false) {
        return true;
      }
    }
    _currentSession = AuthSession(isSignedIn: false, isException: false);
    await _clearRefreshTokenCallback();
    return true;
  }

  // TO PASS HEADERS FOR API CALL
  Map<String, String> _constructHeaders() {
    return {
      'Content-Type': 'application/json',
    };
  }
}
