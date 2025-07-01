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
      title: 'Rasa-Rasa Search',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Roboto',
      ),
      home: const SearchScreen(),
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

  static Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final allRecipes = await getRecipes();
      if (query.trim().isEmpty) return allRecipes;

      final filtered = allRecipes.where((recipe) {
        return recipe.namaMasakan.toLowerCase().contains(query.toLowerCase()) ||
            recipe.bahanUtama.toLowerCase().contains(query.toLowerCase()) ||
            recipe.deskripsi.toLowerCase().contains(query.toLowerCase());
      }).toList();

      debugPrint('Search results for "$query": ${filtered.length} recipes');
      return filtered;
    } catch (e) {
      debugPrint('Error searching recipes: $e');
      return [];
    }
  }

  static Future<List<Recipe>> getNewRecipes() async {
    try {
      final allRecipes = await getRecipes();
      // Sort by created_at (newest first)
      allRecipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return allRecipes.take(5).toList();
    } catch (e) {
      debugPrint('Error getting new recipes: $e');
      return [];
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
        levelKesulitan: 'Mudah',
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
        levelKesulitan: 'Mudah',
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

// Search History Service (simple in-memory storage)
class SearchHistoryService {
  static List<String> _searchHistory = [];

  static List<String> getSearchHistory() {
    return _searchHistory;
  }

  static void addSearchHistory(String query) {
    if (query.trim().isEmpty) return;

    // Remove if already exists
    _searchHistory.remove(query);

    // Add to beginning
    _searchHistory.insert(0, query);

    // Keep only last 10
    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.take(10).toList();
    }

    debugPrint('Added to search history: $query');
  }

  static void clearSearchHistory() {
    _searchHistory.clear();
    debugPrint('Search history cleared');
  }
}

// Search Screen - Halaman utama search
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Recipe> _mostLikedRecipes = [];
  List<Recipe> _newRecipes = [];
  List<String> _searchHistory = [];
  List<String> _filteredHistory = [];

  bool _isLoading = false;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadSearchHistory();

    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      final recipes = await ApiService.getRecipes();
      final newRecipes = await ApiService.getNewRecipes();

      if (mounted) {
        setState(() {
          _mostLikedRecipes = recipes.take(2).toList();
          _newRecipes = newRecipes.take(3).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _loadSearchHistory() {
    setState(() {
      _searchHistory = SearchHistoryService.getSearchHistory();
      _filteredHistory = _searchHistory;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text;

    if (query.isEmpty) {
      setState(() {
        _showHistory = false;
        _filteredHistory = _searchHistory;
      });
    } else {
      // Filter history based on query
      final filtered = _searchHistory
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();

      setState(() {
        _filteredHistory = filtered;
        _showHistory = true;
      });
    }
  }

  void _onFocusChanged() {
    if (_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
      setState(() {
        _showHistory = false;
        _filteredHistory = _searchHistory;
      });
    }
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    // Save to history
    SearchHistoryService.addSearchHistory(query);
    _loadSearchHistory();

    // Navigate to search results
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(query: query),
      ),
    );
  }

  void _selectHistoryItem(String query) {
    _searchController.text = query;
    _searchFocusNode.unfocus();
    _performSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                suffixIcon: _showHistory && _searchController.text.isNotEmpty
                    ? TextButton(
                  onPressed: () {
                    _searchFocusNode.unfocus();
                    setState(() => _showHistory = false);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.orange),
                  ),
                )
                    : _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => _searchController.clear(),
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: _performSearch,
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
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
          currentIndex: 1, // Search tab active
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange));
    }

    if (_showHistory && _searchController.text.isNotEmpty) {
      return _buildSearchHistory();
    }

    return _buildDefaultContent();
  }

  Widget _buildSearchHistory() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _filteredHistory.map((query) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              title: Text(
                query,
                style: const TextStyle(fontSize: 16),
              ),
              onTap: () => _selectHistoryItem(query),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDefaultContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Most Liked Recipes
          const Text(
            'Most Liked Recipes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: _mostLikedRecipes.map((recipe) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: _buildMostLikedCard(recipe),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 30),

          // New Recipes
          const Text(
            'New Recipes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          ..._newRecipes.map((recipe) {
            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              child: _buildNewRecipeCard(recipe),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMostLikedCard(Recipe recipe) {
    return Container(
      height: 120,
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
                  colors: [Colors.orange.shade300, Colors.orange.shade500],
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.namaMasakan,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Icon(Icons.star, size: 12, color: Colors.yellow),
                      Icon(Icons.star, size: 12, color: Colors.yellow),
                      Icon(Icons.star, size: 12, color: Colors.yellow),
                      Icon(Icons.star, size: 12, color: Colors.yellow),
                      Icon(Icons.star_border, size: 12, color: Colors.yellow),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewRecipeCard(Recipe recipe) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
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
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'New Recipes',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.star, size: 12, color: Colors.yellow),
                    Icon(Icons.star, size: 12, color: Colors.yellow),
                    Icon(Icons.star, size: 12, color: Colors.yellow),
                    Icon(Icons.star_border, size: 12, color: Colors.yellow),
                    Icon(Icons.star_border, size: 12, color: Colors.yellow),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Search Results Screen - Halaman kedua (hasil search)
class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({Key? key, required this.query}) : super(key: key);

  @override
  SearchResultsScreenState createState() => SearchResultsScreenState();
}

class SearchResultsScreenState extends State<SearchResultsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Recipe> _searchResults = [];
  List<String> _searchHistory = [];
  List<String> _filteredHistory = [];

  bool _isSearching = false;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.query;
    _loadSearchHistory();
    _performInitialSearch();

    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadSearchHistory() {
    setState(() {
      _searchHistory = SearchHistoryService.getSearchHistory();
      _filteredHistory = _searchHistory;
    });
  }

  Future<void> _performInitialSearch() async {
    await _performSearch(widget.query, saveToHistory: false);
  }

  void _onSearchChanged() {
    final query = _searchController.text;

    if (query.isEmpty) {
      setState(() {
        _showHistory = false;
        _filteredHistory = _searchHistory;
      });
    } else {
      // Filter history based on query
      final filtered = _searchHistory
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();

      setState(() {
        _filteredHistory = filtered;
        _showHistory = true;
      });
    }
  }

  void _onFocusChanged() {
    if (_searchFocusNode.hasFocus) {
      setState(() {
        _filteredHistory = _searchHistory;
        if (_searchController.text.isNotEmpty) {
          _showHistory = true;
        }
      });
    }
  }

  Future<void> _performSearch(String query, {bool saveToHistory = true}) async {
    if (query.trim().isEmpty) return;

    if (saveToHistory) {
      SearchHistoryService.addSearchHistory(query);
      _loadSearchHistory();
    }

    setState(() {
      _isSearching = true;
      _showHistory = false;
    });

    try {
      final results = await ApiService.searchRecipes(query);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      debugPrint('Error performing search: $e');
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _selectHistoryItem(String query) {
    _searchController.text = query;
    _searchFocusNode.unfocus();
    _performSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'telur',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                suffixIcon: _showHistory && _searchController.text.isNotEmpty
                    ? TextButton(
                  onPressed: () {
                    _searchFocusNode.unfocus();
                    setState(() => _showHistory = false);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.orange),
                  ),
                )
                    : _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => _searchController.clear(),
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (query) => _performSearch(query),
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
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
          currentIndex: 1, // Search tab active
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange));
    }

    if (_showHistory && _searchController.text.isNotEmpty) {
      return _buildSearchHistory();
    }

    return _buildSearchResults();
  }

  Widget _buildSearchHistory() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Sample search suggestions sesuai gambar
          _buildHistoryItem('telur Benediktus'),
          _buildHistoryItem('salad telur hijau'),
          _buildHistoryItem('telur spanyol di atas roti panggang'),
          _buildHistoryItem('sandwich bacon dan telur'),
          _buildHistoryItem('roti telur dan jamur klasik'),
          _buildHistoryItem('telur dan kacang hijau'),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String text) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        title: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        onTap: () => _selectHistoryItem(text),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada resep yang ditemukan',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final recipe = _searchResults[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.restaurant, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.namaMasakan,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      recipe.bahanUtama,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.waktuMemasak} menit',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '• ${recipe.levelKesulitan}',
                          style: const TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}