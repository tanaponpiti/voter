import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  static const String id = "setting";
  final BoxConstraints constraints;

  const SettingScreen({Key? key, required this.constraints}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  _SettingScreenState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Settings"));
  }
}
