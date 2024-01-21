import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:voter_app/utility/toast.dart';

import '../../model/vote_choice.dart';

class ConfirmVotingDialog extends StatefulWidget {
  final VoteChoice voteChoice;
  final Function(VoteChoice)? onChoiceVote;

  const ConfirmVotingDialog(
      {super.key, required this.voteChoice, this.onChoiceVote});

  @override
  State<ConfirmVotingDialog> createState() => _ConfirmVotingDialog();
}

class _ConfirmVotingDialog extends State<ConfirmVotingDialog> {
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
        absorbing: _loading,
        child: AlertDialog(
          title: const Text("Are you going to vote for..."),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Row(children: [
                  const Text(
                    "Name:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(widget.voteChoice.name),
                ]),
                const SizedBox(height: 8),
                const Text(
                  "Description:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 100, // Adjust the height as needed
                  child: SingleChildScrollView(
                    child: Text(widget.voteChoice.description),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: _loading ? const CircularProgressIndicator() : const Text('Confirm'),
              onPressed: () async {
                try {
                  setState(() {
                    _loading = true;
                  });
                  var callback = widget.onChoiceVote;
                  var success = false;
                  if(callback!=null){
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
