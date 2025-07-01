import 'package:flutter/material.dart';
import '../model/recipe.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({Key? key}) : super(key: key);

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<Recipe> _bookmarkedRecipes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBookmarkedRecipes();
  }

  Future<void> _loadBookmarkedRecipes() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulasi fetch dari storage/API

    setState(() {
      _bookmarkedRecipes = [
        const Recipe(
          id: 1,
          userId: 1,
          namaMasakan: 'Nasi Goreng Seafood',
          kategoriId: 1,
          waktuMemasak: 25,
          bahanUtama: 'Nasi, Udang, Cumi, Telur',
          deskripsi: 'Nasi goreng dengan seafood segar yang lezat',
          createdAt: '2025-01-01 12:00:00',
          levelKesulitan: 'Sedang',
          jenisWaktu: 'Makan Siang',
          userName: 'Chef Budi',
          gambar: '',
        ),
        const Recipe(
          id: 2,
          userId: 1,
          namaMasakan: 'Rendang Daging Sapi',
          kategoriId: 1,
          waktuMemasak: 180,
          bahanUtama: 'Daging Sapi, Santan, Bumbu Rendang',
          deskripsi: 'Rendang daging sapi khas Padang yang autentik',
          createdAt: '2025-01-02 10:30:00',
          levelKesulitan: 'Sulit',
          jenisWaktu: 'Makan Siang',
          userName: 'Chef Sari',
          gambar: '',
        ),
        const Recipe(
          id: 3,
          userId: 1,
          namaMasakan: 'Soto Ayam Lamongan',
          kategoriId: 2,
          waktuMemasak: 60,
          bahanUtama: 'Ayam, Kuah Bening, Koya',
          deskripsi: 'Soto ayam khas Lamongan dengan kuah yang segar',
          createdAt: '2025-01-03 08:15:00',
          levelKesulitan: 'Mudah',
          jenisWaktu: 'Sarapan',
          userName: 'Chef Ahmad',
          gambar: '',
        ),
      ];
      _isLoading = false;
    });
  }

  void _removeBookmark(Recipe recipe) {
    setState(() {
      _bookmarkedRecipes.removeWhere((r) => r.id == recipe.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recipe.namaMasakan} dihapus dari bookmark'),
        action: SnackBarAction(
          label: 'BATAL',
          onPressed: () {
            setState(() {
              _bookmarkedRecipes.add(recipe);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Resep Tersimpan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          if (_bookmarkedRecipes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all, color: Colors.orange),
              onPressed: _showClearAllDialog,
            ),
        ],
      ),
      backgroundColor: Colors.grey.shade50,
      body: _isLoading
          ? _buildLoadingState()
          : _bookmarkedRecipes.isEmpty
          ? _buildEmptyState()
          : _buildBookmarkList(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.orange),
          SizedBox(height: 16),
          Text('Memuat bookmark...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Belum Ada Resep Tersimpan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          const Text(
            'Simpan resep favorit Anda untuk\nmudah ditemukan nanti',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              // Disarankan: gunakan state management atau callback dari parent untuk pindah ke tab index 1
            },
            icon: const Icon(Icons.search),
            label: const Text('Cari Resep'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            '${_bookmarkedRecipes.length} Resep Tersimpan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _bookmarkedRecipes.length,
            itemBuilder: (context, index) {
              final recipe = _bookmarkedRecipes[index];
              return _buildBookmarkCard(recipe);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookmarkCard(Recipe recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.restaurant, color: Colors.orange, size: 35),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.namaMasakan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(
                    recipe.deskripsi,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text('${recipe.waktuMemasak} min',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      const SizedBox(width: 15),
                      Icon(Icons.signal_cellular_alt,
                          size: 14, color: _getDifficultyColor(recipe.levelKesulitan)),
                      const SizedBox(width: 4),
                      Text(
                        recipe.levelKesulitan,
                        style: TextStyle(
                          color: _getDifficultyColor(recipe.levelKesulitan),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 9,
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.person, size: 10, color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      Text(recipe.userName ?? 'Unknown Chef',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          recipe.jenisWaktu,
                          style: const TextStyle(
                              color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _removeBookmark(recipe),
              icon: const Icon(Icons.bookmark, color: Colors.orange, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'mudah':
        return Colors.green;
      case 'sedang':
        return Colors.orange;
      case 'sulit':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Semua Bookmark'),
          content: const Text('Apakah Anda yakin ingin menghapus semua resep yang disimpan?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('BATAL'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _bookmarkedRecipes.clear();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua bookmark telah dihapus')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('HAPUS'),
            ),
          ],
        );
      },
    );
  }
}
