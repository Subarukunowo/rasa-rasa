import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rasa-Rasa Resep',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Model untuk Resep
class Recipe {
  final int id;
  final int userId;
  final String namaMasakan;
  final int kategoriId;
  final int waktuMemasak;
  final String bahanUtama;
  final String deskripsi;
  final String createdAt;
  final String levelKesulitan;
  final String jenisWaktu;
  final String? video;

  const Recipe({
    required this.id,
    required this.userId,
    required this.namaMasakan,
    required this.kategoriId,
    required this.waktuMemasak,
    required this.bahanUtama,
    required this.deskripsi,
    required this.createdAt,
    required this.levelKesulitan,
    required this.jenisWaktu,
    this.video,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      namaMasakan: _parseString(json['nama_masakan']),
      kategoriId: _parseInt(json['kategori_id']),
      waktuMemasak: _parseInt(json['waktu_memasak']),
      bahanUtama: _parseString(json['bahan_utama']),
      deskripsi: _parseString(json['deskripsi']),
      createdAt: _parseString(json['created_at']),
      levelKesulitan: _parseString(json['level_kesulitan']),
      jenisWaktu: _parseString(json['jenis_waktu']),
      video: json['video'] as String?,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}

// Service untuk API
class ApiService {
  static const String baseUrl = 'http://192.168.1.5/rasa-rasa/api/resep/read.php';

  static Future<List<Recipe>> getRecipes() async {
    try {
      debugPrint('🔍 Calling API: $baseUrl');

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('📡 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        String responseBody = response.body.trim();

        // Clean up response - remove PHP comments
        if (responseBody.contains('// ==========')) {
          int jsonStart = responseBody.indexOf('{');
          if (jsonStart != -1) {
            responseBody = responseBody.substring(jsonStart);
            debugPrint('🧹 Cleaned response body');
          }
        }

        if (responseBody.isEmpty) {
          debugPrint('⚠️ Response body is empty');
          return _getDummyRecipes();
        }

        final dynamic decodedData = json.decode(responseBody);

        if (decodedData is Map<String, dynamic>) {
          if (decodedData['success'] == true && decodedData.containsKey('data')) {
            final List<dynamic> data = decodedData['data'] as List<dynamic>;
            debugPrint('✅ Found ${data.length} recipes from API');

            return data.map((json) {
              try {
                return Recipe.fromJson(json as Map<String, dynamic>);
              } catch (e) {
                debugPrint('⚠️ Error parsing recipe: $e');
                return null;
              }
            }).where((recipe) => recipe != null).cast<Recipe>().toList();
          }
        }

        return _getDummyRecipes();
      } else {
        debugPrint('❌ HTTP Error: ${response.statusCode}');
        return _getDummyRecipes();
      }
    } catch (e) {
      debugPrint('❌ Network Error: $e');
      return _getDummyRecipes();
    }
  }

  static List<Recipe> _getDummyRecipes() {
    debugPrint('🎭 Using dummy data - API unavailable');
    return [
      const Recipe(
        id: 15,
        userId: 1,
        namaMasakan: 'Nasi Goreng Spesial',
        kategoriId: 1,
        waktuMemasak: 20,
        bahanUtama: 'Nasi, Telur, Ayam, Kecap',
        deskripsi: 'Nasi goreng dengan tambahan ayam suwir dan telur, cocok untuk sarapan.',
        createdAt: '2025-06-24 11:40:09',
        levelKesulitan: 'Sedang',
        jenisWaktu: 'Sarapan',
        video: 'https://www.youtube.com/watch?v=dummyvideo123',
      ),
      const Recipe(
        id: 14,
        userId: 1,
        namaMasakan: 'Rendang Daging',
        kategoriId: 1,
        waktuMemasak: 150,
        bahanUtama: 'Daging Sapi',
        deskripsi: 'Masakan tradisional Padang yang kaya rempah',
        createdAt: '2024-01-01 00:00:00',
        levelKesulitan: 'Sedang',
        jenisWaktu: 'Makan Siang',
        video: null,
      ),
      const Recipe(
        id: 13,
        userId: 1,
        namaMasakan: 'Tongseng Kambing',
        kategoriId: 1,
        waktuMemasak: 90,
        bahanUtama: 'Daging Kambing',
        deskripsi: 'Gulai kambing dengan kuah santan pedas',
        createdAt: '2024-01-02 00:00:00',
        levelKesulitan: 'Sedang',
        jenisWaktu: 'Makan Malam',
        video: null,
      ),
      const Recipe(
        id: 12,
        userId: 1,
        namaMasakan: 'Ayam Bakar Kecap',
        kategoriId: 3,
        waktuMemasak: 60,
        bahanUtama: 'Ayam',
        deskripsi: 'Ayam bakar dengan bumbu kecap manis khas Indonesia',
        createdAt: '2024-01-04 00:00:00',
        levelKesulitan: 'Sedang',
        jenisWaktu: 'Makan Siang',
        video: null,
      ),
      const Recipe(
        id: 11,
        userId: 1,
        namaMasakan: 'Gado-gado Jakarta',
        kategoriId: 4,
        waktuMemasak: 45,
        bahanUtama: 'Sayuran',
        deskripsi: 'Salad sayuran segar dengan bumbu kacang',
        createdAt: '2024-01-05 00:00:00',
        levelKesulitan: 'Mudah',
        jenisWaktu: 'Makan Siang',
        video: null,
      ),
    ];
  }
}

// Home Screen - Fokus utama
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Recipe> recipes = [];
  bool isLoading = true;
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    debugPrint('🚀 Fetching recipes...');
    setState(() => isLoading = true);

    try {
      final data = await ApiService.getRecipes();
      debugPrint('📥 Received ${data.length} recipes');

      if (mounted) {
        setState(() {
          recipes = data;
          isLoading = false;
        });
        debugPrint('✅ Home screen updated with recipes');
      }
    } catch (e) {
      debugPrint('❌ Error in fetchRecipes: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.orange))
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan gambar background
              Container(
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                ),
                child: Stack(
                  children: [
                    // Background grid makanan
                    Positioned.fill(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                        ),
                        itemCount: 9,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                color: index % 3 == 0
                                    ? Colors.orange.shade100
                                    : index % 3 == 1
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                child: Icon(
                                  Icons.restaurant,
                                  color: index % 3 == 0
                                      ? Colors.orange
                                      : index % 3 == 1
                                      ? Colors.green
                                      : Colors.red,
                                  size: 30,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Overlay gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // Content
                    Positioned(
                      bottom: 80,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rekomendasi Resep\nMasakan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Text(
                              'Lihat lebih banyak',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Navigation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  children: [
                    _buildTab('Unggulan', 0),
                    _buildTab('Popular', 1),
                    _buildTab('Baru', 2),
                    _buildTab('Terkini', 3),
                  ],
                ),
              ),

              // Featured Recipe Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFeaturedCard(
                        'Resep\nSarapan',
                        [Colors.orange.shade300, Colors.orange.shade600],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildFeaturedCard(
                        'Resep\nMakan Siang',
                        [Colors.amber.shade400, Colors.orange.shade600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Recipe List dari API
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: recipes.take(3).map((recipe) => _buildRecipeCard(recipe)).toList(),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          currentIndex: 0, // Always home
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    bool isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTabIndex = index),
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.orange : Colors.grey,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(String title, List<Color> colors) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.restaurant, color: Colors.white, size: 25),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.namaMasakan,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '${recipe.waktuMemasak} Menit',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 15),
                    const Icon(Icons.star, size: 12, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      recipe.levelKesulitan,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, size: 12, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Malaikat Israil',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${(recipe.id * 1.2).toInt()}.0k',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Cooked',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.bookmark_border, color: Colors.white),
        ],
      ),
    );
  }
}