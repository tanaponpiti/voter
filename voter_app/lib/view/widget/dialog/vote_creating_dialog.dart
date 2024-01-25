import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voter_app/exception/duplicate_vote_exception.dart';
import 'package:voter_app/provider/vote_choice_provider.dart';
import 'package:voter_app/utility/toast.dart';
import '../../../model/vote_choice.dart';

class VoteCreatingDialog extends StatefulWidget {
  final Function(VoteChoiceCreate)? onVoteCreate;

  const VoteCreatingDialog({super.key, this.onVoteCreate});

  @override
  State<VoteCreatingDialog> createState() => _VoteCreatingDialogState();
}

class _VoteCreatingDialogState extends State<VoteCreatingDialog> {
  bool _loading = false;
  bool _isNameEmpty = true;
  bool _isNameDuplicate = false;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _nameController.addListener(() {
      final name = _nameController.text;
      setState(() {
        _isNameEmpty = name.isEmpty;
        _isNameDuplicate = _checkNameDuplicate(name);
      });
    });
  }

  bool _checkNameDuplicate(String name) {
    var voteChoiceProvider =
        Provider.of<VoteChoiceProvider>(context, listen: false);
    var existingVoteList = voteChoiceProvider.voteChoiceList;
    return existingVoteList
        .any((vote) => vote.name.toLowerCase() == name.toLowerCase());
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
          title: const Text("Create your choice"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text(
                  "Name:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter the name',
                    errorText: _isNameEmpty
                        ? 'Name is required'
                        : _isNameDuplicate
                            ? 'Name already exists'
                            : null,
                  ),
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
                  : const Text('Create'),
              onPressed: (_isNameEmpty || _isNameDuplicate || _loading)
                  ? null
                  : () async {
                      final name = _nameController.text;
                      try {
                        setState(() {
                          _loading = true;
                        });
                        final voteCreate = VoteChoiceCreate(name: name);
                        if (_descriptionController.text.isNotEmpty) {
                          voteCreate.description = _descriptionController.text;
                        }
                        var callback = widget.onVoteCreate;
                        var success = false;
                        if (callback != null) {
                          success = await callback(voteCreate);
                        }
                        if (success) {
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                        } else {
                          setState(() {
                            _isNameDuplicate = _checkNameDuplicate(name);
                          });
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
