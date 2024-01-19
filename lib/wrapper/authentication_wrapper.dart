import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voter_app/provider/authentication_provider.dart';
import 'package:voter_app/view/loading/loading_screen.dart';
import 'package:voter_app/view/login/login_screen.dart';
import 'package:voter_app/view/vote/vote_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AuthenticationProvider>(context, listen: false)
          .checkLoggedInStatus()
          .then((isLogin) async {
        return isLogin;
      }),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        // Check connection state and snapshot data to decide the initial page
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == true) {
            return const VoteScreen();
          } else {
            return const LoginScreen();
          }
        } else {
          // Show loading indicator while checking the token
          return const LoadingScreen(); // Create a widget that shows a loading indicator
        }
      },
    );
  }
}
