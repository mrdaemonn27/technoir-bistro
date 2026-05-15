import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'cart_screen.dart'; // <-- 1. TAMBAHKAN IMPORT INI
import 'user_screen.dart'; // <-- TAMBAHKAN IMPORT USER

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int _selectedIndex = 1; // 1 karena ini halaman Menu
  List menus = [];
  List filteredMenus = [];
  List<String> categories = ['All'];
  String selectedCategory = 'All';
  bool isLoading = true;
  Set<int> favoriteMenuIds = {}; // <-- TAMBAHKAN VARIABEL STATE INI

  @override
  void initState() {
    super.initState();
    fetchMenus();
    fetchFavorites(); // <-- PANGGIL FUNGSI FAVORIT SAAT HALAMAN DIBUKA
  }

  // --- TAMBAHKAN FUNGSI UNTUK MENGAMBIL DATA FAVORIT AWAL ---
  Future<void> fetchFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse('http://10.0.2.2:8000/api/favorites');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        setState(() {
          List favs = responseData['data'];
          // Simpan ID menu yang difavoritkan ke dalam Set agar mudah dicek
          favoriteMenuIds = favs.map<int>((f) => f['menu_id'] as int).toSet();
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat favorit: $e');
    }
  }

  // --- TAMBAHKAN FUNGSI UNTUK TOMBOL LOVE DITEKAN ---
  Future<void> toggleFavorite(int menuId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse('http://10.0.2.2:8000/api/favorites/toggle');

    // PERBAIKAN: Cek status favorit saat ini di aplikasi sebelum mengirim request
    bool isAlreadyFavorite = favoriteMenuIds.contains(menuId);

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {
          'menu_id': menuId.toString(),
        }
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        setState(() {
          // Logika toggle yang lebih aman:
          // Jika sebelumnya sudah favorit, berarti diklik untuk dihapus. Jika belum, berarti ditambah.
          if (isAlreadyFavorite) {
            favoriteMenuIds.remove(menuId);
          } else {
            favoriteMenuIds.add(menuId);
          }
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!isAlreadyFavorite ? 'Disimpan ke Favorit ❤️' : 'Dihapus dari Favorit 💔'), 
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengubah favorit'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> fetchMenus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse('http://10.0.2.2:8000/api/menus');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        setState(() {
          menus = responseData['data'];
          filteredMenus = menus;
          
          // Ekstrak kategori unik dari data menu untuk Filter
          Set<String> uniqueCategories = {};
          for (var menu in menus) {
            if (menu['category'] != null) {
              uniqueCategories.add(menu['category']['name']);
            }
          }
          categories.addAll(uniqueCategories);
          
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat menu dari server'), backgroundColor: Colors.red),
      );
      setState(() => isLoading = false);
    }
  }

  void filterMenu(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'All') {
        filteredMenus = menus;
      } else {
        filteredMenus = menus.where((menu) => menu['category'] != null && menu['category']['name'] == category).toList();
      }
    });
  }

  // --- 2. TAMBAHKAN FUNGSI INI UNTUK MEMASUKKAN MENU KE KERANJANG ---
  Future<void> addToCart(Map<String, dynamic> menu) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cartString = prefs.getString('cart');
    List<dynamic> cartItems = cartString != null ? json.decode(cartString) : [];

    // Cek apakah item sudah ada di keranjang
    int existingIndex = cartItems.indexWhere((item) => item['id'] == menu['id']);
    
    if (existingIndex >= 0) {
      cartItems[existingIndex]['quantity'] += 1;
    } else {
      cartItems.add({
        'id': menu['id'],
        'name': menu['name'],
        'price': menu['price'],
        'image': menu['image'],
        'quantity': 1,
      });
    }

    await prefs.setString('cart', json.encode(cartItems));
    
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${menu['name']} ditambahkan ke keranjang!'), duration: const Duration(seconds: 1)),
    );
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data sesi

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      // Kembali ke Home
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else if (index == 1) {
      // Tetap di halaman ini
    } else if (index == 2) {
      // --- 3. TAMBAHKAN NAVIGASI KE HALAMAN KERANJANG ---
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CartScreen()));
    } else if (index == 3) {
      // --- TAMBAHKAN NAVIGASI KE HALAMAN USER ---
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const UserScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        automaticallyImplyLeading: false, // Sembunyikan tombol back default
        title: const Text(
          'Our Menu',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: logout,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF282A45)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                _buildCategoryFilter(),
                Expanded(
                  child: _buildMenuGrid(),
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- KOMPONEN PENCARIAN ---
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search food...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  // Fitur pencarian sederhana
                  setState(() {
                    filteredMenus = menus
                        .where((m) => m['name'].toString().toLowerCase().contains(value.toLowerCase()))
                        .toList();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- KOMPONEN FILTER KATEGORI ---
  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          
          return GestureDetector(
            onTap: () => filterMenu(category),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF282A45) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isSelected) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2)),
                ],
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- KOMPONEN GRID MENU ---
  Widget _buildMenuGrid() {
    if (filteredMenus.isEmpty) {
      return const Center(child: Text("Menu tidak ditemukan.", style: TextStyle(color: Colors.grey)));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 kolom
        childAspectRatio: 0.75, // Rasio tinggi vs lebar kartu
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredMenus.length,
      itemBuilder: (context, index) {
        final menu = filteredMenus[index];
        return _buildMenuCard(menu);
      },
    );
  }

  Widget _buildMenuCard(Map<String, dynamic> menu) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Menu
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: menu['image'] != null
                        ? Image.network(
                            menu['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, color: Colors.grey, size: 40),
                          )
                        : const Icon(Icons.fastfood, color: Colors.grey, size: 40),
                  ),
                  // Rating Badge (Opsional, pakai dummy dulu)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: const [
                          Icon(Icons.star, size: 12, color: Colors.amber),
                          SizedBox(width: 4),
                          Text('4.5', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Info Menu
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  menu['category'] != null ? menu['category']['name'] : 'Kategori',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp ${menu['price']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                    ),
                    // --- BUNGKUS TOMBOL DENGAN ROW AGAR ADA TOMBOL FAVORIT & ADD ---
                    Row(
                      children: [
                        // Tombol Favorit (Love/Heart)
                        GestureDetector(
                          onTap: () => toggleFavorite(menu['id']),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: favoriteMenuIds.contains(menu['id']) ? Colors.red[50] : Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              favoriteMenuIds.contains(menu['id']) ? Icons.favorite : Icons.favorite_border,
                              color: favoriteMenuIds.contains(menu['id']) ? Colors.red : Colors.grey[400],
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Tombol Add to Cart
                        GestureDetector(
                          onTap: () => addToCart(menu),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF282A45),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN BOTTOM NAVIGATION BAR ---
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_filled, 'Home', 0),
              _buildNavItem(Icons.restaurant_menu, 'Menu', 1),
              _buildNavItem(Icons.shopping_cart_outlined, 'Cart', 2),
              _buildNavItem(Icons.person_outline, 'User', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF2C74B3) : Colors.grey[500],
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF2C74B3) : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}