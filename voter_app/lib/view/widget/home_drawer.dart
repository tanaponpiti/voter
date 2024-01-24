import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voter_app/model/user.dart';
import 'package:voter_app/provider/authentication_provider.dart';
import 'package:voter_app/view/home/setting_screen.dart';
import 'package:voter_app/view/home/vote_screen.dart';
import 'package:voter_app/view/login/login_screen.dart';

class HomeDrawer extends StatefulWidget {
  final Function(String) onMenuChange;

  const HomeDrawer({Key? key, required this.onMenuChange}) : super(key: key);

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    final User? user = authProvider.userInfo; // Get the c
    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(user?.name ?? "No Name"),
            accountEmail: Text(user?.username ?? "No Username"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.name.substring(0, 1) ?? "U",
                style: const TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.thumb_up),
                  title: const Text('Vote'),
                  onTap: () {
                    widget.onMenuChange(VoteScreen.id);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    widget.onMenuChange(SettingScreen.id);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final authProvider =
                    Provider.of<AuthenticationProvider>(context, listen: false);
                await authProvider.logout();
                if (mounted && ModalRoute.of(context)?.isCurrent == true) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                      // settings: const RouteSettings(name: LoginScreen.id)
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
