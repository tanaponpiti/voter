import 'package:flutter/material.dart';
import 'package:voter_app/view/widget/vote_choice_card.dart';

class VoteScreen extends StatefulWidget {
  static const String id = "vote";

  const VoteScreen({Key? key}) : super(key: key);

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveCardsLayout(),
    );
  }
}

class ResponsiveCardsLayout extends StatelessWidget {
  // Replace this with your data model
  final List<String> items = List<String>.generate(100, (i) => "Item $i");

  ResponsiveCardsLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double itemWidth = 300;
        const double spacing = 10;
        int numColumns = (constraints.maxWidth / (itemWidth + spacing)).floor();
        return GridView.builder(
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
                voteCount: index+1,
              ),
            );
          },
        );
        // Check the width to decide whether to show a ListView or GridView
        // if (constraints.maxWidth > 600) {
        //   // Use GridView for wider screens
        //   return GridView.builder(
        //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //       crossAxisCount: 3, // Adjust the number of columns here
        //       childAspectRatio: 1.7,
        //       crossAxisSpacing: 10,
        //       mainAxisSpacing: 10,
        //     ),
        //     itemCount: items.length,
        //     itemBuilder: (context, index) {
        //       return VoteChoiceCard(name: items[index], description: items[index]);
        //     },
        //   );
        // } else {
        //   return ListView.builder(
        //     itemCount: items.length,
        //     itemBuilder: (context, index) {
        //       return GestureDetector(
        //         onTap: () {
        //           showDialog(
        //             context: context,
        //             builder: (context) => FluidDialog(
        //               // Set the first page of the dialog.
        //               rootPage: FluidDialogPage(
        //                 alignment: Alignment.bottomLeft, //Aligns the dialog to the bottom left.
        //                 builder: (context) => AlertDialog(
        //                   title: Text('Dialog Title'),
        //                   content: Text('This is the content of the dialog.'),
        //                   actions: <Widget>[
        //                     TextButton(
        //                       child: Text('Close'),
        //                       onPressed: () {
        //                         Navigator.of(context).pop();
        //                       },
        //                     ),
        //                   ],
        //                 ), // This can be any widget.
        //               ),
        //             ),
        //           );
        //         },
        //         child: VoteChoiceCard(
        //           name: items[index],
        //           description: items[index],
        //         ),
        //       );
        //     },
        //   );
        // }
      },
    );
  }
}
