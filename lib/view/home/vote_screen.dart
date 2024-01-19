import 'package:flutter/material.dart';
import 'package:voter_app/view/widget/vote_choice_card.dart';

class VoteScreen extends StatefulWidget {
  static const String id = "vote";
  final BoxConstraints constraints;
  const VoteScreen({Key? key, required this.constraints}) : super(key: key);

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}


class _VoteScreenState extends State<VoteScreen> {
  _VoteScreenState();

  @override
  Widget build(BuildContext context) {
    final List<String> items = List<String>.generate(100, (i) => "Item $i");
    const double itemWidth = 300;
    const double spacing = 10;
    int numColumns = (widget.constraints.maxWidth / (itemWidth + spacing)).floor();
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: numColumns,
        childAspectRatio: 2.5,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {},
          child: VoteChoiceCard(
            name: 'Voting Option ${items[index]}',
            description:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, '
                'sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi '
                'ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit '
                'in voluptate velit esse cillum dolore eu fugiat',
            voteCount: index + 1,
          ),
        );
      },
    );
  }
}