import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // <-- TAMBAHKAN IMPORT INI
import 'menu_screen.dart'; 
import 'cart_screen.dart'; 
import 'user_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _selectedIndex = 0; 
  String _userName = 'User'; 
  
  // Warna utama sesuai dengan referensi wireframe
  final Color _primaryOrange = const Color(0xFFFF6B00);

  @override
  void initState() {
    super.initState();
    _loadUserData(); 
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('username') ?? 'Guest';
    });
  }

  // --- FUNGSI UNTUK MEMBUKA GOOGLE MAPS ---
  Future<void> _launchMaps() async {
    // Koordinat lokasi Technoir Bistro (Contoh ini menggunakan Monas Jakarta)
    // Silakan ganti dengan latitude dan longitude restoran asli Anda
    const double lat = -6.175392;
    const double lng = 106.827153;
    
    // URL ini akan otomatis membuka Google Maps mode "Direction" (Rute)
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

    try {
      // Disederhanakan agar tidak memicu error Lookup LaunchMode pada beberapa versi
      if (!await launchUrl(googleMapsUrl)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka Google Maps'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
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
            const SizedBox(height: 20),
            _buildSectionHeader('Categories', 'See All'),
            _buildCategories(),
            const SizedBox(height: 25),
            _buildSectionHeader('Popular Now', 'See All'),
            _buildPopularNowList(),
            const SizedBox(height: 25),
            _buildSectionHeader('Top Chefs', 'See all'),
            _buildTopChefsList(),
            const SizedBox(height: 25),
            _buildSectionHeader('Location & Navigation', 'Open Maps'), // Judul diubah
            _buildMapSection(), 
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- KOMPONEN HEADER ORANYE (MELENGKUNG BAWAH) ---
  Widget _buildOrangeHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20, // Padding status bar HP
        left: 20,
        right: 20,
        bottom: 30,
      ),
      decoration: BoxDecoration(
        color: _primaryOrange,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
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
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $_userName!',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Check Amazing Menus...',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                child: const Icon(Icons.notifications_none, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: _primaryOrange),
                      const SizedBox(width: 10),
                      // --- PERBAIKAN: MENGGANTI TEKS MENJADI TEXTFIELD AKTIF ---
                      Expanded(
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Looking for?', 
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (value) {
                            // Saat pengguna menekan enter/search di keyboard, navigasi ke MenuScreen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const MenuScreen()),
                            );
                          },
                        ),
                      ),
                      // --------------------------------------------------------
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.tune, color: _primaryOrange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- HEADER SEKSI (TITLE & SEE ALL) ---
  Widget _buildSectionHeader(String title, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(action, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _primaryOrange)),
        ],
      ),
    );
  }

  // --- KOMPONEN KATEGORI GAMBAR BULAT ---
  Widget _buildCategories() {
    List<Map<String, String>> categories = [
      {'title': 'Restaurant', 'img': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80'},
      {'title': 'Caffe', 'img': 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80'},
      {'title': 'Fine Dining', 'img': 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80'},
      {'title': 'Steak', 'img': 'https://images.unsplash.com/photo-1544025162-d76694265947?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80'},
    ];

    return Container(
      height: 90,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(categories[index]['img']!),
                      fit: BoxFit.cover,
                      colorFilter: const ColorFilter.mode(Colors.black38, BlendMode.darken),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      categories[index]['title']!,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- LIST "POPULAR NOW" (KARTU BESAR WIREFRAME) ---
  Widget _buildPopularNowList() {
    return SizedBox(
      height: 260,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, top: 16, bottom: 16),
        clipBehavior: Clip.none,
        children: [
          _buildPopularCard(
            title: 'Steak House',
            subtitle: 'Bundling',
            rating: '4.8',
            price: 'Rp 35.000',
            imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
          ),
          _buildPopularCard(
            title: 'Steak Special',
            subtitle: 'Bundling',
            rating: '4.9',
            price: 'Rp 40.000',
            imageUrl: 'https://images.unsplash.com/photo-1558030006-450675393462?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80',
          ),
        ],
      ),
    );
  }

  Widget _buildPopularCard({required String title, required String subtitle, required String rating, required String price, required String imageUrl}) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                child: Image.network(imageUrl, height: 140, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text('$rating (1k+ Review)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.favorite_border, color: Colors.grey, size: 18),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                    const Icon(Icons.bookmark_border, color: Color(0xFF86C19F)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.local_offer, size: 14, color: _primaryOrange),
                    const SizedBox(width: 4),
                    Text(
                      '$price  •  $subtitle',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
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

  // --- LIST "TOP CHEFS" ---
  Widget _buildTopChefsList() {
    List<Map<String, String>> chefs = [
      {'name': 'Esther T.', 'img': 'https://images.unsplash.com/photo-1583394838336-acd977736f90?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80'},
      {'name': 'Jenny M.', 'img': 'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80'},
      {'name': 'Jacob U.', 'img': 'https://images.unsplash.com/photo-1595273670150-bd0c3c392e46?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80'},
      {'name': 'Bessi K.', 'img': 'https://images.unsplash.com/photo-1607631568010-a87245c0daf8?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80'},
    ];

    return Container(
      height: 100,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: chefs.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(chefs[index]['img']!),
                ),
                const SizedBox(height: 8),
                Text(
                  chefs[index]['name']!,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- BAGIAN "NEARBY MAP" YANG SUDAH TERINTEGRASI NAVIGASI GOOGLE MAPS ---
  Widget _buildMapSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
      child: GestureDetector(
        onTap: _launchMaps, // Panggil fungsi buka peta saat kartu diklik
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Peta Statis Placeholder
              Image.network(
                'https://images.unsplash.com/photo-1524661135-423995f22d0b?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              // Overlay sedikit gelap agar teks lebih mudah dibaca
              Container(
                height: 180,
                color: Colors.black.withOpacity(0.1),
              ),
              // Tombol Card Navigasi
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                    ]
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Technoir Bistro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                          const SizedBox(height: 2),
                          Text('Jl. Jend. Sudirman No. 1, Jakarta', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _primaryOrange,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: _primaryOrange.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.directions, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text('Navigasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
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
              _buildNavItem(Icons.home_filled, 'Home', 0),
              _buildNavItem(Icons.search, 'Discover', 1),
              _buildNavItem(Icons.shopping_cart_outlined, 'Cart', 2),
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
          // Tetap di Home
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MenuScreen()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CartScreen()),
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
            color: isSelected ? _primaryOrange : Colors.grey[500], 
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? _primaryOrange : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}