import 'package:flutter/material.dart';

class UnableToEditVoteDialog extends StatefulWidget {
  const UnableToEditVoteDialog({super.key});
  @override
  State<UnableToEditVoteDialog> createState() => _UnableToEditVoteDialogState();
}

class _UnableToEditVoteDialogState extends State<UnableToEditVoteDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Notice'),
      content: const SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Cannot edit/delete this vote choice.'),
            Text('Someone already voted on it.'),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Dismiss'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
