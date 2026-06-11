import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'menu_screen.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final int _selectedIndex = 3; // Index 3 untuk Profile
  final Color _primaryOrange = const Color(0xFFFE8C00);

  String _userName = 'Loading...';
  
  // URL default avatar
  String _avatarUrl = 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80';
  
  // Dummy data untuk statistik (nanti bisa diambil dari API Laravel)
  final String _reservationCount = "23";
  final String _dishOrderedCount = "39";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('username') ?? 'Guest User';
      
      // Ambil avatar dari SharedPreferences jika ada
      String? savedAvatar = prefs.getString('avatar');
      if (savedAvatar != null && savedAvatar.isNotEmpty) {
        String baseUrl = savedAvatar.startsWith('http') 
            ? savedAvatar 
            : 'http://10.0.2.2:8000/storage/$savedAvatar';
            
        // --- BYPASS CACHE FLUTTER ---
        // Tambahkan timestamp acak di akhir URL agar Flutter dipaksa mendownload gambar yang baru
        _avatarUrl = '$baseUrl?v=${DateTime.now().millisecondsSinceEpoch}';
      }
    });
  }

  Future<void> _logout() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CartScreen()));
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MenuScreen()));
    } else if (index == 3) {
      // Tetap di sini
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          _buildOrangeHeader(),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  
                  // --- FOTO PROFIL (Telah menggunakan _avatarUrl yang di-bypass cache nya) ---
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: NetworkImage(_avatarUrl),
                  ),
                  const SizedBox(height: 16),
                  
                  // --- NAMA ---
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- STATISTIK ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(_reservationCount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text('Reservation', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                      Container(
                        height: 30,
                        width: 1,
                        color: Colors.grey.shade300,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      Column(
                        children: [
                          Text(_dishOrderedCount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text('Dish Ordered', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- TOMBOL EDIT PROFILE ---
                  OutlinedButton.icon(
                    onPressed: () async {
                      // Tunggu hasil dari layar edit profile
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                      );
                      
                      // Jika layar edit membalikkan nilai true (tersimpan), load ulang datanya
                      if (result == true) {
                        _loadUserData();
                      }
                    },
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF5A67D8), size: 20),
                    label: const Text('Edit Profile', style: TextStyle(color: Color(0xFF5A67D8), fontSize: 15)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF5A67D8), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- KARTU MENU AKSI ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildActionCard(
                          icon: Icons.help_outline, 
                          title: 'Helps & FAQs', 
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Halaman Bantuan (Segera Hadir)')));
                          }
                        ),
                        _buildActionCard(
                          icon: Icons.settings_outlined, 
                          title: 'Settings', 
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                          }
                        ),
                        _buildActionCard(
                          icon: Icons.logout, 
                          title: 'Log Out', 
                          isDestructive: true,
                          onTap: _logout
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- HEADER ORANYE ---
  Widget _buildOrangeHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 20, right: 20, bottom: 25),
      decoration: BoxDecoration(
        color: _primaryOrange,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Logo TB
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('T', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF5D1D20))),
              Icon(Icons.wine_bar, size: 28, color: Color(0xFF5D1D20)),
              Text('B', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF5D1D20))),
            ],
          ),
          // Bell Icon
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none, color: Colors.white, size: 22),
            ),
          )
        ],
      ),
    );
  }

  // --- KOMPONEN KARTU AKSI ---
  Widget _buildActionCard({required IconData icon, required String title, required VoidCallback onTap, bool isDestructive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            Icon(icon, color: isDestructive ? Colors.red : Colors.black87, size: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red : Colors.black87,
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