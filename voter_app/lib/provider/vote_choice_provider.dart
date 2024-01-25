import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voter_app/connector/vote_connector.dart';
import 'package:voter_app/exception/duplicate_vote_exception.dart';
import 'package:voter_app/exception/invalid_login_exception.dart';
import 'package:voter_app/model/vote_choice.dart';
import 'package:voter_app/provider/authentication_provider.dart';
import 'package:voter_app/utility/toast.dart';

class VoteChoiceProvider with ChangeNotifier {
  List<VoteChoice> _voteChoiceList = List.empty(growable: true);

  List<VoteChoice> get voteChoiceList => _voteChoiceList;

  bool _isInitialized = false;
  bool _isLoading = false;

  bool get isInitialized => _isInitialized;

  bool get isLoading => _isLoading;

  Future<bool> reloadVoteChoice(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    try {
      final token = await authProvider.getToken();
      _voteChoiceList = await getVoteList(token);
      _voteChoiceList.sort((a, b) => b.voteCount - a.voteCount);
    } on UnauthorizedException catch (_) {
      await authProvider.logout();
      return false;
    } catch (e) {
      Toaster.error("Unable to load vote. Please try again later");
      return false;
    } finally {
      if (!_isInitialized) {
        _isInitialized = true;
      }
      _isLoading = false;
      notifyListeners();
    }
    return true;
  }

  List<VoteChoice> _generateMockVoteChoices() {
    List<VoteChoice> voteChoices = [];
    for (int i = 1; i <= 10; i++) {
      voteChoices.add(VoteChoice(
        id: 'choice$i',
        voteCount: 0, // Just example data
        name: 'Option $i',
        description: 'Description for option $i.',
      ));
    }
    return voteChoices;
  }

  Future<bool> voteFor(BuildContext context, VoteChoice voteChoice) async {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    final token = await authProvider.getToken();
    try {
      var voteId = voteChoice.id;
      var targetVoteChoice =
          _voteChoiceList.firstWhere((element) => element.id == voteId);
      await sendVoteFor(token, voteId);
      targetVoteChoice.voteCount++;
      _voteChoiceList.sort((a, b) => b.voteCount - a.voteCount);
      notifyListeners();
      return true;
    } on UnauthorizedException catch (_) {
      await authProvider.logout();
      return false;
    } on DuplicateVoteException catch (_) {
      Toaster.error("Unable to vote. You have already cast your vote.");
      return false;
    } catch (e) {
      Toaster.error("Unable to vote. Please try again later");
      return false;
    }
  }

  Future<bool> editVote(
      BuildContext context, VoteChoiceEdit voteChoiceEdit) async {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    final token = await authProvider.getToken();
    try {
      var voteId = voteChoiceEdit.id;
      var targetVoteChoice =
          _voteChoiceList.firstWhere((element) => element.id == voteId);
      await sendEditVote(token, voteChoiceEdit);
      final editedName = voteChoiceEdit.name;
      if (editedName != null) {
        targetVoteChoice.name = editedName;
      }
      final editedDescription = voteChoiceEdit.name;
      if (editedDescription != null) {
        targetVoteChoice.description = editedDescription;
      }
      notifyListeners();
      return true;
    } on UnauthorizedException catch (_) {
      await authProvider.logout();
      return false;
    } catch (e) {
      Toaster.error("Unable to edit vote. Please try again later");
      return false;
    }
  }

  Future<bool> deleteVote(BuildContext context, VoteChoice voteChoice) async {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    final token = await authProvider.getToken();
    try {
      var voteId = voteChoice.id;
      await sendDeleteVote(token, voteId);
      _voteChoiceList.removeWhere((element) => element.id == voteId);
      notifyListeners();
      return true;
    } on UnauthorizedException catch (_) {
      await authProvider.logout();
      return false;
    } catch (e) {
      Toaster.error("Unable to delete vote. Please try again later");
      return false;
    }
  }
}
