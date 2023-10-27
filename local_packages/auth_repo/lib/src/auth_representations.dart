// class AuthFlowResponse extends Object {
//   final int? duration;

//   const AuthFlowResponse.authNotInitiated() : duration = null;
//   const AuthFlowResponse.otpRequestSucceeded() : duration = null;
//   const AuthFlowResponse.incorrectUsername() : duration = null;
//   const AuthFlowResponse.signinSucceeded() : duration = null;
//   const AuthFlowResponse.invalidSession() : duration = null;
//   const AuthFlowResponse.incorrectPassword() : duration = null;
//   const AuthFlowResponse.disabledUser({required int disableDuraction})
//       : duration = disableDuraction;
//   const AuthFlowResponse.unknownError() : duration = null;

//   bool isEqual(
//       AuthFlowResponse authFlowResponse1, AuthFlowResponse authFlowResponse2) {
//     return authFlowResponse1.runtimeType == authFlowResponse2.runtimeType;
//   }

//   bool isNotEqual(AuthFlowResponse authFlowResponse) {
//     return runtimeType == authFlowResponse.runtimeType;
//   }
// }
import 'package:flutter/foundation.dart';

class AuthFlowResponse extends Object {
  final int code;
  final int? duration;

  const AuthFlowResponse.authNotInitiated()
      : duration = null,
        code = 1;
  const AuthFlowResponse.otpRequestSucceeded()
      : duration = null,
        code = 2;
  const AuthFlowResponse.incorrectUsername()
      : duration = null,
        code = 3;
  const AuthFlowResponse.signinSucceeded()
      : duration = null,
        code = 4;
  const AuthFlowResponse.invalidSession()
      : duration = null,
        code = 5;
  const AuthFlowResponse.incorrectPassword()
      : duration = null,
        code = 6;
  AuthFlowResponse.disabledUser({required int dur})
      : this.duration = dur,
        code = 7;
  const AuthFlowResponse.unknownError()
      : duration = null,
        code = 8;

  bool isEqual(AuthFlowResponse o) {
    if (kDebugMode) {
      print("...........CODE 1: ${this.code} ..........CODE 2 : ${o.code}");
    }
    return this.code == o.code;
  }

  bool isNotEqual(AuthFlowResponse o) {
    return this.code != o.code;
  }
}
