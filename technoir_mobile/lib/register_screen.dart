import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController(); // Tambahan untuk UI
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Warna utama sesuai desain
  final Color _primaryOrange = const Color(0xFFF68B29);
  final Color _darkText = const Color(0xFF1C1C28);

  Future<void> prosesRegister() async {
    // Validasi kosong
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua kolom harus diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validasi password match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password dan Konfirmasi Password tidak cocok!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse('http://10.0.2.2:8000/api/register');

    try {
      final response = await http
          .post(
            url,
            headers: {'Accept': 'application/json'},
            body: {
              'username': _usernameController.text,
              'email': _emailController.text,
              'password': _passwordController.text,
            },
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        await prefs.setString('token', data['token']);
        await prefs.setString('username', data['user']['username']);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi Berhasil!'),
            backgroundColor: Colors.green,
          ),
        );

        if (!mounted) return;
        // Pindah ke HomeScreen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Gagal mendaftar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Detail Error: $e'),
          backgroundColor: Colors.red,
        ),
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. HEADER MELENGKUNG DENGAN LOGO ---
            _buildHeader(),

            // --- 2. FORM REGISTER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Sign up',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _darkText,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Kolom Full Name
                  _buildTextField(
                    controller: _usernameController,
                    hintText: 'Full name',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  // Kolom Email
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'abc@email.com',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  // Kolom Password
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Your password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isVisible: _isPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    }
                  ),
                  const SizedBox(height: 20),

                  // Kolom Confirm Password
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isVisible: _isConfirmPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    }
                  ),
                  const SizedBox(height: 40),

                  // Tombol SIGN UP
                  _buildSignUpButton(),

                  const SizedBox(height: 40),
                ],
              ),
            ),

            // --- 3. BOTTOM SIGN IN LINK ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                GestureDetector(
                  onTap: () {
                    // Kembali ke halaman Login
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Sign in",
                    style: TextStyle(
                      color: Color(0xFF5A67D8),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HEADER MELENGKUNG ---
  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 280,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFBE4D8), 
                Color(0xFFFFDAB9), 
              ],
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.elliptical(250, 60), 
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // -------------------------------------------------------------
                  // GANTI BAGIAN INI DENGAN LOGO ANDA (Sama seperti login)
                  // Image.asset('assets/logo_technoir.png', height: 80),
                  // -------------------------------------------------------------
                  
                  // Placeholder Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('T', style: TextStyle(fontSize: 50, fontWeight: FontWeight.w900, color: Color(0xFF5D1D20))),
                      Icon(Icons.wine_bar, size: 50, color: _primaryOrange),
                      const Text('B', style: TextStyle(fontSize: 50, fontWeight: FontWeight.w900, color: Color(0xFF5D1D20))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('TECHNOIR', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 3, color: Color(0xFF5D1D20))),
                  const Text('- B I S T R O -', style: TextStyle(fontSize: 12, letterSpacing: 2, color: Color(0xFFF68B29), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
        // Tombol Back Arrow
        Positioned(
          top: 40,
          left: 10,
          child: SafeArea(
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET TEXTFIELD KUSTOM ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityToggle,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isVisible,
        keyboardType: keyboardType,
        style: TextStyle(color: _darkText, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility_off : Icons.visibility_off_outlined,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  // --- WIDGET TOMBOL SIGN UP ---
  Widget _buildSignUpButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: _primaryOrange,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryOrange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isLoading ? null : prosesRegister,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Text(
                          'SIGN UP',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
                if (!_isLoading)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}