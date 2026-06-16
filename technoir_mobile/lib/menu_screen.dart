import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'user_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final int _selectedIndex = 2; // Index 2 untuk halaman Menu

  // Warna Utama
  final Color _primaryOrange = const Color(0xFFFE8C00);

  List menus = [];
  List filteredMenus = [];
  List<String> categories = ['All'];
  String selectedCategory = 'All';
  bool isLoading = true;

  Set<int> favoriteMenuIds = {};

  @override
  void initState() {
    super.initState();
    fetchMenus();
    fetchFavorites();
  }

  // --- AMBIL DATA FAVORIT ---
  Future<void> fetchFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse('http://192.168.18.12:8000/api/favorites');

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
          favoriteMenuIds = favs.map<int>((f) => f['id'] as int).toSet();
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat favorit: $e');
    }
  }

  // --- KLIK BINTANG (FAVORIT) ---
  Future<void> toggleFavorite(int menuId) async {
    bool isAlreadyFavorite = favoriteMenuIds.contains(menuId);

    // Optimistic UI Update: Langsung ubah di layar agar instan pindah ke atas!
    setState(() {
      if (isAlreadyFavorite) {
        favoriteMenuIds.remove(menuId);
      } else {
        favoriteMenuIds.add(menuId);
      }
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final url = Uri.parse('http://192.168.18.12:8000/api/favorites/toggle');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {'menu_id': menuId.toString()},
      );

      final responseData = json.decode(response.body);

      if (response.statusCode != 200 || responseData['success'] != true) {
        // Jika gagal di server, kembalikan state
        setState(() {
          if (isAlreadyFavorite) {
            favoriteMenuIds.add(menuId);
          } else {
            favoriteMenuIds.remove(menuId);
          }
        });
      }
    } catch (e) {
      // Revert state jika error jaringan
      setState(() {
        if (isAlreadyFavorite) {
          favoriteMenuIds.add(menuId);
        } else {
          favoriteMenuIds.remove(menuId);
        }
      });
    }
  }

  // --- AMBIL DATA MENU ---
  Future<void> fetchMenus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse('http://192.168.18.12:8000/api/menus');

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
      setState(() => isLoading = false);
    }
  }

  void filterMenu(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'All') {
        filteredMenus = menus;
      } else {
        filteredMenus = menus
            .where(
              (menu) =>
                  menu['category'] != null &&
                  menu['category']['name'] == category,
            )
            .toList();
      }
    });
  }

  void searchMenu(String query) {
    setState(() {
      if (selectedCategory == 'All') {
        filteredMenus = menus
            .where(
              (m) => m['name'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      } else {
        filteredMenus = menus
            .where(
              (m) =>
                  m['category'] != null &&
                  m['category']['name'] == selectedCategory,
            )
            .where(
              (m) => m['name'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      );
    } else if (index == 2) {
      // Tetap di MenuScreen
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Memisahkan menu favorit dan menu biasa secara dinamis
    List favoriteMenus = filteredMenus
        .where((m) => favoriteMenuIds.contains(m['id']))
        .toList();
    List regularMenus = filteredMenus
        .where((m) => !favoriteMenuIds.contains(m['id']))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrangeHeader(),
          _buildCategoryFilter(),

          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(color: _primaryOrange),
                  )
                : filteredMenus.isEmpty
                ? const Center(
                    child: Text(
                      "Menu tidak ditemukan.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BAGIAN FAVORIT (Otomatis naik ke sini jika bintang diklik)
                        if (favoriteMenus.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.only(
                              left: 20,
                              top: 10,
                              bottom: 16,
                            ),
                            child: Text(
                              'Your Favourite',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF373B4D),
                              ),
                            ),
                          ),
                          _buildMenuGrid(favoriteMenus),
                          const SizedBox(height: 10),
                        ],

                        // BAGIAN SEMUA MENU / BUNDLE
                        if (regularMenus.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              top: 10,
                              bottom: 16,
                            ),
                            child: Text(
                              selectedCategory == 'All'
                                  ? 'Bundle'
                                  : selectedCategory,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF373B4D),
                              ),
                            ),
                          ),
                          _buildMenuGrid(regularMenus),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- HEADER ORANYE ---
  Widget _buildOrangeHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        bottom: 25,
      ),
      decoration: BoxDecoration(
        color: _primaryOrange,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Logo di Tengah
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'T',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF5D1D20),
                    ),
                  ),
                  Icon(Icons.wine_bar, size: 28, color: Color(0xFF5D1D20)),
                  Text(
                    'B',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF5D1D20),
                    ),
                  ),
                ],
              ),
              // Bell di Kanan
              Align(
                alignment: Alignment.centerRight,
                child: Container(padding: const EdgeInsets.all(8)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Search Bar Full Width (Karena Cart Dihapus)
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white70, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 20,
                  color: Colors.white70,
                ), // Garis pemisah vertical
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.white70, fontSize: 16),
                      border: InputBorder.none,
                    ),
                    onChanged: searchMenu,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- KOMPONEN FILTER KATEGORI ---
  Widget _buildCategoryFilter() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(top: 20, bottom: 10),
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF373B4D) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : Border.all(color: Colors.grey.shade300),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
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
  Widget _buildMenuGrid(List menuList) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio:
            0.9, // Diperbarui agar lebih proporsional setelah tombol "+" dihapus
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: menuList.length,
      itemBuilder: (context, index) {
        final menu = menuList[index];
        return _buildMenuCard(menu);
      },
    );
  }

  // --- KARTU MENU ---
  Widget _buildMenuCard(Map<String, dynamic> menu) {
    bool isFav = favoriteMenuIds.contains(menu['id']);

    String? imageUrl = menu['image'];
    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        !imageUrl.startsWith('http')) {
      imageUrl = 'http://192.168.18.12:8000/storage/$imageUrl';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => _placeholderImg(),
                    )
                  : _placeholderImg(),
            ),
          ),

          // Info & Tombol Bintang (TIDAK ADA TOMBOL KERANJANG LAGI)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        menu['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp. ${menu['price']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol Bintang (Favorit)
                GestureDetector(
                  onTap: () => toggleFavorite(menu['id']),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isFav ? _primaryOrange : Colors.white,
                      shape: BoxShape.circle,
                      border: isFav
                          ? null
                          : Border.all(color: Colors.grey.shade300),
                    ),
                    child: Icon(
                      Icons.star,
                      color: isFav ? Colors.white : Colors.grey[400],
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImg() {
    return Container(
      width: double.infinity,
      color: Colors.grey[200],
      child: const Icon(Icons.fastfood, color: Colors.grey, size: 40),
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
              _buildNavItem(Icons.explore, 'Explore', 0),
              _buildNavItem(Icons.calendar_today_outlined, 'Reservation', 1),
              _buildNavItem(Icons.restaurant_menu, 'Menu', 2),
              _buildNavItem(Icons.person_outline, 'Profile', 3),
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
            color: isSelected ? _primaryOrange : Colors.grey[400],
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? _primaryOrange : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
