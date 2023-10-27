import 'dart:async';

import 'package:auth_repo/auth_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:meta/meta.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepositary _authenticationRepository;
  final GraphQLClient _graphQLClient;
  late StreamSubscription<AuthStatus> _authenticationStatusSubscription;
  AuthenticationBloc({
    required AuthenticationRepositary authenticationRepository,
    required GraphQLClient graphQLClient,
  })  : _authenticationRepository = authenticationRepository,
        _graphQLClient = graphQLClient,
        super(const AuthenticationState.unknown()) {
    on<AuthenticationStatusChanged>(_onAuthenticationStatusChanged);
    on<AuthenticationLogoutRequested>(_onAuthenticationLogoutRequested);
    _authenticationStatusSubscription = _authenticationRepository.status.listen(
      (status) {
        if (kDebugMode) {
          print("authstatus--------------------> $status");
        }
        add(AuthenticationStatusChanged(status));
      },
    );
  }

  @override
  Future<void> close() {
    _authenticationStatusSubscription.cancel();
    _authenticationRepository.dispose();
    return super.close();
  }

  void _onAuthenticationStatusChanged(
    AuthenticationStatusChanged event,
    Emitter<AuthenticationState> emit,
  ) async {
    switch (event.status) {
      case AuthStatus.unauthenticated:
        return emit(const AuthenticationState.unauthenticated());
      case AuthStatus.authenticated:
        return emit(const AuthenticationState.authenticated());
      case AuthStatus.exception:
        return emit(const AuthenticationState.error());
      case AuthStatus.sessionExpired:
        return emit(const AuthenticationState.sessionExpired());
      default:
        return emit(const AuthenticationState.unknown());
    }
  }

  void _onAuthenticationLogoutRequested(
    AuthenticationLogoutRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    event.onCompleted();
    await _authenticationRepository.logOut();
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.setString('chr', "");
    // clear the graphql client cache
    _graphQLClient.resetStore(
      refetchQueries: false,
    );
  }
}
