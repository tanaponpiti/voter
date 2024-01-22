import 'package:flutter/material.dart';
import 'package:voter_app/provider/vote_choice_provider.dart';
import 'package:voter_app/storage/storage_service_factory.dart';
import 'package:voter_app/provider/authentication_provider.dart';
import 'package:provider/provider.dart';
import 'package:voter_app/wrapper/authentication_wrapper.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => AuthenticationProvider(
          storageService: StorageServiceFactory.create(),
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => VoteChoiceProvider(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voting App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      // onGenerateRoute: (settings) {
      //   return onGenerateRoute(settings, context);
      // }
    );
  }
}
