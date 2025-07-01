// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/recipe.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _userProfile;
  List<dynamic> _foodPhotos = [];
  List<Recipe> _favoriteRecipes = [];
  List<String> _favoriteFoods = [];

  // Constants
  static const String baseUrl = 'http://192.168.1.5/rasa-rasa/api';
  static const Color primaryColor = Color(0xFFE8B86D);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await Future.wait([
        _fetchUserProfile(),
        _fetchUserFoodPhotos(),
        _fetchFavoriteRecipes(),
        _fetchFavoriteFoods(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile data: ${e.toString()}';
      });
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/login'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          _userProfile = responseData['data'];
          return;
        }
      }
      throw Exception('Invalid response from server');
    } catch (e) {
      // Fallback data
      _userProfile = {
        'name': 'Malaikat Israfil',
        'bio': 'Hidupilah Seperti Larry',
        'profile_image': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
        'email': 'malaikat@gmail.com',
      };
      debugPrint('Using fallback user data: $e');
    }
  }

  Future<void> _fetchUserFoodPhotos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/food-photos'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          _foodPhotos = responseData['data'] ?? [];
          return;
        }
      }
      throw Exception('Invalid response from server');
    } catch (e) {
      _foodPhotos = [
        {
          'image_url': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300&h=300&fit=crop',
          'recipe_name': 'Nasi Goreng',
        },
        {
          'image_url': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=300&h=300&fit=crop',
          'recipe_name': 'Pizza Margherita',
        },
        {
          'image_url': 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=300&h=300&fit=crop',
          'recipe_name': 'Sate Ayam',
        },
      ];
      debugPrint('Using fallback food photos: $e');
    }
  }

  Future<void> _fetchFavoriteRecipes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/favorite-recipes'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'] ?? [];
          _favoriteRecipes = data.map((json) {
            try {
              return Recipe.fromJson(json);
            } catch (e) {
              debugPrint('Error parsing favorite recipe: $e');
              return null;
            }
          }).where((recipe) => recipe != null).cast<Recipe>().toList();
          return;
        }
      }
      throw Exception('Invalid response from server');
    } catch (e) {
      _favoriteRecipes = [
        const Recipe(
          id: 1,
          userId: 1,
          namaMasakan: 'Rendang Daging',
          kategoriId: 1,
          waktuMemasak: 180,
          bahanUtama: 'Daging Sapi, Santan, Cabai',
          deskripsi: 'Masakan tradisional Padang yang kaya rempah',
          createdAt: '2024-01-01 00:00:00',
          levelKesulitan: 'Sulit',
          jenisWaktu: 'Makan Siang',
          userName: 'Malaikat Israfil',
          gambar: '',
        ),
        const Recipe(
          id: 2,
          userId: 1,
          namaMasakan: 'Tongseng Kambing',
          kategoriId: 1,
          waktuMemasak: 120,
          bahanUtama: 'Daging Kambing, Santan',
          deskripsi: 'Gulai kambing dengan kuah santan pedas',
          createdAt: '2024-01-02 00:00:00',
          levelKesulitan: 'Sedang',
          jenisWaktu: 'Makan Malam',
          userName: 'Malaikat Israfil',
          gambar: '',
        ),
        const Recipe(
          id: 3,
          userId: 1,
          namaMasakan: 'Gudeg Jogja',
          kategoriId: 2,
          waktuMemasak: 240,
          bahanUtama: 'Nangka Muda, Santan',
          deskripsi: 'Masakan khas Jogjakarta yang manis dan gurih',
          createdAt: '2024-01-03 00:00:00',
          levelKesulitan: 'Sulit',
          jenisWaktu: 'Makan Siang',
          userName: 'Malaikat Israfil',
          gambar: '',
        ),
      ];
      debugPrint('Using fallback favorite recipes: $e');
    }
  }

  Future<void> _fetchFavoriteFoods() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/favorite-foods'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          _favoriteFoods = List<String>.from(responseData['data'] ?? []);
          return;
        }
      }
      throw Exception('Invalid response from server');
    } catch (e) {
      _favoriteFoods = ['Cheese', 'Fruit', 'Chicken', 'Seafood', 'Vegetables', 'Spicy Food'];
      debugPrint('Using fallback favorite foods: $e');
    }
  }

  Future<void> _refreshProfile() async {
    await _loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingWidget()
            : _errorMessage != null
            ? _buildErrorWidget()
            : RefreshIndicator(
          onRefresh: _refreshProfile,
          color: primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildAppBar(),
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildStatsSection(),
                const SizedBox(height: 24),
                _buildFoodPhotos(),
                const SizedBox(height: 24),
                _buildFavoriteFoods(),
                const SizedBox(height: 24),
                _buildFavoriteRecipes(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
          SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadUserProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text(
            'Profil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              _showProfileMenu(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.more_horiz,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // Add edit profile functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // Add settings functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  // Add logout functionality
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey[300],
            backgroundImage: _userProfile?['profile_image'] != null
                ? NetworkImage(_userProfile!['profile_image'])
                : null,
            child: _userProfile?['profile_image'] == null
                ? const Icon(Icons.person, size: 35, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userProfile?['name'] ?? 'Unknown User',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (_userProfile?['bio'] != null) ...[
                  const Text(
                    'Bio:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _userProfile!['bio'],
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Resep', '${_favoriteRecipes.length}', Icons.restaurant_menu),
          _buildStatDivider(),
          _buildStatItem('Pengikut', '148', Icons.people),
          _buildStatDivider(),
          _buildStatItem('Mengikuti', '23', Icons.person_add),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.orange,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildFoodPhotos() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Food Photos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_foodPhotos.length > 3)
                GestureDetector(
                  onTap: () {
                    // Navigate to see all photos
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _foodPhotos.isEmpty
              ? const Text(
            'No food photos yet',
            style: TextStyle(color: Colors.grey),
          )
              : Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _foodPhotos.take(6).map((photo) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  photo['image_url'] ?? '',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteFoods() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Favorite Foods',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _favoriteFoods.isEmpty
              ? const Text(
            'No favorite foods selected',
            style: TextStyle(color: Colors.grey),
          )
              : Wrap(
            spacing: 12,
            runSpacing: 8,
            children: _favoriteFoods.map((food) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  food,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteRecipes() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Favorite Recipes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_favoriteRecipes.length > 2)
                GestureDetector(
                  onTap: () {
                    // Navigate to see all recipes
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _favoriteRecipes.isEmpty
              ? const Text(
            'No favorite recipes yet',
            style: TextStyle(color: Colors.grey),
          )
              : ListView.separated(
            itemCount: _favoriteRecipes.take(3).length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final recipe = _favoriteRecipes[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          color: Colors.orange,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.namaMasakan,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${recipe.waktuMemasak} menit',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                recipe.levelKesulitan,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 12,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'by ${recipe.userName ?? 'Unknown'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.bookmark,
                      color: Colors.orange,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}