// lib/screen/EditRecipeScreen.dart
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../service/LangkahResepService.dart';
import '../service/ResepService.dart';
import '../model/recipe.dart';
import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../service/ApiService.dart';
import '../util/user_sessions.dart';
import '../screen/auth/editresepscreen.dart';

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;

  const EditRecipeScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _bahanUtamaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _waktuController = TextEditingController();
  final TextEditingController _videoController = TextEditingController();

  int _selectedKategori = 1;
  String _selectedDifficulty = 'Mudah';
  String _selectedTimeType = 'Menit';
  String _selectedJenisWaktu = 'Sarapan';

  List<LangkahResepInput> _langkahList = [];
  File? _selectedImage;
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _isLoadingData = true;

  final List<String> _difficulties = ['Mudah', 'Sedang', 'Sulit'];
  final List<String> _timeTypes = ['Menit', 'Jam'];
  final List<String> _jenisWaktu = ['Sarapan', 'Makan Siang', 'Makan Malam'];
  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'Makanan Utama'},
    {'id': 2, 'name': 'Makanan Ringan'},
    {'id': 3, 'name': 'Minuman'},
    {'id': 4, 'name': 'Dessert'},
    {'id': 5, 'name': 'Sup'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRecipeData();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _bahanUtamaController.dispose();
    _deskripsiController.dispose();
    _waktuController.dispose();
    _videoController.dispose();
    _scrollController.dispose();
    for (var langkah in _langkahList) langkah.dispose();
    super.dispose();
  }

  Future<void> _loadRecipeData() async {
    try {
      setState(() => _isLoadingData = true);

      _namaController.text = widget.recipe.namaMasakan;
      _bahanUtamaController.text = widget.recipe.bahanUtama;
      _deskripsiController.text = widget.recipe.deskripsi;
      _waktuController.text = widget.recipe.waktuMemasak.toString();
      _videoController.text = widget.recipe.video ?? '';

      _selectedKategori = widget.recipe.kategoriId;
      _selectedDifficulty = widget.recipe.levelKesulitan;
      _selectedJenisWaktu = widget.recipe.jenisWaktu;
      _selectedTimeType = 'Menit';
      _currentImageUrl = widget.recipe.gambarUrl;

      await _fetchRecipeDetails();
    } catch (e) {
      debugPrint('❌ Error loading recipe data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data resep: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }


Future<void> _fetchRecipeDetails() async {
  try {
    final langkahList = await LangkahResepService.getLangkahResepByResepId(widget.recipe.id);

    if (langkahList.isNotEmpty) {
      setState(() {
        _langkahList = langkahList.asMap().entries.map((entry) {
          int index = entry.key;
          var langkah = entry.value;
          LangkahResepInput input = LangkahResepInput(urutan: index + 1);
          input.judulController.text = langkah.judul ?? '';
          input.deskripsiController.text = langkah.deskripsi ?? '';
          return input;
        }).toList();
      });
    } else {
      setState(() => _langkahList = [LangkahResepInput(urutan: 1)]);
    }
  } catch (e) {
    debugPrint('❌ Error fetching recipe details: $e');
    setState(() => _langkahList = [LangkahResepInput(urutan: 1)]);
  }
}
  void _addLangkah() {
    setState(() {
      _langkahList.add(LangkahResepInput(urutan: _langkahList.length + 1));
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _removeLangkah(int index) {
    if (_langkahList.length > 1) {
      setState(() {
        _langkahList[index].dispose();
        _langkahList.removeAt(index);

        for (int i = 0; i < _langkahList.length; i++) {
          _langkahList[i].urutan = i + 1;
        }
      });
    }
  }

  void _reorderLangkah(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _langkahList.removeAt(oldIndex);
      _langkahList.insert(newIndex, item);
      // Update urutan after reorder
      for (int i = 0; i < _langkahList.length; i++) {
        _langkahList[i].urutan = i + 1;
      }
    });
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

Future<void> _submitForm() async {
  if (!_formKey.currentState!.validate()) return;

  // Validasi langkah-langkah resep
  for (int i = 0; i < _langkahList.length; i++) {
    final langkah = _langkahList[i];
    final error = LangkahResepService.validateLangkahResep(
      judul: langkah.judulController.text,
      deskripsi: langkah.deskripsiController.text,
    );
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Langkah ${i + 1}: $error'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
  }

  // Validasi gambar
  if (_selectedImage == null && (_currentImageUrl == null || _currentImageUrl!.isEmpty)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gambar masakan wajib dipilih'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    String? base64Image;
    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      base64Image = "data:image/jpeg;base64,${base64Encode(bytes)}";
    }

    int waktuMasak = int.tryParse(_waktuController.text) ?? -1;
    if (waktuMasak <= 0) throw Exception('Waktu memasak tidak valid');

    final langkahData = _langkahList.map((l) => {
      'judul': l.judulController.text.trim(),
      'deskripsi': l.deskripsiController.text.trim(),
    }).toList();

    final resepData = {
      'id': widget.recipe.id,
      'user_id': UserSession.instance.currentUser?['id'],
      'nama_masakan': _namaController.text.trim(),
      'kategori_id': _selectedKategori,
      'waktu_memasak': waktuMasak,
      'bahan_utama': _bahanUtamaController.text.trim(),
      'deskripsi': _deskripsiController.text.trim(),
      'level_kesulitan': _selectedDifficulty,
      'jenis_waktu': _selectedJenisWaktu,
      'satuan_waktu': _selectedTimeType,
      'video': _videoController.text.trim().isEmpty ? null : _videoController.text.trim(),
      'langkah': langkahData,
    };

    if (base64Image != null) {
      resepData['gambar'] = base64Image;
    }

    // Kirim update ke backend
    final response = await ResepService.updateResep(widget.recipe.id, resepData);

    bool isSuccess = response is Map &&
        (response['success'] == true ||
         response['success'] == 'true' ||
         (response['message'] is String &&
          RegExp(r'berhasil', caseSensitive: false).hasMatch(response['message'])));

    if (!isSuccess) {
      throw Exception(
        response is Map
            ? (response['message'] ?? 'Respon tidak valid')
            : 'Gagal mengupdate resep',
      );
    }

    // Tampilkan ResepSuccessScreen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResepSuccessScreens(
            namaResep: _namaController.text.trim(),
            levelKesulitan: _selectedDifficulty,
            gambarPath: _currentImageUrl ?? widget.recipe.gambar,
          ),
        ),
      );
    }
  } catch (e, stackTrace) {
    debugPrint('❌ Error saat update: $e');
    debugPrintStack(stackTrace: stackTrace);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Resep'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _isLoadingData ? null : _submitForm,
              child: const Text(
                'SIMPAN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoadingData
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 16),
                  Text('Memuat data resep...'),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== SECTION: INFO RESEP =====
                    _buildSectionHeader('Informasi Resep', Icons.restaurant_menu),
                    const SizedBox(height: 16),

                    // ===== Jenis Waktu =====
                    _buildDropdown<String>(
                      value: _selectedJenisWaktu,
                      label: 'Jenis Waktu',
                      icon: Icons.schedule_outlined,
                      items: _jenisWaktu.map((jenis) => DropdownMenuItem<String>(
                        value: jenis,
                        child: Text(jenis),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedJenisWaktu = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // ===== IMAGE PICKER SECTION =====
                    _buildImagePicker(),
                    const SizedBox(height: 16),

                    _buildTextFormField(
                      controller: _namaController,
                      label: 'Nama Masakan',
                      hint: 'Masukkan nama masakan',
                      icon: Icons.fastfood,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama masakan wajib diisi';
                        }
                        if (value.trim().length < 3) {
                          return 'Nama masakan minimal 3 karakter';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                      // ===== FIXED: Kategori Full Width =====
              _buildDropdown<int>(
                value: _selectedKategori,
                label: 'Kategori',
                icon: Icons.category,
                items: _categories.map((cat) => DropdownMenuItem<int>(
                  value: cat['id'],
                  child: Text(cat['name']),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedKategori = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

                    // ===== Kesulitan =====
                    _buildDropdown<String>(
                      value: _selectedDifficulty,
                      label: 'Tingkat Kesulitan',
                      icon: Icons.star,
                      items: _difficulties.map((diff) => DropdownMenuItem<String>(
                        value: diff,
                        child: Text(diff),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDifficulty = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // ===== Waktu Memasak =====
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildTextFormField(
                            controller: _waktuController,
                            label: 'Waktu Memasak',
                            hint: 'contoh: 30',
                            icon: Icons.timer,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Waktu memasak wajib diisi';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Masukkan angka yang valid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _buildDropdown<String>(
                            value: _selectedTimeType,
                            label: 'Satuan Waktu',
                            icon: Icons.schedule,
                            items: _timeTypes.map((type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            )).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedTimeType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildTextFormField(
                      controller: _bahanUtamaController,
                      label: 'Bahan Utama',
                      hint: 'contoh: Ayam, Daging Sapi, Tahu',
                      icon: Icons.grass,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Bahan utama wajib diisi';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildTextFormField(
                      controller: _deskripsiController,
                      label: 'Deskripsi',
                      hint: 'Ceritakan tentang masakan ini...',
                      icon: Icons.description,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Deskripsi wajib diisi';
                        }
                        if (value.trim().length < 10) {
                          return 'Deskripsi minimal 10 karakter';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildTextFormField(
                      controller: _videoController,
                      label: 'Link Video (Opsional)',
                      hint: 'https://youtube.com/watch?v=...',
                      icon: Icons.video_library,
                      keyboardType: TextInputType.url,
                    ),

                    const SizedBox(height: 32),

                    // ===== SECTION: LANGKAH-LANGKAH =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('Langkah-langkah', Icons.list_alt),
                        ElevatedButton.icon(
                          onPressed: _addLangkah,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Tambah'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // List langkah-langkah
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _langkahList.length,
                      onReorder: _reorderLangkah,
                      itemBuilder: (context, index) {
                        final langkah = _langkahList[index];
                        return _buildLangkahCard(langkah, index);
                      },
                    ),

                    const SizedBox(height: 32),

                    // Tombol Submit
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Menyimpan...'),
                          ],
                        )
                            : const Text(
                          'UPDATE RESEP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ===== IMAGE PICKER WIDGET =====
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.image, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Gambar Masakan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImageFromGallery,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: (_selectedImage != null || _currentImageUrl != null) 
                    ? Colors.orange 
                    : Colors.grey.shade300,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: _selectedImage != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  )
                : _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _currentImageUrl!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pilih Gambar Masakan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ketuk untuk memilih dari galeri',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.orange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.orange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildLangkahCard(LangkahResepInput langkah, int index) {
    return Card(
      key: ValueKey(langkah.urutan),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  radius: 16,
                  child: Text(
                    '${langkah.urutan}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Langkah ${langkah.urutan}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_langkahList.length > 1)
                  IconButton(
                    onPressed: () => _removeLangkah(index),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Hapus langkah',
                  ),
                const Icon(Icons.drag_handle, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: langkah.judulController,
              decoration: InputDecoration(
                labelText: 'Judul Langkah',
                hintText: 'contoh: Siapkan bahan-bahan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: langkah.deskripsiController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Deskripsi Langkah',
                hintText: 'Jelaskan secara detail langkah ini...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class untuk input langkah resep
class LangkahResepInput {
  int urutan;
  final TextEditingController judulController;
  final TextEditingController deskripsiController;

  LangkahResepInput({required this.urutan})
      : judulController = TextEditingController(),
        deskripsiController = TextEditingController();

  void dispose() {
    judulController.dispose();
    deskripsiController.dispose();
  }
}