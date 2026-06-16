import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // Tambahan untuk File
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // Tambahan untuk ambil gambar

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  File? _imageFile; // Variabel untuk menyimpan foto yang dipilih
  final ImagePicker _picker = ImagePicker();

  // URL Default sementara
  String _currentAvatarUrl =
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80';

  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  Future<void> _loadCurrentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('username') ?? '';
      _emailController.text = prefs.getString('email') ?? '';

      // Ambil avatar dari SharedPreferences jika sudah pernah disimpan
      String? savedAvatar = prefs.getString('avatar');
      if (savedAvatar != null && savedAvatar.isNotEmpty) {
        // Jika format path relatif dari Laravel, tambahkan host URL
        if (!savedAvatar.startsWith('http')) {
          _currentAvatarUrl = 'http://192.168.18.12:8000/storage/$savedAvatar';
        } else {
          _currentAvatarUrl = savedAvatar;
        }
      }
    });
  }

  // --- FUNGSI UNTUK MEMBUKA GALERI ---
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Kompres sedikit agar tidak terlalu berat
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuka galeri'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- FUNGSI UPDATE MENGGUNAKAN MULTIPART REQUEST (Karena ada file foto) ---
  Future<void> _updateProfile() async {
    if (_usernameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username dan Email tidak boleh kosong!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse('http://192.168.18.12:8000/api/profile/update');

    try {
      // Gunakan MultipartRequest karena kita akan mengirim File Gambar
      var request = http.MultipartRequest('POST', url);

      // Tambahkan Headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Tambahkan Teks (Fields)
      request.fields['username'] = _usernameController.text;
      request.fields['email'] = _emailController.text;
      if (_passwordController.text.isNotEmpty) {
        request.fields['password'] = _passwordController.text;
      }

      // Tambahkan Foto (File) jika user memilih foto baru
      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'avatar', // Nama field (key) file yang akan ditangkap oleh Laravel
            _imageFile!.path,
          ),
        );
      }

      // Kirim Request
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
      );
      var response = await http.Response.fromStream(streamedResponse);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await prefs.setString('username', data['user']['username']);
        await prefs.setString('email', data['user']['email']);

        // --- PERBAIKAN: Simpan URL Avatar terbaru ke SharedPreferences ---
        if (data['user']['avatar'] != null) {
          await prefs.setString('avatar', data['user']['avatar']);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );

        // --- PERBAIKAN: Mengirim sinyal 'true' ke halaman sebelumnya ---
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Gagal memperbarui profil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- AVATAR SECTION DENGAN GESTURE DETECTOR ---
            Center(
              child: GestureDetector(
                onTap: _pickImage, // Buka galeri saat foto/ikon kamera diklik
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      // Logika: Jika ada file lokal yang dipilih, tampilkan. Jika tidak, pakai foto online.
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!) as ImageProvider
                          : NetworkImage(_currentAvatarUrl),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C74B3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            _buildTextField(
              label: 'Username',
              icon: Icons.person_outline,
              controller: _usernameController,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              label: 'Email',
              icon: Icons.email_outlined,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              label: 'New Password (Optional)',
              icon: Icons.lock_outline,
              controller: _passwordController,
              obscureText: true,
              hintText: 'Biarkan kosong jika tidak diubah',
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF282A45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                ),
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'SAVE CHANGES',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: Icon(icon, color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF282A45)),
            ),
          ),
        ),
      ],
    );
  }
}
