import 'package:auth_repo/auth_repo.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmi_jobs_search/blocs/signin/signin_bloc.dart';

enum UsernameOption { mobile, email }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otp = TextEditingController();
  bool isOtpRequestedOrSessionInvalid(SignInState state) {
    return state.authFlowResponse
            .isEqual(const AuthFlowResponse.otpRequestSucceeded()) ||
        state.authFlowResponse
            .isEqual(const AuthFlowResponse.invalidSession()) ||
        state.authFlowResponse
            .isEqual(const AuthFlowResponse.incorrectPassword());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        body: BlocBuilder<SignInBloc, SignInState>(
          builder: (context, state) {
            return Padding(
                padding: const EdgeInsets.all(20.0),
                child: !(isOtpRequestedOrSessionInvalid(state))
                    // child: !(state.authFlowResponse.isEqual(state.authFlowResponse, const AuthFlowResponse.authNotInitiated()))
                    ? Column(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            children: [
                              SizedBox(
                                height: 18,
                              ),
                              Text(
                                'Tmi job search',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const Text("Email"),
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                                hintText: "enter mail address"),
                            onChanged: (email) {
                              return context
                                  .read<SignInBloc>()
                                  .add(SignInUsernameChanged(email, ""));
                            },
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<SignInBloc>()
                                  .add(const SignInUsernameSubmitted());
                            },
                            child: const Text("Send Otp"),
                          )
                        ],
                      )
                    : Column(children: [
                        const Text("Enter the otp"),
                        TextFormField(
                          controller: otp,
                          decoration:
                              const InputDecoration(hintText: "enter otp"),
                          onChanged: (otp) {
                            context
                                .read<SignInBloc>()
                                .add(SignInOtpChanged(otp));
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<SignInBloc>()
                                .add(const SignInOtpSubmitted());
                          },
                          child: const Text("Verify"),
                        )
                      ]));
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // context.read<AuthenticationBloc>().add(FetchTurboHireAPI());
  }
}
