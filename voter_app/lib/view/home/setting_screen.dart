import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:voter_app/view/home/vote_editing_screen.dart';

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
    return SettingsList(
      contentPadding: EdgeInsets.only(left: 16.0, right: 16.0),
      sections: [
        SettingsSection(
          title: const Text('Common'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              onPressed: (context) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const VoteEditingScreen()),
                );
              },
              leading: const Icon(Icons.edit),
              title: const Text('Edit vote choice'),
            ),
            SettingsTile.switchTile(
              onToggle: (value) {},
              initialValue: true,
              leading: const Icon(Icons.edit_calendar),
              title: const Text('Change voting time'),
            ),
          ],
        ),
        SettingsSection(
          title: const Text('Advance'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              onPressed: (context) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Clear all vote choice'),
                        content: const Text(
                            'This will remove all existing vote and score. Are you sure you want to proceed?'),
                        actions: <Widget>[
                          TextButton(
                            key: const Key('delete_all'),
                            onPressed: () => {Navigator.of(context).pop()},
                            child: const Text('Delete All'),
                          ),
                          TextButton(
                            key: const Key('cancel'),
                            onPressed: () => {Navigator.of(context).pop()},
                            child: const Text('Cancel'),
                          ),
                        ],
                      );
                    });
              },
              leading: const Icon(Icons.highlight_remove_outlined),
              title: const Text('Clear all vote choice'),
              description: const Text('Remove all existing vote and score.'),
            ),
            SettingsTile.navigation(
              onPressed: (context) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Reset vote choice to beginning'),
                        content: const Text(
                            'This will reset all existing vote and score to the beginning. Are you sure you want to proceed?'),
                        actions: <Widget>[
                          TextButton(
                            key: const Key('reset_all'),
                            onPressed: () => {Navigator.of(context).pop()},
                            child: const Text('Reset'),
                          ),
                          TextButton(
                            key: const Key('cancel'),
                            onPressed: () => {Navigator.of(context).pop()},
                            child: const Text('Cancel'),
                          ),
                        ],
                      );
                    });
              },
              leading: const Icon(Icons.lock_reset),
              title: const Text('Reset vote choice to beginning'),
              description:
                  const Text('Reset vote and score to beginning state.'),
            )
          ],
        ),
      ],
    );
  }
}
