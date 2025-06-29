import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RASARASA',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8B86D),
          brightness: Brightness.light,
        ),
        fontFamily: 'SF Pro Display',
      ),
      // Fixed: Provide default values for required parameters
      home: const RecipeDetailScreen(
        recipeId: "1", // Default recipe ID for testing
        previousScreen: "beranda", // Default previous screen
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;
  final String? previousScreen;

  const RecipeDetailScreen({
    Key? key,
    required this.recipeId, // This is required
    this.previousScreen
  }) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _isLoading = true;
  bool _isFavorited = false;
  Map<String, dynamic>? _recipeData;
  String _selectedTab = 'Bahan-bahan';

  @override
  void initState() {
    super.initState();
    _loadRecipeDetail();
  }

  Future<void> _loadRecipeDetail() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.get(
        Uri.parse('http://192.168.1.5/rasa-rasa/api/resep/read.php?id=${widget.recipeId}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            _recipeData = responseData['data'];
            _isFavorited = _recipeData?['is_favorited'] ?? false;
            _isLoading = false;
          });
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load recipe');
        }
      } else {
        throw Exception('Failed to load recipe');
      }
    } catch (e) {
      print('API Error: $e');
      // Fallback to mock data
      setState(() {
        _recipeData = {
          'id': widget.recipeId,
          'name': 'Telur Benediktus',
          'description': 'Kuasat hidangan sarapan raja',
          'image': 'https://images.unsplash.com/photo-1551218808-94e220e084d2?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
          'rating': 4.5,
          'review_count': 2564,
          'cooking_count': 8300,
          'portions': 2,
          'prep_time': 25,
          'cook_time': 20,
          'full_description': 'Tumpukan klasik muffin Inggris panggang dengan tambahan bacon Kanada, telur rebus, dan saus hollandaise lembut yang biasanya Anda simpan untuk rencana makan siang di akhir pekan.',
          'ingredients': [
            '3 - muffin Inggris, dibuka',
            '6 - Telur, ditambah 3 kuning telur, dibagi',
            '2 - Sendok makan air jeruk lemon',
            '1 - Sendok teh mustard Dijon',
            '1/2 - Cangkir mentega tawar, leleh'
          ],
          'instructions': [
            {
              'step': 1,
              'title': 'Buat mentega yang sudah diternilkan',
              'description': 'Panaskan panci kecil bertele air setinggi 1 inci di atas api sedang hingga mendingkap. Letakkan mangkuk besar sebatang di atas air bergolak sehingga mangkuk dan bihirn kecang sebanyak hingga mentega menghela dan suatu yang dicarikan mengadam ke dasar mangkuk, 10 menit.',
            },
            {
              'step': 2,
              'title': 'Buat selanjutnya',
              'description': 'Isi mangkuk besar dengan air es. Letakkan mangkuk kecil di dalam air es untuk menahan panas berlebih.'
            }
          ],
          'is_favorited': false,
        };
        _isFavorited = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.5/rasa-rasa/api/resep/toggle-favorite.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'recipe_id': widget.recipeId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            _isFavorited = !_isFavorited;
          });
        }
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      // Still toggle locally for demo
      setState(() {
        _isFavorited = !_isFavorited;
      });
    }
  }

  String _getBackButtonTitle() {
    switch (widget.previousScreen) {
      case 'beranda':
        return 'Beranda';
      case 'bookmark':
        return 'Bookmark';
      case 'search':
        return 'Pencarian';
      case 'profile':
        return 'Profil';
      default:
        return 'Pencarian'; // Default title
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE8B86D)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            title: Text(
              _getBackButtonTitle(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(_recipeData?['image'] ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Info
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _recipeData?['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE8B86D),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  '${(_recipeData?['cooking_count'] ?? 0) / 1000}K',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Cooked',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          _recipeData?['description'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Rating
                        Row(
                          children: [
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < (_recipeData?['rating'] ?? 0).floor()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: const Color(0xFFE8B86D),
                                  size: 20,
                                );
                              }),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${_recipeData?['review_count'] ?? 0} Review)',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Add to Fav Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _toggleFavorite,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFavorited
                                  ? Colors.grey[300]
                                  : const Color(0xFFE8B86D),
                              foregroundColor: _isFavorited
                                  ? Colors.black87
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              _isFavorited ? 'Added to Fav' : 'Add to Fav',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Time Info Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTimeCard(
                            'Porsi',
                            'Persiapan',
                            '${_recipeData?['portions'] ?? 0}\npp',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTimeCard(
                            'Waktu',
                            'Persiapan',
                            '${_recipeData?['prep_time'] ?? 0}\nmin',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTimeCard(
                            'Waktunya',
                            'Memasak',
                            '${_recipeData?['cook_time'] ?? 0}\nmin',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deskripsi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _recipeData?['full_description'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Tab Section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        _buildTabButton('Bahan-bahan'),
                        const SizedBox(width: 24),
                        _buildTabButton('Langkah-Langkah'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tab Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _selectedTab == 'Bahan-bahan'
                        ? _buildIngredientsContent()
                        : _buildInstructionsContent(),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomNavItem(Icons.apps, widget.previousScreen == 'beranda'),
            _buildBottomNavItem(Icons.search, widget.previousScreen == 'search'),
            _buildBottomNavItem(Icons.bookmark_border, widget.previousScreen == 'bookmark'),
            _buildBottomNavItem(Icons.person, widget.previousScreen == 'profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(String title, String subtitle, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title) {
    final isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? const Color(0xFFE8B86D) : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE8B86D) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsContent() {
    final ingredients = _recipeData?['ingredients'] as List<dynamic>? ?? [];

    return Column(
      children: ingredients.map<Widget>((ingredient) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8B86D),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ingredient.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInstructionsContent() {
    final instructions = _recipeData?['instructions'] as List<dynamic>? ?? [];

    return Column(
      children: instructions.map<Widget>((instruction) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8B86D),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    instruction['step'].toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instruction['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      instruction['description'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomNavItem(IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE8B86D) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isActive ? Colors.white : Colors.grey[600],
        size: 24,
      ),
    );
  }
}