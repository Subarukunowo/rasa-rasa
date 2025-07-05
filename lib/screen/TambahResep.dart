// lib/service/TambahResep.dart
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../service/LangkahResepervice.dart';
import '../service/ResepService.dart';
import 'dart:io';
import 'dart:convert';
import '../screen/auth/ResepSuccessScreen.dart';

class TambahResep extends StatefulWidget {
  const TambahResep({Key? key}) : super(key: key);

  @override
  State<TambahResep> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<TambahResep> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Controllers untuk data resep
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _bahanUtamaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _waktuController = TextEditingController();
  final TextEditingController _videoController = TextEditingController();

  // Data resep
  int _selectedKategori = 1;
  String _selectedDifficulty = 'Mudah';
  String _selectedTimeType = 'Menit';
  String _selectedJenisWaktu = 'Sarapan';

  // List untuk langkah-langkah
  List<LangkahResepInput> _langkahList = [
    LangkahResepInput(urutan: 1),
  ];

  File? _selectedImage;
  bool _isLoading = false;

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
  void dispose() {
    _namaController.dispose();
    _bahanUtamaController.dispose();
    _deskripsiController.dispose();
    _waktuController.dispose();
    _videoController.dispose();
    _scrollController.dispose();

    for (var langkah in _langkahList) {
      langkah.dispose();
    }

    super.dispose();
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

  if (_selectedImage == null) {
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
    final bytes = await _selectedImage!.readAsBytes();
    final base64Image = "data:image/jpeg;base64,${base64Encode(bytes)}";

    int waktuMasak = int.tryParse(_waktuController.text) ?? -1;
    if (waktuMasak <= 0) throw Exception('Waktu memasak tidak valid');

    // ⛔️ Tidak diubah
    final langkahData = _langkahList.map((langkah) => {
      'judul': langkah.judulController.text.trim(),
      'deskripsi': langkah.deskripsiController.text.trim(),
    }).toList();

    final resepData = {
      'user_id': 1,
      'nama_masakan': _namaController.text.trim(),
      'kategori_id': _selectedKategori,
      'waktu_memasak': waktuMasak,
      'bahan_utama': _bahanUtamaController.text.trim(),
      'deskripsi': _deskripsiController.text.trim(),
      'level_kesulitan': _selectedDifficulty,
      'jenis_waktu': _selectedJenisWaktu,
      'satuan_waktu': _selectedTimeType,
      'video': _videoController.text.trim().isEmpty
          ? null
          : _videoController.text.trim(),
      'gambar': base64Image,
      'langkah': langkahData,
    };

    final resepResponse = await ResepService.createResep(resepData);

    bool isSuccess = resepResponse is Map &&
        (resepResponse['success'] == true ||
         resepResponse['success'] == 'true' ||
         (resepResponse['message'] is String &&
          RegExp(r'berhasil', caseSensitive: false).hasMatch(resepResponse['message'])));

    if (!isSuccess) {
      throw Exception(
        resepResponse is Map
            ? (resepResponse['message'] ?? 'Respon tidak valid')
            : 'Gagal membuat resep',
      );
    }

    // ✅ Navigasi ke halaman sukses
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResepSuccessScreen(
            namaResep: _namaController.text.trim(),
            levelKesulitan: _selectedDifficulty,
            gambarPath: _selectedImage!.path,
          ),
        ),
      );
    }
  } catch (e, stackTrace) {
    debugPrint('❌ Error saat submit: $e');
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
        title: const Text('Tambah Resep'),
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
              onPressed: _submitForm,
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
      body: Form(
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

              // ===== NEW: Jenis Waktu =====
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

              // ===== NEW: IMAGE PICKER SECTION =====
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

              // ===== FIXED: Kesulitan Full Width =====
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

              // ===== FIXED: Waktu Memasak Row with better spacing =====
              Row(
                children: [
                  Expanded(
                    flex: 3, // More space for number input
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
                    flex: 2, // Less space for dropdown
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
                    'SIMPAN RESEP',
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

  // ===== NEW: IMAGE PICKER WIDGET =====
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
                color: _selectedImage == null ? Colors.grey.shade300 : Colors.orange,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: _selectedImage == null
                ? Column(
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
            )
                : Stack(
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
      isExpanded: true, // FIXED: Prevent overflow
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