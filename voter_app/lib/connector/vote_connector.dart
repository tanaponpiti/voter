import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:voter_app/config/api_constant.dart';
import 'package:voter_app/connector/authentication_connector.dart';
import 'package:voter_app/exception/duplicate_vote_exception.dart';
import 'package:voter_app/model/vote_choice.dart';
import '../exception/invalid_login_exception.dart';

Future<List<VoteChoice>> getVoteList(String token) async {
  const String apiUrl = APIConstants.baseUrl + APIConstants.voteEndpoint;
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
Future<String?> getUserVote(String token) async {
  const String apiUrl = APIConstants.baseUrl + APIConstants.userVoteEndpoint;
  final response = await http.get(
    Uri.parse(apiUrl),
    headers: generateAuthHeaders(token),
  );
  if (response.statusCode == 200) {
    final jsonObj = jsonDecode(response.body);
    return jsonObj['VoteId'];
  } else if (response.statusCode == 401) {
    throw UnauthorizedException(
        "unable to get user vote, token might be expired");
  } else {
    throw Exception("unable to get user vote, please try again later");
  }
}
Future<void> sendVoteFor(String token, String voteId) async {
  String apiUrl =
      APIConstants.baseUrl + APIConstants.voteEndpoint + "/" + voteId + "/vote";
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
Future<void> sendEditVote(String token, VoteChoiceEdit voteChoice) async {
  String apiUrl =
      APIConstants.baseUrl + APIConstants.voteEndpoint + "/" + voteChoice.id;
  final response = await http.put(
    Uri.parse(apiUrl),
    headers: generateAuthHeaders(token, {
      'Content-Type': 'application/json; charset=UTF-8',
    }),
    body: jsonEncode(<String, String?>{
      'name': voteChoice.name,
      'description': voteChoice.description,
    }),
  );
  if (response.statusCode == 200) {
    return null;
  } else if (response.statusCode == 401) {
    throw UnauthorizedException("unable to edit vote, token might be expired");
  } else if (response.statusCode == 409) {
    throw DuplicateVoteException("unable to edit vote that already have score");
  } else {
    throw Exception("unable to edit vote, please try again later");
  }
}
Future<void> sendCreateVote(String token, VoteChoiceCreate voteChoice) async {
  String apiUrl = APIConstants.baseUrl + APIConstants.voteEndpoint + "/";
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: generateAuthHeaders(token, {
      'Content-Type': 'application/json; charset=UTF-8',
    }),
    body: jsonEncode(<String, String?>{
      'name': voteChoice.name,
      'description': voteChoice.description,
    }),
  );
  if (response.statusCode == 200) {
    return null;
  } else if (response.statusCode == 401) {
    throw UnauthorizedException(
        "unable to create vote, token might be expired");
  } else if (response.statusCode == 409) {
    throw DuplicateVoteException(
        "unable to create vote that already have same name");
  } else {
    throw Exception("unable to create vote, please try again later");
  }
}
Future<void> sendDeleteVote(String token, String voteId) async {
  String apiUrl =
      APIConstants.baseUrl + APIConstants.voteEndpoint + "/" + voteId;
  final response = await http.delete(
    Uri.parse(apiUrl),
    headers: generateAuthHeaders(token),
  );
  if (response.statusCode == 200) {
    return null;
  } else if (response.statusCode == 401) {
    throw UnauthorizedException(
        "unable to delete vote, token might be expired");
  } else {
    throw Exception("unable to delete vote, please try again later");
  }
}
Future<void> sendClearAllVote(String token) async {
  String apiUrl =
      APIConstants.baseUrl + APIConstants.voteEndpoint + "/delete-all";
  final response = await http.delete(
    Uri.parse(apiUrl),
    headers: generateAuthHeaders(token),
  );
  if (response.statusCode == 200) {
    return null;
  } else if (response.statusCode == 401) {
    throw UnauthorizedException(
        "unable to delete all vote, token might be expired");
  } else {
    throw Exception("unable to delete all vote, please try again later");
  }
}
Future<void> sendClearAllScore(String token) async {
  String apiUrl =
      APIConstants.baseUrl + APIConstants.voteEndpoint + "/delete-vote-score";
  final response = await http.delete(
    Uri.parse(apiUrl),
    headers: generateAuthHeaders(token),
  );
  if (response.statusCode == 200) {
    return null;
  } else if (response.statusCode == 401) {
    throw UnauthorizedException(
        "unable to delete vote score, token might be expired");
  } else {
    throw Exception("unable to delete vote score, please try again later");
  }
}