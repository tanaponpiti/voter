import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:voter_app/config/api_constant.dart';
import 'package:voter_app/connector/authentication_connector.dart';
import 'package:voter_app/exception/duplicate_vote_exception.dart';
import 'package:voter_app/model/vote_choice.dart';
import '../exception/invalid_login_exception.dart';

Future<List<VoteChoice>> getVoteList(String token) async {
  const String apiUrl = APIConstants.baseUrl + APIConstants.voteListEndpoint;
  final response = await http.get(
    Uri.parse(apiUrl),
    headers: generateAuthHeaders(token),
  );
  if (response.statusCode == 200) {
    final List<dynamic> jsonObj = jsonDecode(response.body);
    return jsonObj.map((json) => VoteChoice.fromJson(json)).toList();
  } else if (response.statusCode == 401) {
    throw UnauthorizedException(
        "unable to get vote list, token might be expired");
  } else {
    throw Exception("unable to get vote list, please try again later");
  }
}

Future<void> sendVoteFor(String token, String voteId) async {
  String apiUrl = APIConstants.baseUrl +
      APIConstants.voteListEndpoint +
      "/" +
      voteId +
      "/vote";
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: generateAuthHeaders(token),
  );
  if (response.statusCode == 200) {
    return null;
  } else if (response.statusCode == 401) {
    throw UnauthorizedException("unable to vote, token might be expired");
  } else if (response.statusCode == 409) {
    throw DuplicateVoteException("unable to vote, user already vote");
  } else {
    throw Exception("unable to vote, please try again later");
  }
}
