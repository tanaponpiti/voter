import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voter_app/model/user.dart';
import 'package:voter_app/provider/authentication_provider.dart';
import 'package:voter_app/view/home/setting_screen.dart';
import 'package:voter_app/view/home/vote_screen.dart';
import 'package:voter_app/view/login/login_screen.dart';
import 'package:voter_app/view/widget/home_drawer.dart';

class HomeScreen extends StatefulWidget {
  static const String id = "home";

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedMenu = VoteScreen.id;
  static final Map<String, dynamic> _menuOptions = {
    VoteScreen.id: (BuildContext context, BoxConstraints constraints) =>
        VoteScreen(constraints: constraints),
    SettingScreen.id: (BuildContext context, BoxConstraints constraints) =>
        SettingScreen(constraints: constraints),
  };

  void _onMenuChange(String menu) {
    setState(() {
      _selectedMenu = menu;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthenticationProvider>(context);
    // If the user is not logged in, navigate to the login page.
    if (!authProvider.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && ModalRoute.of(context)?.isCurrent == true) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    final User? user = authProvider.userInfo; // Get the c
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Row(
          children: [
            CircleAvatar(
              child: Text(
                user?.name.substring(0, 1) ?? "U",
              ),
            ),
            SizedBox(width: 5),
            Text(user?.name ?? "No Name"),
          ],
        ),
        centerTitle: false,
      ),
      drawer: HomeDrawer(
        onMenuChange: _onMenuChange,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          var screenConstructor = _menuOptions[_selectedMenu] ??
              (BuildContext context, BoxConstraints constraints) =>
                  VoteScreen(constraints: constraints);
          return screenConstructor(context, constraints);
        },
      ),
    );
  }
}
