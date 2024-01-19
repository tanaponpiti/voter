import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voter_app/provider/authentication_provider.dart';
import 'package:voter_app/view/vote/vote_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String id = "login";

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              child: const Text('Login'),
              onPressed: () async {
                await Provider.of<AuthenticationProvider>(context,
                        listen: false)
                    .login("test");
                if (mounted && ModalRoute.of(context)?.isCurrent == true) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const VoteScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
