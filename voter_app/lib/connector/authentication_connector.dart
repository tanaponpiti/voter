import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:voter_app/config/api_constant.dart';
import 'package:voter_app/model/user.dart';
import '../exception/invalid_login_exception.dart';

Map<String, String> generateAuthHeaders(String token,
    [Map<String, String>? additionalHeaders]) {
  Map<String, String> headers = {
    'Authorization': 'Bearer $token',
  };

  if (additionalHeaders != null) {
    headers.addAll(additionalHeaders);
  }

  return headers;
}

Future<String> loginUser(String username, String password) async {
  const String apiUrl = APIConstants.baseUrl + APIConstants.loginEndpoint;
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'username': username,
      'password': password,
    }),
  );
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    final String token = jsonResponse['token'];
    return token;
  } else if (response.statusCode == 401) {
    throw UnauthorizedException("Username or/and Password is invalid");
  } else {
    throw Exception("unable to login, please try again later");
  }
}

Future<void> logoutUser(String token) async {
  const String apiUrl = APIConstants.baseUrl + APIConstants.logoutEndpoint;
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: generateAuthHeaders(token),
  );
  if (response.statusCode != 200) {
    throw Exception("unable to logout");
  }
}

Future<User> getUserInfo(String token) async {
  const String apiUrl = APIConstants.baseUrl + APIConstants.userDataEndpoint;
  final response = await http.get(
    Uri.parse(apiUrl),
    headers: generateAuthHeaders(token),
  );
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return User.fromJson(jsonResponse);
  } else if (response.statusCode == 401) {
    throw UnauthorizedException(
        "unable to get user info, token might be expired");
  } else {
    throw Exception("unable to get user info, please try again later");
  }
}
