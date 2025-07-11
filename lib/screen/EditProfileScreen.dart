// lib/screen/EditProfileScreen.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../service/ProfileService.dart';
import '../util/user_sessions.dart';
import '../util/ProfileSession.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  File? _selectedImage;
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _isLoadingData = true;
  
  // Variabel untuk menyimpan data profil dari server
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _bioController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoadingData = true);
      
      // Ambil user_id dari UserSession
      final currentUser = UserSession.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User session tidak ditemukan');
      }

      final userId = currentUser['id'];
      if (userId == null) {
        throw Exception('User ID tidak ditemukan dalam session');
      }

      debugPrint('📦 [EditProfile] Loading profile for user_id: $userId');

      // Fetch data profil dari server berdasarkan user_id
    final profileData = await ProfilService.fetchProfileByUserId(userId);
      
      if (profileData == null) {
        // Jika profil belum ada, biarkan form kosong untuk pembuatan profil baru
        debugPrint('📦 [EditProfile] No profile found, creating new profile');
        _profileData = null;
        _namaController.text = '';
        _bioController.text = '';
        _currentImageUrl = null;
      } else {
        // Jika profil sudah ada, load data ke form
        debugPrint('📦 [EditProfile] Profile loaded: $profileData');
        _profileData = profileData;
        _namaController.text = profileData['nama_lengkap'] ?? '';
        _bioController.text = profileData['bio'] ?? '';
        _currentImageUrl = profileData['foto'];

        // Update ProfileSession dengan data terbaru dari server
        ProfileSession.instance.setProfile(profileData);
      }

    } catch (e) {
      debugPrint('❌ Gagal memuat data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data profil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = UserSession.instance.currentUser;
      
      if (currentUser == null) {
        throw Exception('User session tidak ditemukan.');
      }

      final userId = currentUser['id'];
      if (userId == null) {
        throw Exception('User ID tidak ditemukan dalam session');
      }

      final profileData = <String, dynamic>{
        'user_id': userId,
        'nama_lengkap': _namaController.text.trim(),
        'bio': _bioController.text.trim(),
      };

      // Jika ini adalah update (profil sudah ada), sertakan id profil
      if (_profileData != null && _profileData!['id'] != null) {
        profileData['id'] = _profileData!['id'];
      }

      // Handle image upload
      if (_selectedImage != null) {
        final fileName = _selectedImage!.path.split('/').last;
        final bytes = await _selectedImage!.readAsBytes();
        final base64Image = base64Encode(bytes);

        profileData['foto'] = fileName;
        profileData['foto_base64'] = base64Image;
      }

      debugPrint('📤 [Profile Update] Sending data: $profileData');

      final response = await ProfilService.updateProfile(profileData);
      debugPrint('📥 [Profile Update] Response: $response');

      if (response == null) {
        throw Exception('Tidak ada respons dari server');
      }

      final isResponseFull = response.containsKey('nama_lengkap') && response.containsKey('bio');
      final isSuccess = response['success'] == true ||
          response['success'] == 'true' ||
          (response['message'] is String &&
              RegExp(r'berhasil', caseSensitive: false).hasMatch(response['message']));

      if (!isResponseFull && !isSuccess) {
        throw Exception(response['message'] ?? 'Gagal memperbarui profil');
      }

      // Perbarui data profil lokal
      final updatedProfileData = <String, dynamic>{
        'id': response['id'] ?? _profileData?['id'],
        'user_id': userId,
        'nama_lengkap': _namaController.text.trim(),
        'bio': _bioController.text.trim(),
      };

      if (_selectedImage != null) {
        updatedProfileData['foto'] = _selectedImage!.path.split('/').last;
      } else if (response.containsKey('foto')) {
        updatedProfileData['foto'] = response['foto'];
      } else {
        updatedProfileData['foto'] = _currentImageUrl;
      }

      // Update ProfileSession dengan data yang baru
      ProfileSession.instance.setProfile(updatedProfileData);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error update profil: $e');
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
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_profileData == null ? 'Buat Profil' : 'Edit Profil'),
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
                  Text('Memuat data profil...'),
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
                    // ===== SECTION: FOTO PROFIL =====
                    _buildSectionHeader('Foto Profil', Icons.person),
                    const SizedBox(height: 16),
                    _buildImagePicker(),
                    const SizedBox(height: 32),

                    // ===== SECTION: INFORMASI =====
                    _buildSectionHeader('Informasi Profil', Icons.info),
                    const SizedBox(height: 16),

                    _buildTextFormField(
                      controller: _namaController,
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama lengkap wajib diisi';
                        }
                        if (value.trim().length < 2) {
                          return 'Nama minimal 2 karakter';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildTextFormField(
                      controller: _bioController,
                      label: 'Bio',
                      hint: 'Tulis sesuatu tentang dirimu',
                      icon: Icons.info_outline,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Bio tidak boleh kosong';
                        }
                        return null;
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
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Menyimpan...'),
                                ],
                              )
                            : Text(
                                _profileData == null ? 'BUAT PROFIL' : 'UPDATE PROFIL',
                                style: const TextStyle(
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
    return Center(
      child: GestureDetector(
        onTap: _pickImageFromGallery,
        child: Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.orange,
                  width: 3,
                ),
                color: Colors.grey.shade50,
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.file(
                        _selectedImage!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    )
                  : _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.network(
                            _currentImageUrl!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey.shade400,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey.shade400,
                        ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
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
            fontSize: 18,
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
}