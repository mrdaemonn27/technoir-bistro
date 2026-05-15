import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'admin_dashboard_screen.dart'; // <-- TAMBAHKAN IMPORT INI

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> prosesLogin() async {
    setState(() => _isLoading = true);

    // IP 10.0.2.2 adalah localhost khusus untuk Emulator Android
    final url = Uri.parse('http://10.0.2.2:8000/api/login');

    try {
      final response = await http.post(
        url,
        headers: {'Accept': 'application/json'},
        body: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      ).timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        // --- 1. Simpan Token dan Username ---
        await prefs.setString('token', data['token']);
        await prefs.setString('username', data['user']['username']); 
        
        // --- 2. CEK & SIMPAN STATUS ADMIN ---
        bool isAdmin = data['user']['is_admin'] == 1 || data['user']['is_admin'] == true;
        await prefs.setBool('is_admin', isAdmin);
        // --------------------------------------------

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Berhasil!'), 
            backgroundColor: Colors.green
          ),
        );

        if (!mounted) return;
        
        // --- 3. PEMBELOKAN ARAH BERDASARKAN ROLE ---
        if (isAdmin) {
          // Jika Admin, pindah ke Dashboard Admin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
          );
        } else {
          // Jika User biasa, pindah ke Home Screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
        // --------------------------------------------

      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Login Gagal'), 
            backgroundColor: Colors.red
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Detail Error: $e'), 
          backgroundColor: Colors.red, 
          duration: const Duration(seconds: 5)
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
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restaurant, size: 80, color: Colors.cyan),
              const SizedBox(height: 20),
              const Text(
                'TECHNOIR BISTRO',
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white
                ),
              ),
              const SizedBox(height: 40),

              // Kolom Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.cyan),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyan)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Kolom Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.cyan),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyan)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Tombol Login
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                  onPressed: _isLoading ? null : prosesLogin,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'LOGIN', 
                          style: TextStyle(
                            color: Colors.black, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 18
                          )
                        ),
                ),
              ),
              
              const SizedBox(height: 20),

              // Tombol Navigasi ke Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Belum punya akun? ", 
                    style: TextStyle(color: Colors.grey)
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen()
                        ),
                      );
                    },
                    child: const Text(
                      "Daftar di sini",
                      style: TextStyle(
                        color: Colors.cyan, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}