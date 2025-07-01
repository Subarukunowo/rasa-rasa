// ===== USER SERVICE =====
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'APIService.dart';

class UserService extends BaseApiService {
  static const String endpoint = '${BaseApiService.baseUrl}/user';

  // Read all users
  static Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('$endpoint/read_user.php'));
    return BaseApiService.handleResponse(response);
  }

  // Create user
  static Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$endpoint/create_user.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return BaseApiService.handleSingleResponse(response);
  }

  // Update user
  static Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$endpoint/update_user.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({...data, 'id': id}),
    );
    return BaseApiService.handleSingleResponse(response);
  }

  // Delete user
  static Future<Map<String, dynamic>> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('$endpoint/delete_user.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    return BaseApiService.handleSingleResponse(response);
  }

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$endpoint/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return BaseApiService.handleSingleResponse(response);
  }

  // Test login
  static Future<Map<String, dynamic>> testLogin() async {
    final response = await http.get(Uri.parse('$endpoint/test_login.php'));
    return BaseApiService.handleSingleResponse(response);
  }
}

// ===== PROFIL SERVICE =====
class ProfilService extends BaseApiService {
  static const String endpoint = '${BaseApiService.baseUrl}/profil';

  // Read all profiles
  static Future<List<dynamic>> fetchProfiles() async {
    final response = await http.get(Uri.parse('$endpoint/read.php'));
    return BaseApiService.handleResponse(response);
  }

  // Create profile
  static Future<Map<String, dynamic>> createProfile(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$endpoint/create.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return BaseApiService.handleSingleResponse(response);
  }

  // Update profile
  static Future<Map<String, dynamic>> updateProfile(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$endpoint/update.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({...data, 'id': id}),
    );
    return BaseApiService.handleSingleResponse(response);
  }

  // Delete profile
  static Future<Map<String, dynamic>> deleteProfile(int id) async {
    final response = await http.delete(
      Uri.parse('$endpoint/delete.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    return BaseApiService.handleSingleResponse(response);
  }
}
