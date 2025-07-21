import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> loginUser(String username, String password) async {
  final response = await http.post(
    Uri.parse("http://192.168.0.102:8000/login"), // ✅ Replace with your actual PC IP
    headers: {"Content-Type": "application/x-www-form-urlencoded"},
    body: {
      "username": username,
      "password": password,
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return {"status": "error", "message": "Login failed"};
  }
}
