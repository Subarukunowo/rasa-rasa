import 'package:flutter/material.dart';
import '../model/recipe.dart';
import '../service/APIService.dart';
import '../detail.dart'; // Import halaman detail

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

// Service layer untuk Recipe
class RecipeService {
  static Future<List<Recipe>> getRecipes() async {
    try {
      debugPrint('🔍 Fetching recipes from API...');

      final List<dynamic> data = await ApiService.fetchResep();
      debugPrint('📡 Received ${data.length} recipes from API');

      if (data.isEmpty) {
        debugPrint('⚠️ No recipes found, using dummy data');
        return _getDummyRecipes();
      }

      List<Recipe> recipes = [];
      for (var item in data) {
        try {
          if (item is Map<String, dynamic>) {
            recipes.add(Recipe.fromJson(item));
          }
        } catch (e) {
          debugPrint('⚠️ Error parsing recipe: $e');
        }
      }

      return recipes.isNotEmpty ? recipes : _getDummyRecipes();

    } catch (e) {
      debugPrint('❌ Error fetching recipes: $e');
      return _getDummyRecipes();
    }
  }

  static List<Recipe> _getDummyRecipes() {
    return [
      const Recipe(
        id: 15, userId: 1, namaMasakan: 'Nasi Goreng Spesial', kategoriId: 1,
        waktuMemasak: 20, bahanUtama: 'Nasi, Telur, Ayam, Kecap',
        deskripsi: 'Nasi goreng dengan tambahan ayam suwir dan telur, cocok untuk sarapan.',
        createdAt: '2025-06-24 11:40:09', levelKesulitan: 'Sedang', jenisWaktu: 'Sarapan',
      ),
      const Recipe(
        id: 14, userId: 1, namaMasakan: 'Rendang Daging', kategoriId: 1,
        waktuMemasak: 150, bahanUtama: 'Daging Sapi',
        deskripsi: 'Masakan tradisional Padang yang kaya rempah',
        createdAt: '2024-01-01 00:00:00', levelKesulitan: 'Sulit', jenisWaktu: 'Makan Siang',
      ),
      const Recipe(
        id: 13, userId: 1, namaMasakan: 'Gado-gado Jakarta', kategoriId: 4,
        waktuMemasak: 45, bahanUtama: 'Sayuran',
        deskripsi: 'Salad sayuran segar dengan bumbu kacang',
        createdAt: '2024-01-05 00:00:00', levelKesulitan: 'Mudah', jenisWaktu: 'Makan Siang',
      ),
    ];
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Recipe> recipes = [];
  bool isLoading = true;
  int selectedTabIndex = 0;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await RecipeService.getRecipes();
      if (mounted) {
        setState(() {
          recipes = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Gagal memuat data. Periksa koneksi internet Anda.';
        });
      }
    }
  }

  // Method untuk navigasi ke halaman detail
  void _navigateToRecipeDetail(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(
          recipeId: recipe.id.toString(),
          previousScreen: 'beranda',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? _buildLoadingState()
            : errorMessage != null
            ? _buildErrorState()
            : _buildMainContent(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.orange),
          SizedBox(height: 16),
          Text('Memuat resep...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadRecipes,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: _loadRecipes,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabs(),
            _buildFeaturedCards(),
            const SizedBox(height: 25),
            _buildRecipeList(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 280,
      decoration: BoxDecoration(color: Colors.grey.shade200),
      child: Stack(
        children: [
          _buildBackgroundGrid(),
          _buildGradientOverlay(),
          _buildHeaderContent(),
        ],
      ),
    );
  }

  Widget _buildBackgroundGrid() {
    return Positioned.fill(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final colors = [Colors.orange, Colors.green, Colors.red];
          final color = colors[index % 3];

          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 3)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: color.shade100,
                child: Icon(Icons.restaurant, color: color, size: 30),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.7)],
        ),
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Positioned(
      bottom: 80,
      left: 20,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rekomendasi Resep\nMasakan',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: Text(
              '${recipes.length} Resep Tersedia',
              style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: ['Unggulan', 'Popular', 'Baru', 'Terkini']
            .asMap()
            .entries
            .map((entry) => _buildTab(entry.value, entry.key))
            .toList(),
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

  Widget _buildFeaturedCards() {
    final sarapanCount = recipes.where((r) => r.jenisWaktu.toLowerCase().contains('sarapan')).length;
    final siangCount = recipes.where((r) => r.jenisWaktu.toLowerCase().contains('siang')).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Filter resep sarapan dan tampilkan yang pertama jika ada
                final sarapanRecipes = recipes.where((r) => r.jenisWaktu.toLowerCase().contains('sarapan')).toList();
                if (sarapanRecipes.isNotEmpty) {
                  _navigateToRecipeDetail(sarapanRecipes.first);
                }
              },
              child: _buildFeaturedCard('Resep\nSarapan', [Colors.orange.shade300, Colors.orange.shade600], sarapanCount),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Filter resep makan siang dan tampilkan yang pertama jika ada
                final siangRecipes = recipes.where((r) => r.jenisWaktu.toLowerCase().contains('siang')).toList();
                if (siangRecipes.isNotEmpty) {
                  _navigateToRecipeDetail(siangRecipes.first);
                }
              },
              child: _buildFeaturedCard('Resep\nMakan Siang', [Colors.amber.shade400, Colors.orange.shade600], siangCount),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(String title, List<Color> colors, int count) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(decoration: BoxDecoration(gradient: LinearGradient(colors: colors))),
            Positioned(
              bottom: 10,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('$count resep', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resep Terbaru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          const SizedBox(height: 15),
          ...recipes.take(5).map(_buildRecipeCard),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return GestureDetector(
      onTap: () => _navigateToRecipeDetail(recipe), // Tambahkan navigasi ke detail
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.restaurant, color: Colors.white, size: 25),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.namaMasakan, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(recipe.deskripsi, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text('${recipe.waktuMemasak} Menit', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 15),
                      const Icon(Icons.star, size: 12, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(recipe.levelKesulitan, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        width: 20, height: 20,
                        decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                        child: const Icon(Icons.person, size: 12, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Text('Chef Rasa-Rasa', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10)),
                        child: Text(recipe.jenisWaktu, style: const TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.bookmark_border, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, -2))],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}