// lib/screen/EditProfileScreen.dart
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../service/UserService.dart';
import '../util/user_sessions.dart';
import 'dart:io';
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _selectedGender = 'Laki-laki';
  File? _selectedImage;
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _isLoadingData = true;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoadingData = true);

      final currentUser = UserSession.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User session tidak ditemukan');
      }

      _namaController.text = currentUser['nama'] ?? '';
      _usernameController.text = currentUser['username'] ?? '';
      _emailController.text = currentUser['email'] ?? '';
      _noHpController.text = currentUser['no_hp'] ?? '';
      _alamatController.text = currentUser['alamat'] ?? '';
      _selectedGender = currentUser['jenis_kelamin'] ?? 'Laki-laki';
      _currentImageUrl = currentUser['foto_profil'];
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data profil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
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

    if (_passwordController.text.isNotEmpty || _confirmPasswordController.text.isNotEmpty) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password dan konfirmasi password tidak sama'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_passwordController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password minimal 6 karakter'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = UserSession.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User session tidak ditemukan');
      }

      String? base64Image;
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        base64Image = "data:image/jpeg;base64,${base64Encode(bytes)}";
      }

      final profileData = {
        'user_id': currentUser['id'],
        'nama': _namaController.text.trim(),
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'no_hp': _noHpController.text.trim(),
        'alamat': _alamatController.text.trim(),
        'jenis_kelamin': _selectedGender,
      };

      if (_passwordController.text.isNotEmpty) {
        profileData['password'] = _passwordController.text;
      }

      if (base64Image != null) {
        profileData['foto_profil'] = base64Image;
      }

      Map<String, dynamic> response;

      try {
        response = await UserService.updateUser(currentUser['id'], profileData);
      } catch (e) {
        response = await ProfilService.updateProfile(currentUser['id'], profileData);
      }

      bool isSuccess = response['success'] == true ||
          response['success'] == 'true' ||
          (response['message'] is String &&
           RegExp(r'berhasil', caseSensitive: false).hasMatch(response['message']));

      if (!isSuccess) {
        throw Exception(response['message'] ?? 'Gagal mengupdate profil');
      }

      final updatedUserData = Map<String, dynamic>.from(currentUser);
      updatedUserData.addAll({
        'nama': _namaController.text.trim(),
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'no_hp': _noHpController.text.trim(),
        'alamat': _alamatController.text.trim(),
        'jenis_kelamin': _selectedGender,
      });

      if (base64Image != null) {
        updatedUserData['foto_profil'] = base64Image;
      }

      UserSession.instance.setUser(updatedUserData, UserSession.instance.token!);

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
      debugPrint('❌ Error saat update profil: $e');
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
        title: const Text('Edit Profil'),
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

                    // ===== IMAGE PICKER SECTION =====
                    _buildImagePicker(),
                    const SizedBox(height: 32),

                    // ===== SECTION: INFORMASI PRIBADI =====
                    _buildSectionHeader('Informasi Pribadi', Icons.info),
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
                      controller: _usernameController,
                      label: 'Username',
                      hint: 'Masukkan username',
                      icon: Icons.account_circle_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username wajib diisi';
                        }
                        if (value.trim().length < 3) {
                          return 'Username minimal 3 karakter';
                        }
                        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
                          return 'Username hanya boleh huruf, angka, dan underscore';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildTextFormField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'contoh@email.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email wajib diisi';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildTextFormField(
                      controller: _noHpController,
                      label: 'Nomor HP',
                      hint: '08xxxxxxxxxx',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nomor HP wajib diisi';
                        }
                        if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(value.trim())) {
                          return 'Format nomor HP tidak valid';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ===== Jenis Kelamin =====
                    _buildDropdown<String>(
                      value: _selectedGender,
                      label: 'Jenis Kelamin',
                      icon: Icons.wc_outlined,
                      items: _genderOptions.map((gender) => DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildTextFormField(
                      controller: _alamatController,
                      label: 'Alamat',
                      hint: 'Masukkan alamat lengkap',
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Alamat wajib diisi';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // ===== SECTION: UBAH PASSWORD =====
                    _buildSectionHeader('Ubah Password (Opsional)', Icons.lock_outline),
                    const SizedBox(height: 8),
                    Text(
                      'Kosongkan jika tidak ingin mengubah password',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildPasswordFormField(
                      controller: _passwordController,
                      label: 'Password Baru',
                      hint: 'Masukkan password baru',
                      icon: Icons.lock_outline,
                      isVisible: _isPasswordVisible,
                      onToggleVisibility: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildPasswordFormField(
                      controller: _confirmPasswordController,
                      label: 'Konfirmasi Password',
                      hint: 'Ulangi password baru',
                      icon: Icons.lock_outline,
                      isVisible: _isConfirmPasswordVisible,
                      onToggleVisibility: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
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
                                'UPDATE PROFIL',
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

  Widget _buildPasswordFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.orange),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
        ),
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
}