import 'package:flutter/material.dart';
import 'package:voter_app/model/vote_choice.dart';

class VoteChoiceCard extends StatelessWidget {
  final int index;
  final VoteChoice voteChoice;
  final Function(VoteChoice)? onChoiceTap;
  final bool isVoted; // New variable

  const VoteChoiceCard(
      {super.key,
      required this.voteChoice,
      this.onChoiceTap,
      required this.index,
      this.isVoted = false});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 8,
        child: Stack(children: [
          Positioned.fill(
              child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isVoted ? Colors.blue.shade100 : Colors.transparent, // Blueish highlight if isVoted is true
                      width: 5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 8,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                voteChoice.name,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                voteChoice.voteCount.toString(),
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            voteChoice.description,
                            style: const TextStyle(fontSize: 14),
                            softWrap: true,
                            maxLines: null,
                            // overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ))),
          Positioned.fill(
              child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: InkWell(
                onTap: () {
                  var callback = onChoiceTap;
                  if (callback != null) {
                    callback(voteChoice);
                  }
                },
              ),
            ),
          ))
        ]));
  }
}
