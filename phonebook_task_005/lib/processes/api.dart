import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:phonebook_task_005/model/userModel.dart';

class APIService {
  var client = http.Client();
  Future<LoginResponseModel> login(LoginRequestModel requestModel) async {
    print(requestModel.toJson());
    String email = requestModel.email.toString();
    String password = requestModel.password.toString();
    final response = await client.post(
        Uri.parse('https://kc-api-005.herokuapp.com/api/user/login'),
        headers: <String, String>{
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            <String, dynamic>{'email': email, 'password': password}));
    if (response.statusCode == 200 || response.statusCode == 400) {
      String jsonDataString = response.body.toString().replaceAll("\n", "");
      var _data = jsonDecode(jsonDataString);
      return LoginResponseModel.fromJson(_data);
    } else {
      throw Exception('Failed to load data');
    }
  }
}

class RegisterService {
  var client = http.Client();
  Future<LoginResponseModel> login(RegisterRequestModel regrequestModel) async {
    print(regrequestModel.toJson());
    String name = regrequestModel.name.toString();
    String email = regrequestModel.email.toString();
    String password = regrequestModel.password.toString();
    final response = await client.post(
        Uri.parse('https://kc-api-005.herokuapp.com/api/user/register'),
        headers: <String, String>{
          "Accept": "application/json",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'email': email,
          'password': password
        }));
    if (response.statusCode == 200 || response.statusCode == 400) {
      String jsonDataString = response.body.toString().replaceAll("\n", "");
      var _data = jsonDecode(jsonDataString);
      return LoginResponseModel.fromJson(_data);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
