import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voter_app/model/vote_choice.dart';
import 'package:voter_app/provider/vote_choice_provider.dart';
import 'package:voter_app/view/home/vote_editing_screen.dart';
import 'package:voter_app/view/widget/dialog/confirm_voting_dialog.dart';
import 'package:voter_app/view/widget/vote_choice_card.dart';
import 'package:voter_app/view/widget/vote_choice_empty.dart';

class VoteScreen extends StatefulWidget {
  static const String id = "vote";
  final BoxConstraints constraints;

  const VoteScreen({Key? key, required this.constraints}) : super(key: key);

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  _VoteScreenState();

  _onVoteChoiceClick(VoteChoice voteChoice) {
    showDialog(
        context: context,
        builder: (context) {
          return ConfirmVotingDialog(
              voteChoice: voteChoice, onChoiceVote: _onVoteChoiceConfirm);
        });
  }

  Future<bool> _onVoteChoiceConfirm(VoteChoice voteChoice) async {
    var voteChoiceProvider =
        Provider.of<VoteChoiceProvider>(context, listen: false);
    return voteChoiceProvider.voteFor(context, voteChoice);
  }

  @override
  void initState() {
    super.initState();
    // Schedule a callback for the end of this frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
      // final voteChoiceProvider =
      //     Provider.of<VoteChoiceProvider>(context, listen: false);
      // voteChoiceProvider.reloadVoteChoice();
    });
  }

  Widget _buildVotingList(
      BuildContext context, VoteChoiceProvider voteChoiceProvider) {
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
      itemCount: voteChoiceProvider.voteChoiceList.length,
      itemBuilder: (context, index) {
        return VoteChoiceCard(
          index: index,
          voteChoice: voteChoiceProvider.voteChoiceList[index],
          onChoiceTap: _onVoteChoiceClick,
        );
      },
    );
  }

  Widget _buildEmptyVotingList(BuildContext context) {
    return VoteChoiceEmpty(onCreateNewChoiceTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const VoteEditingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var voteChoiceProvider = Provider.of<VoteChoiceProvider>(context);
    return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async {
          await voteChoiceProvider.reloadVoteChoice(context);
        },
        child: Container(
            color: const Color.fromARGB(255, 238, 238, 238),
            child: voteChoiceProvider.voteChoiceList.isEmpty
                ? _buildEmptyVotingList(context)
                : _buildVotingList(context, voteChoiceProvider)));
  }
}
