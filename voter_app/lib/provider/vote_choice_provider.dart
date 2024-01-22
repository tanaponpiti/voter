import 'package:flutter/material.dart';
import 'package:voter_app/model/vote_choice.dart';
import 'package:voter_app/storage/storage_service.dart';
import 'package:voter_app/utility/toast.dart';

class VoteChoiceProvider with ChangeNotifier {
  List<VoteChoice> _voteChoiceList = List.empty(growable: true);

  List<VoteChoice> get voteChoiceList => _voteChoiceList;

  bool _isInitialized = false;
  bool _isLoading = false;

  bool get isInitialized => _isInitialized;

  bool get isLoading => _isLoading;

  Future<bool> reloadVoteChoice() async {
    _isLoading = true;
    notifyListeners();
    try {
      // throw "TEST";
      //TODO fetch new data and replace whole list
      await Future.delayed(Duration(seconds: 2));
      _voteChoiceList = _generateMockVoteChoices();
      _voteChoiceList.sort((a, b) => b.voteCount - a.voteCount);
      //TODO make it pagination instead of whole list
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

  Future<bool> voteFor(VoteChoice voteChoice) async {
    try {
      var voteId = voteChoice.id;
      var targetVoteChoice =
          _voteChoiceList.firstWhere((element) => element.id == voteId);
      //TODO send actual request to update vote on server
      await Future.delayed(Duration(seconds: 2));
      targetVoteChoice.voteCount++;
      _voteChoiceList.sort((a, b) => b.voteCount - a.voteCount);
      notifyListeners();
      return true;
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
