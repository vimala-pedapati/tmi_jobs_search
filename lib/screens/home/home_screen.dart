import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmi_jobs_search/blocs/authentication/authentication_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            const Text("HomeScreen"),
            ElevatedButton(
              onPressed:() {
                context
                    .read<AuthenticationBloc>()
                    .add(AuthenticationLogoutRequested(() {}));
              },
              child: const Text("Log Out"),
            )
          ],
        ),
      ),
    );
  }
}
