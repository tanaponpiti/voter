import 'package:flutter/material.dart';
import 'package:voter_app/model/vote_choice.dart';
import 'package:voter_app/view/widget/confirm_voting_dialog.dart';
import 'package:voter_app/view/widget/vote_choice_card.dart';

class VoteScreen extends StatefulWidget {
  static const String id = "vote";
  final BoxConstraints constraints;

  const VoteScreen({Key? key, required this.constraints}) : super(key: key);

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  late List<VoteChoice> voteChoiceList;

  _VoteScreenState();

  _onVoteChoiceClick(VoteChoice voteChoice) {
    showDialog(
        context: context,
        builder: (context) {
          return ConfirmVotingDialog(
              voteChoice: voteChoice, onChoiceVote: _onVoteChoiceConfirm);
        });
  }

  _onVoteChoiceConfirm(VoteChoice voteChoice) {
    setState(() {
      voteChoice.voteCount++;
      voteChoiceList.sort((a, b) => b.voteCount - a.voteCount);
    });
  }

  List<VoteChoice> generateMockVoteChoices() {
    List<VoteChoice> voteChoices = [];
    for (int i = 1; i <= 10; i++) {
      voteChoices.add(VoteChoice(
        id: 'choice$i',
        voteCount: i * 10, // Just example data
        name: 'Option $i',
        description: 'Description for option $i.',
      ));
    }
    return voteChoices;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      voteChoiceList = generateMockVoteChoices();
      voteChoiceList.sort((a, b) => b.voteCount - a.voteCount);
    });
  }

  @override
  Widget build(BuildContext context) {
    const double itemWidth = 300;
    const double spacing = 10;
    int numColumns =
        (widget.constraints.maxWidth / (itemWidth + spacing)).floor();
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: numColumns,
        childAspectRatio: 2.5,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: voteChoiceList.length,
      itemBuilder: (context, index) {
        return VoteChoiceCard(
          index: index,
          voteChoice: voteChoiceList[index],
          onChoiceTap: _onVoteChoiceClick,
        );
      },
    );
  }
}
