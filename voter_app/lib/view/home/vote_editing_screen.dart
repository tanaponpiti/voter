import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voter_app/model/vote_choice.dart';
import 'package:voter_app/provider/vote_choice_provider.dart';
import 'package:voter_app/view/widget/dialog/unable_to_edit_vote_dialog.dart';
import 'package:voter_app/view/widget/dialog/vote_editing_dialog.dart';
import 'package:voter_app/view/widget/vote_choice_edit_card.dart';
import 'package:voter_app/view/widget/vote_choice_empty.dart';

class VoteEditingScreen extends StatefulWidget {
  static const String id = "vote_edit";

  const VoteEditingScreen({Key? key}) : super(key: key);

  @override
  State<VoteEditingScreen> createState() => _VoteEditingScreenState();
}

class _VoteEditingScreenState extends State<VoteEditingScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  _VoteEditingScreenState();

  _onVoteChoiceClick(VoteChoice voteChoice) {
    if (voteChoice.voteCount > 0) {
      showDialog(
          context: context,
          builder: (context) {
            return const UnableToEditVoteDialog();
          });
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return VoteEditingDialog(
                voteChoice: voteChoice, onChoiceVote: _onEditConfirm);
          });
    }
  }

  Future<bool> _onEditConfirm(VoteChoice voteChoice) async {
    var voteChoiceProvider =
        Provider.of<VoteChoiceProvider>(context, listen: false);
    return voteChoiceProvider.editVote(voteChoice);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
    });
  }

  Widget _buildVotingList(BuildContext context, BoxConstraints constraints,
      VoteChoiceProvider voteChoiceProvider) {
    const double itemWidth = 300;
    const double spacing = 10;
    int numColumns = (constraints.maxWidth / (itemWidth + spacing)).floor();
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
        return VoteChoiceEditCard(
          index: index,
          voteChoice: voteChoiceProvider.voteChoiceList[index],
          onChoiceTap: _onVoteChoiceClick,
        );
      },
    );
  }

  Widget _buildEmptyVotingList(BuildContext context) {
    return VoteChoiceEmpty(onCreateNewChoiceTap: () {
      // Navigator.of(context).push(
      //   MaterialPageRoute(builder: (context) => const SecondRoute()),
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    var voteChoiceProvider = Provider.of<VoteChoiceProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit vote choice'),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () async {
              await voteChoiceProvider.reloadVoteChoice();
            },
            child: Container(
                color: const Color.fromARGB(255, 238, 238, 238),
                child: voteChoiceProvider.voteChoiceList.isEmpty
                    ? _buildEmptyVotingList(context)
                    : _buildVotingList(
                        context, constraints, voteChoiceProvider)));
      }),
      floatingActionButton:  FloatingActionButton(
        onPressed: () {

        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
