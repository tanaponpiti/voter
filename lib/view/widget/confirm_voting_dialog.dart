import 'package:flutter/material.dart';

import '../../model/vote_choice.dart';

class ConfirmVotingDialog extends StatelessWidget {
  final VoteChoice voteChoice;
  final Function(VoteChoice)? onChoiceVote;
  const ConfirmVotingDialog(
      {super.key, required this.voteChoice, this.onChoiceVote});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Are you going to vote for..."),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Row(children: [
              const Text(
                "Name:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(voteChoice.name),
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
                child: Text(voteChoice.description),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Confirm'),
          onPressed: () {
            var callback = onChoiceVote;
            if (callback != null) {
              callback(voteChoice);
            }
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
