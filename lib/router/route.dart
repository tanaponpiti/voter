import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voter_app/provider/authentication_provider.dart';
import 'package:voter_app/view/home/home_screen.dart';
import 'package:voter_app/view/login/login_screen.dart';

final routes = {
  LoginScreen.id: (context) => const LoginScreen(),
  HomeScreen.id: (context) => const HomeScreen(),
};

Route<dynamic> onGenerateRoute(RouteSettings settings, BuildContext context) {
  final String? name = settings.name;
  final Function? pageContentBuilder = routes[name];

  final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
  if (!authProvider.isLoggedIn && settings.name != 'login') {
    return MaterialPageRoute(
      builder: (context) => const LoginScreen(),
      settings: const RouteSettings(name: 'login'),
    );
  }
  if (authProvider.isLoggedIn && settings.name == 'login') {
    return MaterialPageRoute(
      builder: (context) => const HomeScreen(),
      settings: const RouteSettings(name: 'vote'),
    );
  }

  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      final Route route = MaterialPageRoute(
        builder: (context) =>
            pageContentBuilder(context, arguments: settings.arguments),
        settings: settings,
      );
      return route;
    } else {
      final Route route = MaterialPageRoute(
        builder: (context) => pageContentBuilder(context),
        settings: settings,
      );
      return route;
    }
  }
  return MaterialPageRoute(
    builder: (context) => const LoginScreen(),
    settings: const RouteSettings(name: 'login'),
  );
}
