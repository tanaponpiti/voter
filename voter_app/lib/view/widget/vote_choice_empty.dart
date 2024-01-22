import 'package:flutter/material.dart';

class VoteChoiceEmpty extends StatelessWidget {
  final Function()? onCreateNewChoiceTap;

  const VoteChoiceEmpty({Key? key, this.onCreateNewChoiceTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.inbox,
            size: 100,
            color: Colors.grey,
          ),
          const Text(
            'There is no voting choice.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              var callback = onCreateNewChoiceTap;
              if (callback != null) {
                callback();
              }
            },
            child: const Text('Click here to create new one.'),
          ),
        ],
      ),
    );
  }
}
