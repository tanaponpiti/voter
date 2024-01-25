import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:voter_app/provider/vote_choice_provider.dart';
import 'package:voter_app/view/home/vote_editing_screen.dart';

class SettingScreen extends StatefulWidget {
  static const String id = "setting";
  final BoxConstraints constraints;

  const SettingScreen({Key? key, required this.constraints}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool isDeleting = false;
  bool isResetting = false;

  @override
  Widget build(BuildContext context) {
    final voteChoiceProvider = Provider.of<VoteChoiceProvider>(context);
    return AbsorbPointer(
      absorbing: isDeleting || isResetting,
      child: SettingsList(
        contentPadding: const EdgeInsets.only(left: 16.0, right: 16.0),
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
                              onPressed: () async {
                                try {
                                  setState(
                                          () => isDeleting = true);
                                  await voteChoiceProvider
                                      .deleteAllVoteChoiceAndScore(context);
                                } finally {
                                  setState(
                                      () => isDeleting = false);
                                }
                                Navigator.of(context).pop();
                              },
                              child: isDeleting
                                  ? const CircularProgressIndicator()
                                  : const Text('Delete All'),
                            ),
                            TextButton(
                              key: const Key('cancel'),
                              onPressed: () {
                                if (!isDeleting) {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text('Cancel'),
                            ),
                          ],
                        );
                      });
                },
                leading: const Icon(Icons.highlight_remove_outlined),
                title: const Text('Clear all vote choice and score'),
                description: const Text('Remove all existing vote and score.'),
              ),
              SettingsTile.navigation(
                onPressed: (context) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Reset all vote score to 0'),
                          content: const Text(
                              'This will reset all existing score to 0. Are you sure you want to proceed?'),
                          actions: <Widget>[
                            TextButton(
                              key: const Key('reset_all'),
                              onPressed: () async {
                                try {
                                  setState(() =>
                                      isResetting = true); // Start loading
                                  await voteChoiceProvider
                                      .deleteAllVoteScore(context);
                                } finally {
                                  setState(() => isResetting = false);
                                }
                                Navigator.of(context).pop();
                              },
                              child: isResetting
                                  ? const CircularProgressIndicator()
                                  : const Text('Reset'),
                            ),
                            TextButton(
                              key: const Key('cancel'),
                              onPressed: () {
                                if (!isResetting) {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text('Cancel'),
                            ),
                          ],
                        );
                      });
                },
                leading: const Icon(Icons.lock_reset),
                title: const Text('Clear all vote score'),
                description: const Text('Reset all vote score to 0.'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
