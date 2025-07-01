// ===== KATEGORI SERVICE =====
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'APIService.dart';


class KategoriService extends BaseApiService {
static const String endpoint = '${BaseApiService.baseUrl}/kategori';

// Read all kategori
static Future<List<dynamic>> fetchKategori() async {
final response = await http.get(Uri.parse('$endpoint/read.php'));
return BaseApiService.handleResponse(response);
}

// Create kategori
static Future<Map<String, dynamic>> createKategori(Map<String, dynamic> data) async {
final response = await http.post(
Uri.parse('$endpoint/create.php'),
headers: {'Content-Type': 'application/json'},
body: jsonEncode(data),
);
return BaseApiService.handleSingleResponse(response);
}

// Update kategori
static Future<Map<String, dynamic>> updateKategori(int id, Map<String, dynamic> data) async {
final response = await http.put(
Uri.parse('$endpoint/update.php'),
headers: {'Content-Type': 'application/json'},
body: jsonEncode({...data, 'id': id}),
);
return BaseApiService.handleSingleResponse(response);
}

// Delete kategori
static Future<Map<String, dynamic>> deleteKategori(int id) async {
final response = await http.delete(
Uri.parse('$endpoint/delete.php'),
headers: {'Content-Type': 'application/json'},
body: jsonEncode({'id': id}),
);
return BaseApiService.handleSingleResponse(response);
}
}