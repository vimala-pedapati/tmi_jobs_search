part of 'authentication_bloc.dart';

class AuthenticationState extends Equatable {
  const AuthenticationState._({
    this.status = AuthStatus.unknown,
  });

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated()
      : this._(status: AuthStatus.authenticated);

  const AuthenticationState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  const AuthenticationState.sessionExpired()
      : this._(status: AuthStatus.sessionExpired);

  const AuthenticationState.error()
      : this._(status: AuthStatus.exception);

  final AuthStatus status;

  @override
  List<Object> get props => [status];
}