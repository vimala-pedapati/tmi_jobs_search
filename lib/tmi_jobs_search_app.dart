import 'dart:async';
import 'package:auth_repo/auth_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmi_jobs_search/blocs/authentication/authentication_bloc.dart';
import 'package:tmi_jobs_search/blocs/signin/signin_bloc.dart';
import 'package:tmi_jobs_search/navigation/routes.dart';

class TmiJobSearchApp extends StatelessWidget {
  const TmiJobSearchApp(
      {Key? key,
      required this.graphQLClient,
      required this.authRepo,
      required this.prefs})
      : super(key: key);

  final GraphQLClient graphQLClient;
  final AuthenticationRepositary authRepo;
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    print(".................>TMI JOBS SEARCH");
    return RepositoryProvider.value(
      value: authRepo,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (_) => AuthenticationBloc(
                  authenticationRepository: authRepo,
                  graphQLClient: graphQLClient)),
                   BlocProvider(
              create: (_) => SignInBloc(
                  authenticationRepository: authRepo,)),
        ],
        child: const _AppView(),
      ),
    );
  }
}

class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, authState) {
      if (kDebugMode) {
        print(authState);
      }
      final router = TMIJobSearch.authenticationRoute(authState.status);
      return MaterialApp.router(
        routeInformationProvider: router.routeInformationProvider,
        routeInformationParser: router.routeInformationParser,
        routerDelegate: router.routerDelegate,
      );
    });
  }
}
