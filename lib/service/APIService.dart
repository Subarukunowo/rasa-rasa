import 'dart:convert';
import 'package:http/http.dart' as http;

class BaseApiService {
  static const String baseUrl = 'http://rasa-rasa.polbeng.web.id/api';
  static String? authToken;

  static Map<String, String> _defaultHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  // ======================
  // == WRAPPER FUNCTIONS ==
  // ======================

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.get(url, headers: _defaultHeaders());
  }

  static Future<http.Response> post(String endpoint, dynamic body) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.post(url,
        headers: _defaultHeaders(), body: jsonEncode(body));
  }

  static Future<http.Response> put(String endpoint, dynamic body) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.put(url,
        headers: _defaultHeaders(), body: jsonEncode(body));
  }

  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.delete(url, headers: _defaultHeaders());
  }

  // ======================
  // == RESPONSE HANDLER ==
  // ======================

  static List<dynamic> handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    try {
      final decoded = jsonDecode(response.body);
      if (statusCode == 200) {
        if (decoded['success'] == true && decoded.containsKey('data')) {
          return decoded['data'];
        } else {
          throw Exception(decoded['message'] ?? 'Gagal mengambil data');
        }
      } else if (statusCode == 401) {
        throw Exception('Unauthorized (401). Silakan login kembali.');
      } else {
        throw Exception(decoded['message'] ?? 'Gagal memuat data: $statusCode');
      }
    } catch (e) {
      print('Gagal decode response body: ${response.body}');
      throw Exception('Response tidak dapat diparsing');
    }
  }

  static Map<String, dynamic> handleSingleResponse(http.Response response) {
    final statusCode = response.statusCode;

    try {
      final decoded = jsonDecode(response.body);
      if (statusCode == 200 || statusCode == 201) {
        return decoded;
      } else if (statusCode == 401) {
        throw Exception(decoded['message'] ?? 'Unauthorized (401).');
      } else {
        throw Exception(decoded['message'] ?? 'Gagal memuat data: $statusCode');
      }
    } catch (e) {
      print('Gagal decode response body: ${response.body}');
      throw Exception('Response tidak dapat diparsing');
    }
  }
}
