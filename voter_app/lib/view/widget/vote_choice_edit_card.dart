import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voter_app/provider/vote_choice_provider.dart';
import 'package:voter_app/view/widget/dialog/delete_vote_dialog.dart';
import 'package:voter_app/view/widget/dialog/unable_to_edit_vote_dialog.dart';
import 'package:voter_app/view/widget/vote_choice_card.dart';

class VoteChoiceEditCard extends VoteChoiceCard {
  const VoteChoiceEditCard(
      {super.key,
      required super.voteChoice,
      super.onChoiceTap,
      required super.index});

  void _showUnableToEditDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const UnableToEditVoteDialog();
        });
  }

  void _showDeleteDialog(BuildContext context) {
    var voteProvider = Provider.of<VoteChoiceProvider>(context, listen: false);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DeleteVoteDialog(
              voteChoice: super.voteChoice,
              onDeleteVote: voteProvider.deleteVote);
        });
  }

  @override
  Widget build(BuildContext context) {
    var voteCard = super.build(context);
    return Container(
        padding: const EdgeInsets.only(top: 10, right: 10),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topRight,
          children: <Widget>[
            voteCard,
            Positioned(
              top: -10,
              right: -10,
              child: FloatingActionButton(
                heroTag: "vote-del-${super.voteChoice.id}",
                onPressed: () {
                  if (super.voteChoice.voteCount > 0) {
                    _showUnableToEditDialog(context);
                  } else {
                    _showDeleteDialog(context);
                  }
                },
                backgroundColor:
                    super.voteChoice.voteCount > 0 ? Colors.grey : Colors.red,
                mini: true,
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ));
  }
}
