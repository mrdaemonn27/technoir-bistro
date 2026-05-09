import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _userName = 'User'; // Variabel untuk menyimpan nama user secara dinamis

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Ambil nama user saat halaman pertama kali dibuka
  }

  // Fungsi untuk mengambil nama user dari SharedPreferences (Memori HP)
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Mengambil data dengan kunci 'username', jika tidak ada maka tampilkan 'Guest'
      _userName = prefs.getString('username') ?? 'Guest';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildSearchBar(),
                const SizedBox(height: 30),
                _buildCategories(),
                const SizedBox(height: 35),
                _buildSectionTitle('Popular Now'),
                const SizedBox(height: 16),
                _buildPopularNowList(),
                const SizedBox(height: 35),
                _buildSectionTitle('Perfect for dinner'),
                const SizedBox(height: 16),
                _buildPerfectDinnerList(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- KOMPONEN HEADER ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $_userName Where\nShall we Order?', // Tampilkan nama user di sini
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.black87),
                  const SizedBox(width: 4),
                  Text(
                    'Jakarta, Central Java',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const CircleAvatar(
          radius: 26,
          backgroundImage: NetworkImage(
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
          ),
        ),
      ],
    );
  }

  // --- KOMPONEN PENCARIAN ---
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.search, size: 28, color: Colors.black87),
                const SizedBox(width: 12),
                Text(
                  'Looking for?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.transparent),
          ),
          child: const Icon(Icons.camera_alt_outlined, size: 32, color: Colors.black87),
        ),
      ],
    );
  }

  // --- KOMPONEN KATEGORI ---
  Widget _buildCategories() {
    List<Map<String, dynamic>> categories = [
      {'title': 'Restaurant', 'icon': Icons.restaurant, 'isSelected': true},
      {'title': 'Caffe', 'icon': Icons.local_cafe_outlined, 'isSelected': false},
      {'title': 'Fine Dining', 'icon': Icons.room_service_outlined, 'isSelected': false},
      {'title': 'Steak', 'icon': Icons.set_meal_outlined, 'isSelected': false},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories.map((cat) {
        bool isSelected = cat['isSelected'];
        return Column(
          children: [
            Container(
              height: 75,
              width: 75,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF282A45) : const Color(0xFFF0F0F5),
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]
                    : [],
              ),
              child: Icon(
                cat['icon'],
                size: 32,
                color: isSelected ? Colors.white : const Color(0xFF282A45),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              cat['title'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.black87 : Colors.grey[700],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // --- JUDUL SEKSI ---
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  // --- LIST "POPULAR NOW" ---
  Widget _buildPopularNowList() {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildPopularCard(
            title: 'Steak House',
            subtitle: 'Bundling',
            rating: '4,8',
            oldPrice: 'Rp 40.000',
            newPrice: 'Rp 35.000',
            imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
          ),
          const SizedBox(width: 16),
          _buildPopularCard(
            title: 'Steak Special',
            subtitle: 'Bundling',
            rating: '4,9',
            oldPrice: 'Rp 45.000',
            newPrice: 'Rp 40.000',
            imageUrl: 'https://images.unsplash.com/photo-1558030006-450675393462?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80',
          ),
        ],
      ),
    );
  }

  Widget _buildPopularCard({
    required String title,
    required String subtitle,
    required String rating,
    required String oldPrice,
    required String newPrice,
    required String imageUrl,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(rating, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      oldPrice,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                        decoration: TextDecoration.lineThrough,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      newPrice,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const Spacer(),
                    const Icon(Icons.local_fire_department, size: 16, color: Colors.deepOrangeAccent),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- LIST "PERFECT FOR DINNER" ---
  Widget _buildPerfectDinnerList() {
    return SizedBox(
      height: 220,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildDinnerCard(
            rating: '4,7',
            imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80',
          ),
          const SizedBox(width: 16),
          _buildDinnerCard(
            rating: '4,7',
            imageUrl: 'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?ixlib=rb-4.0.3&auto=format&fit=crop&w=500&q=80',
          ),
        ],
      ),
    );
  }

  Widget _buildDinnerCard({required String rating, required String imageUrl}) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Image.network(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
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
              _buildNavItem(Icons.favorite_border, 'Shopping list', 1),
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
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
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