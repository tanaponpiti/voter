import 'package:flutter/material.dart';

import '../../../model/vote_choice.dart';

class DeleteVoteDialog extends StatefulWidget {
  final VoteChoice voteChoice;
  final Function(VoteChoice)? onDeleteVote;

  const DeleteVoteDialog(
      {super.key, required this.voteChoice, this.onDeleteVote});

  @override
  State<DeleteVoteDialog> createState() => _DeleteVoteDialogState();
}

class _DeleteVoteDialogState extends State<DeleteVoteDialog> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
        absorbing: _loading,
        child: AlertDialog(
          title: const Text("Notice"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Are you sure you want to delete.'),
                Text('Vote choice : ${widget.voteChoice.name}'),
                const Text('This action is irreversible.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Confirm'),
              onPressed: () async {
                try {
                  setState(() {
                    _loading = true;
                  });
                  var callback = widget.onDeleteVote;
                  var success = false;
                  if (callback != null) {
                    success = await callback(widget.voteChoice);
                  }
                  if (success) {
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  }
                } finally {
                  setState(() {
                    _loading = false;
                  });
                }
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ));
  }
}
