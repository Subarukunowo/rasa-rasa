// lib/screens/search_results_screen.dart
import 'package:flutter/material.dart';
import 'package:rasarasa_app/screen/search.dart';
import '../model/recipe.dart';
import 'search.dart'; // For ApiService and SearchHistoryService

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
          'Hasil Pencarian',
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
                hintText: 'Cari resep...',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Ditemukan ${_searchResults.length} resep untuk "${widget.query}"',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Results list
        Expanded(
          child: _searchResults.isEmpty
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Tidak ada resep yang ditemukan',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Coba kata kunci yang berbeda',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
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
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Chef ${recipe.userName ?? 'Unknown'}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  recipe.jenisWaktu,
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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
          ),
        ),
      ],
    );
  }
}