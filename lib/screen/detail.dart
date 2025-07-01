// lib/detail.dart
import 'package:flutter/material.dart';
import '../model/recipe.dart';
import '../service/ResepService.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;
  final String? previousScreen;

  const RecipeDetailScreen({
    Key? key,
    required this.recipeId,
    this.previousScreen,
  }) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _isLoading = true;
  bool _isFavorited = false;
  Recipe? _recipe;
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

      final recipe = await ResepService.getRecipeById(widget.recipeId);

      if (recipe != null) {
        setState(() {
          _recipe = recipe;
          _isLoading = false;
        });
        debugPrint('✅ Recipe loaded: ${recipe.namaMasakan}');
      } else {
        throw Exception('Recipe not found');
      }
    } catch (e) {
      debugPrint('❌ Error loading recipe: $e');
      setState(() {
        _isLoading = false;
      });

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat detail resep: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final success = await ResepService.toggleFavorite(widget.recipeId);
      if (success) {
        setState(() {
          _isFavorited = !_isFavorited;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFavorited ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
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
        return 'Beranda';
    }
  }

  // Get ingredients list from bahanUtama
  List<String> _getIngredientsList() {
    if (_recipe?.bahanUtama == null) return [];
    return _recipe!.bahanUtama.split(',').map((e) => e.trim()).toList();
  }

  // Get dummy instructions based on recipe
  List<Map<String, dynamic>> _getInstructions() {
    if (_recipe == null) return [];

    // Generate dummy instructions based on recipe
    return [
      {
        'step': 1,
        'title': 'Persiapan Bahan',
        'description': 'Siapkan semua bahan yang diperlukan: ${_recipe!.bahanUtama}. Pastikan semua bahan dalam kondisi segar dan berkualitas baik.',
      },
      {
        'step': 2,
        'title': 'Mulai Memasak',
        'description': 'Mulai proses memasak ${_recipe!.namaMasakan} dengan tingkat kesulitan ${_recipe!.levelKesulitan.toLowerCase()}. Perhatikan waktu memasak sekitar ${_recipe!.waktuMemasak} menit.',
      },
      {
        'step': 3,
        'title': 'Finishing',
        'description': 'Selesaikan proses memasak dan lakukan penyajian. ${_recipe!.deskripsi}',
      },
    ];
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

    if (_recipe == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(_getBackButtonTitle()),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Resep tidak ditemukan'),
            ],
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
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1551218808-94e220e084d2?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'),
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
                        // Title and Cooked Count - FIXED OVERFLOW
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _recipe!.namaMasakan,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE8B86D),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '${_recipe!.userId}K',
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

                        const SizedBox(height: 16),

                        Text(
                          _recipe!.deskripsi,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Rating & Chef Info - FIXED OVERFLOW
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Rating stars
                            Row(
                              children: [
                                Row(
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < 4 ? Icons.star : Icons.star_border,
                                      color: const Color(0xFFE8B86D),
                                      size: 20,
                                    );
                                  }),
                                ),
                                const SizedBox(width: 8),
                                const Flexible(
                                  child: Text(
                                    '(2564 Review)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Chef info
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE8B86D),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Chef ${_recipe!.userName}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
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

                  // Time Info Cards - RESPONSIVE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Responsive layout based on screen width
                        if (constraints.maxWidth < 350) {
                          // Small screen: Stack vertically
                          return Column(
                            children: [
                              _buildTimeCard('Porsi', 'Persiapan', '2\npp'),
                              const SizedBox(height: 12),
                              _buildTimeCard('Waktu', 'Persiapan', '${(_recipe!.waktuMemasak * 0.3).round()}\nmin'),
                              const SizedBox(height: 12),
                              _buildTimeCard('Waktunya', 'Memasak', '${_recipe!.waktuMemasak}\nmin'),
                            ],
                          );
                        } else {
                          // Normal screen: Horizontal row
                          return Row(
                            children: [
                              Expanded(
                                child: _buildTimeCard('Porsi', 'Persiapan', '2\npp'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTimeCard('Waktu', 'Persiapan', '${(_recipe!.waktuMemasak * 0.3).round()}\nmin'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTimeCard('Waktunya', 'Memasak', '${_recipe!.waktuMemasak}\nmin'),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Recipe Details - FIXED OVERFLOW WITH WRAP
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detail Resep',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildDetailChip('Kategori: ${_recipe!.kategoriId}'),
                            _buildDetailChip('Level: ${_recipe!.levelKesulitan}'),
                            _buildDetailChip(_recipe!.jenisWaktu),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Tab Section - RESPONSIVE
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildTabButton('Bahan-bahan'),
                              const SizedBox(width: 24),
                              _buildTabButton('Langkah-Langkah'),
                            ],
                          ),
                        );
                      },
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

  Widget _buildDetailChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8B86D).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8B86D).withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFFE8B86D),
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
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
    final ingredients = _getIngredientsList();

    if (ingredients.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text(
            'Bahan-bahan tidak tersedia',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

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
                  ingredient,
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
    final instructions = _getInstructions();

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