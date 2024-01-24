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
    try {
      final authProvider =
          Provider.of<AuthenticationProvider>(context, listen: false);
      final token = await authProvider.getToken();
      _voteChoiceList = await getVoteList(token);
      _voteChoiceList.sort((a, b) => b.voteCount - a.voteCount);
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
    try {
      var voteId = voteChoice.id;
      var targetVoteChoice =
          _voteChoiceList.firstWhere((element) => element.id == voteId);
      final authProvider =
          Provider.of<AuthenticationProvider>(context, listen: false);
      final token = await authProvider.getToken();
      await sendVoteFor(token, voteId);
      targetVoteChoice.voteCount++;
      _voteChoiceList.sort((a, b) => b.voteCount - a.voteCount);
      notifyListeners();
      return true;
    } on DuplicateVoteException catch (_) {
      Toaster.error("Unable to vote. You have already cast your vote.");
      return false;
    } catch (e) {
      Toaster.error("Unable to vote. Please try again later");
      return false;
    }
  }

  Future<bool> editVote(VoteChoice voteChoice) async {
    try {
      var voteId = voteChoice.id;
      var targetVoteChoice =
          _voteChoiceList.firstWhere((element) => element.id == voteId);
      //TODO send actual request to update vote on server
      await Future.delayed(Duration(seconds: 2));
      targetVoteChoice.name = voteChoice.name;
      targetVoteChoice.description = voteChoice.description;
      notifyListeners();
      return true;
    } catch (e) {
      Toaster.error("Unable to vote. Please try again later");
      return false;
    }
  }

  Future<bool> deleteVote(VoteChoice voteChoice) async {
    try {
      var voteId = voteChoice.id;
      _voteChoiceList.removeWhere((element) => element.id == voteId);
      //TODO send actual request to update vote on server
      await Future.delayed(Duration(seconds: 2));
      notifyListeners();
      return true;
    } catch (e) {
      Toaster.error("Unable to vote. Please try again later");
      return false;
    }
  }
}
