import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List menus = [];
  bool isLoading = true;
  String userName = "Guest";

  @override
  void initState() {
    super.initState();
    fetchMenus();
  }

  Future<void> fetchMenus() async {
    // Ambil token dari penyimpanan HP
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse('[http://10.0.2.2:8000/api/menus](http://10.0.2.2:8000/api/menus)');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Tunjukkan token ke Laravel
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        setState(() {
          menus = responseData['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat menu dari server')),
      );
      setState(() => isLoading = false);
    }
  }

  // Fungsi Logout
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Hapus token

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Menu Technoir', style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: logout,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.cyan))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: menus.length,
              itemBuilder: (context, index) {
                final menu = menus[index];
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        // Gambar Menu
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: menu['image'] != null
                              ? Image.network(
                                  menu['image'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                                )
                              : _buildPlaceholder(),
                        ),
                        const SizedBox(width: 16),
                        // Detail Menu
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                menu['name'],
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                menu['category']['name'] ?? 'Kategori',
                                style: const TextStyle(color: Colors.cyan, fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Rp ${menu['price']}',
                                style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[800],
      child: const Icon(Icons.fastfood, color: Colors.grey),
    );
  }
}
