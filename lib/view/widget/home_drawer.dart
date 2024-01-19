import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return Drawer(
      child: Column(
        children: <Widget>[
          const UserAccountsDrawerHeader(
            accountName: Text("Username"),
            accountEmail: Text("user@example.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                "U",
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.thumb_up), // VoteIcon
                  title: const Text('Vote'),
                  onTap: () {
                    widget.onMenuChange(VoteScreen.id);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings), // SettingIcon
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
              leading: const Icon(Icons.logout), // LogoutIcon
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
