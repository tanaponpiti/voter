import 'package:flutter/material.dart';
import 'package:voter_app/view/home/setting_screen.dart';
import 'package:voter_app/view/home/vote_screen.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: const Row(
          children: [
            CircleAvatar(
              child: Text(
                "U",
              ),
            ),
            SizedBox(width: 5),
            Text('User Name'),
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
