import 'dart:convert';
import 'package:http/http.dart' as http;
import 'APIService.dart';

class UserService extends BaseApiService {
  static const String endpoint = '${BaseApiService.baseUrl}/user';

  // ===== USER CRUD =====
  static Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('$endpoint/read_user.php'));
    return BaseApiService.handleResponse(response);
  }

  static Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$endpoint/create_user.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return BaseApiService.handleSingleResponse(response);
  }

  static Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$endpoint/update_user.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({...data, 'id': id}),
    );
    return BaseApiService.handleSingleResponse(response);
  }

  static Future<Map<String, dynamic>> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('$endpoint/delete_user.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    return BaseApiService.handleSingleResponse(response);
  }

  // ===== LOGIN =====
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$endpoint/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    return BaseApiService.handleSingleResponse(response);
  }

  static Future<Map<String, dynamic>> testLogin() async {
    final response = await http.get(Uri.parse('$endpoint/test_login.php'));
    return BaseApiService.handleSingleResponse(response);
  }

  // ===== PROFIL (berbasis user_id) =====
  static Future<Map<String, dynamic>> getProfileByUserId(int userId) async {
    final response = await http.get(
      Uri.parse('$endpoint/read_profil.php?user_id=$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${BaseApiService.authToken}', // jika pakai token
      },
    );
    return BaseApiService.handleSingleResponse(response);
  }

  static Future<Map<String, dynamic>> createProfile(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$endpoint/create_profil.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return BaseApiService.handleSingleResponse(response);
  }

  static Future<Map<String, dynamic>> updateProfile(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$endpoint/update_profil.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({...data, 'id': id}),
    );
    return BaseApiService.handleSingleResponse(response);
  }

  static Future<Map<String, dynamic>> deleteProfile(int id) async {
    final response = await http.delete(
      Uri.parse('$endpoint/delete_profil.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    return BaseApiService.handleSingleResponse(response);
  }
}
