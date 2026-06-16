import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'admin/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false; // Untuk fitur mata (hide/show password)
  bool _rememberMe = true; // Untuk fitur switch button

  // Warna utama sesuai desain
  final Color _primaryOrange = const Color(0xFFF68B29);
  final Color _darkText = const Color(0xFF1C1C28);

  Future<void> prosesLogin() async {
    setState(() => _isLoading = true);

    final url = Uri.parse('http://192.168.18.12:8000/api/login');

    try {
      final response = await http
          .post(
            url,
            headers: {'Accept': 'application/json'},
            body: {
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

        bool isAdmin =
            data['user']['is_admin'] == 1 || data['user']['is_admin'] == true;
        await prefs.setBool('is_admin', isAdmin);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Berhasil!'),
            backgroundColor: Colors.green,
          ),
        );

        if (!mounted) return;

        if (isAdmin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminDashboardScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Login Gagal'),
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
          duration: const Duration(seconds: 5),
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
      backgroundColor: Colors.white, // Background putih bersih
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. HEADER MELENGKUNG DENGAN LOGO ---
            _buildHeader(),

            // --- 2. FORM LOGIN ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _darkText,
                    ),
                  ),
                  const SizedBox(height: 30),

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
                  ),
                  const SizedBox(height: 20),

                  // Switch Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Transform.scale(
                            scale: 0.8, // Mengecilkan sedikit ukuran switch
                            child: Switch(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value;
                                });
                              },
                              activeColor: Colors.white,
                              activeTrackColor: _primaryOrange,
                            ),
                          ),
                          Text(
                            'Remember Me',
                            style: TextStyle(
                              color: _darkText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Fitur Lupa Password
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Tombol SIGN IN
                  _buildSignInButton(),

                  const SizedBox(height: 40),
                ],
              ),
            ),

            // --- 3. BOTTOM SIGN UP LINK ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                      color: Color(
                        0xFF5A67D8,
                      ), // Warna biru keunguan seperti di gambar
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
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
    return Container(
      height: 280,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFBE4D8), // Warna peach sangat muda di atas
            Color(0xFFFFDAB9), // Warna peach/oranye muda di bawah
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.elliptical(
            250,
            60,
          ), // Membuat lengkungan melengkung lembut
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // -------------------------------------------------------------
              // GANTI BAGIAN INI DENGAN LOGO ANDA
              // Jika Anda sudah memasukkan gambar ke folder assets, gunakan:
              // Image.asset('assets/logo_technoir.png', height: 80),
              // -------------------------------------------------------------

              // Placeholder Logo (Sementara)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'T',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF5D1D20),
                    ),
                  ),
                  Icon(Icons.wine_bar, size: 50, color: _primaryOrange),
                  const Text(
                    'B',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF5D1D20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'TECHNOIR',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                  color: Color(0xFF5D1D20),
                ),
              ),
              const Text(
                '- B I S T R O -',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2,
                  color: Color(0xFFF68B29),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET TEXTFIELD KUSTOM ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
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
        obscureText: isPassword && !_isPasswordVisible,
        keyboardType: keyboardType,
        style: TextStyle(color: _darkText, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility_off_outlined,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  // --- WIDGET TOMBOL SIGN IN ---
  Widget _buildSignInButton() {
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
          onTap: _isLoading ? null : prosesLogin,
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
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'SIGN IN',
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
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 14,
                      ),
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
