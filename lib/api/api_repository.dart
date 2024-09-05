import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text_project/model/user_model.dart';

class ApiRepository {
  var client = http.Client();
  var url = Uri.https('jsonplaceholder.typicode.com', '/users');

  Future<List<User>> fetchUsers() async {
    final response = await client.get(url);

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }
}
