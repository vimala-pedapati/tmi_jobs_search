class AuthSession {
  bool isSignedIn = false;
  String? username;
  String? session;
  AuthTokens? tokens;
  bool isException = false;
  AuthSession({required this.isSignedIn, this.username, this.session, this.tokens, required this.isException});

  String accessTokenJwt() {
    return tokens == null ? '' : 'Bearer ${tokens?.accessToken}';
  }
}

class AuthTokens {
  String accessToken;
  String refreshToken;
 

  AuthTokens(
      {required this.accessToken,
      required this.refreshToken,
      });
}