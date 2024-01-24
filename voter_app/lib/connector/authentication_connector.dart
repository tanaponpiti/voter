import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:voter_app/config/api_constant.dart';
import '../exception/invalid_login_exception.dart';

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
    throw InvalidLoginException("Username or/and Password is invalid");
  } else {
    throw Exception("unable to login, please try again later");
  }
}
