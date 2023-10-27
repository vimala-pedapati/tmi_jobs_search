import 'package:auth_repo/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tmi_jobs_search/screens/home/home_screen.dart';
import 'package:tmi_jobs_search/screens/login/login_screen.dart';
import 'package:tmi_jobs_search/screens/login/signin_screen.dart';

class NavigationString {
  static String loginScreen = "/login";
  static String forgetPassword = "forgetPassword";
  static String signinscreen = "/signin";
  static String jobExperienceScreen = "jobExperience";
  static String home = "/";
  static String appliedIndents = "appliedIndents";
  static String profilePage = "profilePage";
  static String search = "search";
  static String indentScreen = "indent";
  static String referFriendScreen = "referScreen";
}

class TMIJobSearch {
  static GoRouter authenticationRoute(AuthStatus authStatus) {
    return GoRouter(
      initialLocation: NavigationString.signinscreen, routes: [
      GoRoute(
          name: NavigationString.signinscreen,
          path: NavigationString.signinscreen,
          builder: (context, state) => const SignInScreen(),
          redirect: (context, state) {
          if (authStatus == AuthStatus.authenticated) {
            return NavigationString.home;
          }
          return NavigationString.signinscreen;
        },
          routes: const []),
      GoRoute(
        name: NavigationString.loginScreen,
        path: NavigationString.loginScreen,
        builder: (context, state) => const LoginScreen(), 
      ),
      GoRoute(
          name: NavigationString.home,
          path: NavigationString.home,
          builder: (context, state) => const HomeScreen(),
          pageBuilder: (context, state) {
            return const MaterialPage(child: HomeScreen());
          },
          routes: const [

          ]),
    ]);
  }
}
