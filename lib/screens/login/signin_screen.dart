import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tmi_jobs_search/navigation/routes.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  
                  const SizedBox(height: 250,),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                    child: SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                          onPressed: () {
                            // go to login
                           context.goNamed(NavigationString.loginScreen);
                          },
                          child: const Text("Continue")),
                    ),
                  ),
                ],
              )),
           const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
