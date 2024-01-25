import 'package:flutter/material.dart';
import '../../../model/vote_choice.dart';

class VoteEditingDialog extends StatefulWidget {
  final VoteChoice voteChoice;
  final Function(VoteChoiceEdit)? onChoiceVote;

  const VoteEditingDialog(
      {super.key, required this.voteChoice, this.onChoiceVote});

  @override
  State<VoteEditingDialog> createState() => _VoteEditingDialogState();
}

class _VoteEditingDialogState extends State<VoteEditingDialog> {
  bool _loading = false;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.voteChoice.name);
    _descriptionController =
        TextEditingController(text: widget.voteChoice.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
        absorbing: _loading,
        child: AlertDialog(
          title: const Text("Edit your choice"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                  "Name:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _nameController,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Description:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 100,
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: null,
                    expands: true,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Save'),
              onPressed: () async {
                try {
                  setState(() {
                    _loading = true;
                  });
                  final voteEdit = VoteChoiceEdit(id: widget.voteChoice.id);
                  if (widget.voteChoice.name != _nameController.text) {
                    widget.voteChoice.name = _nameController.text;
                    voteEdit.name = _nameController.text;
                  }
                  if (widget.voteChoice.description !=
                      _descriptionController.text) {
                    widget.voteChoice.description = _descriptionController.text;
                    voteEdit.description = _descriptionController.text;
                  }
                  var callback = widget.onChoiceVote;
                  var success = false;
                  if (callback != null) {
                    success = await callback(voteEdit);
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
