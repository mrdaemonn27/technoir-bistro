import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'menu_screen.dart';
import 'cart_screen.dart';
import 'user_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _selectedIndex = 0;
  String _userName = 'User';
  String? _profileImage;

  // --- VARIABEL DATA DINAMIS ---
  List<dynamic> _bestSellingDishes = [];
  bool _isLoadingMenus = true;

  List<Map<String, dynamic>> _bestChefs = [];
  bool _isLoadingChefs = true;

  // Warna utama sesuai gambar
  final Color _primaryOrange = const Color(0xFFFE8C00);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchMenus(); // Ambil menu dari database Laravel
    _fetchChefs(); // Ambil koki (Siap untuk API)
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('username') ?? 'Guest';
      
      // --- PERBAIKAN: Ganti 'profile_image' menjadi 'avatar' agar sama dengan UserScreen ---
      _profileImage = prefs.getString('avatar'); 
    });
  }

  // --- MENGAMBIL MENU DARI DATABASE LARAVEL ---
  Future<void> _fetchMenus() async {
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
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _bestSellingDishes = data['data'];
          _isLoadingMenus = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingMenus = false);
    }
  }

  // --- MENGAMBIL DATA KOKI (KERANGKA API DINAMIS) ---
  Future<void> _fetchChefs() async {
    // Saat ini menggunakan data dummy,
    // Nanti tinggal diganti dengan http.get() ke /api/chefs
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _bestChefs = [
        {
          'name': 'Chef Renatta',
          'image':
              'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
        },
        {
          'name': 'Chef Arnold',
          'image':
              'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
        },
        {
          'name': 'Chef Gordon',
          'image':
              'https://images.unsplash.com/photo-1607631568010-a87245c0daf8?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
        },
      ];
      _isLoadingChefs = false;
    });
  }

  // --- FUNGSI UNTUK MEMBUKA GOOGLE MAPS ---
  Future<void> _launchMaps() async {
    // Menggunakan link lokasi baru dari Anda
    final Uri googleMapsUrl = Uri.parse(
      'https://maps.app.goo.gl/6aA4zTsMVh1EgrCt5',
    );
    try {
      // LaunchMode.externalApplication memastikan link dibuka di dalam aplikasi Google Maps (bukan di browser)
      if (!await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrangeHeader(),
            const SizedBox(height: 24),
            _buildSectionHeader('Best selling dish'),
            _buildBestSellingDishes(),
            const SizedBox(height: 25),
            _buildSectionHeader('Our Best Chefs'),
            _buildBestChefs(),
            const SizedBox(height: 25),
            _buildSectionHeader('Location and Navigation'),
            _buildMapSection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- KOMPONEN HEADER ORANYE (DESAIN BARU) ---
  Widget _buildOrangeHeader() {
    // --- LOGIKA URL FOTO PROFIL ANTI-CACHE & URL ENCODING ---
    String encodedName = Uri.encodeComponent(_userName);
    String avatarUrl =
        'https://ui-avatars.com/api/?name=$encodedName&background=random&format=png';

    if (_profileImage != null && _profileImage!.isNotEmpty) {
      if (_profileImage!.startsWith('http')) {
        avatarUrl = '$_profileImage?v=${DateTime.now().millisecondsSinceEpoch}';
      } else {
        avatarUrl =
            'http://192.168.18.12:8000/storage/$_profileImage?v=${DateTime.now().millisecondsSinceEpoch}';
      }
    }

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 30,
      ),
      decoration: BoxDecoration(
        color: _primaryOrange,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Image.network(
                      avatarUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 48,
                          height: 48,
                          color: Colors.white24,
                          child: const Icon(Icons.person, color: Colors.white),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $_userName!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Check Our Amazing Menus...',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              // --- Ikon lonceng dengan GestureDetector ---
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          // Kolom Pencarian Transparan
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white70, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Container(
                  width: 1,
                  height: 20,
                  color: Colors.white70,
                ), // Garis pemisah
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: Colors.white70, fontSize: 15),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onSubmitted: (value) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MenuScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HEADER SEKSI ---
  Widget _buildSectionHeader(String title, {bool showSeeAll = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (showSeeAll)
            Row(
              children: [
                Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _primaryOrange,
                  ),
                ),
                Icon(Icons.arrow_right, color: _primaryOrange, size: 18),
              ],
            ),
        ],
      ),
    );
  }

  // --- LIST "BEST SELLING DISH" (DATA DINAMIS) ---
  Widget _buildBestSellingDishes() {
    if (_isLoadingMenus) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_bestSellingDishes.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text("Belum ada menu tersedia.")),
      );
    }

    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
        itemCount: _bestSellingDishes.length > 5
            ? 5
            : _bestSellingDishes.length, // Tampilkan maksimal 5
        itemBuilder: (context, index) {
          final menu = _bestSellingDishes[index];

          // --- LOGIKA PINTAR UNTUK GAMBAR ---
          String? imageUrl = menu['image'];
          // Jika URL gambar tidak kosong dan BUKAN diawali 'http' (berarti gambar lokal hasil upload admin)
          if (imageUrl != null &&
              imageUrl.isNotEmpty &&
              !imageUrl.startsWith('http')) {
            // Gabungkan dengan alamat localhost
            imageUrl = 'http://192.168.18.12:8000/storage/$imageUrl';
          }

          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            height: 110,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.fastfood,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          height: 110,
                          color: Colors.grey[200],
                          child: const Icon(Icons.fastfood, color: Colors.grey),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    menu['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- LIST "OUR BEST CHEFS" (DATA DINAMIS SIAP API) ---
  Widget _buildBestChefs() {
    if (_isLoadingChefs) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 110,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _bestChefs.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage: NetworkImage(_bestChefs[index]['image']),
                ),
                const SizedBox(height: 8),
                Text(
                  _bestChefs[index]['name'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- BAGIAN "LOCATION AND NAVIGATION" ---
  Widget _buildMapSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Gambar Peta Placeholder
            Image.network(
              'https://images.unsplash.com/photo-1524661135-423995f22d0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              height: 200,
              color: Colors.black.withOpacity(0.05),
            ), // Filter redup
            // Overlay Card Info Restoran
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Gambar Restoran Kecil
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Detail Alamat
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '10.00 - 22.00',
                            style: TextStyle(
                              color: _primaryOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Technoir Bistro',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 12,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  'Jl. Bojong Santos No.1',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Tombol Navigasi Oranye
                    GestureDetector(
                      onTap: _launchMaps,
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          color: _primaryOrange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.near_me,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- KOMPONEN BOTTOM NAVIGATION BAR ---
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 20,
            offset: Offset(0, -5),
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
      onTap: () {
        if (index == 0) {
          // Tetap di Home (Explore)
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CartScreen()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MenuScreen()),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserScreen()),
          );
        }
      },
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