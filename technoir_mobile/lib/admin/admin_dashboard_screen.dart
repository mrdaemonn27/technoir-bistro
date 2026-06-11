import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login_screen.dart';
import 'admin_menu_screen.dart';
import 'admin_reservation_screen.dart';
import 'admin_report_screen.dart';

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
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari sesi admin?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.red),
            ),
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

  // Scaling system berdasarkan referensi lebar 832
  double _scale(BuildContext context) {
    return MediaQuery.of(context).size.width / 832;
  }

  @override
  Widget build(BuildContext context) {
    final s = _scale(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFFF8622),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER CUSTOM ---
              _buildHeader(context),

              SizedBox(height: 60 * s),

              // --- TITLE KELOLA RESTORAN ---
              Padding(
                padding: EdgeInsets.only(left: 54 * s),
                child: Text(
                  'Kelola Restoran',
                  style: TextStyle(
                    fontSize: 44 * s,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF373347),
                    letterSpacing: -0.5 * s,
                  ),
                ),
              ),

              SizedBox(height: 34 * s),

              // --- KARTU 1: RESERVASI ---
              _buildFeatureCard(
                context: context,
                title: 'Reservasi',
                subtitle: 'Kelola jadwal kunjungan pelanggan',
                type: _AdminCardType.reservasi,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminReservationScreen(),
                  ),
                ),
              ),

              SizedBox(height: 50 * s),

              // --- KARTU 2: KELOLA MENU ---
              _buildFeatureCard(
                context: context,
                title: 'Kelola menu',
                subtitle: 'Atur ketersediaan menu dan harga menu',
                type: _AdminCardType.menu,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminMenuScreen(),
                  ),
                ),
              ),

              SizedBox(height: 50 * s),

              // --- KARTU 3: LAPORAN KEUANGAN ---
              _buildFeatureCard(
                context: context,
                title: 'laporan keuangan',
                subtitle: 'Lihat ringkasan performa penjualan',
                type: _AdminCardType.laporan,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminReportScreen(),
                  ),
                ),
              ),

              SizedBox(height: 80 * s),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final s = _scale(context);

    return Container(
      height: 280 * s, // Sedikit dilebarkan agar seimbang
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFF8622),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(72 * s),
          bottomRight: Radius.circular(72 * s),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 52 * s,
            right: 40 * s, // Disesuaikan agar icon logout presisi
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // KUNCI: Sejajar rata tengah secara vertikal
            children: [
              // FOTO PROFIL
              Container(
                width: 140 * s,
                height: 140 * s,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/admin_profile.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: 76 * s,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
              ),

              SizedBox(width: 36 * s),

              // TEKS NAMA & ROLE
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // KUNCI: Teks rata tengah vertikal
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $_adminName!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 34 * s,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3 * s,
                      ),
                    ),
                    SizedBox(height: 8 * s),
                    Text(
                      'Admin',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 25 * s,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // TOMBOL LOGOUT (ICON KELUAR)
              IconButton(
                icon: Icon(Icons.exit_to_app_rounded, color: Colors.white, size: 55 * s),
                onPressed: _logout,
                tooltip: 'Logout',
                padding: EdgeInsets.zero, // Menghilangkan padding default tombol agar rata
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required _AdminCardType type,
    required VoidCallback onTap,
  }) {
    final s = _scale(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 184 * s,
        margin: EdgeInsets.symmetric(horizontal: 35 * s),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40 * s),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20 * s,
              offset: Offset(0, 10 * s),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 38 * s),

            // ICON KUSTOM - DIBUNGKUS SIZEDBOX AGAR SEJAJAR RAPI
            SizedBox(
              width: 115 * s, // Ruang lebar seragam untuk semua ikon
              child: Center(
                child: _buildCardIcon(context, type),
              ),
            ),

            SizedBox(width: 32 * s),

            // TEKS RATA KANAN (KETebalan DIPERBAIKI)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 35 * s),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end, // Teks Rata Kanan
                  children: [
                    // Judul
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 50 * s, // Disesuaikan
                        height: 1.1,
                        fontWeight: FontWeight.w700, // Diubah agar tidak terlalu tebal
                        color: Colors.black,
                        letterSpacing: -1.0 * s,
                      ),
                    ),

                    SizedBox(height: 10 * s),

                    // Subjudul
                    Text(
                      subtitle,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24 * s,
                        height: 1.2,
                        fontWeight: FontWeight.w500, // Lebih rapih dan tipis
                        color: Colors.black87,
                        letterSpacing: -0.2 * s,
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

  Widget _buildCardIcon(BuildContext context, _AdminCardType type) {
    final s = _scale(context);

    switch (type) {
      case _AdminCardType.reservasi:
        return Container(
          width: 75 * s, 
          height: 115 * s,
          decoration: BoxDecoration(
            color: const Color(0xFFFF7600),
            borderRadius: BorderRadius.circular(16 * s),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center, // Memastikan simetris ke tengah
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 14 * s),
                width: 34 * s,
                height: 6 * s,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20 * s),
                ),
              ),
            ],
          ),
        );

      case _AdminCardType.menu:
        return Container(
          width: 115 * s,
          height: 115 * s,
          decoration: const BoxDecoration(
            color: Color(0xFFFF3540),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.restaurant_rounded,
            color: Colors.white,
            size: 60 * s,
          ),
        );

      case _AdminCardType.laporan:
        return Container(
          width: 115 * s,
          height: 115 * s,
          decoration: const BoxDecoration(
            color: Color(0xFF34C95C),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.insert_chart_rounded,
            color: Colors.white,
            size: 60 * s,
          ),
        );
    }
  }
}

enum _AdminCardType {
  reservasi,
  menu,
  laporan,
}