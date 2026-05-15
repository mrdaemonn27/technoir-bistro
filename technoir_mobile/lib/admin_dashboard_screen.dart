import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _adminName = 'Admin';

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _adminName = prefs.getString('username') ?? 'Admin';
    });
  }

  Future<void> _logout() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout Admin', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari panel admin?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Hapus sesi

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // Warna background admin sedikit berbeda
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B), // Warna gelap elegan untuk Admin
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            Text('Welcome, $_adminName', style: const TextStyle(color: Colors.cyanAccent, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Hari Ini',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            // --- WIDGET RINGKASAN ---
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Pesanan Baru', '12', Icons.shopping_bag, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Reservasi', '5', Icons.book_online, Colors.orange)),
              ],
            ),
            const SizedBox(height: 30),

            const Text(
              'Menu Kelola (CRUD)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            
            // --- WIDGET MENU ADMIN ---
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildAdminFeatureCard(
                  title: 'Kelola Menu',
                  subtitle: 'Tambah, Edit, Hapus Makanan',
                  icon: Icons.restaurant_menu,
                  color: Colors.indigo,
                  onTap: () {
                    // TODO: Arahkan ke halaman AdminMenuScreen
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Halaman Kelola Menu (Segera Hadir)')));
                  },
                ),
                _buildAdminFeatureCard(
                  title: 'Status Meja',
                  subtitle: 'Pantau ketersediaan meja',
                  icon: Icons.table_restaurant,
                  color: Colors.teal,
                  onTap: () {
                    // TODO: Arahkan ke halaman AdminTableScreen
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Halaman Status Meja (Segera Hadir)')));
                  },
                ),
                _buildAdminFeatureCard(
                  title: 'Laporan',
                  subtitle: 'Rekap Harian & Bulanan',
                  icon: Icons.analytics,
                  color: Colors.purple,
                  onTap: () {
                    // TODO: Arahkan ke halaman AdminReportScreen
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Halaman Laporan (Segera Hadir)')));
                  },
                ),
                _buildAdminFeatureCard(
                  title: 'Pengguna',
                  subtitle: 'Daftar pelanggan aktif',
                  icon: Icons.people,
                  color: Colors.blueGrey,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Halaman Pengguna (Segera Hadir)')));
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildAdminFeatureCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500]), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}